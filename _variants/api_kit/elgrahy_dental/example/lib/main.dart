import 'package:api_kit/api_kit.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiKitRuntime.use(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    timeout: const Duration(seconds: 10),

    // For a real app you'd pass a SharedPreferences/Hive-backed adapter.
    // The default is in-memory.
    // tokenStorage: MyTokenStorage(),

    // For a real app you'd plug in actual refresh + logout:
    // onRefreshToken: (refresh) async => '<new-access-token>',
    // onLogout: () async { /* navigate to login */ },

    // Skip user auth on JSONPlaceholder (no auth involved here):
    skipUserAuthEndpoints: const ['/'],
  );

  runApp(const _ExampleApp());
}

class _ExampleApp extends StatelessWidget {
  const _ExampleApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'api_kit example',
      home: _Home(),
    );
  }
}

class _Home extends StatefulWidget {
  const _Home();

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  final _client = DioApiClient.authenticated();
  String _result = '(no result yet)';
  bool _loading = false;

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _result = 'Loading…';
    });
    try {
      final data = await _client.get('/posts/1');
      setState(() => _result = data.toString());
    } on ApiException catch (e) {
      setState(() => _result = 'Error: ${e.message}');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('api_kit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _fetch,
              child: Text(_loading ? 'Loading…' : 'GET /posts/1'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(_result),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
