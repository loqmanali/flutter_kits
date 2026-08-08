import 'package:flutter/material.dart';

/// The navigation + content catalog for the docs site.
///
/// Single source of truth: the sidebar, the router, and the search box all read
/// from [catalog]. To add a kit, append a [KitEntry] here; to add a page to a
/// kit, append a [PageEntry]. Nothing else needs to know about content.
///
/// Page builders are no-arg function tear-offs so the list stays `const`-ish
/// (each entry is constructed at runtime, but the structure is declarative).

/// One documented kit (e.g. otp_kit). Has a landing page + child pages.
class KitEntry {
  const KitEntry({
    required this.slug,
    required this.title,
    required this.blurb,
    required this.version,
    required this.icon,
    required this.landing,
    required this.pages,
  });

  /// URL segment, lowercase (e.g. 'otp_kit').
  final String slug;

  /// Display name (e.g. 'otp_kit').
  final String title;

  /// One-line description shown in the kit list + on its landing page.
  final String blurb;

  /// Version badge shown beside the title (cosmetic; from the kit's pubspec).
  final String version;

  /// Sidebar/list icon.
  final IconData icon;

  /// The landing page for the kit (overview, install, getting started).
  final Widget Function() landing;

  /// Child pages, in display order.
  final List<PageEntry> pages;
}

/// One page within a kit (e.g. "OTPTextField", "Themes", "Validation").
class PageEntry {
  const PageEntry({
    required this.slug,
    required this.title,
    required this.description,
    required this.build,
  });

  /// URL segment, lowercase + hyphens (e.g. 'text-field').
  final String slug;

  /// Sidebar label + page heading.
  final String title;

  /// Short subtitle shown under the title and in search results.
  final String description;

  /// Builds the page body (sans the page shell, which the router wraps).
  final Widget Function() build;

  /// Full route path: `/<kitSlug>/<slug>`.
  String routeFor(String kitSlug) => '/$kitSlug/$slug';
}
