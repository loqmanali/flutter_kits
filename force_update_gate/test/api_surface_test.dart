// Smoke test that the public API surface is intact.
//
// Each `Type` reference here forces the analyzer to verify the
// corresponding name is still exported from the barrel. Adding or
// removing exports without updating this list is an intentional API
// change and should be reflected here.
import 'package:flutter_test/flutter_test.dart';
import 'package:force_update_gate/force_update_gate.dart';

void main() {
  test('public API exports', () {
    expect(ForceUpdateGate, isNotNull);
    expect(ForceUpdateBanner, isNotNull);
    expect(ForceUpdateConfig, isNotNull);
    expect(ForceUpdateLabels, isNotNull);
    expect(ForceUpdatePolicy, isNotNull);
    expect(ForceUpdateActions, isNotNull);
    expect(ForceUpdateService, isNotNull);
    expect(DefaultForceUpdateScreen, isNotNull);
    expect(CupertinoForceUpdateScreen, isNotNull);
    expect(DismissalStore, isNotNull);
    expect(InAppUpdateHelper, isNotNull);

    // Enums
    expect(ForceUpdateSkipMode.values, hasLength(3));
    expect(AndroidInAppUpdateMode.values, hasLength(2));
    expect(InAppUpdateResult.values, hasLength(3));

    // Functions / typedefs
    expect(showForceUpdateDialog, isNotNull);
    expect(defaultVersionComparator('1.0.0', '1.0.0'), 0);
  });

  test('built-in label factories cover all locales', () {
    final all = [
      ForceUpdateLabels.en(),
      ForceUpdateLabels.ar(),
      ForceUpdateLabels.fr(),
      ForceUpdateLabels.es(),
      ForceUpdateLabels.de(),
      ForceUpdateLabels.tr(),
    ];
    for (final l in all) {
      expect(l.title, isNotEmpty);
      expect(l.message, isNotEmpty);
      expect(l.updateButton, isNotEmpty);
      expect(l.laterButton, isNotEmpty);
      expect(l.skipVersionButton, isNotEmpty);
      expect(l.releaseNotesTitle, isNotEmpty);
    }
  });
}
