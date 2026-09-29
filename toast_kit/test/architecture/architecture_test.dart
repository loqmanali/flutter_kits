import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the boundaries the rest of this package assumes: domain and
/// application stay pure Dart, presentation widgets are classes (never
/// `Widget _helper()` methods), only the barrel is public API, and no
/// `left`/`right` geometry sneaks into presentation.
/// Strips `//` line comments so a doc comment that *names* a banned pattern
/// (to explain why the code avoids it) cannot trip a check meant for code.
String _stripLineComments(String source) => source.split('\n').map((line) {
      final index = line.indexOf('//');
      return index == -1 ? line : line.substring(0, index);
    }).join('\n');

void main() {
  final libDir = Directory('lib');
  final domainAndApplication = <File>[
    ...Directory('lib/src/domain').listSync(recursive: true).whereType<File>(),
    ...Directory('lib/src/application')
        .listSync(recursive: true)
        .whereType<File>(),
  ];
  final presentationFiles = Directory('lib/src/presentation')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('domain and application never import package:flutter', () {
    final offenders = <String>[];
    for (final file in domainAndApplication) {
      if (!file.path.endsWith('.dart')) continue;
      final content = _stripLineComments(file.readAsStringSync());
      if (content.contains('package:flutter')) offenders.add(file.path);
    }
    expect(offenders, isEmpty,
        reason: 'Pure-Dart layers importing Flutter: $offenders');
  });

  test('no Widget _helper() methods in lib/src', () {
    final regex = RegExp(r'^\s*Widget\??\s+(?!build\b)[A-Za-z_]\w*\s*\(',
        multiLine: true);
    final offenders = <String>[];
    for (final file in libDir.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      // `lib/src/presentation/previews/` is exempt: `package:flutter/
      // widget_previews.dart`'s own `@Preview` contract requires top-level
      // (or static) functions returning `Widget`, not widget classes — the
      // rule this test guards does not apply to that one, SDK-mandated
      // shape.
      if (file.path.contains(
          '${Platform.pathSeparator}previews${Platform.pathSeparator}')) {
        continue;
      }
      final content = _stripLineComments(file.readAsStringSync());
      if (regex.hasMatch(content)) offenders.add(file.path);
    }
    expect(offenders, isEmpty,
        reason: 'Widget-returning methods found in: $offenders');
  });

  test('only toast_kit.dart is public API under lib/', () {
    final topLevel = libDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => f.path)
        .toList();
    expect(topLevel, equals(<String>['lib/toast_kit.dart']));
  });

  test('no left/right EdgeInsets or Alignment in presentation', () {
    final regex = RegExp(
        r'EdgeInsets\.(only|fromLTRB)\([^)]*\b(left|right)\s*:|'
        r'Alignment\.(topLeft|topRight|bottomLeft|bottomRight|centerLeft|centerRight)\b');
    final offenders = <String>[];
    for (final file in presentationFiles) {
      final content = _stripLineComments(file.readAsStringSync());
      if (regex.hasMatch(content)) offenders.add(file.path);
    }
    expect(offenders, isEmpty,
        reason: 'left/right geometry found in: $offenders');
  });

  test('no print() in lib/', () {
    final regex = RegExp(r'(?<![\w.])print\s*\(');
    final offenders = <String>[];
    for (final file in libDir.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final content = _stripLineComments(file.readAsStringSync());
      if (regex.hasMatch(content)) offenders.add(file.path);
    }
    expect(offenders, isEmpty, reason: 'print() found in: $offenders');
  });
}
