import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/notification_settings.dart';
import '../../domain/repositories/notification_settings_repository.dart';
import 'notification_providers.dart';
import 'notification_settings_state.dart';

class NotificationSettingsNotifier extends Notifier<NotificationSettingsState> {
  late final NotificationSettingsRepository _repository;

  @override
  NotificationSettingsState build() {
    _repository = ref.watch(notificationSettingsRepositoryProvider);
    _loadSettings();
    return const NotificationSettingsState(isLoading: true);
  }

  Future<void> _loadSettings() async {
    final result = await _repository.getSettings();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (settings) =>
          state = state.copyWith(isLoading: false, settings: settings),
    );
  }

  Future<void> toggleNotification(bool enabled) async {
    state = state.copyWith(isSavingNotification: true);
    final newSettings = state.settings.copyWith(enabled: enabled);
    await _saveSettings(newSettings, isNotification: true);
  }

  Future<void> toggleSound(bool enabled) async {
    state = state.copyWith(isSavingSound: true);
    final newSettings = state.settings.copyWith(soundEnabled: enabled);
    await _saveSettings(newSettings, isSound: true);
  }

  Future<void> toggleVibration(bool enabled) async {
    state = state.copyWith(isSavingVibration: true);
    final newSettings = state.settings.copyWith(vibrationEnabled: enabled);
    await _saveSettings(newSettings, isVibration: true);
  }

  Future<void> updateCustomSound(String? soundPath) async {
    state = state.copyWith(isSavingSound: true);
    final newSettings = state.settings.copyWith(
      customSoundPath: soundPath,
      clearCustomSoundPath: soundPath == null,
    );
    await _saveSettings(newSettings, isSound: true);
  }

  Future<void> toggleChannel(String channelId, bool enabled) async {
    state = state.copyWith(isSaving: true);
    final result = await _repository.updateChannelSetting(channelId, enabled);
    result.fold(
      (failure) => state = state.copyWith(isSaving: false, error: failure),
      (_) {
        final newChannels =
            Map<String, bool>.from(state.settings.channelSettings);
        newChannels[channelId] = enabled;
        state = state.copyWith(
          isSaving: false,
          settings: state.settings.copyWith(channelSettings: newChannels),
        );
      },
    );
  }

  Future<void> _saveSettings(
    NotificationSettings newSettings, {
    bool isNotification = false,
    bool isSound = false,
    bool isVibration = false,
  }) async {
    final result = await _repository.saveSettings(newSettings);
    result.fold(
      (failure) => state = state.copyWith(
        isSavingNotification: false,
        isSavingSound: false,
        isSavingVibration: false,
        error: failure,
      ),
      (_) => state = state.copyWith(
        isSavingNotification: false,
        isSavingSound: false,
        isSavingVibration: false,
        settings: newSettings,
      ),
    );
  }
}
