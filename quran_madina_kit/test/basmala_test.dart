import 'package:flutter_test/flutter_test.dart';
import 'package:quran_madina_kit/src/ranges.dart';

BasmalaMode mode({
  int counter = 0,
  int words = 4,
  WordRange? display,
  WordRange? highlight,
  WordRange? error,
}) =>
    basmalaRenderMode(
      counter: counter,
      basmalaWords: words,
      displayRange: display,
      highlightRange: highlight,
      errorRange: error,
    );

void main() {
  test('no display range (plain page/verse render) shows the ligature', () {
    expect(mode().ligature, isTrue);
    expect(mode().mark, BasmalaMark.none);
  });

  test('all 4 words inside the selection shows the ligature', () {
    expect(mode(display: const WordRange(1, 10)).ligature, isTrue);
  });

  test('a partial selection shows the individual tokens', () {
    expect(mode(display: const WordRange(1, 2)).ligature, isFalse,
        reason: 'words 1-2 of 4 — the selection must stay visible');
    expect(mode(display: const WordRange(3, 8)).ligature, isFalse);
  });

  test('a selection that misses the basmala entirely shows tokens', () {
    expect(mode(counter: 10, display: const WordRange(1, 5)).ligature, isFalse);
  });

  test('a mark covering all 4 words keeps the ligature and marks it', () {
    final m =
        mode(display: const WordRange(1, 10), highlight: const WordRange(1, 4));
    expect(m.ligature, isTrue);
    expect(m.mark, BasmalaMark.highlight);
  });

  test('a mark cutting into only some words forces the tokens', () {
    expect(
        mode(display: const WordRange(1, 10), highlight: const WordRange(2, 3))
            .ligature,
        isFalse);
    expect(
        mode(display: const WordRange(1, 10), error: const WordRange(4, 6))
            .ligature,
        isFalse);
  });

  test('a mark that misses the basmala leaves the ligature unmarked', () {
    final m =
        mode(display: const WordRange(1, 10), highlight: const WordRange(6, 8));
    expect(m.ligature, isTrue);
    expect(m.mark, BasmalaMark.none);
  });

  test('error wins over highlight when both fully cover it', () {
    final m = mode(
      display: const WordRange(1, 10),
      highlight: const WordRange(1, 4),
      error: const WordRange(1, 4),
    );
    expect(m.mark, BasmalaMark.error);
  });

  test('respects a non-zero running counter', () {
    // Counter 9 means the basmala occupies words 10..13.
    expect(mode(counter: 9, display: const WordRange(1, 14)).ligature, isTrue);
    expect(mode(counter: 9, display: const WordRange(1, 12)).ligature, isFalse);
  });
}
