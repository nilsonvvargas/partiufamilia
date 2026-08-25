import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../utils/haptics.dart';

class MaceioButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isLoading;
  final Color? customColor;

  const MaceioButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = customColor ?? MaceioColors.turquoisePrimary;
    final bgColor = isSecondary ? (customColor != null ? customColor!.withValues(alpha: 0.12) : MaceioColors.oceanLight) : primaryColor;
    final fgColor = isSecondary ? primaryColor : Colors.white;

    return ElevatedButton(
      onPressed: isLoading || onPressed == null
          ? null
          : () {
              AppHaptics.light();
              onPressed!();
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: isSecondary ? 0 : 2,
        shadowColor: MaceioColors.turquoisePrimary.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: fgColor),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: fgColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: MaceioTypography.titleMedium.copyWith(
                    color: fgColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
    );
  }
}
