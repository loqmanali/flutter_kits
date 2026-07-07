import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';

import 'comparator.dart';
import 'config.dart';
import 'policy.dart';

/// Performs the version-check against the App Store / Play Store.
///
/// Wraps the `upgrader` package and normalises the result into a
/// [ForceUpdatePolicy]. Most consumers should use `ForceUpdateGate`
/// instead — this class is useful when integrating with custom state
/// management.
class ForceUpdateService {
  const ForceUpdateService({this.config = const ForceUpdateConfig()});

  final ForceUpdateConfig config;

  Future<ForceUpdatePolicy> resolvePolicy() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final fallbackUrl = config.fallbackStoreUrl ?? '';

    if (!Platform.isAndroid && !Platform.isIOS) {
      return ForceUpdatePolicy(
        updateRequired: config.debugAlwaysShow,
        currentVersion: packageInfo.version,
        latestVersion: null,
        storeUrl: fallbackUrl,
      );
    }

    try {
      final upgrader = Upgrader(
        debugLogging: config.debugLogging,
        debugDisplayAlways: config.debugAlwaysShow,
        durationUntilAlertAgain: Duration.zero,
        countryCode: config.countryCode,
        minAppVersion: config.minAppVersion,
      );
      await upgrader.initialize();

      final storeVersion = upgrader.currentAppStoreVersion;
      final installed =
          upgrader.currentInstalledVersion ?? packageInfo.version;
      final storeUrl = upgrader.currentAppStoreListingURL ?? fallbackUrl;
      final releaseNotes =
          config.includeReleaseNotes ? upgrader.releaseNotes : null;
      final osBelowMinimum = _isOsBelowMinimum(config.minOsVersion);

      final compare = config.versionComparator ?? defaultVersionComparator;

      var required = false;
      if (config.debugAlwaysShow) {
        required = true;
      } else if (osBelowMinimum) {
        required = true;
      } else if (storeVersion != null && storeVersion.isNotEmpty) {
        required = compare(installed, storeVersion) < 0;
      }
      if (!required &&
          config.minAppVersion != null &&
          config.minAppVersion!.isNotEmpty) {
        required = compare(installed, config.minAppVersion!) < 0;
      }

      return ForceUpdatePolicy(
        updateRequired: required,
        currentVersion: installed,
        latestVersion: storeVersion,
        storeUrl: storeUrl,
        releaseNotes: releaseNotes,
        osBelowMinimum: osBelowMinimum,
      );
    } catch (error, stackTrace) {
      if (config.debugLogging) {
        debugPrint('[ForceUpdateGate] check failed: $error\n$stackTrace');
      }
      return ForceUpdatePolicy(
        updateRequired: config.debugAlwaysShow,
        currentVersion: packageInfo.version,
        latestVersion: null,
        storeUrl: fallbackUrl,
      );
    }
  }

  bool _isOsBelowMinimum(String? minOsVersion) {
    if (minOsVersion == null || minOsVersion.isEmpty) return false;
    final raw = Platform.operatingSystemVersion;
    final extracted = _extractVersionNumber(raw);
    if (extracted == null) return false;
    final compare = config.versionComparator ?? defaultVersionComparator;
    return compare(extracted, minOsVersion) < 0;
  }

  static String? _extractVersionNumber(String value) {
    final match = RegExp(r'(\d+(?:\.\d+){0,3})').firstMatch(value);
    return match?.group(1);
  }
}
