import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/providers.dart';

/// Configuration for the location preview card appearance.
///
/// Customize colors, icons, and button text.
class LocationPreviewCardConfig {
  /// Confirm button text.
  final String confirmButtonText;

  /// Change location button text.
  final String changeButtonText;

  /// Background color of the card.
  final Color? backgroundColor;

  /// Color of the confirm button.
  final Color? confirmButtonColor;

  /// Whether to show the mini map preview.
  final bool showMiniMap;

  /// Whether to show address details.
  final bool showAddressDetails;

  /// Creates a new [LocationPreviewCardConfig].
  const LocationPreviewCardConfig({
    this.confirmButtonText = 'Confirm Location',
    this.changeButtonText = 'Change',
    this.backgroundColor,
    this.confirmButtonColor,
    this.showMiniMap = false,
    this.showAddressDetails = true,
  });
}

/// A card widget displaying the selected location details.
///
/// Shows the selected address with confirm and change actions.
/// Typically displayed at the bottom of the location picker.
///
/// ## Usage
///
/// ```dart
/// LocationPreviewCard(
///   config: LocationPreviewCardConfig(
///     confirmButtonText: 'Deliver Here',
///     showAddressDetails: true,
///   ),
///   onConfirm: (location) {
///     // Handle confirmation
///     Navigator.pop(context, location);
///   },
///   onChangePressed: () {
///     // Return to map or search
///   },
/// )
/// ```
///
/// ## Features
///
/// - Displays selected location name and address
/// - Confirm and change buttons
/// - Loading state during reverse geocoding
/// - Customizable appearance
class LocationPreviewCard extends ConsumerWidget {
  /// Card configuration.
  final LocationPreviewCardConfig config;

  /// Called when confirm button is pressed.
  final void Function(LocationAddress location)? onConfirm;

  /// Called when change button is pressed.
  final VoidCallback? onChangePressed;

  /// Custom builder for the location display.
  final Widget Function(BuildContext, LocationAddress)? locationBuilder;

  /// Creates a new [LocationPreviewCard].
  const LocationPreviewCard({
    super.key,
    this.config = const LocationPreviewCardConfig(),
    this.onConfirm,
    this.onChangePressed,
    this.locationBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationPickerProvider);
    final theme = Theme.of(context);

    if (!state.hasSelection) {
      return const SizedBox.shrink();
    }

    final location = state.selectedLocation!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.backgroundColor ?? theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Location info
            if (locationBuilder != null)
              locationBuilder!(context, location)
            else
              _buildLocationInfo(context, state, location),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                // Change button
                if (onChangePressed != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onChangePressed,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(config.changeButtonText),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Confirm button
                Expanded(
                  flex: onChangePressed != null ? 2 : 1,
                  child: ElevatedButton(
                    onPressed: () => onConfirm?.call(location),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          config.confirmButtonColor ?? theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(config.confirmButtonText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(
    BuildContext context,
    LocationPickerState state,
    LocationAddress location,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.location_on,
            color: theme.primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),

        // Location details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.isLoadingAddress)
                _buildLoadingState(context)
              else ...[
                // Primary name
                Text(
                  _getPrimaryName(location),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Address details
                if (config.showAddressDetails) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getSecondaryAddress(location),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Coordinates
                const SizedBox(height: 4),
                Text(
                  '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.disabledColor,
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).disabledColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Getting address...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
        ),
      ],
    );
  }

  String _getPrimaryName(LocationAddress location) {
    // Try to get the most specific name
    if (location.street != null && location.street!.isNotEmpty) {
      return location.street!;
    }
    if (location.displayName != null && location.displayName!.isNotEmpty) {
      // Get first part of display name
      final parts = location.displayName!.split(',');
      if (parts.isNotEmpty) {
        return parts.first.trim();
      }
    }
    return 'Selected Location';
  }

  String _getSecondaryAddress(LocationAddress location) {
    final parts = <String>[];

    if (location.city != null && location.city!.isNotEmpty) {
      parts.add(location.city!);
    }
    if (location.state != null && location.state!.isNotEmpty) {
      parts.add(location.state!);
    }
    if (location.country != null && location.country!.isNotEmpty) {
      parts.add(location.country!);
    }

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    // Fallback to display name if available
    if (location.displayName != null) {
      final displayParts = location.displayName!.split(',');
      if (displayParts.length > 1) {
        return displayParts.skip(1).map((e) => e.trim()).join(', ');
      }
    }

    return '';
  }
}
