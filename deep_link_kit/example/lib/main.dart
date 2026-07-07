import 'package:deep_link_kit/deep_link_kit.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DeepLinkKitRuntime.use(
    customSchemes: const ['myapp'],
    universalLinkHosts: const ['example.com', 'www.example.com'],
  );

  runApp(const _ExampleApp());
}

class _ExampleApp extends StatelessWidget {
  const _ExampleApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'deep_link_kit example',
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
  final _service = DeepLinkService();
  final _events = <LinkData>[];

  @override
  void initState() {
    super.initState();
    _service.init();
    _service.linkStream.listen((link) {
      setState(() => _events.insert(0, link));
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _simulate(String url) {
    // Just demonstrate the parser path — in a real app links come in via
    // `AppLinks` from outside the app.
    final parsed = RouteParser.parseLink(url);
    setState(() => _events.insert(0, parsed));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('deep_link_kit')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _simulate('myapp://product/42?ref=banner'),
                  child: const Text('Parse product link'),
                ),
                ElevatedButton(
                  onPressed: () => _simulate('https://example.com/category/3'),
                  child: const Text('Parse universal link'),
                ),
                ElevatedButton(
                  onPressed: () => _simulate('myapp://settings/2fa'),
                  child: const Text('Parse custom type'),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, i) {
                final link = _events[i];
                return ListTile(
                  title: Text('${link.type} (${link.rawType ?? '-'})'),
                  subtitle: Text('id: ${link.id} | params: ${link.parameters}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
