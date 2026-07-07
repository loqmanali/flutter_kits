import '../../core/models/analytics_event.dart';
import '../../presentation/providers/analytics_provider.dart';

/// A mock analytics service that records all events.
class MockAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> events = [];
  final List<MapEntry<String, String?>> userProperties = [];
  String? userId;
  int resetCount = 0;

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    events.add(event);
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    userProperties.add(MapEntry(name, value));
  }

  @override
  Future<void> setUserId(String? id) async {
    userId = id;
  }

  @override
  Future<void> reset() async {
    resetCount++;
    events.clear();
    userProperties.clear();
    userId = null;
  }

  /// Gets all events of a specific type.
  List<T> eventsOfType<T extends AnalyticsEvent>() {
    return events.whereType<T>().toList();
  }

  /// Gets the last event of a specific type.
  T? lastEventOfType<T extends AnalyticsEvent>() {
    final typed = eventsOfType<T>();
    return typed.isEmpty ? null : typed.last;
  }

  /// Whether an event with the given name was logged.
  bool hasEvent(String name) {
    return events.any((e) => e.name == name);
  }

  /// Gets all events with the given name.
  List<AnalyticsEvent> eventsByName(String name) {
    return events.where((e) => e.name == name).toList();
  }

  /// Clears all recorded data without incrementing reset count.
  void clear() {
    events.clear();
    userProperties.clear();
    userId = null;
  }
}

/// A callback-based mock analytics service.
class CallbackAnalyticsService implements AnalyticsService {
  final void Function(AnalyticsEvent)? onEvent;
  final void Function(String, String?)? onSetUserProperty;
  final void Function(String?)? onSetUserId;
  final void Function()? onReset;

  CallbackAnalyticsService({
    this.onEvent,
    this.onSetUserProperty,
    this.onSetUserId,
    this.onReset,
  });

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    onEvent?.call(event);
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    onSetUserProperty?.call(name, value);
  }

  @override
  Future<void> setUserId(String? userId) async {
    onSetUserId?.call(userId);
  }

  @override
  Future<void> reset() async {
    onReset?.call();
  }
}
