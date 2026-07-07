import 'package:flutter/material.dart';
import 'package:force_update_gate/force_update_gate.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'force_update_gate demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return ForceUpdateGate(
          config: ForceUpdateConfig(
            allowLater: true,
            skipMode: ForceUpdateSkipMode.cooldown,
            laterCooldown: const Duration(hours: 24),
            recheckOnForeground: true,
            includeReleaseNotes: true,
            debugAlwaysShow: true, // remove in production
            labels: ForceUpdateLabels.en().copyWith(versionPrefix: 'Demo'),
            onUpdateRequired:
                (policy) => debugPrint(
                  '[demo] update required: ${policy.latestVersion}',
                ),
            onStoreOpened:
                (policy) =>
                    debugPrint('[demo] launching store ${policy.storeUrl}'),
            onUpdateDismissed:
                (policy) => debugPrint('[demo] dismissed for cooldown'),
          ),
          child: child!,
        );
      },
      home: const _Home(),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('force_update_gate demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'You\'re inside the app.\n\nTry tapping the buttons below '
                'to demo the alternative entry points.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _BannerDemoPage(),
                  ),
                ),
                child: const Text('Banner mode'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const _CupertinoDemoPage(),
                  ),
                ),
                child: const Text('Cupertino screen'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed:
                    () => showForceUpdateDialog(
                      context: context,
                      config: const ForceUpdateConfig(
                        allowLater: true,
                        debugAlwaysShow: true,
                        includeReleaseNotes: true,
                      ),
                    ),
                child: const Text('Dialog mode'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerDemoPage extends StatelessWidget {
  const _BannerDemoPage();

  @override
  Widget build(BuildContext context) {
    return ForceUpdateBanner(
      config: ForceUpdateConfig(
        allowLater: true,
        debugAlwaysShow: true,
        labels: ForceUpdateLabels.ar(),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Banner demo')),
        body: const Center(
          child: Text('The banner is rendered above this screen.'),
        ),
      ),
    );
  }
}

class _CupertinoDemoPage extends StatelessWidget {
  const _CupertinoDemoPage();

  @override
  Widget build(BuildContext context) {
    return ForceUpdateGate(
      config: const ForceUpdateConfig(
        allowLater: true,
        debugAlwaysShow: true,
        includeReleaseNotes: true,
      ),
      screenBuilder:
          (context, policy, actions) => CupertinoForceUpdateScreen(
            policy: policy,
            actions: actions,
            labels: ForceUpdateLabels.en(),
            showReleaseNotes: true,
          ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Cupertino demo')),
        body: const Center(child: Text('Hello iOS-styled gate.')),
      ),
    );
  }
}
