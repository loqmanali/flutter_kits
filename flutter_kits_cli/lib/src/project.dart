import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'catalog.g.dart';

/// Thrown when the CLI can't do what was asked; the runner prints the message
/// and exits non-zero rather than dumping a stack trace at the user.
class CliException implements Exception {
  CliException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// How a kit should be wired into the target project.
enum InstallSource {
  /// `git:` with a pinned `ref` — what a consuming app should use.
  git,

  /// `path:` into a local checkout — for working on the kits themselves.
  path,
}

/// The Flutter project the CLI is operating on.
class Project {
  Project._(this.root, this._pubspecFile, this._document);

  /// Finds the nearest enclosing project by walking up for a pubspec.yaml.
  ///
  /// Walking up means `fkit add` works from `lib/features/whatever`, the way
  /// git does — not just from the project root.
  factory Project.locate([String? from]) {
    var dir = Directory(from ?? Directory.current.path).absolute;

    while (true) {
      final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        final text = pubspec.readAsStringSync();
        if (loadYaml(text) is! YamlMap) {
          throw CliException('${pubspec.path} is not valid YAML.');
        }
        return Project._(dir.path, pubspec, YamlEditor(text));
      }

      final parent = dir.parent;
      if (parent.path == dir.path) {
        throw CliException(
          'No pubspec.yaml found here or in any parent directory.\n'
          'Run this from inside a Flutter project.',
        );
      }
      dir = parent;
    }
  }

  final String root;
  final File _pubspecFile;
  final YamlEditor _document;

  YamlMap get _map => _document.parseAt([]) as YamlMap;

  String get name => _map['name'] as String? ?? p.basename(root);

  /// Kits already declared under `dependencies`, by name.
  Map<String, YamlNode> get installedKits {
    final deps = _map['dependencies'];
    if (deps is! YamlMap) return {};

    return {
      for (final entry in deps.nodes.entries)
        if (kCatalog.any((k) => k.name == entry.key.toString()))
          entry.key.toString(): entry.value,
    };
  }

  bool hasDependency(String package) {
    final deps = _map['dependencies'];
    return deps is YamlMap && deps.containsKey(package);
  }

  /// Adds or replaces a kit dependency. Returns false when nothing changed.
  bool addKit(
    String kit, {
    required InstallSource source,
    required String ref,
    String? localPath,
    bool overwrite = false,
  }) {
    if (hasDependency(kit) && !overwrite) return false;

    // `dependencies:` may be absent or explicitly null in a fresh pubspec.
    if (_map['dependencies'] is! YamlMap) {
      _document.update(['dependencies'], {});
    }

    final value = switch (source) {
      InstallSource.git => {
          'git': {'url': kRepoUrl, 'path': kit, 'ref': ref},
        },
      InstallSource.path => {
          'path': p.join(localPath ?? '../flutter_kits', kit),
        },
    };

    _document.update(['dependencies', kit], value);
    return true;
  }

  /// Removes a kit dependency. Returns false if it wasn't there.
  bool removeKit(String kit) {
    if (!hasDependency(kit)) return false;
    _document.remove(['dependencies', kit]);
    return true;
  }

  /// Writes the edited pubspec back to disk.
  void save() => _pubspecFile.writeAsStringSync(_document.toString());

  /// The pubspec as it currently stands in memory — used for `--dry-run`.
  String get pubspecText => _document.toString();

  String get pubspecPath => _pubspecFile.path;
}
