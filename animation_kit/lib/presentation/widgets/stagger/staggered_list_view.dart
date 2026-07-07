import 'package:flutter/material.dart';

import '../../../core/enums/animation_curve.dart';
import '../../../core/models/stagger_config.dart';

/// Staggered List View Widget
///
/// Provides staggered animation for a list of items.
class StaggeredListView extends StatefulWidget {
  /// Stagger configuration
  final StaggerConfig staggerConfig;

  /// Number of items
  final int itemCount;

  /// Item builder
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Padding
  final EdgeInsetsGeometry? padding;

  const StaggeredListView({
    super.key,
    required this.staggerConfig,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
  });

  @override
  State<StaggeredListView> createState() => _StaggeredListViewState();
}

class _StaggeredListViewState extends State<StaggeredListView>
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
    return ListView.builder(
      padding: widget.padding,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Opacity(
              opacity: _animations[index].value,
              child: Transform.translate(
                offset: Offset(
                  30 * (1 - _animations[index].value),
                  0,
                ),
                child: widget.itemBuilder(context, index),
              ),
            );
          },
        );
      },
    );
  }
}
