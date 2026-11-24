## 1.1.0

Flutter 3.50 / Dart 3.14 migration (monorepo release 2.1.0).

- Migrated from the deprecated `package:flutter/material.dart` / `cupertino.dart` to `package:material_ui` / `package:cupertino_ui`. Requires Flutter >= 3.47 / Dart >= 3.13; extensions and themes are now material_ui `ThemeData` types.
- Dependencies: `firebase_core ^5.2.0`, `firebase_auth ^7.1.0`, `cloud_firestore ^7.2.0`, `firebase_ai ^5.2.0`, `equatable ^3.0.0`, `material_ui ^1.11.1`.
- firebase_ai 5: `FirebaseAI.vertexAI()` is now `FirebaseAI.agentPlatform()`. `FirebaseAiConfig.useVertexAi` is unchanged.

## 1.0.0

- Initial release.
- Auth module: email/password, phone, anonymous, custom token, OAuth via
  pluggable adapters, account linking, re-authentication, profile updates.
- Generic Firestore CRUD repository with fluent query builder.
- Firebase AI Logic module: text generation, streaming, chat sessions,
  token counting.
- Riverpod providers and `AuthNotifier` facade.
- Pluggable `FirebaseLogger`, `OAuthProviderAdapter`, and collection config.
