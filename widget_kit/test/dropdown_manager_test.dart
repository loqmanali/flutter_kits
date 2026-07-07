import 'package:flutter_test/flutter_test.dart';
import 'package:widget_kit/src/dropdown_menu/dropdown_manager.dart';

void main() {
  group('DropdownManager', () {
    tearDown(() {
      // Leave the shared singleton clean for the next test.
      DropdownManager().closeAll();
    });

    test('is a singleton (same instance every time)', () {
      expect(identical(DropdownManager(), DropdownManager()), isTrue);
    });

    test('registering a second dropdown closes the first', () {
      final manager = DropdownManager();
      var firstClosed = 0;

      manager.register(() => firstClosed++);
      // Registering again should close the previously open one.
      manager.register(() {});

      expect(firstClosed, 1);
    });

    test('closeAll invokes every registered close callback once', () {
      final manager = DropdownManager();
      var aClosed = 0;
      // register() closes existing ones first, so register a single callback
      // and close it to verify the invocation.
      manager.register(() => aClosed++);
      manager.closeAll();
      expect(aClosed, 1);
    });

    test('closeAll on an empty manager is a no-op (does not throw)', () {
      final manager = DropdownManager();
      expect(manager.closeAll, returnsNormally);
    });

    test('a closed dropdown is not invoked again on the next closeAll', () {
      final manager = DropdownManager();
      var closed = 0;
      manager.register(() => closed++);
      manager.closeAll(); // closed -> 1
      manager.closeAll(); // already cleared, no further calls
      expect(closed, 1);
    });

    test('unregister removes a callback so closeAll does not call it', () {
      final manager = DropdownManager();
      var closed = 0;
      void cb() => closed++;

      manager.register(cb);
      manager.unregister(cb);
      manager.closeAll();

      expect(closed, 0);
    });
  });
}
