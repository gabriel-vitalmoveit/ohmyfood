import 'package:flutter/material.dart';

import '../foundations/colors.dart';
import '../foundations/spacing.dart';
import '../foundations/typography.dart';

class OhMyFoodAppScaffold extends StatelessWidget {
  const OhMyFoodAppScaffold({
    required this.title,
    required this.body,
    this.leading,
    this.actions,
    this.bottom,
    this.floatingActionButton,
    this.backgroundColor,
    super.key,
  });

  final String title;
  final Widget body;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? OhMyFoodColors.neutral50,
      appBar: AppBar(
        leading: leading,
        title: Text(title, style: OhMyFoodTypography.titleMd),
        actions: actions,
        centerTitle: false,
        bottom: bottom,
      ),
      floatingActionButton: floatingActionButton,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: OhMyFoodSpacing.md),
        child: body,
      ),
    );
  }
}
