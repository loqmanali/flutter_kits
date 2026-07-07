import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_kit/picker.dart';
import 'package:map_kit/tracking.dart';

void main() {
  MapKitRuntime.use(
    nominatimUserAgent: 'MapKitExample/1.0',
    osrmUserAgent: 'MapKitExample/1.0',
  );
  runApp(const ProviderScope(child: _ExampleApp()));
}

class _ExampleApp extends StatelessWidget {
  const _ExampleApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'map_kit example',
      home: _Home(),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('map_kit')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _PickerDemo()),
              ),
              child: const Text('Open location picker'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _TrackingDemo()),
              ),
              child: const Text('Open delivery tracking'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerDemo extends ConsumerWidget {
  const _PickerDemo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location picker')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Wire up LocationPickerMap + LocationSearchBar from '
            'package:map_kit/picker.dart here.\n\n'
            'See the package README for the full snippet.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _TrackingDemo extends ConsumerWidget {
  const _TrackingDemo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery tracking')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Wire up DeliveryMap + DeliveryInfoPanel from '
            'package:map_kit/tracking.dart here.\n\n'
            'See the package README for the full snippet.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
