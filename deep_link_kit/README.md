# deep_link_kit

Project-agnostic deep-link toolkit for Flutter.

`deep_link_kit` listens for incoming deep links (both hot-start and
cold-start), filters out links that don't belong to your app, parses the
rest into structured `LinkData`, and emits them on a stream. It deliberately
**doesn't** make routing decisions — your router stays in your app.

## What you get

- **`DeepLinkService`** — wraps [`app_links`](https://pub.dev/packages/app_links)
  to capture both runtime and launch-time links and exposes them as a
  `Stream<LinkData>`.
- **`RouteParser`** — converts a raw URL string into [`LinkData`], handling
  both custom schemes (`myapp://product/42`) and universal links
  (`https://example.com/product/42`).
- **`LinkData`** — typed result with `LinkType`, raw type string, optional
  id, and query parameters.
- **`DeepLinkKitRuntime`** — single config surface: which custom schemes
  and universal-link hosts belong to your app.

## What you bring

- The scheme(s) and host(s) that identify your app (configured once).
- The navigation logic — listen to `service.linkStream` and call your
  router from a `ConsumerWidget` / `StatefulWidget` / wherever.

## Install

```yaml
dependencies:
  deep_link_kit:
    path: ../packages/deep_link_kit
```

```dart
import 'package:deep_link_kit/deep_link_kit.dart';
```

## Quick start

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DeepLinkKitRuntime.use(
    customSchemes: const ['myapp'],
    universalLinkHosts: const ['example.com', 'www.example.com'],
  );

  final service = DeepLinkService();
  await service.init();

  service.linkStream.listen((link) {
    switch (link.type) {
      case LinkType.product:
        appRouter.push('/products/${link.id}');
        break;
      case LinkType.category:
        appRouter.push('/categories/${link.id}');
        break;
      case LinkType.search:
        appRouter.push('/search?q=${link.parameters?['query'] ?? link.id}');
        break;
      case LinkType.custom:
        // Your app's domain-specific type, available on link.rawType.
        appRouter.push('/${link.rawType}/${link.id ?? ''}');
        break;
      case LinkType.unknown:
        break;
      // … profile / orders / faq / form / notifications
      default:
        break;
    }
  });

  runApp(const MyApp());
}
```

## Supported URL formats

### Custom scheme

```
myapp://<type>/<id>?<query>
```

- `host` is the type (e.g. `product`).
- The first path segment (if any) is the id.

Examples:

- `myapp://category/1` → `LinkType.category`, id: `'1'`
- `myapp://product/42?ref=banner` → `LinkType.product`, id: `'42'`,
  params: `{'ref': 'banner'}`
- `myapp://faq` → `LinkType.faq`

### Universal link

```
https://<allowed-host>/<type>/<id>?<query>
```

- First path segment is the type, second is the id.

Examples:

- `https://example.com/product/42` → `LinkType.product`, id: `'42'`
- `https://www.example.com/orders` → `LinkType.orders`

## Built-in link types

Out of the box, the parser recognises these types:

| Type | Examples |
| --- | --- |
| `category` | `myapp://category/123` |
| `product` | `myapp://product/42` |
| `faq` | `myapp://faq` |
| `form` | `myapp://form/contact?source=home` |
| `profile` | `myapp://profile` |
| `orders` | `myapp://orders` |
| `notifications` | `myapp://notifications` |
| `search` | `myapp://search?query=burger` |

Anything else (e.g. `myapp://settings/2fa`) falls through to
`LinkType.custom` with the raw type preserved on `LinkData.rawType`:

```dart
final link = RouteParser.parseLink('myapp://settings/2fa');
// link.type     == LinkType.custom
// link.rawType  == 'settings'
// link.id       == '2fa'
```

So your app can route on either the typed enum or the raw string —
whichever is more convenient.

## Cold-start vs hot-start

`service.init()` handles both:

- **Hot-start**: subscribes to `AppLinks.stringLinkStream` so links that
  arrive while the app is running are forwarded.
- **Cold-start**: calls `AppLinks.getInitialLink()` to capture the URL that
  launched the app (e.g. when the user tapped a link from outside).

If you want to defer cold-start processing until after your router is
ready, you can call `init()` later in your widget tree's `initState`
instead of inside `main()`.

## Validation

`RouteParser.isAppLink('myapp://product/1')` returns `true` only when the
URL's scheme is in `customSchemes` or its host is in `universalLinkHosts`.
The service uses this internally to ignore foreign links.

## Platform setup

`deep_link_kit` doesn't add any native-side glue beyond what
[`app_links`](https://pub.dev/packages/app_links) requires.

### Android

In `android/app/src/main/AndroidManifest.xml`, inside your main `<activity>`:

```xml
<!-- Custom scheme -->
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="myapp"/>
</intent-filter>

<!-- Universal links -->
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="https"
        android:host="example.com"/>
</intent-filter>
```

Add an `assetlinks.json` to `https://example.com/.well-known/assetlinks.json`.

### iOS

Custom scheme in `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array><string>myapp</string></array>
  </dict>
</array>
```

Universal links: enable the **Associated Domains** capability and add
`applinks:example.com`. Host an `apple-app-site-association` file on your
domain.

## Notes

- The package doesn't include the commented-out `DeepLinkHandler` /
  `DeepLinkHelper` from the original module — those tied directly into the
  host app's router (`AppNavigations.*`, `GoRouter`, `UIHelper`), which is
  exactly what a generic package should avoid. Implement the equivalent in
  your app's navigation layer by listening to `service.linkStream`.
- The kit is single-instance friendly: keep one `DeepLinkService` for the
  lifetime of the app.
