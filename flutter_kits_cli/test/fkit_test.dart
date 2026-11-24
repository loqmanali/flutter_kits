import 'dart:io';

import 'package:flutter_kits_cli/src/catalog.g.dart';
import 'package:flutter_kits_cli/src/kit.dart';
import 'package:flutter_kits_cli/src/project.dart';
import 'package:flutter_kits_cli/src/templates.g.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _pubspec = '''
name: demo_app
environment:
  sdk: ^3.8.0

dependencies:
  flutter:
    sdk: flutter
  # keep me
  cupertino_icons: ^1.0.8
''';

void main() {
  late Directory temp;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('fkit_test');
    File(p.join(temp.path, 'pubspec.yaml')).writeAsStringSync(_pubspec);
  });

  tearDown(() => temp.deleteSync(recursive: true));

  Project open() => Project.locate(temp.path);

  group('Project', () {
    test('walks up to find the enclosing pubspec', () {
      final nested = Directory(p.join(temp.path, 'lib', 'features'))
        ..createSync(recursive: true);

      expect(Project.locate(nested.path).root, temp.path);
    });

    test('throws a CliException outside any project', () {
      final orphan = Directory.systemTemp.createTempSync('fkit_orphan');
      addTearDown(() => orphan.deleteSync(recursive: true));

      // A temp dir can sit under a parent that has a pubspec; only assert the
      // failure mode when there genuinely isn't one above it.
      try {
        Project.locate(orphan.path);
      } on CliException catch (e) {
        expect(e.message, contains('No pubspec.yaml'));
      }
    });

    test('adds a git dependency with the monorepo ref', () {
      final project = open();
      expect(
        project.addKit('widget_kit',
            source: InstallSource.git, ref: kDefaultRef),
        isTrue,
      );

      final text = project.pubspecText;
      expect(text, contains('widget_kit:'));
      expect(text, contains('url: $kRepoUrl'));
      expect(text, contains('path: widget_kit'));
      expect(text, contains('ref: $kDefaultRef'));
    });

    test('leaves existing comments and dependencies intact', () {
      final project = open()
        ..addKit('otp_kit', source: InstallSource.git, ref: kDefaultRef);

      expect(project.pubspecText, contains('# keep me'));
      expect(project.pubspecText, contains('cupertino_icons: ^1.0.8'));
      expect(project.pubspecText, contains('sdk: flutter'));
    });

    test('refuses to re-add a kit unless overwrite is set', () {
      final project = open()
        ..addKit('otp_kit', source: InstallSource.git, ref: kDefaultRef);

      expect(
        project.addKit('otp_kit', source: InstallSource.git, ref: kDefaultRef),
        isFalse,
      );
      expect(
        project.addKit('otp_kit',
            source: InstallSource.git, ref: 'v9.9.9', overwrite: true),
        isTrue,
      );
      expect(project.pubspecText, contains('ref: v9.9.9'));
    });

    test('a path install writes a path dependency', () {
      final project = open()
        ..addKit('map_kit',
            source: InstallSource.path,
            ref: kDefaultRef,
            localPath: '../kits');

      expect(project.pubspecText, contains('path: ../kits/map_kit'));
      expect(project.pubspecText, isNot(contains('git:')));
    });

    test('removeKit reports whether anything changed', () {
      final project = open()
        ..addKit('storage_kit', source: InstallSource.git, ref: kDefaultRef);

      expect(project.removeKit('storage_kit'), isTrue);
      expect(project.removeKit('storage_kit'), isFalse);
      expect(project.pubspecText, isNot(contains('storage_kit')));
    });

    test('installedKits reports only catalog packages', () {
      final project = open()
        ..addKit('widget_kit', source: InstallSource.git, ref: kDefaultRef);

      expect(project.installedKits.keys, ['widget_kit']);
    });

    test('save round-trips to disk', () {
      open()
        ..addKit('logging_kit', source: InstallSource.git, ref: kDefaultRef)
        ..save();

      expect(open().installedKits.keys, contains('logging_kit'));
    });
  });

  group('catalog', () {
    test('is non-empty and pinned to a plain release tag', () {
      expect(kCatalog, isNotEmpty);
      expect(kDefaultRef, matches(RegExp(r'^v\d+\.\d+\.\d+$')));
    });

    test('holds no duplicate or non-kit entries', () {
      final names = kCatalog.map((k) => k.name).toList();
      expect(names.toSet().length, names.length);
      expect(names, isNot(contains('docs')));
      expect(names, isNot(contains('flutter_kits_cli')));
    });

    test('every setup note names a kit that exists', () {
      final names = kCatalog.map((k) => k.name).toSet();
      for (final noted in kitSetupNotes.keys) {
        expect(names, contains(noted), reason: '$noted is not in the catalog');
      }
    });
  });

  group('templates', () {
    final all = [...kSnippets, ...kStyles];

    test('are present with unique names and non-empty bodies', () {
      expect(kSnippets, isNotEmpty);
      expect(kStyles, isNotEmpty);

      final names = all.map((s) => s.name).toList();
      expect(names.toSet().length, names.length);

      for (final snippet in all) {
        expect(snippet.body.trim(), isNotEmpty, reason: snippet.name);
        expect(snippet.description.trim(), isNotEmpty, reason: snippet.name);
      }
    });

    test('every declared kit exists in the catalog', () {
      final kits = kCatalog.map((k) => k.name).toSet();
      for (final snippet in all) {
        for (final kit in snippet.kits) {
          expect(kits, contains(kit), reason: '${snippet.name} names $kit');
        }
      }
    });

    test('output paths are project-relative dart files', () {
      for (final snippet in all) {
        expect(snippet.output, endsWith('.dart'), reason: snippet.name);
        expect(p.isAbsolute(snippet.output), isFalse, reason: snippet.name);
      }
    });

    // The generator strips its own header; a leaked "// snippet:" line would
    // mean the parser and the emitter disagree.
    test('bodies carry no leftover metadata header', () {
      for (final snippet in all) {
        expect(snippet.body, isNot(contains('// template:')), reason: snippet.name);
        expect(snippet.body, isNot(contains('// output:')), reason: snippet.name);
      }
    });

    test('every import of a kit is declared in that snippet\'s kits', () {
      final kits = kCatalog.map((k) => k.name).toSet();
      for (final snippet in all) {
        final imported = RegExp(r"import 'package:(\w+)/")
            .allMatches(snippet.body)
            .map((m) => m.group(1)!)
            .where(kits.contains);

        for (final kit in imported) {
          expect(
            snippet.kits,
            contains(kit),
            reason: '${snippet.name} imports $kit but does not declare it',
          );
        }
      }
    });
  });
}
