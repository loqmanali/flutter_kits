/// Central API configuration for the Granzia Health Connect backend.
///
/// All paths are relative to the base URL configured on
/// [ApiKitRuntime.baseUrl]. The legacy `baseUrl` constant below is kept for
/// the bootstrap flow that hasn't migrated to the runtime yet.
abstract class ApiConfig {
  ApiConfig._();

  /// Default base URL used when `.env` is not loaded or `API_BASE_URL` is
  /// missing. The app overrides this at startup via [configureApiKit] using
  /// the value from `.env`.
  static const String baseUrl = 'http://192.168.1.3:8088/api/v1/';

  // ── Health (Public) ────────────────────────────────────────────────────────
  static const String health = 'health';

  // ── Auth (Public) ──────────────────────────────────────────────────────────
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String forgotPassword = 'auth/forgot-password';
  static const String resetPassword = 'auth/reset-password';

  // ── Auth (Protected) ───────────────────────────────────────────────────────
  static const String me = 'auth/me';
  static const String logout = 'auth/logout';
  static const String refreshToken = 'auth/refresh-token';
  static const String updateProfile = 'auth/profile';
  static const String changePassword = 'auth/change-password';
  static const String deleteAccount = 'auth/account';
  static const String registerFcmToken = 'auth/fcm-token';
  static const String uploadAvatar = 'auth/avatar';

  // ── Readings ───────────────────────────────────────────────────────────────
  static const String readings = 'readings';
  static const String readingsBulk = 'readings/bulk';
  static const String readingsStats = 'readings/stats';
  static String reading(String id) => 'readings/$id';

  // ── OCR ────────────────────────────────────────────────────────────────────
  static const String ocrScan = 'ocr/scan';
  static const String ocrQuota = 'ocr/quota';
  static const String ocrScans = 'ocr/scans';

  // ── Notifications ──────────────────────────────────────────────────────────
  static const String notifications = 'notifications';
  static const String notificationsSend = 'notifications/send';
  static const String notificationsReport = 'notifications/report';
  static String notificationRead(String id) => 'notifications/$id/read';

  // ── Reminders ──────────────────────────────────────────────────────────────
  static const String reminderPreferences =
      'notifications/reminders/preferences';
  static const String reminders = 'notifications/reminders';
  static String reminder(String id) => 'notifications/reminders/$id';

  // ── Support Tickets ────────────────────────────────────────────────────────
  static const String supportTickets = 'support/tickets';
  static String supportTicket(String id) => 'support/tickets/$id';
  static String supportTicketMessages(String id) =>
      'support/tickets/$id/messages';

  // ── Weekly Reports ─────────────────────────────────────────────────────────
  static const String weeklyReports = 'reports/weekly';
  static String weeklyReportDownload(String id) =>
      'reports/weekly/$id/download';

  // ── Content (Public) ───────────────────────────────────────────────────────
  static const String helpCategories = 'content/help/categories';
  static const String helpArticles = 'content/help/articles';
  static String helpArticle(String id) => 'content/help/articles/$id';
  static String contentPage(String slug) => 'content/$slug';

  // ── App Settings (public keys only) ───────────────────────────────────────
  static const String appSettings = 'settings';

  // ── Health Thresholds (Public — no auth required) ─────────────────────────
  static const String healthThresholds = 'health-thresholds';

  // ── Admin ──────────────────────────────────────────────────────────────────
  static const String adminStats = 'admin/stats';
  static const String adminStatsReadings = 'admin/stats/readings';
  static const String adminStatsUsers = 'admin/stats/users';

  static const String adminUsers = 'admin/users';
  static String adminUser(String id) => 'admin/users/$id';
  static String adminUserDeactivate(String id) => 'admin/users/$id/deactivate';
  static String adminUserActivate(String id) => 'admin/users/$id/activate';
  static String adminUserResetPassword(String id) =>
      'admin/users/$id/reset-password';
  static String adminUserReadings(String userId) =>
      'admin/users/$userId/readings';
  static String adminUserReadingsStats(String userId) =>
      'admin/users/$userId/readings/stats';
  static String adminReading(String id) => 'admin/readings/$id';

  static const String adminNotifications = 'admin/notifications';
  static const String adminNotificationsBroadcast =
      'admin/notifications/broadcast';

  static const String adminSettings = 'admin/settings';
  static String adminSetting(String key) => 'admin/settings/$key';

  static const String adminSupportTickets = 'admin/support/tickets';
  static String adminSupportTicket(String id) => 'admin/support/tickets/$id';
  static String adminSupportTicketStatus(String id) =>
      'admin/support/tickets/$id/status';
  static String adminSupportTicketMessages(String id) =>
      'admin/support/tickets/$id/messages';

  static const String adminReports = 'admin/reports';
  static String adminReport(String id) => 'admin/reports/$id';
  static String adminReportDownload(String id) => 'admin/reports/$id/download';
}
