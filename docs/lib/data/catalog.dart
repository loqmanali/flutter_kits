import 'package:flutter/material.dart';

import '../content/otp_kit/sections/otp_text_field_section.dart';
import '../content/otp_kit/sections/overview_section.dart';
import '../content/otp_kit/sections/programmatic_section.dart';
import '../content/otp_kit/sections/resend_button_section.dart';
import '../content/otp_kit/sections/themes_section.dart';
import '../content/otp_kit/sections/validation_section.dart';
import '../content/widget_kit/sections/app_button_section.dart';
import '../content/widget_kit/sections/overview_section.dart' as widget_kit;
import 'docs_catalog.dart';

/// The complete docs catalog — every kit and every page, in display order.
///
/// This is the single source of truth for the sidebar, the router, and the
/// search box. To document a new kit, append a [KitEntry] here; to add a page
/// to a kit, append a [PageEntry].
final List<KitEntry> catalog = [
  KitEntry(
    slug: 'widget_kit',
    title: 'widget_kit',
    blurb: 'Buttons, inputs, dialogs, feedback, media, menus, pickers, effects.',
    version: 'v1.2.0',
    icon: Icons.widgets_rounded,
    landing: () => const widget_kit.WidgetKitOverview(),
    pages: [
      PageEntry(
        slug: 'app-button',
        title: 'AppButton',
        description:
            'Ten Material 3 variants, three sizes, loading/disabled, FAB, Cupertino.',
        build: () => const AppButtonSection(),
      ),
    ],
  ),
  KitEntry(
    slug: 'otp_kit',
    title: 'otp_kit',
    blurb: 'OTP input: Riverpod state, validation, resend cooldown, theming, RTL.',
    version: 'v3.2.0',
    icon: Icons.password_rounded,
    landing: () => const OtpKitOverview(),
    pages: [
      PageEntry(
        slug: 'text-field',
        title: 'OTPTextField',
        description: 'The core input — length, input types, obscure, expand, RTL, error.',
        build: () => const OtpTextFieldSection(),
      ),
      PageEntry(
        slug: 'themes',
        title: 'Themes',
        description: '11 presets + OTPTheme.custom builder.',
        build: () => const ThemesSection(),
      ),
      PageEntry(
        slug: 'validation',
        title: 'Validation',
        description: 'Built-in checks + composable OTPValidationRule classes.',
        build: () => const ValidationSection(),
      ),
      PageEntry(
        slug: 'resend-button',
        title: 'OTPResendButton',
        description: 'Countdown, escalation, persisted resend cooldown.',
        build: () => const ResendButtonSection(),
      ),
      PageEntry(
        slug: 'programmatic',
        title: 'Programmatic control',
        description: 'Fill, error, clear, validate via OTPController + selectors.',
        build: () => const ProgrammaticSection(),
      ),
    ],
  ),
];
