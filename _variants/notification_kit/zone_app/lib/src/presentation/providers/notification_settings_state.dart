import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_settings.dart';
import '../../domain/failures/notification_failures.dart';

class NotificationSettingsState extends Equatable {
  final NotificationSettings settings;
  final bool isLoading;
  final bool isSaving;
  final bool isSavingNotification;
  final bool isSavingSound;
  final bool isSavingVibration;
  final NotificationFailure? error;

  const NotificationSettingsState({
    this.settings = const NotificationSettings(),
    this.isLoading = false,
    this.isSaving = false,
    this.isSavingNotification = false,
    this.isSavingSound = false,
    this.isSavingVibration = false,
    this.error,
  });

  NotificationSettingsState copyWith({
    NotificationSettings? settings,
    bool? isLoading,
    bool? isSaving,
    bool? isSavingNotification,
    bool? isSavingSound,
    bool? isSavingVibration,
    NotificationFailure? error,
  }) {
    return NotificationSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSavingNotification: isSavingNotification ?? this.isSavingNotification,
      isSavingSound: isSavingSound ?? this.isSavingSound,
      isSavingVibration: isSavingVibration ?? this.isSavingVibration,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        settings,
        isLoading,
        isSaving,
        isSavingNotification,
        isSavingSound,
        isSavingVibration,
        error,
      ];
}
