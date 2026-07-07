// Minimal example: wire firebase_kit into a Riverpod app.
//
// This is a documentation snippet — not a runnable example. Drop into a real
// Flutter project, configure Firebase, then run.
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_kit/firebase_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseKitRuntime.use(
    config: const FirebaseKitConfig(
      ai: FirebaseAiConfig(model: 'gemini-1.5-flash'),
    ),
  );

  runApp(const ProviderScope(child: _App()));
}

class _App extends ConsumerWidget {
  const _App();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('firebase_kit example')),
        body: Center(
          child: authState.user == null
              ? ElevatedButton(
                  onPressed: () => ref
                      .read(authNotifierProvider.notifier)
                      .signInAnonymously(),
                  child: const Text('Sign in anonymously'),
                )
              : Text('Signed in as ${authState.user!.uid}'),
        ),
      ),
    );
  }
}
