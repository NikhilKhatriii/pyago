# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| 0.2.x (current) | ✅ |
| 0.1.x | ❌ (no longer maintained) |

---

## Reporting a Vulnerability

**Please do not report security vulnerabilities via GitHub Issues.**

If you discover a security vulnerability in Pyago, please disclose it
responsibly by emailing **security@pyago.app** with the subject line:

```
[SECURITY] <brief description>
```

Include as much of the following as possible:

- Type of vulnerability (e.g. injection, auth bypass, data exposure)
- Full path of the affected source file(s)
- Any special configuration required to reproduce
- Step-by-step reproduction instructions
- Proof-of-concept or exploit code (if available)
- Impact and attack scenario

We will acknowledge your report within **48 hours** and aim to provide a
fix or mitigation within **14 days** for critical issues.

We ask that you:
- Give us reasonable time to respond before any public disclosure
- Make a good-faith effort to avoid privacy violations and service disruption
- Not access or modify data that is not your own

---

## Security Architecture Notes

The following design decisions are intentional and documented for auditors:

| Area | Decision |
|---|---|
| **Token storage** | Auth tokens are stored exclusively in `flutter_secure_storage` (Android Keystore / iOS Keychain). They are **never** written to `SharedPreferences` or the Hive box. |
| **App lock** | Optional biometric / PIN gate (`AppLockGate`) activates on cold start and on resume-from-background when enabled in settings. |
| **Network** | All production traffic goes over HTTPS. The `AuthInterceptor` handles token refresh on 401 and force-logs-out on unrecoverable session expiry (`SessionExpiredException`). |
| **Offline data** | Hive boxes store feed cache, drafts, and bookmarks. **No credentials or tokens are stored in Hive.** |
| **Mock flavor** | The `dev` flavor (`PYAGO_FLAVOR=dev`) runs entirely against in-memory fake data. No real user data is ever sent or received in the dev flavor. |

---

## Acknowledgements

We are grateful to the security researchers who help keep Pyago and its users
safe. Significant contributors will be listed here with their permission.
