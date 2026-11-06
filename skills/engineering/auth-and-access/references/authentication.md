# Authentication details

Read this when you write or change code that handles passwords, sessions, tokens, password resets,
MFA or login rate limits. If a managed provider or the framework's built-in auth already does it, use
that and check its settings against this list instead of reimplementing it.

Primary sources: NIST SP 800-63B-4 (Digital Identity Guidelines, final July 2025); OWASP ASVS 5.0
(V6 Authentication, V7 Session Management, V8 Authorization); OWASP Cheat Sheet Series
(Authentication, Password Storage, Session Management, Forgot Password, Multifactor Authentication).
Check the current versions when in doubt; numbers below are minimums.

## Passwords (NIST SP 800-63B-4)

- **Length over complexity.** Require at least 15 characters when the password is the only factor,
  and at least 8 when it's used with MFA. Allow at least 64.
- **No composition rules** (no "must contain a symbol"). They push people to predictable patterns.
- **Check new passwords against a blocklist** of breached and common passwords (e.g. the
  Have I Been Pwned range API) and reject matches.
- **No forced periodic changes.** Force a change only on evidence of compromise.
- Allow paste and password managers. Accept all printable characters and spaces; normalize Unicode.
- No password hints or knowledge-based security questions.

## Storing passwords (OWASP Password Storage Cheat Sheet)

- **Argon2id**, minimum m = 19 MiB, t = 2, p = 1 (or an equivalent trade-off from the cheat sheet).
- Otherwise **bcrypt** with cost 10 or more (12 is common). bcrypt only uses the first 72 bytes, so cap
  or pre-hash long inputs safely.
- **PBKDF2-HMAC-SHA256** with 600,000 or more iterations only where FIPS compliance requires it.
- Never plain SHA-256, MD5, or any fast hash. Never reversible encryption. Use the library's
  constant-time verify function.

## Sessions (ASVS V7, OWASP Session Management)

- Store the session ID in a cookie with `HttpOnly`, `Secure` and `SameSite=Lax` (or `Strict`). Don't
  put session tokens in `localStorage`, where any XSS can read them.
- **Issue a new session ID at login** and on privilege change (prevents session fixation).
- Expire sessions: an idle timeout and an absolute lifetime suited to the risk (shorter for admin).
- **Invalidate on the server** at logout, password change and account deletion, including other
  sessions of the same user where appropriate.
- State-changing requests authenticated by cookie need CSRF protection (SameSite plus a CSRF token or
  origin checks for older browsers and cross-site flows).

## Tokens (JWT and API keys)

- **Verify, don't decode:** check the signature with a fixed, expected algorithm (reject `alg: none`
  and algorithm switching), and check `exp`, `nbf`, `iss` and `aud`.
- Keep access tokens short-lived (minutes); use refresh tokens that rotate and can be revoked.
- JWT payloads are readable by anyone. Put no secrets or personal data beyond an ID in them.
- API keys: generate with a secure random source, show once, store only a hash, allow revocation,
  scope to the minimum permissions.
- Signing secrets come from the environment or a secrets manager. **A missing secret stops the app**;
  never fall back to a default value.

## Login, sign-up and reset flows

- **No enumeration:** login failures and "forgot password" give the same response and timing whether
  or not the account exists.
- **Rate limit and slow down** login, sign-up, reset and MFA endpoints per account and per IP, with
  backoff rather than permanent lockout (which lets attackers lock out real users).
- **Reset tokens:** random, single-use, short expiry (e.g. 15–60 minutes), stored hashed, invalidated
  after use and when the password changes. Don't log users in automatically on reset if MFA is enabled.
- Re-authenticate (ask for the password or MFA again) before sensitive changes: email, password, MFA
  settings, payout details, account deletion.
- Email verification before an address can be used to reset a password or receive sensitive data.

## MFA and passkeys

- Offer MFA; require it for admin and other high-risk roles.
- Prefer **phishing-resistant** methods: passkeys / WebAuthn (FIDO2) and security keys. TOTP apps are
  acceptable. SMS codes are the weakest option and shouldn't be the only one for high-risk accounts.
- Provide recovery codes, and treat account recovery as an attack path with the same rigor as login.

## Logging

- Log authentication events (logins, failures, resets, MFA changes, role changes) with user ID, time
  and source, without passwords, tokens or full session IDs.
