/// Singleton that tracks open dropdowns and enforces "only one open at a time".
class DropdownManager {
  DropdownManager._internal();

  static final DropdownManager _instance = DropdownManager._internal();
  factory DropdownManager() => _instance;

  final List<void Function()> _openDropdowns = [];

  /// Register a new dropdown, closing any currently open ones first.
  void register(void Function() closeCallback) {
    closeAll();
    _openDropdowns.add(closeCallback);
  }

  /// Remove a dropdown from tracking (called when it closes itself).
  void unregister(void Function() closeCallback) {
    _openDropdowns.remove(closeCallback);
  }

  /// Close every registered dropdown.
  void closeAll() {
    final copy = List<void Function()>.from(_openDropdowns);
    _openDropdowns.clear();
    for (final close in copy) {
      close();
    }
  }
}
