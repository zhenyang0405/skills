#!/usr/bin/env bash
# Builds ./orders-api: a Node.js API (no dependencies) with HMAC-signed tokens.
# Planted problems: readToken() decodes the token without checking its signature or expiry,
# and the signing secret falls back to a hardcoded default.
set -eu
rm -rf orders-api && mkdir -p orders-api/src orders-api/test orders-api/.github/workflows && cd orders-api
git init -q -b main
git config user.email dev@example.com && git config user.name dev
cat > package.json <<'EOF'
{
  "name": "orders-api",
  "version": "1.0.0",
  "type": "commonjs",
  "scripts": {
    "start": "node src/server.js",
    "test": "node --test",
    "lint": "node --check src/app.js && node --check src/auth.js"
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
        env:
          TOKEN_SECRET: test-secret-for-ci
EOF
cat > src/auth.js <<'EOF'
const crypto = require('node:crypto');

const SECRET = process.env.TOKEN_SECRET || 'dev-secret';

const b64 = (obj) => Buffer.from(JSON.stringify(obj)).toString('base64url');

// Creates a signed token: header.payload.signature (HMAC-SHA256).
function signToken(claims) {
  const header = b64({ alg: 'HS256', typ: 'JWT' });
  const payload = b64({ exp: Math.floor(Date.now() / 1000) + 3600, ...claims });
  const signature = crypto.createHmac('sha256', SECRET).update(`${header}.${payload}`).digest('base64url');
  return `${header}.${payload}.${signature}`;
}

// Returns the token's claims.
function readToken(token) {
  try {
    const [, payload] = token.split('.');
    return JSON.parse(Buffer.from(payload, 'base64url').toString());
  } catch {
    return null;
  }
}

module.exports = { signToken, readToken };
EOF
cat > src/app.js <<'EOF'
const http = require('node:http');
const { signToken, readToken } = require('./auth');

const USERS = [
  { id: 'u1', email: 'alice@example.com', password: 'alice-password-123' },
  { id: 'u2', email: 'bob@example.com', password: 'bob-password-456' },
];
const PRODUCTS = [
  { id: 'p1', name: 'Mug', price: 12 },
  { id: 'p2', name: 'Poster', price: 25 },
];
const ORDERS = [
  { id: 'o1', userId: 'u1', items: ['p1'], total: 12 },
  { id: 'o2', userId: 'u1', items: ['p2'], total: 25 },
  { id: 'o3', userId: 'u2', items: ['p1', 'p2'], total: 37 },
];

function send(res, status, body) {
  res.writeHead(status, { 'content-type': 'application/json' });
  res.end(JSON.stringify(body));
}
function readJson(req) {
  return new Promise((resolve) => {
    let data = '';
    req.on('data', (c) => (data += c));
    req.on('end', () => { try { resolve(data ? JSON.parse(data) : {}); } catch { resolve(null); } });
  });
}
function currentUser(req) {
  const m = /^Bearer (.+)$/.exec(req.headers.authorization || '');
  const claims = m && readToken(m[1]);
  return claims ? USERS.find((u) => u.id === claims.sub) || null : null;
}

function createApp() {
  return http.createServer(async (req, res) => {
    const url = new URL(req.url, 'http://localhost');
    if (req.method === 'POST' && url.pathname === '/login') {
      const body = await readJson(req);
      const user = body && USERS.find((u) => u.email === body.email && u.password === body.password);
      if (!user) return send(res, 401, { error: 'invalid email or password' });
      return send(res, 200, { token: signToken({ sub: user.id }) });
    }
    if (req.method === 'GET' && url.pathname === '/products') {
      return send(res, 200, PRODUCTS);
    }
    return send(res, 404, { error: 'not found' });
  });
}

module.exports = { createApp, ORDERS };
EOF
cat > src/server.js <<'EOF'
const { createApp } = require('./app');
const port = Number(process.env.PORT || 3000);
createApp().listen(port, () => console.log(`orders API on http://localhost:${port}`));
EOF
cat > test/app.test.js <<'EOF'
const test = require('node:test');
const assert = require('node:assert');
const { createApp } = require('../src/app');

async function start() {
  const server = createApp();
  await new Promise((r) => server.listen(0, r));
  const base = `http://localhost:${server.address().port}`;
  const request = async (method, path, { token, body } = {}) => {
    const res = await fetch(base + path, {
      method,
      headers: { 'content-type': 'application/json', ...(token ? { authorization: `Bearer ${token}` } : {}) },
      body: body === undefined ? undefined : JSON.stringify(body),
    });
    return { status: res.status, body: await res.json() };
  };
  return { request, close: () => new Promise((r) => server.close(r)) };
}

test('products are public', async (t) => {
  const app = await start();
  t.after(app.close);
  const res = await app.request('GET', '/products');
  assert.strictEqual(res.status, 200);
  assert.strictEqual(res.body.length, 2);
});

test('login returns a token', async (t) => {
  const app = await start();
  t.after(app.close);
  const res = await app.request('POST', '/login', { body: { email: 'alice@example.com', password: 'alice-password-123' } });
  assert.strictEqual(res.status, 200);
  assert.ok(res.body.token);
});
EOF
cat > README.md <<'EOF'
# orders-api

`POST /login {"email","password"}` returns a token; send it as `Authorization: Bearer <token>`.
`GET /products` is public. Set `TOKEN_SECRET` in production.
EOF
git add -A && git commit -qm "Orders API with token login"
