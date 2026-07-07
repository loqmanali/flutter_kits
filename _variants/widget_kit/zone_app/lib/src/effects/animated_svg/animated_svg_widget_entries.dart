import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

enum AnimatedSvgAnimationType {
  strokeToFill,
  fadeIn,
  scaleIn,
  scaleInBounce,
  slideIn,
  typewriter,
  pulse,
  shimmer,
  morphIn,
  staggeredPaths,
  glowPulse,
  elasticScale,
  rotateIn,
  flipIn,
  waveIn,
  logoReveal,
  glitchReveal,
  fragmentAssemble,
  splitMerge,
  rotate3D,
  flip3D,
  perspective3D,
  cubeRotate,
  cardFlip,
  swing3D,
  tumble3D,
}

enum AnimatedSvgSlideDirection {
  fromLeft,
  fromRight,
  fromTop,
  fromBottom,
}

enum AnimatedSvgFillDirection {
  bottomToTop,
  topToBottom,
  leftToRight,
  rightToLeft,
}

class SvgVector {
  const SvgVector({
    required this.viewBoxWidth,
    required this.viewBoxHeight,
    required this.paths,
  });

  final double viewBoxWidth;
  final double viewBoxHeight;
  final List<SvgPath> paths;

  static SvgVector parse(String raw) {
    final document = XmlDocument.parse(raw);
    final svgElement =
        document.findElements('svg').firstOrNull ?? document.rootElement;

    final viewBox = _parseViewBox(svgElement);
    final width = viewBox?.width ??
        _parseDimension(svgElement.getAttribute('width')) ??
        100;
    final height = viewBox?.height ??
        _parseDimension(svgElement.getAttribute('height')) ??
        100;

    final paths = <SvgPath>[];
    _collectPaths(svgElement, null, paths);

    return SvgVector(
      viewBoxWidth: width,
      viewBoxHeight: height,
      paths: paths,
    );
  }

  static _ViewBox? _parseViewBox(XmlElement svgElement) {
    final viewBoxAttr = svgElement.getAttribute('viewBox');
    if (viewBoxAttr == null) {
      return null;
    }
    final values = viewBoxAttr
        .split(RegExp(r'[ ,]+'))
        .where((value) => value.isNotEmpty)
        .map(double.tryParse)
        .whereType<double>()
        .toList();
    if (values.length != 4) {
      return null;
    }
    return _ViewBox(width: values[2], height: values[3]);
  }

  static double? _parseDimension(String? raw) {
    if (raw == null) return null;
    final cleaned = raw.replaceAll(RegExp(r'[^0-9.]+'), '');
    return double.tryParse(cleaned);
  }

  static void _collectPaths(
    XmlElement element,
    Color? inheritedFill,
    List<SvgPath> collector,
  ) {
    if (element.name.local == 'path') {
      final data = element.getAttribute('d');
      if (data != null && data.trim().isNotEmpty) {
        final path = parseSvgPathData(data);
        final fill = _resolveFillColor(element, inheritedFill);
        collector.add(SvgPath(path: path, fillColor: fill));
      }
      return;
    }

    final nextInheritedFill = _resolveFillColor(element, inheritedFill);
    for (final node in element.children) {
      if (node is XmlElement) {
        _collectPaths(node, nextInheritedFill, collector);
      }
    }
  }

  static Color _resolveFillColor(XmlElement element, Color? fallback) {
    final fillAttr = element.getAttribute('fill');
    final parsedFill = _parseColor(fillAttr);
    if (parsedFill != null) {
      return parsedFill;
    }

    final styleAttr = element.getAttribute('style');
    if (styleAttr != null) {
      final styleMap = styleAttr
          .split(';')
          .map((entry) => entry.trim())
          .where((entry) => entry.contains(':'))
          .fold<Map<String, String>>({}, (map, entry) {
        final parts = entry.split(':');
        if (parts.length == 2) {
          map[parts[0].trim()] = parts[1].trim();
        }
        return map;
      });
      final styleFill = styleMap['fill'];
      final parsedStyleFill = _parseColor(styleFill);
      if (parsedStyleFill != null) {
        return parsedStyleFill;
      }
    }

    return fallback ?? Colors.black;
  }

  static Color? _parseColor(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    if (normalized.isEmpty || normalized == 'none') {
      return Colors.transparent;
    }
    if (normalized.startsWith('#')) {
      final hex = normalized.substring(1);
      if (hex.length == 3) {
        final r = hex[0];
        final g = hex[1];
        final b = hex[2];
        final expanded = '$r$r$g$g$b$b';
        final intColor = int.tryParse(expanded, radix: 16);
        if (intColor != null) {
          return Color(0xFF000000 | intColor);
        }
      } else if (hex.length == 6) {
        final intColor = int.tryParse(hex, radix: 16);
        if (intColor != null) {
          return Color(0xFF000000 | intColor);
        }
      } else if (hex.length == 8) {
        final intColor = int.tryParse(hex, radix: 16);
        if (intColor != null) {
          return Color(intColor);
        }
      }
    }

    if (normalized.startsWith('rgb')) {
      final values = normalized
          .replaceAll(RegExp(r'[rgb()\s]'), '')
          .split(',')
          .where((entry) => entry.isNotEmpty)
          .map(int.tryParse)
          .whereType<int>()
          .toList();
      if (values.length == 3) {
        return Color.fromARGB(255, values[0], values[1], values[2]);
      }
    }

    return null;
  }
}

class SvgPath {
  const SvgPath({required this.path, required this.fillColor});

  final Path path;
  final Color fillColor;
}

class _ViewBox {
  const _ViewBox({required this.width, required this.height});

  final double width;
  final double height;
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
