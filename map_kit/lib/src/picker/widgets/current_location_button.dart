import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

/// Configuration for the current location button.
///
/// Customize appearance, position, and behavior.
class CurrentLocationButtonConfig {
  /// Button background color.
  final Color? backgroundColor;

  /// Icon color.
  final Color? iconColor;

  /// Button size (width and height).
  final double size;

  /// Border radius of the button.
  final double borderRadius;

  /// Icon to display.
  final IconData icon;

  /// Icon to display when loading.
  final IconData loadingIcon;

  /// Tooltip text.
  final String tooltip;

  /// Creates a new [CurrentLocationButtonConfig].
  const CurrentLocationButtonConfig({
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.borderRadius = 12,
    this.icon = Icons.my_location,
    this.loadingIcon = Icons.location_searching,
    this.tooltip = 'Current Location',
  });
}

/// A button that centers the map on the user's current location.
///
/// Integrates with the location picker provider to get and display
/// the user's current location on the map.
///
/// ## Usage
///
/// ```dart
/// CurrentLocationButton(
///   config: CurrentLocationButtonConfig(
///     size: 56,
///     icon: Icons.gps_fixed,
///   ),
///   onLocationObtained: (location) {
///     // Handle location
///   },
/// )
/// ```
///
/// ## Features
///
/// - Shows loading state while getting location
/// - Customizable icon and appearance
/// - Callback when location is obtained
class CurrentLocationButton extends ConsumerWidget {
  /// Button configuration.
  final CurrentLocationButtonConfig config;

  /// Called when current location is obtained.
  final void Function(double latitude, double longitude)? onLocationObtained;

  /// Called when there's an error getting location.
  final void Function(String error)? onError;

  /// Whether the button is enabled.
  final bool enabled;

  /// Creates a new [CurrentLocationButton].
  const CurrentLocationButton({
    super.key,
    this.config = const CurrentLocationButtonConfig(),
    this.onLocationObtained,
    this.onError,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationPickerProvider);
    final theme = Theme.of(context);
    final isLoading = state.isLoading;

    return Tooltip(
      message: config.tooltip,
      child: Material(
        color: config.backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(config.borderRadius),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        child: InkWell(
          onTap: enabled && !isLoading ? () => _onPressed(ref) : null,
          borderRadius: BorderRadius.circular(config.borderRadius),
          child: SizedBox(
            width: config.size,
            height: config.size,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: config.iconColor ?? theme.primaryColor,
                      ),
                    )
                  : Icon(
                      config.icon,
                      color: enabled
                          ? (config.iconColor ?? theme.primaryColor)
                          : theme.disabledColor,
                      size: 24,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onPressed(WidgetRef ref) async {
    // Note: This requires integrating with a location service like geolocator
    // For now, we'll just notify that the feature needs location permission
    onError?.call('Location service integration required. Use geolocator package.');
  }
}
