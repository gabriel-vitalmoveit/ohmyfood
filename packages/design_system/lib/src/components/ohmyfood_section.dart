import 'package:flutter/material.dart';

import '../foundations/spacing.dart';
import '../foundations/typography.dart';

class OhMyFoodSection extends StatelessWidget {
  const OhMyFoodSection({
    required this.title,
    required this.child,
    this.trailing,
    this.margin,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.only(bottom: OhMyFoodSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: OhMyFoodTypography.titleMd),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: OhMyFoodSpacing.md),
          child,
        ],
      ),
    );
  }
}
