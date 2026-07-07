import 'package:flutter/material.dart';

import 'flexible_shimmer_loading.dart';
import 'shimmer_shape.dart';

/// Pre-built Shimmer Layouts
class ShimmerLayouts {
  // Tab Shimmer Layout
  static Widget tabs({
    int count = 4,
    double tabHeight = 30,
    double minWidth = 80,
    double maxWidth = 120,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8.0),
  }) {
    return FlexibleShimmerLoading(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(count, (index) {
            return Padding(
              padding: padding,
              child: ShimmerShape.rectangle(
                width: minWidth + (index * 10).clamp(0, maxWidth - minWidth),
                height: tabHeight,
                borderRadius: 4,
              ),
            );
          }),
        ),
      ),
    );
  }

  // Card Shimmer Layout
  static Widget card({
    double? width,
    // Tall enough for the default content (avatar row + title + subtitle +
    // padding); a smaller value overflows the inner Column.
    double height = 148,
    bool showAvatar = true,
    bool showTitle = true,
    bool showSubtitle = true,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return FlexibleShimmerLoading(
      child: Container(
        width: width,
        height: height,
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAvatar) ...[
              const Row(
                children: [
                  ShimmerShape.circle(radius: 20),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerShape.text(width: 100, height: 14),
                      SizedBox(height: 4),
                      ShimmerShape.text(width: 60, height: 12),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (showTitle) ...[
              const ShimmerShape.text(width: double.infinity),
              const SizedBox(height: 8),
            ],
            if (showSubtitle) ...[
              const ShimmerShape.text(width: 200, height: 14),
              const SizedBox(height: 4),
              const ShimmerShape.text(width: 150, height: 14),
            ],
          ],
        ),
      ),
    );
  }

  // List Item Shimmer Layout
  static Widget listItem({
    bool showLeading = true,
    bool showTrailing = true,
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
  }) {
    return FlexibleShimmerLoading(
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (showLeading) ...[
              const ShimmerShape.circle(radius: 24),
              const SizedBox(width: 16),
            ],
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerShape.text(width: double.infinity),
                  SizedBox(height: 4),
                  ShimmerShape.text(width: 200, height: 14),
                ],
              ),
            ),
            if (showTrailing) ...[
              const SizedBox(width: 16),
              const ShimmerShape.text(width: 60, height: 14),
            ],
          ],
        ),
      ),
    );
  }

  // Banner Shimmer Layout
  static Widget banner({
    double? width,
    double height = 200,
    bool showContent = true,
    EdgeInsets margin = EdgeInsets.zero,
  }) {
    return FlexibleShimmerLoading(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        child: Stack(
          children: [
            const ShimmerShape.rectangle(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 16,
            ),
            if (showContent)
              const Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerShape.text(width: 120, height: 18),
                        ShimmerShape.text(width: 80),
                      ],
                    ),
                    SizedBox(height: 8),
                    ShimmerShape.text(width: 200, height: 14),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Order Item Shimmer Layout
  static Widget orderItem({
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 10),
  }) {
    return FlexibleShimmerLoading(
      child: Padding(
        padding: padding,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: const BoxDecoration(color: Colors.white),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with icon, status, date, and order number
              Row(
                children: [
                  ShimmerShape.rectangle(
                    width: 24,
                    height: 24,
                    borderRadius: 4,
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerShape.text(width: 80),
                      SizedBox(height: 4),
                      ShimmerShape.text(width: 80, height: 12),
                    ],
                  ),
                  Spacer(),
                  ShimmerShape.rectangle(
                    width: 24,
                    height: 24,
                    borderRadius: 4,
                  ),
                ],
              ),
              // Divider
              SizedBox(height: 15),
              ShimmerShape.rectangle(width: double.infinity, height: 1),
              SizedBox(height: 15),
              // Product row with image and details
              Row(
                children: [
                  ShimmerShape.rectangle(
                    width: 100,
                    height: 100,
                    borderRadius: 10,
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerShape.text(width: 100),
                        SizedBox(height: 8),
                        ShimmerShape.text(width: 60, height: 14),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            ShimmerShape.text(width: 45, height: 12),
                            SizedBox(width: 15),
                            ShimmerShape.text(width: 35, height: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                ],
              ),
              SizedBox(height: 15),
              ShimmerShape.rectangle(width: double.infinity, height: 1),
              SizedBox(height: 15),
              // Button
              ShimmerShape.rectangle(width: double.infinity, height: 44),
            ],
          ),
        ),
      ),
    );
  }
}
