// أمثلة على كيفية استخدام النظام الجديد

// 1. استخدام Home Tab Shimmer الجديد
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'flexible_shimmer_loading.dart';
import 'shimmer_layouts.dart';
import 'shimmer_shape.dart';

class HomeTabsExample extends StatelessWidget {
  const HomeTabsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabShimmerLoading(
      tabCount: 5,
      tabHeight: 35,
      minTabWidth: 70,
      maxTabWidth: 130,
    );
  }
}

// 2. استخدام Shimmer للبانر (بدلاً من الكود القديم)
class BannerShimmerExample extends StatelessWidget {
  const BannerShimmerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLayouts.banner(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
    );
  }
}

// 3. استخدام Shimmer للقوائم
class ListShimmerExample extends StatelessWidget {
  const ListShimmerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (index) => ShimmerLayouts.listItem(),
      ),
    );
  }
}

// 4. استخدام Shimmer للكاردز
class CardShimmerExample extends StatelessWidget {
  const CardShimmerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => ShimmerLayouts.card(),
    );
  }
}

// 5. استخدام أشكال مخصصة
class CustomShapesExample extends StatelessWidget {
  const CustomShapesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const FlexibleShimmerLoading(
      child: Column(
        children: [
          // دائرة
          ShimmerShape.circle(radius: 40),
          SizedBox(height: 16),

          // نص
          ShimmerShape.text(width: 200),
          SizedBox(height: 8),
          ShimmerShape.text(width: 150, height: 14),
          SizedBox(height: 16),

          // زر
          ShimmerShape.button(),
          SizedBox(height: 16),

          // مستطيل مخصص
          ShimmerShape.rectangle(
            width: double.infinity,
            height: 100,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}

// 6. تخصيص الألوان والسرعة
class CustomAnimationExample extends StatelessWidget {
  const CustomAnimationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const FlexibleShimmerLoading(
      duration: Duration(milliseconds: 1500), // سرعة مختلفة
      gradientColors: [
        Colors.transparent,
        Color(0x33FFEB3B), // أصفر فاتح
        Colors.white,
        Color(0x33FFEB3B),
        Colors.transparent,
      ],
      gradientSpeed: 1.5,
      child: ShimmerShape.rectangle(
        width: 200,
        height: 100,
        borderRadius: 16,
      ),
    );
  }
}

// 8. إنشاء shimmer مخصص تماماً
class FullyCustomShimmer extends HookWidget {
  const FullyCustomShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return FlexibleShimmerLoading(
      duration: const Duration(milliseconds: 3000),
      gradientColors: const [
        Colors.transparent,
        Color(0x22E3F2FD), // أزرق فاتح
        Color(0x44BBDEFB),
        Colors.white,
        Color(0x44BBDEFB),
        Color(0x22E3F2FD),
        Colors.transparent,
      ],
      gradientSpeed: 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            ShimmerShape.circle(radius: 30),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerShape.text(width: double.infinity, height: 18),
                  SizedBox(height: 8),
                  ShimmerShape.text(width: 180, height: 14),
                  SizedBox(height: 4),
                  ShimmerShape.text(width: 120, height: 14),
                ],
              ),
            ),
            ShimmerShape.rectangle(
              width: 60,
              height: 25,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}
