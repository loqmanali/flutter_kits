import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/notification_priority.dart';
import '../../domain/entities/notification_target_type.dart';
import '../providers/notification_admin_provider.dart';

/// Page for composing and sending push notifications
class NotificationAdminPage extends ConsumerStatefulWidget {
  const NotificationAdminPage({super.key});

  @override
  ConsumerState<NotificationAdminPage> createState() =>
      _NotificationAdminPageState();
}

class _NotificationAdminPageState extends ConsumerState<NotificationAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _deviceTokenController = TextEditingController();
  final _dataKeyController = TextEditingController();
  final _dataValueController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    _deviceTokenController.dispose();
    _dataKeyController.dispose();
    _dataValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final composerState = ref.watch(notificationComposerProvider);
    final composerNotifier = ref.read(notificationComposerProvider.notifier);
    final topics = ref.watch(availableTopicsProvider);

    // Update controllers when state changes from external sources
    _titleController.text = composerState.title;
    _bodyController.text = composerState.body;
    _imageUrlController.text = composerState.imageUrl;
    _deviceTokenController.text = composerState.deviceToken ?? '';
    _dataKeyController.text = composerState.customDataKey ?? '';
    _dataValueController.text = composerState.customDataValue ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Send Notification',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        actions: [
          if (composerState.title.isNotEmpty || composerState.body.isNotEmpty)
            Container(
              margin: EdgeInsets.only(right: 16.w),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () {
                    composerNotifier.reset();
                    _titleController.clear();
                    _bodyController.clear();
                    _imageUrlController.clear();
                    _deviceTokenController.clear();
                    _dataKeyController.clear();
                    _dataValueController.clear();
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    child: Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20.r,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Error/Success messages
                if (composerState.errorMessage != null)
                  _buildMessageCard(
                    context,
                    composerState.errorMessage!,
                    MessageType.error,
                    showRetry: !composerState.isServiceInitialized &&
                        composerState.errorMessage!.contains('FCM Service'),
                  ),
                if (composerState.successMessage != null)
                  _buildMessageCard(
                    context,
                    composerState.successMessage!,
                    MessageType.success,
                  ),

                // Notification Content Section
                _buildSectionCard(
                  title: 'Notification Content',
                  icon: Icons.notifications,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field
                      _buildModernTextField(
                        controller: _titleController,
                        label: 'Title',
                        hint: 'Enter notification title',
                        icon: Icons.title,
                        onChanged: composerNotifier.updateTitle,
                        required: true,
                      ),
                      20.verticalSpace,
                      // Body field
                      _buildModernTextField(
                        controller: _bodyController,
                        label: 'Message',
                        hint: 'Enter notification message',
                        icon: Icons.message,
                        maxLines: 4,
                        onChanged: composerNotifier.updateBody,
                        required: true,
                      ),
                      20.verticalSpace,
                      // Image URL field
                      _buildModernTextField(
                        controller: _imageUrlController,
                        label: 'Image URL',
                        hint: 'https://example.com/image.png',
                        icon: Icons.image,
                        onChanged: composerNotifier.updateImageUrl,
                      ),
                    ],
                  ),
                ),
                24.verticalSpace,

                // Target Section
                _buildSectionCard(
                  title: 'Target Audience',
                  icon: Icons.group,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Target type selector
                      _buildModernTargetTypeSelector(
                        composerState.targetType,
                        composerNotifier.updateTargetType,
                      ),
                      20.verticalSpace,
                      // Topic selector (when targetType is topic)
                      if (composerState.targetType ==
                          NotificationTargetType.topic)
                        _buildModernTopicSelector(
                          topics,
                          composerState.selectedTopic,
                          composerNotifier.updateTopic,
                        ),
                      // Device token field (when targetType is singleDevice)
                      if (composerState.targetType ==
                          NotificationTargetType.singleDevice)
                        _buildModernTextField(
                          controller: _deviceTokenController,
                          label: 'Device Token',
                          hint: 'Enter FCM device token',
                          icon: Icons.phone_android,
                          onChanged: composerNotifier.updateDeviceToken,
                          required: true,
                        ),
                    ],
                  ),
                ),
                24.verticalSpace,

                // Priority Section
                _buildSectionCard(
                  title: 'Priority Level',
                  icon: Icons.tune,
                  subtitle:
                      'Choose the delivery priority for your notification',
                  child: _buildEnhancedPrioritySelector(
                    composerState.priority,
                    composerNotifier.updatePriority,
                  ),
                ),
                24.verticalSpace,

                // Custom Data Section
                _buildSectionCard(
                  title: 'Custom Data',
                  icon: Icons.data_object,
                  subtitle:
                      'Add custom key-value pairs to send with the notification',
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildModernTextField(
                          controller: _dataKeyController,
                          label: 'Key',
                          hint: 'e.g., screen',
                          icon: Icons.key,
                          onChanged: composerNotifier.updateCustomDataKey,
                        ),
                      ),
                      16.horizontalSpace,
                      Expanded(
                        child: _buildModernTextField(
                          controller: _dataValueController,
                          label: 'Value',
                          hint: 'e.g., /details',
                          icon: Icons.code,
                          onChanged: composerNotifier.updateCustomDataValue,
                        ),
                      ),
                    ],
                  ),
                ),
                32.verticalSpace,

                // Preview Section
                _buildSectionCard(
                  title: 'Preview',
                  icon: Icons.preview,
                  child: _buildModernNotificationPreview(composerState),
                ),
                40.verticalSpace,

                // Send Button
                _buildModernSendButton(composerState),
                32.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================
  // Modern UI Components
  // ===========================================

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.r,
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    if (subtitle != null) ...[
                      4.verticalSpace,
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          20.verticalSpace,
          child,
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required void Function(String) onChanged,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          required ? '$label *' : label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        8.verticalSpace,
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20.r,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          maxLines: maxLines,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
          onChanged: onChanged,
          validator: required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildModernTargetTypeSelector(
    NotificationTargetType selected,
    void Function(NotificationTargetType) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Target Type',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        12.verticalSpace,
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: NotificationTargetType.values.map((type) {
            final isSelected = selected == type;
            return GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  type.displayName,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildModernTopicSelector(
    List topics,
    String? selected,
    void Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Topic',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        12.verticalSpace,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: topics.map((topic) {
            final isSelected = selected == topic.key;
            return FilterChip(
              label: Text(topic.label),
              selected: isSelected,
              onSelected: (_) => onChanged(topic.key),
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
              avatar: isSelected
                  ? null
                  : Icon(
                      _getIconData(topic.icon),
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEnhancedPrioritySelector(
    FCMNotificationPriority selected,
    void Function(FCMNotificationPriority) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Priority cards with enhanced design
        ...FCMNotificationPriority.values.map((priority) {
          final isSelected = selected == priority;
          final colors = _getPriorityColors(priority);

          return GestureDetector(
            onTap: () => onChanged(priority),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors['background']
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected
                      ? colors['border']!
                      : Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colors['shadow']!.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Priority icon container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors['iconBg']
                          : Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      _getPriorityIcon(priority),
                      color: isSelected
                          ? colors['icon']
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 24.r,
                    ),
                  ),
                  16.horizontalSpace,
                  // Priority info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          priority.displayName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? colors['text']
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        4.verticalSpace,
                        Text(
                          _getPriorityDescription(priority),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isSelected
                                        ? colors['textSubtle']
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // Selection indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 24.r,
                    height: 24.r,
                    decoration: BoxDecoration(
                      color: isSelected ? colors['check'] : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? colors['check']!
                            : Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16.r,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Map<String, Color> _getPriorityColors(FCMNotificationPriority priority) {
    switch (priority) {
      case FCMNotificationPriority.high:
        return {
          'background': Colors.red.shade50,
          'border': Colors.red.shade300,
          'shadow': Colors.red,
          'iconBg': Colors.red.shade100,
          'icon': Colors.red.shade700,
          'text': Colors.red.shade900,
          'textSubtle': Colors.red.shade700,
          'check': Colors.red.shade600,
        };
      case FCMNotificationPriority.normal:
        return {
          'background': Colors.blue.shade50,
          'border': Colors.blue.shade300,
          'shadow': Colors.blue,
          'iconBg': Colors.blue.shade100,
          'icon': Colors.blue.shade700,
          'text': Colors.blue.shade900,
          'textSubtle': Colors.blue.shade700,
          'check': Colors.blue.shade600,
        };
      case FCMNotificationPriority.low:
        return {
          'background': Colors.grey.shade50,
          'border': Colors.grey.shade300,
          'shadow': Colors.grey,
          'iconBg': Colors.grey.shade100,
          'icon': Colors.grey.shade700,
          'text': Colors.grey.shade900,
          'textSubtle': Colors.grey.shade700,
          'check': Colors.grey.shade600,
        };
    }
  }

  String _getPriorityDescription(FCMNotificationPriority priority) {
    switch (priority) {
      case FCMNotificationPriority.high:
        return 'Immediate delivery with high visibility';
      case FCMNotificationPriority.normal:
        return 'Standard delivery timing';
      case FCMNotificationPriority.low:
        return 'Delivered when network conditions allow';
    }
  }

  Widget _buildModernNotificationPreview(NotificationComposerState state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: const BoxDecoration(
                  color: Color(0xFFF49B25), // Secondary brand color
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fastfood,
                  color: Colors.white,
                  size: 20.r,
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.title.isNotEmpty
                          ? state.title
                          : 'Notification Title',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.verticalSpace,
                    Text(
                      state.body.isNotEmpty ? state.body : 'Notification body',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                _formatTime(DateTime.now()),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          if (state.imageUrl.isNotEmpty) ...[
            16.verticalSpace,
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                state.imageUrl,
                height: 100.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100.h,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernSendButton(NotificationComposerState state) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: FilledButton(
        onPressed: state.isSending
            ? null
            : () {
                if (_formKey.currentState?.validate() ?? false) {
                  ref
                      .read(notificationComposerProvider.notifier)
                      .sendNotification();
                }
              },
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        child: state.isSending
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : const Text('Send Notification'),
      ),
    );
  }

  Widget _buildMessageCard(
    BuildContext context,
    String message,
    MessageType type, {
    bool showRetry = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = type == MessageType.error
        ? (isDark ? Colors.red.shade900 : Colors.red.shade50)
        : (isDark ? Colors.green.shade900 : Colors.green.shade50);
    final iconColor =
        type == MessageType.error ? Colors.red.shade700 : Colors.green.shade700;
    final icon = type == MessageType.error ? Icons.error : Icons.check_circle;
    final textColor = type == MessageType.error
        ? (isDark ? Colors.red.shade200 : Colors.red.shade900)
        : (isDark ? Colors.green.shade200 : Colors.green.shade900);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          12.horizontalSpace,
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          if (showRetry) ...[
            TextButton(
              onPressed: () {
                ref
                    .read(notificationComposerProvider.notifier)
                    .retryInitialization();
              },
              child: Text(
                'Retry',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            8.horizontalSpace,
          ],
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            color: iconColor,
            onPressed: () {
              ref.read(notificationComposerProvider.notifier).clearMessages();
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  IconData _getPriorityIcon(FCMNotificationPriority priority) {
    switch (priority) {
      case FCMNotificationPriority.high:
        return Icons.arrow_upward;
      case FCMNotificationPriority.normal:
        return Icons.remove;
      case FCMNotificationPriority.low:
        return Icons.arrow_downward;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'people':
        return Icons.people;
      case 'tag':
        return Icons.local_offer;
      case 'newspaper':
        return Icons.newspaper;
      case 'refresh':
        return Icons.refresh;
      case 'android':
        return Icons.android;
      case 'apple':
        return Icons.phone_iphone;
      default:
        return Icons.circle;
    }
  }
}

enum MessageType { error, success }
