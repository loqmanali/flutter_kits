import 'package:flutter/material.dart';
import 'package:storage_kit/storage_kit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pick a backend — SharedPreferences by default.
  await AppStorage.initialize();

  // Or use Hive (faster, supports encryption):
  // await AppStorage.initialize(
  //   type: StorageType.hive,
  //   hiveBoxName: 'app_storage',
  //   hiveEncryptionKey: 'optional-32-byte-key-goes-here',
  // );

  runApp(const _ExampleApp());
}

class _ExampleApp extends StatelessWidget {
  const _ExampleApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'storage_kit example',
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
  final _controller = TextEditingController();
  String? _stored;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await AppStorage.instance.getString('note');
    setState(() => _stored = value);
  }

  Future<void> _save() async {
    await AppStorage.instance.setString('note', _controller.text);
    await _load();
  }

  Future<void> _clear() async {
    await AppStorage.instance.remove('note');
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('storage_kit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Note')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: _save, child: const Text('Save'))),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton(onPressed: _clear, child: const Text('Clear'))),
              ],
            ),
            const SizedBox(height: 24),
            Text('Stored: ${_stored ?? "(nothing)"}'),
          ],
        ),
      ),
    );
  }
}
