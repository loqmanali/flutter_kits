/// Fails when two kits in this monorepo declare version ranges for the same
/// dependency that cannot both be satisfied.
///
/// Why this exists: the kits are independent packages, but apps consume several
/// of them at once. A pair of disjoint ranges (`^2.4.9` here, `^3.1.0` there)
/// is invisible in either pubspec on its own and only surfaces as an
/// unresolvable app — usually in someone else's project, long after the change.
///
/// Run from the repo root:
///   dart run tool/bin/check_constraints.dart
library;

import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

/// Only `dependencies` can conflict for a consumer.
///
/// A package's `dev_dependencies` are NOT installed by anyone depending on it,
/// so mismatched dev constraints across kits (e.g. flutter_lints ^4 vs ^6) are
/// repo-hygiene drift, never a resolution failure. Checking them here produced
/// false failures, so they are reported separately as a warning.
const _dependencySections = ['dependencies'];
const _devSection = 'dev_dependencies';

/// Packages supplied by the SDK — they carry no version and never conflict.
const _sdkPackages = {'flutter', 'flutter_test', 'flutter_localizations'};

/// Kits excluded from the check, each with the reason it is exempt.
///
/// An entry here is debt, not an exoneration: it is printed on every run so
/// it stays visible. Remove the entry as soon as the kit is fixed.
const _excluded = <String, String>{
  'commerce_kit': 'declares flutter_riverpod ^2.4.9 while the rest of the repo '
      'is on 3.x, and its sources sit outside lib/ so it is not consumable as '
      'a package. Needs a real migration, not a constraint bump.',
};

void main(List<String> args) {
  final root = Directory(args.isEmpty ? '.' : args.first);

  // dependency name -> list of (kit, constraint)
  final declarations = <String, List<({String kit, VersionConstraint range})>>{};
  final devDeclarations = <String, List<({String kit, String raw})>>{};
  final unparsed = <String>[];

  for (final entity in root.listSync().whereType<Directory>()) {
    final kit = entity.uri.pathSegments.where((s) => s.isNotEmpty).last;
    if (kit.startsWith('.') || kit == 'tool') continue;
    if (_excluded.containsKey(kit)) continue;

    final pubspec = File('${entity.path}/pubspec.yaml');
    if (!pubspec.existsSync()) continue;

    final doc = loadYaml(pubspec.readAsStringSync());
    if (doc is! YamlMap) continue;

    final devDeps = doc[_devSection];
    if (devDeps is YamlMap) {
      devDeps.forEach((name, spec) {
        if (spec is! String || _sdkPackages.contains(name)) return;
        if (spec.trim() == 'any' || spec.trim().isEmpty) return;
        (devDeclarations[name as String] ??= []).add((kit: kit, raw: spec));
      });
    }

    for (final section in _dependencySections) {
      final deps = doc[section];
      if (deps is! YamlMap) continue;

      deps.forEach((name, spec) {
        // Only plain "name: <constraint>" entries are comparable. A git/path
        // entry is a YamlMap and pins a source, not a range.
        if (spec is! String || _sdkPackages.contains(name)) return;
        if (spec.trim() == 'any' || spec.trim().isEmpty) return;
        try {
          (declarations[name as String] ??= []).add(
            (kit: kit, range: VersionConstraint.parse(spec)),
          );
        } on FormatException {
          unparsed.add('$kit: $name: $spec');
        }
      });
    }
  }

  final conflicts = <String>[];

  for (final entry in declarations.entries) {
    final declared = entry.value;
    if (declared.length < 2) continue;

    for (var i = 0; i < declared.length; i++) {
      for (var j = i + 1; j < declared.length; j++) {
        final a = declared[i];
        final b = declared[j];
        // `isEmpty` on the intersection is the whole test: two ranges that
        // share no version can never resolve together in one app.
        if (a.range.intersect(b.range).isEmpty) {
          conflicts.add(
            '  ${entry.key}\n'
            '    ${a.kit}: ${a.range}\n'
            '    ${b.kit}: ${b.range}',
          );
        }
      }
    }
  }

  if (unparsed.isNotEmpty) {
    stderr.writeln('Unparseable constraints (not checked):');
    for (final line in unparsed) {
      stderr.writeln('  $line');
    }
    stderr.writeln('');
  }

  for (final entry in _excluded.entries) {
    stdout.writeln('SKIPPED ${entry.key}: ${entry.value}\n');
  }

  // Hygiene only — never a failure, for the reason documented on _devSection.
  for (final entry in devDeclarations.entries) {
    final distinct = entry.value.map((d) => d.raw).toSet();
    if (distinct.length < 2) continue;
    final byKit =
        entry.value.map((d) => '${d.kit}: ${d.raw}').join(', ');
    stdout.writeln('drift (dev_dependencies, harmless): ${entry.key} — $byKit');
  }

  if (conflicts.isEmpty) {
    stdout.writeln(
      'OK — ${declarations.length} shared dependencies, no disjoint ranges.\n'
      'Note: only DECLARED constraints are compared. A conflict reached '
      'through a transitive dependency still shows up at `pub get` time.',
    );
    return;
  }

  stderr.writeln('Conflicting version ranges across kits:\n');
  stderr.writeln(conflicts.join('\n\n'));
  stderr.writeln(
    '\nApps consuming both kits in a pair above cannot resolve. '
    'Widen one range so they overlap.',
  );
  exit(1);
}
