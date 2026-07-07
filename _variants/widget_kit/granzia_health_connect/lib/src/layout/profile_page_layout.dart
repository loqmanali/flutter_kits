import 'package:flutter/material.dart';

import 'page_top_bar.dart';

class ProfilePageLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? bottomNavigationBar;
  final bool showTopBar;
  final VoidCallback? onBackPressed;

  const ProfilePageLayout({
    super.key,
    required this.title,
    required this.child,
    this.bottomNavigationBar,
    this.showTopBar = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTopBar) ...[
                PageTopBar(
                  title: title,
                  onBackPressed: onBackPressed,
                ),
                const SizedBox(height: 30),
              ],
              Expanded(child: child),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
