/// What the spotlight UI is allowed to ask of the tour.
///
/// Kept separate from [TourManager] so a custom spotlight widget can be driven
/// by anything that can move between steps.
abstract interface class ISpotlightNavigator {
  /// Advances to the next step, or ends the tour if this was the last one.
  void next();

  /// Goes back one step. No-op on the first step.
  void prev();

  /// Ends the tour immediately.
  void skip();
}
