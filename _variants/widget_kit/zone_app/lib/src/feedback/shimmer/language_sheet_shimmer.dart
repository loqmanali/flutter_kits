import 'package:flutter/material.dart';

import 'flexible_shimmer_loading.dart';
import 'shimmer_shape.dart';

/// Shimmer loading widget for the language selection sheet.
/// Matches the exact design of [LanguageOptionTile] and [RadioDot].
class LanguageSheetShimmer extends StatelessWidget {
  final int itemCount;

  const LanguageSheetShimmer({
    super.key,
    this.itemCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return FlexibleShimmerLoading(
      child: Column(
        children: List.generate(itemCount, (index) {
          return Column(
            children: [
              const _LanguageOptionShimmer(),
              if (index < itemCount - 1) Divider(color: Colors.grey.shade400),
            ],
          );
        }),
      ),
    );
  }
}

class _LanguageOptionShimmer extends StatelessWidget {
  const _LanguageOptionShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          // Radio dot shimmer
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.4,
              ),
              color: Colors.grey.shade200,
            ),
          ),
          const SizedBox(width: 20),
          // Text shimmer
          ShimmerShape.text(
            width: 150,
            backgroundColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}
