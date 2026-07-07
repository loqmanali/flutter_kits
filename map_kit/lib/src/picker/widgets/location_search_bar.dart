import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/providers.dart';

/// Configuration for the search bar appearance and behavior.
///
/// Customize placeholder text, styling, and debounce duration.
///
/// ## Usage
///
/// ```dart
/// LocationSearchBarConfig(
///   hintText: 'Search for a place...',
///   debounceMs: 500,
///   backgroundColor: Colors.white,
///   borderRadius: 12.0,
/// )
/// ```
class LocationSearchBarConfig {
  /// Placeholder text shown when search field is empty.
  final String hintText;

  /// Debounce duration in milliseconds before triggering search.
  final int debounceMs;

  /// Background color of the search bar.
  final Color? backgroundColor;

  /// Border radius of the search bar.
  final double borderRadius;

  /// Prefix icon to display.
  final IconData prefixIcon;

  /// Whether to show a clear button when text is entered.
  final bool showClearButton;

  /// Creates a new [LocationSearchBarConfig].
  const LocationSearchBarConfig({
    this.hintText = 'Search for a location...',
    this.debounceMs = 300,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.prefixIcon = Icons.search,
    this.showClearButton = true,
  });
}

/// A search bar widget for searching locations.
///
/// Provides text input with debounced search, clear functionality,
/// and integrates with the location picker provider.
///
/// ## Usage
///
/// ```dart
/// LocationSearchBar(
///   config: LocationSearchBarConfig(
///     hintText: 'Where to?',
///     debounceMs: 500,
///   ),
///   onSearchFocusChanged: (focused) {
///     if (focused) {
///       // Switch to search mode
///     }
///   },
/// )
/// ```
///
/// ## Features
///
/// - Debounced search to avoid excessive API calls
/// - Clear button to reset search
/// - Focus change callbacks for UI transitions
/// - Customizable appearance
class LocationSearchBar extends ConsumerStatefulWidget {
  /// Search bar configuration.
  final LocationSearchBarConfig config;

  /// Called when search focus changes.
  final void Function(bool hasFocus)? onSearchFocusChanged;

  /// Called when search is submitted (user presses enter).
  final void Function(String query)? onSubmitted;

  /// External text controller (optional).
  final TextEditingController? controller;

  /// Whether the search bar is enabled.
  final bool enabled;

  /// Creates a new [LocationSearchBar].
  const LocationSearchBar({
    super.key,
    this.config = const LocationSearchBarConfig(),
    this.onSearchFocusChanged,
    this.onSubmitted,
    this.controller,
    this.enabled = true,
  });

  @override
  ConsumerState<LocationSearchBar> createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends ConsumerState<LocationSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _isInternalController = true;
    }
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _controller.dispose();
    }
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    widget.onSearchFocusChanged?.call(_focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      ref.read(locationPickerProvider.notifier).enterSearchMode();
    }
  }

  void _onTextChanged(String value) {
    ref.read(locationPickerProvider.notifier).updateSearchQuery(value);
  }

  void _onClear() {
    _controller.clear();
    ref.read(locationPickerProvider.notifier).exitSearchMode();
  }

  void _onSubmitted(String value) {
    widget.onSubmitted?.call(value);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationPickerProvider);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: widget.config.backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(widget.config.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        onChanged: _onTextChanged,
        onSubmitted: _onSubmitted,
        decoration: InputDecoration(
          hintText: widget.config.hintText,
          prefixIcon: Icon(widget.config.prefixIcon),
          suffixIcon: _buildSuffixIcon(state),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.config.borderRadius),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon(LocationPickerState state) {
    if (state.isSearching) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (widget.config.showClearButton && _controller.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear),
        onPressed: _onClear,
      );
    }

    return null;
  }
}
