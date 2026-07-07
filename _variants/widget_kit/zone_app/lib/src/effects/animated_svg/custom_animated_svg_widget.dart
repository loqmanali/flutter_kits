import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'animated_svg_widget_entries.dart';
import 'animated_svg_widget_renderer.dart' show AnimatedSvgPainter;

class AnimatedSvgWidget extends StatefulWidget {
  const AnimatedSvgWidget({
    super.key,
    required this.assetName,
    this.assetBundle,
    this.assetPackage,
    this.width,
    this.height,
    this.duration = const Duration(milliseconds: 2000),
    this.strokeWidth = 3,
    this.style = PaintingStyle.stroke,
    this.repeat = true,
    this.animateStrokeToFill = true,
    this.fillStartFraction = 0.65,
    this.strokeCurve = Curves.easeInOutCubic,
    this.fillCurve = Curves.easeOutCubic,
    this.fillDirection = AnimatedSvgFillDirection.bottomToTop,
    this.useSvgColors = true,
    this.strokeColor,
    this.fillColor,
    this.placeholder,
    this.errorBuilder,
    this.animationType = AnimatedSvgAnimationType.strokeToFill,
    this.slideDirection = AnimatedSvgSlideDirection.fromBottom,
    this.staggerDelay = 0.1,
    this.shimmerColor,
    this.glowColor,
    this.glowRadius = 10.0,
    this.scaleFrom = 0.0,
    this.scaleTo = 1.0,
    this.rotationAngle = 2 * 3.14159,
    this.flipAxis = Axis.horizontal,
    this.waveAmplitude = 20.0,
    this.waveFrequency = 2.0,
    this.elasticity = 0.5,
    this.entranceCurve = Curves.easeOutCubic,
    this.onAnimationComplete,
    this.perspective3DDistance = 800.0,
    this.rotationX = 0.0,
    this.rotationY = 0.0,
    this.rotationZ = 0.0,
    this.scale3D = 1.0,
    this.translateX = 0.0,
    this.translateY = 0.0,
    this.translateZ = 0.0,
    this.enable3DPerspective = false,
  }) : assert(
          fillStartFraction > 0 && fillStartFraction < 1,
          'fillStartFraction must be between 0 and 1 (exclusive).',
        );

  final String assetName;
  final AssetBundle? assetBundle;
  final String? assetPackage;
  final double? width;
  final double? height;
  final Duration duration;
  final double strokeWidth;
  final PaintingStyle style;
  final bool repeat;
  final bool animateStrokeToFill;
  final double fillStartFraction;
  final Curve strokeCurve;
  final Curve fillCurve;
  final AnimatedSvgFillDirection fillDirection;
  final bool useSvgColors;
  final Color? strokeColor;
  final Color? fillColor;
  final Widget? placeholder;
  final Widget Function(BuildContext context, String error)? errorBuilder;

  final AnimatedSvgAnimationType animationType;
  final AnimatedSvgSlideDirection slideDirection;
  final double staggerDelay;
  final Color? shimmerColor;
  final Color? glowColor;
  final double glowRadius;
  final double scaleFrom;
  final double scaleTo;
  final double rotationAngle;
  final Axis flipAxis;
  final double waveAmplitude;
  final double waveFrequency;
  final double elasticity;
  final Curve entranceCurve;
  final VoidCallback? onAnimationComplete;

  final double perspective3DDistance;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final double scale3D;
  final double translateX;
  final double translateY;
  final double translateZ;
  final bool enable3DPerspective;

  @override
  State<AnimatedSvgWidget> createState() => _AnimatedSvgWidgetState();
}

