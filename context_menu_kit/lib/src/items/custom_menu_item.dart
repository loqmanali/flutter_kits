import 'package:flutter/material.dart';

/// Contract for a fully custom menu row.
///
/// Use this interface when [MenuItem] is too restrictive — e.g. a row that
/// needs a switch, an image, a multi-line block, or any layout that
/// the built-in `icon + text` row can't express.
///
/// Implementations are responsible for their own tap handling and for
/// dismissing the menu if appropriate.
abstract class CustomMenuItem {
  /// Build the row widget.
  Widget build(BuildContext context);
}
