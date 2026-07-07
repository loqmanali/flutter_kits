import 'package:flutter/material.dart';

// ==================== Rating Widget ====================

class CustomStarRating extends StatefulWidget {
  const CustomStarRating({
    super.key,
    required this.initialRating,
    this.starCount = 5,
    this.iconSize = 20,
    this.allowHalfRating = true,
    this.filledColor = const Color(0xFFF4BD2F),
    this.emptyColor = const Color(0xFF9CA3AF),
    this.filledIcon = const Icon(Icons.star_rounded),
    this.halfIcon = const Icon(Icons.star_half_rounded),
    this.emptyIcon = const Icon(Icons.star_rounded),
    this.starSpacing = 4,
    this.readOnly = false,
    this.onRatingChanged,
  })  : assert(starCount > 0, 'starCount must be greater than zero'),
        assert(iconSize > 0, 'iconSize must be greater than zero');

  final double initialRating;
  final int starCount;
  final double iconSize;
  final bool allowHalfRating;
  final Color filledColor;
  final Color emptyColor;
  final Widget filledIcon;
  final Widget halfIcon;
  final Widget emptyIcon;
  final double starSpacing;
  final bool readOnly;
  final ValueChanged<double>? onRatingChanged;

  @override
  State<CustomStarRating> createState() => _CustomStarRatingState();
}

class _CustomStarRatingState extends State<CustomStarRating> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating =
        _clampToRange(widget.initialRating, widget.starCount.toDouble());
  }

  void _updateRating(double rating) {
    final double normalized =
        _clampToRange(rating, widget.starCount.toDouble());
    if (normalized != _currentRating) {
      setState(() {
        _currentRating = normalized;
      });
      widget.onRatingChanged?.call(_currentRating);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stars = <Widget>[];
    for (var index = 0; index < widget.starCount; index++) {
      stars.add(
        _StarButton(
          index: index,
          rating: _currentRating,
          iconSize: widget.iconSize,
          allowHalfRating: widget.allowHalfRating,
          filledColor: widget.filledColor,
          emptyColor: widget.emptyColor,
          filledIcon: widget.filledIcon,
          halfIcon: widget.halfIcon,
          emptyIcon: widget.emptyIcon,
          readOnly: widget.readOnly,
          onSelect: _updateRating,
        ),
      );
      if (index != widget.starCount - 1) {
        stars.add(SizedBox(width: widget.starSpacing));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: stars,
    );
  }
}

class _StarButton extends StatelessWidget {
  const _StarButton({
    required this.index,
    required this.rating,
    required this.iconSize,
    required this.allowHalfRating,
    required this.filledColor,
    required this.emptyColor,
    required this.filledIcon,
    required this.halfIcon,
    required this.emptyIcon,
    required this.readOnly,
    required this.onSelect,
  });

  final int index;
  final double rating;
  final double iconSize;
  final bool allowHalfRating;
  final Color filledColor;
  final Color emptyColor;
  final Widget filledIcon;
  final Widget halfIcon;
  final Widget emptyIcon;
  final bool readOnly;
  final ValueChanged<double> onSelect;

  @override
  Widget build(BuildContext context) {
    final bool isFilled = rating >= index + 1;
    final bool isHalf = allowHalfRating && !isFilled && rating >= index + 0.5;
    final icon = isFilled
        ? filledIcon
        : isHalf
            ? halfIcon
            : emptyIcon;
    final color = isFilled || isHalf ? filledColor : emptyColor;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: readOnly
          ? null
          : (details) {
              final double localDx =
                  details.localPosition.dx.clamp(0, iconSize).toDouble();
              final bool isFirstHalf =
                  allowHalfRating && localDx <= iconSize / 2;
              final double newRating = index + (isFirstHalf ? 0.5 : 1);
              onSelect(newRating);
            },
      onTap: readOnly
          ? null
          : () {
              final double newRating = index + 1;
              onSelect(newRating);
            },
      child: IconTheme(
        data: IconThemeData(
          color: color,
          size: iconSize,
        ),
        child: icon,
      ),
    );
  }
}

double _clampToRange(double value, double max) =>
    value.clamp(0, max).toDouble();
