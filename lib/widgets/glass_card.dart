import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Color? color;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: AppTheme.glassDecoration(
        color: color,
        borderRadius: borderRadius ?? AppConstants.radiusL,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppConstants.radiusL,
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppConstants.spacingL),
            child: child,
          ),
        ),
      ),
    );
  }
}

