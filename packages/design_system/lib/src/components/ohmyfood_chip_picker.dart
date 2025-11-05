import 'package:flutter/material.dart';

import '../foundations/colors.dart';
import '../foundations/spacing.dart';
import '../foundations/typography.dart';

class OhMyFoodChipPicker<T> extends StatelessWidget {
  const OhMyFoodChipPicker({
    required this.items,
    required this.labelBuilder,
    required this.onSelected,
    required this.selected,
    this.scrollDirection = Axis.horizontal,
    this.wrapSpacing,
    super.key,
  });

  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;
  final T? selected;
  final Axis scrollDirection;
  final double? wrapSpacing;

  @override
  Widget build(BuildContext context) {
    if (scrollDirection == Axis.horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(right: OhMyFoodSpacing.sm),
                child: _Chip(
                  label: labelBuilder(item),
                  selected: selected == item,
                  onTap: () => onSelected(item),
                ),
              ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: wrapSpacing ?? OhMyFoodSpacing.sm,
      runSpacing: wrapSpacing ?? OhMyFoodSpacing.sm,
      children: [
        for (final item in items)
          _Chip(
            label: labelBuilder(item),
            selected: selected == item,
            onTap: () => onSelected(item),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected ? OhMyFoodColors.primarySoft : OhMyFoodColors.neutral100;
    final foreground = selected ? OhMyFoodColors.primaryDark : OhMyFoodColors.neutral600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: OhMyFoodSpacing.md,
          vertical: OhMyFoodSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: OhMyFoodTypography.label.copyWith(
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
