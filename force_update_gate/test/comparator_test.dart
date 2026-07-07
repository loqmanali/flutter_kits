import 'package:flutter_test/flutter_test.dart';
import 'package:force_update_gate/force_update_gate.dart';

void main() {
  group('defaultVersionComparator', () {
    test('treats equal semver as 0', () {
      expect(defaultVersionComparator('1.0.0', '1.0.0'), 0);
    });

    test('detects older installed', () {
      expect(defaultVersionComparator('1.0.0', '1.0.1'), lessThan(0));
      expect(defaultVersionComparator('1.0.0', '1.1.0'), lessThan(0));
      expect(defaultVersionComparator('1.0.0', '2.0.0'), lessThan(0));
      expect(defaultVersionComparator('1.0', '1.0.1'), lessThan(0));
    });

    test('detects newer installed', () {
      expect(defaultVersionComparator('1.0.1', '1.0.0'), greaterThan(0));
      expect(defaultVersionComparator('2.0.0', '1.99.99'), greaterThan(0));
    });

    test('strips build metadata after +', () {
      expect(defaultVersionComparator('1.0.0+10', '1.0.0+1'), 0);
      expect(defaultVersionComparator('1.0.0+1', '1.0.1+999'), lessThan(0));
    });

    test('strips pre-release tags after -', () {
      expect(defaultVersionComparator('1.0.0-beta', '1.0.0'), 0);
      expect(defaultVersionComparator('1.0.0-alpha.2', '1.0.0'), 0);
    });

    test('coerces non-numeric parts to 0', () {
      expect(defaultVersionComparator('1.0.x', '1.0.0'), 0);
      expect(defaultVersionComparator('1.0.foo', '1.0.1'), lessThan(0));
    });
  });
}
