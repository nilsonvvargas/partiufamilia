import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

class MaceioButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isLoading;

  const MaceioButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSecondary ? MaceioColors.oceanLight : MaceioColors.turquoisePrimary;
    final fgColor = isSecondary ? MaceioColors.turquoiseDark : Colors.white;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
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
