import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class RoundedPillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final double? width;
  final EdgeInsets? padding;

  const RoundedPillButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          foregroundColor: textColor ?? Colors.white,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingXL,
                vertical: AppConstants.spacingM,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusPill),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

