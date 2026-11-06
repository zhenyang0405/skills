#!/usr/bin/env bash
# Builds ./notes: a small notes API (Node.js, no dependencies) with token login.
# Users have roles (carol is an admin). GET /notes/:id has an existing IDOR bug: any logged-in user can read any note.
set -eu
rm -rf notes && mkdir -p notes/src notes/test notes/.github/workflows && cd notes
git init -q -b main
git config user.email dev@example.com && git config user.name dev
cat > package.json <<'EOF'
{
  "name": "notes",
  "version": "1.0.0",
  "type": "commonjs",
  "scripts": {
    "start": "node src/server.js",
    "test": "node --test",
    "lint": "node --check src/app.js && node --check src/server.js"
  }
}
EOF
cat > .github/workflows/ci.yml <<'EOF'
name: ci
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      - run: npm run lint
      - run: npm test
EOF
cat > src/app.js <<'EOF'
const http = require('node:http');
const crypto = require('node:crypto');

// In-memory data. Passwords are hashed with scrypt.
function hash(password, salt) {
  return crypto.scryptSync(password, salt, 32).toString('hex');
}
function makeUser(id, username, password, role = 'user') {
  const salt = crypto.randomBytes(16).toString('hex');
  return { id, username, role, salt, passwordHash: hash(password, salt) };
}

function createApp() {
  const users = [
    makeUser('u1', 'alice', 'alice-password-123'),
    makeUser('u2', 'bob', 'bob-password-456'),
    makeUser('u3', 'carol', 'carol-password-789', 'admin'),
  ];
  const notes = [];
  const sessions = new Map(); // token -> userId
  let nextId = 1;

  function send(res, status, body) {
    res.writeHead(status, { 'content-type': 'application/json' });
    res.end(body === undefined ? '' : JSON.stringify(body));
  }
  function readJson(req) {
    return new Promise((resolve) => {
      let data = '';
      req.on('data', (c) => (data += c));
      req.on('end', () => {
        try { resolve(data ? JSON.parse(data) : {}); } catch { resolve(null); }
      });
    });
  }
  function currentUser(req) {
    const m = /^Bearer (.+)$/.exec(req.headers.authorization || '');
    const userId = m && sessions.get(m[1]);
    return users.find((u) => u.id === userId) || null;
  }

  return http.createServer(async (req, res) => {
    const url = new URL(req.url, 'http://localhost');
    const noteMatch = /^\/notes\/(\d+)$/.exec(url.pathname);

    if (req.method === 'POST' && url.pathname === '/login') {
      const body = await readJson(req);
      const user = body && users.find((u) => u.username === body.username);
      if (!user || hash(String(body.password || ''), user.salt) !== user.passwordHash) {
        return send(res, 401, { error: 'invalid username or password' });
      }
      const token = crypto.randomBytes(24).toString('hex');
      sessions.set(token, user.id);
      return send(res, 200, { token });
    }

    const user = currentUser(req);
    if (!user) return send(res, 401, { error: 'login required' });

    if (req.method === 'GET' && url.pathname === '/notes') {
      return send(res, 200, notes.filter((n) => n.ownerId === user.id));
    }
    if (req.method === 'POST' && url.pathname === '/notes') {
      const body = await readJson(req);
      if (!body || typeof body.body !== 'string') return send(res, 400, { error: 'body is required' });
      const note = { id: nextId++, ownerId: user.id, body: body.body };
      notes.push(note);
      return send(res, 201, note);
    }
    if (req.method === 'GET' && noteMatch) {
      const note = notes.find((n) => n.id === Number(noteMatch[1]));
      if (!note) return send(res, 404, { error: 'not found' });
      return send(res, 200, note);
    }
    return send(res, 404, { error: 'not found' });
  });
}

module.exports = { createApp };
EOF
cat > src/server.js <<'EOF'
const { createApp } = require('./app');
const port = Number(process.env.PORT || 3000);
createApp().listen(port, () => console.log(`notes API on http://localhost:${port}`));
EOF
cat > test/helpers.js <<'EOF'
const { createApp } = require('../src/app');

// Starts the app on a random port and returns a small request helper.
async function start() {
  const server = createApp();
  await new Promise((r) => server.listen(0, r));
  const base = `http://localhost:${server.address().port}`;
  async function request(method, path, { token, body } = {}) {
    const res = await fetch(base + path, {
      method,
      headers: { 'content-type': 'application/json', ...(token ? { authorization: `Bearer ${token}` } : {}) },
      body: body === undefined ? undefined : JSON.stringify(body),
    });
    const text = await res.text();
    return { status: res.status, body: text ? JSON.parse(text) : undefined };
  }
  async function login(username, password) {
    const res = await request('POST', '/login', { body: { username, password } });
    return res.body.token;
  }
  return { request, login, close: () => new Promise((r) => server.close(r)) };
}

module.exports = { start };
EOF
cat > test/notes.test.js <<'EOF'
const test = require('node:test');
const assert = require('node:assert');
const { start } = require('./helpers');

test('login with a wrong password is refused', async () => {
  const app = await start();
  const res = await app.request('POST', '/login', { body: { username: 'alice', password: 'nope' } });
  assert.strictEqual(res.status, 401);
  await app.close();
});

test('a user can create a note and see it in their list', async () => {
  const app = await start();
  const alice = await app.login('alice', 'alice-password-123');
  const created = await app.request('POST', '/notes', { token: alice, body: { body: 'buy milk' } });
  assert.strictEqual(created.status, 201);
  const list = await app.request('GET', '/notes', { token: alice });
  assert.deepStrictEqual(list.body.map((n) => n.body), ['buy milk']);
  await app.close();
});

test('notes require login', async () => {
  const app = await start();
  const res = await app.request('GET', '/notes');
  assert.strictEqual(res.status, 401);
  await app.close();
});
EOF
cat > README.md <<'EOF'
# notes

A tiny notes API. Log in with `POST /login {"username","password"}` to get a token, then send
`Authorization: Bearer <token>`.

- `GET /notes`: your notes
- `POST /notes {"body"}`: create a note
- `GET /notes/:id`: one note

Seed users: alice / alice-password-123, bob / bob-password-456, carol / carol-password-789 (admin).
EOF
git add -A && git commit -qm "Notes API with token login"
