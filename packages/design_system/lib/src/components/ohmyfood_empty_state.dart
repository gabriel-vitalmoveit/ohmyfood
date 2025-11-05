import 'package:flutter/material.dart';

import '../foundations/colors.dart';
import '../foundations/spacing.dart';
import '../foundations/typography.dart';

class OhMyFoodEmptyState extends StatelessWidget {
  const OhMyFoodEmptyState({
    required this.title,
    required this.message,
    this.icon = Icons.search_off_rounded,
    this.action,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(OhMyFoodSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: OhMyFoodColors.neutral100,
              child: Icon(icon, size: 36, color: OhMyFoodColors.primaryDark),
            ),
            const SizedBox(height: OhMyFoodSpacing.lg),
            Text(title, style: OhMyFoodTypography.titleLg, textAlign: TextAlign.center),
            const SizedBox(height: OhMyFoodSpacing.sm),
            Text(
              message,
              style: OhMyFoodTypography.body,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: OhMyFoodSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
