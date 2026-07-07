# system_ui_kit

Reusable Flutter helpers for matching the platform status bar with a custom
app bar or top header.

## Basic Use

Wrap your custom app bar content with `StatusBarColorScope`.

```dart
Scaffold(
  appBar: PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: StatusBarColorScope(
      color: Colors.blue,
      child: AppBar(
        primary: false,
        backgroundColor: Colors.blue,
        title: const Text('Home'),
      ),
    ),
  ),
);
```

When wrapping Flutter's `AppBar`, set `primary: false`. The scope already owns
the top safe-area padding.

## Android Setup

For Android projects, make the runtime status bar transparent so Flutter can
paint behind it. In `android/app/src/main/res/values/styles.xml`:

```xml
<style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <item name="android:windowDrawsSystemBarBackgrounds">true</item>
    <item name="android:statusBarColor">#00000000</item>
    <item name="android:navigationBarColor">#FFFFFF</item>
    <item name="android:windowLightStatusBar">true</item>
    <item name="android:windowLightNavigationBar">true</item>
</style>
```

Apply the same idea to `values-night`, `values-v31`, and `values-night-v31`.
After changing Android resources, uninstall/reinstall or do a full rebuild.
