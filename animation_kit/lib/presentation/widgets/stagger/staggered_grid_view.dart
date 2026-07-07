import 'package:flutter/material.dart';

import '../../../core/enums/animation_curve.dart';
import '../../../core/models/stagger_config.dart';

/// Staggered Grid View Widget
///
/// Provides staggered animation for a grid of items.
class StaggeredGridView extends StatefulWidget {
  /// Stagger configuration
  final StaggerConfig staggerConfig;

  /// Grid delegate
  final SliverGridDelegate gridDelegate;

  /// Number of items
  final int itemCount;

  /// Item builder
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Padding
  final EdgeInsetsGeometry? padding;

  const StaggeredGridView({
    super.key,
    required this.staggerConfig,
    required this.gridDelegate,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
  });

  @override
  State<StaggeredGridView> createState() => _StaggeredGridViewState();
}

class _StaggeredGridViewState extends State<StaggeredGridView>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _playAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.itemCount,
      (index) => AnimationController(
        vsync: this,
        duration: widget.staggerConfig.duration,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: widget.staggerConfig.curve.toFlutterCurve(),
        ),
      );
    }).toList();
  }

  Future<void> _playAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(widget.staggerConfig.delay);
      if (mounted) {
        _controllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: widget.padding,
      gridDelegate: widget.gridDelegate,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Opacity(
              opacity: _animations[index].value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * _animations[index].value),
                child: widget.itemBuilder(context, index),
              ),
            );
          },
        );
      },
    );
  }
}
