# firebase_kit

A self-contained, project-agnostic Firebase module for Flutter. Drop it into
any project and you get:

- **Auth** — every Firebase Auth method: email/password, phone (SMS),
  anonymous, custom token, and every OAuth provider (Google, Apple, Facebook,
  GitHub, Microsoft, Yahoo, Twitter/X, …) through pluggable adapters.
- **Firestore** — a generic, type-safe `FirestoreRepository<T>` with a fluent
  query builder. One line of glue per entity, no per-collection boilerplate.
- **Firebase AI Logic** — Vertex AI / Google AI / Gemini in Firebase. One-shot
  and streaming generation, chat sessions, token counting.
- **Riverpod** — all the providers wired for you, plus a `AuthNotifier`
  facade that maps cleanly to UI state.
- **Pluggable** — bring your own logger, OAuth adapters, and collection names.

The kit ships **no native OAuth SDKs**. You implement an `OAuthProviderAdapter`
for each provider you need (Google, Apple, Facebook, …) so the kit stays small
and only pulls the deps your app actually uses.

---

## 1. Setup

In the host app's `pubspec.yaml`:

```yaml
dependencies:
  firebase_kit:
    path: packages/firebase_kit
```

Initialize Firebase, then configure the kit at startup:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_kit/firebase_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseKitRuntime.use(
    logger: AppLoggerFirebaseAdapter(),  // your logger
    collections: const FirestoreCollectionConfig(usersCollection: 'users'),
    oauthAdapters: [GoogleOAuthAdapter(), AppleOAuthAdapter()],
    config: const FirebaseKitConfig(
      ai: FirebaseAiConfig(
        model: 'gemini-1.5-flash',
        useVertexAi: true,
      ),
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}
```

### Wiring your existing logger

```dart
class AppLoggerFirebaseAdapter implements FirebaseLogger {
  @override
  void debug(String m, [Object? e, StackTrace? st]) => AppLogger.debug(m, e, st);
  @override
  void info(String m, [Object? e, StackTrace? st]) => AppLogger.info(m, e, st);
  @override
  void warning(String m, [Object? e, StackTrace? st]) => AppLogger.warning(m, e, st);
  @override
  void error(String m, [Object? e, StackTrace? st]) => AppLogger.error(m, e, st);
}
```

---

## 2. Auth

```dart
// Trigger sign-in from a widget
ref.read(authNotifierProvider.notifier)
   .signInWithEmail(email: 'a@b.com', password: '••••••');

// React to the result
final state = ref.watch(authNotifierProvider);
if (state.error != null) showError(state.error!.message);
if (state.user != null)  goToHome(state.user!);
```

### Phone

```dart
await ref.read(authNotifierProvider.notifier)
         .startPhoneVerification(phoneNumber: '+201234567890');

final session = ref.read(authNotifierProvider).phoneSession!;
await ref.read(authNotifierProvider.notifier).confirmPhoneCode(
  verificationId: session.verificationId,
  smsCode: '123456',
);
```

### OAuth (Google example)

Add `google_sign_in` to your host app, then:

```dart
class GoogleOAuthAdapter implements OAuthProviderAdapter {
  @override
  String get id => 'google.com';

  @override
  Future<AuthCredential?> obtainCredential() async {
    final account = await GoogleSignIn().signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    return GoogleAuthProvider.credential(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
  }

  @override
  Future<void> signOut() => GoogleSignIn().signOut();
}

// Register at startup:
FirebaseKitRuntime.use(oauthAdapters: [GoogleOAuthAdapter()]);

// Use:
await ref.read(authNotifierProvider.notifier).signInWithOAuth('google.com');
```

Apple, Facebook, GitHub, Microsoft, Yahoo, Twitter follow the same shape.

### Account linking

```dart
await ref.read(authRepositoryProvider).linkOAuthProvider('google.com');
await ref.read(authRepositoryProvider).linkEmailPassword(email: ..., password: ...);
await ref.read(authRepositoryProvider).unlinkProvider('google.com');
```

---

## 3. Firestore

Define a converter for each entity (one short class — no inheritance):

```dart
class Todo {
  final String id;
  final String title;
  final bool done;
  Todo({this.id = '', required this.title, this.done = false});
}

class TodoConverter implements FirestoreConverter<Todo> {
  const TodoConverter();
  @override
  Todo fromFirestore(String id, Map<String, dynamic> data) => Todo(
        id: id,
        title: data['title'] as String,
        done: data['done'] as bool? ?? false,
      );
  @override
  Map<String, dynamic> toFirestore(Todo t) => {'title': t.title, 'done': t.done};
  @override
  String idOf(Todo t) => t.id;
}
```

Construct a typed repository — same `FirestoreRepository<T>` for every entity:

```dart
final todosRepo = FirestoreRepositoryImpl<Todo>(
  path: 'todos',
  converter: const TodoConverter(),
);

final saved   = await todosRepo.create(Todo(title: 'Ship it'));
final one     = await todosRepo.get(saved.id);
final mine    = await todosRepo.find(
  todosRepo.query()
    .where('done', isEqualTo: false)
    .orderBy('title')
    .limit(20),
);
final stream  = todosRepo.watchQuery(todosRepo.query().where('done', isEqualTo: false));
```

Need transactions or batched writes? Call `rawCollection()` and use the
Firestore SDK directly — the kit doesn't get in the way.

---

## 4. Firebase AI

One-shot:

```dart
final reply = await ref.read(firebaseAiRepositoryProvider).generateText(
  'Write a haiku about Firestore.',
);
```

Streamed:

```dart
final stream = ref.watch(aiTextStreamProvider('Tell me a joke'));
stream.when(
  data: (chunk) => Text(chunk),
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => Text('$e'),
);
```

Multi-turn chat:

```dart
final chat = ref.read(firebaseAiRepositoryProvider).startChat();
final hello = await chat.send('Hello!');
final more  = await chat.send('Tell me more.');
print(chat.history);
```

Token counting:

```dart
final tokens = await ref.read(firebaseAiRepositoryProvider).countTokens(prompt);
```

---

## 5. What's pluggable

| Surface                          | Plug via                                  |
|----------------------------------|-------------------------------------------|
| Logger                           | `FirebaseLogger` + `FirebaseKitRuntime.use(logger:)` |
| User collection name             | `FirestoreCollectionConfig`               |
| OAuth providers                  | `OAuthProviderAdapter` + `oauthAdapters:` |
| AI model / backend / temperature | `FirebaseAiConfig`                        |
| Any custom collection            | `FirestoreRepositoryImpl<T>(path:, converter:)` |

Reset everything (test hook): `FirebaseKitRuntime.reset()`.
