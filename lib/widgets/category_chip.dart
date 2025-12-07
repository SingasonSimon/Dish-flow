import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingS,
        ),
        margin: const EdgeInsets.only(right: AppConstants.spacingS),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusPill),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

