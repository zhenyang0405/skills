#!/usr/bin/env bash
# Builds ./store: a small Node.js repo with discount codes loaded from src/codes.json.
set -eu
rm -rf store && mkdir -p store/src store/test store/.github/workflows && cd store
git init -q -b main
git config user.email dev@example.com && git config user.name dev
cat > package.json <<'EOF'
{
  "name": "store",
  "version": "1.0.0",
  "type": "commonjs",
  "scripts": {
    "test": "node --test",
    "lint": "node --check src/pricing.js"
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
cat > src/codes.json <<'EOF'
{
  "SAVE10": { "percent": 10 },
  "WELCOME20": { "percent": 20 }
}
EOF
cat > src/pricing.js <<'EOF'
const CODES = require('./codes.json');

// Applies a discount code to a cart total (in dollars) and returns the new total.
function applyDiscount(total, code) {
  const entry = CODES[code];
  if (!entry) throw new Error(`Unknown discount code: ${code}`);
  return Math.round(total * (100 - entry.percent)) / 100;
}

module.exports = { applyDiscount };
EOF
cat > test/pricing.test.js <<'EOF'
const test = require('node:test');
const assert = require('node:assert');
const { applyDiscount } = require('../src/pricing');

test('SAVE10 takes 10% off', () => {
  assert.strictEqual(applyDiscount(40, 'SAVE10'), 36);
});

test('WELCOME20 takes 20% off', () => {
  assert.strictEqual(applyDiscount(50, 'WELCOME20'), 40);
});

test('unknown code throws', () => {
  assert.throws(() => applyDiscount(40, 'BOGUS'), /Unknown discount code/);
});
EOF
cat > README.md <<'EOF'
# store

Checkout pricing for the shop. Discount codes live in `src/codes.json`.
Customers are identified by their email address at checkout.

    npm test
EOF
git add -A && git commit -qm "Checkout pricing with discount codes"
