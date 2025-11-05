import 'package:flutter/material.dart';

import '../foundations/spacing.dart';
import '../foundations/typography.dart';

class OhMyFoodCard extends StatelessWidget {
  const OhMyFoodCard({
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(OhMyFoodSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: OhMyFoodSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: OhMyFoodTypography.bodyBold),
                    const SizedBox(height: OhMyFoodSpacing.xs),
                    Text(subtitle, style: OhMyFoodTypography.caption),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
