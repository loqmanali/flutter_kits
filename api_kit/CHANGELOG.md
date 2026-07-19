## 1.0.1

### Added

* `ApiKitRuntime.resetForTesting()` — restores every static field to its
  declared default (`@visibleForTesting`). `use()` only ever overwrites
  non-null fields and there was previously no way to clean up between
  tests, so any test touching the runtime contaminated every later test in
  the same process. Does not change `use()`'s merge semantics.
* First `test/` suite for the package (previously had none) covering
  `ApiKitRuntime.use()` + `resetForTesting()`.

## 1.0.0

* Initial release as a standalone, project-agnostic package extracted from
  `lib/core/apis`.
* Four pluggable adapters (`AuthTokenStorageAdapter`,
  `TokenRefreshCallback`, `LogoutCallback`, `LanguageCodeProvider`) keep the
  kit free of any specific storage backend, auth-state manager, or DI
  framework.
* `ApiKitRuntime` centralises base URL, timeout, headers, skip-lists and
  callbacks — configure once at startup.
* `ApiTokenType.odooToken` is generalised to `ApiTokenType.staticToken`;
  the Odoo-specific `OdooTokenInterceptor` is replaced by a generic
  `StaticTokenInterceptor` driven by `ApiKitRuntime.staticBearerToken`.
* `ApiClient.post`'s `odooToken:` parameter is renamed `bearerTokenOverride:`.
* `ApiHelper` no longer depends on Riverpod — pass an `ApiClientResolver`
  function instead.
* `ApiConfig` (Burger Republic-specific endpoint constants) deliberately
  **stays in the host app** — every project has its own endpoints.