class _AnimatedSvgWidgetState extends State<AnimatedSvgWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  SvgVector? _vector;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _loadSvg();
  }

  @override
  void didUpdateWidget(covariant AnimatedSvgWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.assetName != widget.assetName ||
        oldWidget.assetBundle != widget.assetBundle ||
        oldWidget.assetPackage != widget.assetPackage) {
      _loadSvg();
    }

    if (oldWidget.duration != widget.duration) {
      _controller
        ..duration = widget.duration
        ..reset();
      _startAnimation();
    }

    if (oldWidget.repeat != widget.repeat) {
      if (widget.repeat) {
        _controller
          ..reset()
          ..repeat();
      } else {
        _controller
          ..stop()
          ..forward(from: _controller.value);
      }
    }

    if (!widget.repeat && !_controller.isAnimating && _controller.value >= 1) {
      _controller.value = 1;
    }
  }

  Future<void> _loadSvg() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _vector = null;
    });

    try {
      final bundle = widget.assetBundle ?? rootBundle;
      final assetKey = widget.assetPackage != null
          ? 'packages/${widget.assetPackage}/${widget.assetName}'
          : widget.assetName;
      final raw = await bundle.loadString(assetKey);
      final vector = SvgVector.parse(raw);
      if (vector.paths.isEmpty) {
        throw FormatException(
          'AnimatedSvgWidget requires at least one <path> element. '
          '"${widget.assetName}" has none. Flatten shapes (rect/circle/polygon) '
          'into <path d="..."> with a defined viewBox before exporting.',
        );
      }
      if (!mounted) return;
      setState(() {
        _vector = vector;
        _isLoading = false;
      });
      _controller
        ..duration = widget.duration
        ..reset();
      _startAnimation();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'widget_kit',
            context: ErrorDescription(
              'while loading AnimatedSvgWidget asset "${widget.assetName}"',
            ),
          ),
        );
      }
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _startAnimation() {
    final vector = _vector;
    if (vector == null || vector.paths.isEmpty) {
      return;
    }

    _controller.removeStatusListener(_onAnimationStatus);
    _controller.addStatusListener(_onAnimationStatus);

    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward(from: 0);
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onAnimationComplete?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vector = _vector;
    final width = widget.width ?? vector?.viewBoxWidth ?? 100;
    final height = widget.height ??
        (widget.width != null && vector != null
            ? widget.width! * (vector.viewBoxHeight / vector.viewBoxWidth)
            : vector?.viewBoxHeight ?? 100);

    if (_isLoading) {
      return widget.placeholder ?? SizedBox(width: width, height: height);
    }

    if (_error != null) {
      final builder = widget.errorBuilder;
      if (builder != null) {
        return builder(context, _error!);
      }
      return widget.placeholder ?? SizedBox(width: width, height: height);
    }

    if (vector == null || vector.paths.isEmpty) {
      return widget.placeholder ?? SizedBox(width: width, height: height);
    }

    return SizedBox(
      width: width,
      height: height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final textDirection =
              Directionality.maybeOf(context) ?? TextDirection.ltr;
          final effectiveFillDirection = _resolveFillDirection(
            widget.fillDirection,
            textDirection,
          );
          return CustomPaint(
            painter: AnimatedSvgPainter(
              progress: _controller.value,
              vector: vector,
              strokeWidth: widget.strokeWidth,
              style: widget.style,
              animateStrokeToFill: widget.animateStrokeToFill,
              fillStartFraction: widget.fillStartFraction,
              strokeCurve: widget.strokeCurve,
              fillCurve: widget.fillCurve,
              fillDirection: effectiveFillDirection,
              useSvgColors: widget.useSvgColors,
              strokeColorOverride: widget.strokeColor,
              fillColorOverride: widget.fillColor,
              animationType: widget.animationType,
              slideDirection: widget.slideDirection,
              staggerDelay: widget.staggerDelay,
              shimmerColor: widget.shimmerColor,
              glowColor: widget.glowColor,
              glowRadius: widget.glowRadius,
              scaleFrom: widget.scaleFrom,
              scaleTo: widget.scaleTo,
              rotationAngle: widget.rotationAngle,
              flipAxis: widget.flipAxis,
              waveAmplitude: widget.waveAmplitude,
              waveFrequency: widget.waveFrequency,
              elasticity: widget.elasticity,
              entranceCurve: widget.entranceCurve,
              perspective3DDistance: widget.perspective3DDistance,
              rotationX: widget.rotationX,
              rotationY: widget.rotationY,
              rotationZ: widget.rotationZ,
              scale3D: widget.scale3D,
              translateX: widget.translateX,
              translateY: widget.translateY,
              translateZ: widget.translateZ,
              enable3DPerspective: widget.enable3DPerspective,
            ),
          );
        },
      ),
    );
  }

  AnimatedSvgFillDirection _resolveFillDirection(
    AnimatedSvgFillDirection direction,
    TextDirection textDirection,
  ) {
    if (textDirection != TextDirection.rtl) {
      return direction;
    }

    switch (direction) {
      case AnimatedSvgFillDirection.leftToRight:
        return AnimatedSvgFillDirection.rightToLeft;
      case AnimatedSvgFillDirection.rightToLeft:
        return AnimatedSvgFillDirection.leftToRight;
      case AnimatedSvgFillDirection.bottomToTop:
      case AnimatedSvgFillDirection.topToBottom:
        return direction;
    }
  }
}
