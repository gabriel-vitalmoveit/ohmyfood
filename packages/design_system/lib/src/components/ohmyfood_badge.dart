import 'package:flutter/material.dart';

import '../foundations/colors.dart';
import '../foundations/spacing.dart';
import '../foundations/typography.dart';

class OhMyFoodBadge extends StatelessWidget {
  const OhMyFoodBadge.success(this.label, {super.key})
      : color = OhMyFoodColors.success,
        icon = Icons.check_circle_outline;

  const OhMyFoodBadge.warning(this.label, {super.key})
      : color = OhMyFoodColors.warning,
        icon = Icons.warning_amber_rounded;

  const OhMyFoodBadge.info(this.label, {super.key})
      : color = OhMyFoodColors.primary,
        icon = Icons.info_outline;

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OhMyFoodSpacing.sm,
        vertical: OhMyFoodSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: OhMyFoodSpacing.xs),
          Text(
            label,
            style: OhMyFoodTypography.label.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
