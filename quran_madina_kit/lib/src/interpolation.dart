import 'repository.dart';
import 'source.dart';

/// Every font ships a pre-built DB at exactly these sizes.
const List<double> kAnchorSizes = [16, 24];

/// Accepted `fontSize` bounds; anything else falls back to [kDefaultFontSize].
const double kMinFontSize = 6;
const double kMaxFontSize = 100;
const double kDefaultFontSize = 16;

/// Header values re-targeting a nearest-anchor DB to a requested size.
class SizeOverrides {
  const SizeOverrides({
    required this.fontSize,
    required this.lineWidth,
    required this.stretchScale,
    required this.nearestAnchor,
  });

  /// The size actually rendered at.
  final double fontSize;

  /// The frame width for that size, read off the fitted line.
  final double lineWidth;

  /// Multiplier applied to every stored stretch factor.
  final double stretchScale;

  /// Which anchor's DB supplies the render data.
  final double nearestAnchor;
}

double clampFontSize(double requested, void Function(String) log) {
  if (requested < kMinFontSize || requested > kMaxFontSize) {
    log('font-size $requested outside ${kMinFontSize.round()}..'
        '${kMaxFontSize.round()}, using ${kDefaultFontSize.round()}');
    return kDefaultFontSize;
  }
  return requested;
}

/// Null for an anchor size (its DB is used as-is).
///
/// The per-size line widths are hand-tuned, NOT proportional to the size (Hafs
/// is 270@16 but 410@24), so the width for size S is read off the line fitted
/// through the two anchor points. Glyph widths DO grow proportionally with the
/// size while that fitted width does not, so every justified line's scaleX gets
/// one global correction:
///
///     natural width at S  = natural(anchor) * S / anchor
///     needed stretch at S = stored * lw(S) * anchor / (lw(anchor) * S)
SizeOverrides? interpolate({
  required double requested,
  required double lineWidth16,
  required double lineWidth24,
}) {
  final lo = kAnchorSizes[0];
  final hi = kAnchorSizes[1];
  if (requested == lo || requested == hi) return null;

  final lw =
      (lineWidth16 + (lineWidth24 - lineWidth16) * (requested - lo) / (hi - lo))
          .roundToDouble();
  // A tie prefers the lower anchor, matching the web's `S - lo <= hi - S`.
  final nearest = (requested - lo <= hi - requested) ? lo : hi;
  final nearestWidth = nearest == lo ? lineWidth16 : lineWidth24;

  return SizeOverrides(
    fontSize: requested,
    lineWidth: lw,
    stretchScale: (lw * nearest) / (nearestWidth * requested),
    nearestAnchor: nearest,
  );
}

/// Fetches both anchor headers and fits the requested size between them.
///
/// Returns null when the size is already an anchor, or when either anchor is
/// missing — the caller then falls back to [kDefaultFontSize].
Future<SizeOverrides?> resolveSizeOverrides({
  required MadinaSource source,
  required String name,
  required String font,
  required double requested,
  void Function(String)? log,
}) async {
  final logger = log ?? (String _) {};
  if (kAnchorSizes.contains(requested)) return null;

  final widths = <double, double>{};
  for (final size in kAnchorSizes) {
    final stem = MadinaDb.stemFor(name, font, size);
    // The small sharded manifest when available, else the monolith (large, but
    // it lands in the same cache the render will read from anyway).
    final header = await source.loadJson('db/$stem/manifest.json') ??
        await source.loadJson('db/$stem.json');
    if (header == null) {
      logger('missing anchor DB for font-size interpolation ($stem)');
      return null;
    }
    widths[size] = (header['line_width'] as num).toDouble();
  }

  final overrides = interpolate(
    requested: requested,
    lineWidth16: widths[kAnchorSizes[0]]!,
    lineWidth24: widths[kAnchorSizes[1]]!,
  );
  if (overrides != null) {
    logger('font-size $requested interpolated from ${kAnchorSizes[0]}px/'
        '${kAnchorSizes[1]}px anchors: line_width ${overrides.lineWidth}, '
        'render data from ${overrides.nearestAnchor}px');
  }
  return overrides;
}
