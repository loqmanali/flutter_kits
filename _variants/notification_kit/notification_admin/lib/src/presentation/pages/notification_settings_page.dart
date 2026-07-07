import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/notification_channels.dart';
import '../providers/notification_providers.dart';
import '../widgets/notification_settings_tile.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                NotificationSettingsTile(
                  title: 'Enable Notifications',
                  subtitle: 'Turn on/off all notifications',
                  value: state.settings.enabled,
                  onChanged: notifier.toggleNotification,
                  isLoading: state.isSavingNotification,
                ),
                const Divider(),
                NotificationSettingsTile(
                  title: 'Sound',
                  subtitle: _getSoundName(state.settings.customSoundPath),
                  value: state.settings.soundEnabled,
                  onChanged: notifier.toggleSound,
                  isLoading: state.isSavingSound,
                  onTap: () => _showSoundSelectionDialog(
                    context,
                    notifier,
                    state.settings.customSoundPath,
                  ),
                ),
                NotificationSettingsTile(
                  title: 'Vibration',
                  value: state.settings.vibrationEnabled,
                  onChanged: notifier.toggleVibration,
                  isLoading: state.isSavingVibration,
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notification Sound',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final settingsState =
                              ref.watch(notificationSettingsProvider);
                          final settingsNotifier =
                              ref.read(notificationSettingsProvider.notifier);

                          return TextButton(
                            onPressed: () => _showSoundSelectionDialog(
                              context,
                              settingsNotifier,
                              settingsState.settings.customSoundPath,
                            ),
                            child: Text(
                              _getSoundName(
                                settingsState.settings.customSoundPath,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Notification Channels',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ..._getMainChannels().map((channelId) {
                  final isEnabled =
                      state.settings.channelSettings[channelId] ?? true;
                  return NotificationSettingsTile(
                    title: _getChannelDisplayName(channelId),
                    subtitle: _getChannelDescription(channelId),
                    value: isEnabled,
                    onChanged: (val) => notifier.toggleChannel(channelId, val),
                    isLoading: state.isSaving,
                  );
                }),
              ],
            ),
    );
  }

  String _getSoundName(String? path) {
    if (path == null || path.isEmpty) return 'Default';
    switch (path) {
      case 'notification_sound_1':
        return 'Success Tone';
      case 'notification_sound_2':
        return 'Bubble Pop';
      default:
        return 'Default';
    }
  }

  /// Returns the main notification channels (excluding sound-specific channels)
  List<String> _getMainChannels() {
    return [
      NotificationChannels.generalChannelId,
      NotificationChannels.ordersChannelId,
      NotificationChannels.promotionsChannelId,
      NotificationChannels.updatesChannelId,
      NotificationChannels.alertsChannelId,
    ];
  }

  /// Maps channel IDs to user-friendly display names
  String _getChannelDisplayName(String channelId) {
    switch (channelId) {
      case NotificationChannels.generalChannelId:
        return 'General Notifications';
      case NotificationChannels.ordersChannelId:
        return 'Order Updates';
      case NotificationChannels.promotionsChannelId:
        return 'Promotions & Offers';
      case NotificationChannels.updatesChannelId:
        return 'App Updates';
      case NotificationChannels.alertsChannelId:
        return 'Important Alerts';
      default:
        return channelId;
    }
  }

  /// Returns a description for each channel
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case NotificationChannels.generalChannelId:
        return 'General notifications about the app';
      case NotificationChannels.ordersChannelId:
        return 'Notifications about your order status';
      case NotificationChannels.promotionsChannelId:
        return 'Special offers and discounts';
      case NotificationChannels.updatesChannelId:
        return 'Updates about the application';
      case NotificationChannels.alertsChannelId:
        return 'Critical alerts that require attention';
      default:
        return '';
    }
  }

  void _showSoundSelectionDialog(
    BuildContext context,
    dynamic notifier,
    String? currentPath,
  ) {
    final player = AudioPlayer();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Default'),
              leading: Radio<String?>(
                value: null,
                groupValue: currentPath,
                onChanged: (val) {
                  notifier.updateCustomSound(null);
                  Navigator.pop(context);
                },
              ),
              onTap: () async {
                await player
                    .play(AssetSource('sounds/notification_default.mp3'));
                notifier.updateCustomSound(null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Success Tone'),
              leading: Radio<String?>(
                value: 'notification_sound_1',
                groupValue: currentPath,
                onChanged: (val) {
                  notifier.updateCustomSound(val);
                  Navigator.pop(context);
                },
              ),
              onTap: () async {
                await player
                    .play(AssetSource('sounds/notification_sound_1.wav'));
                notifier.updateCustomSound('notification_sound_1');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Bubble Pop'),
              leading: Radio<String?>(
                value: 'notification_sound_2',
                groupValue: currentPath,
                onChanged: (val) {
                  notifier.updateCustomSound(val);
                  Navigator.pop(context);
                },
              ),
              onTap: () async {
                await player
                    .play(AssetSource('sounds/notification_sound_2.wav'));
                notifier.updateCustomSound('notification_sound_2');
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
