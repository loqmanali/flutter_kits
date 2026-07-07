## 1.0.0

* Initial release as a standalone, project-agnostic package extracted from
  `lib/core/deep_linking`.
* `DeepLinkKitRuntime` replaces the hardcoded `lekbox` scheme + `lekbox.com`
  hosts — both are now configurable lists.
* `RouteParser.isValidLekboxLink` renamed to `RouteParser.isAppLink`.
* New `LinkType.custom` case + `LinkData.rawType` field — unknown but
  well-formed link types are surfaced rather than collapsed into `unknown`,
  so apps can route on `rawType` without having to extend the enum.
* `DeepLinkHandler` and `DeepLinkHelper` from the original module are
  intentionally **not** ported — they were commented out and tied directly
  to the host app's `AppNavigations` and `GoRouter` instance. Implement the
  equivalent in your app's navigation layer by listening to
  `DeepLinkService.linkStream`.
