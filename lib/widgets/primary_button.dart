import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final Widget? trailingIcon;
  final TextStyle? textStyle;
  final bool hasGlowShadow;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 52,
    this.borderRadius = 16,
    this.trailingIcon,
    this.textStyle,
    this.hasGlowShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: textStyle ?? AppTextStyles.button,
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              trailingIcon!,
            ],
          ],
        ),
      ),
    );

    if (hasGlowShadow) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLight.withAlpha(64), // rgba(244, 63, 94, 0.25)
              blurRadius: 25,
              spreadRadius: -5,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: AppColors.primaryLight.withAlpha(64),
              blurRadius: 10,
              spreadRadius: -6,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: button,
      );
    }

    return button;
  }
}
