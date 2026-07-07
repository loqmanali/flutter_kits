import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:force_update_gate/force_update_gate.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StubService extends Mock implements ForceUpdateService {}

class _StubInAppUpdate extends Mock implements InAppUpdateHelper {}

ForceUpdatePolicy _policy({bool required = true, String? latest = '1.0.1'}) =>
    ForceUpdatePolicy(
      updateRequired: required,
      currentVersion: '1.0.0',
      latestVersion: latest,
      storeUrl: 'https://example.com/store',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    registerFallbackValue(AndroidInAppUpdateMode.immediate);
  });

  testWidgets('renders child while policy is resolving', (tester) async {
    final service = _StubService();
    when(() => service.resolvePolicy()).thenAnswer(
      (_) async => _policy(required: false),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ForceUpdateGate(
          service: service,
          inAppUpdateHelper: _StubInAppUpdate(),
          child: const Text('home'),
        ),
      ),
    );

    expect(find.text('home'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('shows default screen when update required', (tester) async {
    final service = _StubService();
    when(() => service.resolvePolicy()).thenAnswer((_) async => _policy());
    final inApp = _StubInAppUpdate();
    when(
      () => inApp.start(
        mode: any(named: 'mode'),
        debugLogging: any(named: 'debugLogging'),
      ),
    ).thenAnswer((_) async => InAppUpdateResult.notHandled);

    await tester.pumpWidget(
      MaterialApp(
        home: ForceUpdateGate(
          service: service,
          inAppUpdateHelper: inApp,
          config: const ForceUpdateConfig(),
          child: const Text('home'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Update available'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
    expect(find.text('home'), findsNothing);
  });

  testWidgets('hides Later button when allowLater is false', (tester) async {
    final service = _StubService();
    when(() => service.resolvePolicy()).thenAnswer((_) async => _policy());

    await tester.pumpWidget(
      MaterialApp(
        home: ForceUpdateGate(
          service: service,
          inAppUpdateHelper: _StubInAppUpdate(),
          child: const Text('home'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Later'), findsNothing);
  });

  testWidgets('renders Later when allowLater and dismisses on tap', (
    tester,
  ) async {
    final service = _StubService();
    when(() => service.resolvePolicy()).thenAnswer((_) async => _policy());

    var dismissedCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ForceUpdateGate(
          service: service,
          inAppUpdateHelper: _StubInAppUpdate(),
          config: ForceUpdateConfig(
            allowLater: true,
            onUpdateDismissed: (_) => dismissedCalls++,
          ),
          child: const Text('home'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Later'), findsOneWidget);

    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(dismissedCalls, 1);
  });

  testWidgets('custom screenBuilder takes over rendering', (tester) async {
    final service = _StubService();
    when(() => service.resolvePolicy()).thenAnswer((_) async => _policy());

    await tester.pumpWidget(
      MaterialApp(
        home: ForceUpdateGate(
          service: service,
          inAppUpdateHelper: _StubInAppUpdate(),
          screenBuilder:
              (context, policy, actions) => Scaffold(
                body: Center(
                  child: Text('custom-${policy.latestVersion}'),
                ),
              ),
          child: const Text('home'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('custom-1.0.1'), findsOneWidget);
  });

  testWidgets('onUpdateRequired callback fires once', (tester) async {
    final service = _StubService();
    when(() => service.resolvePolicy()).thenAnswer((_) async => _policy());

    var calls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ForceUpdateGate(
          service: service,
          inAppUpdateHelper: _StubInAppUpdate(),
          config: ForceUpdateConfig(
            onUpdateRequired: (_) => calls++,
          ),
          child: const Text('home'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(calls, 1);
  });
}
