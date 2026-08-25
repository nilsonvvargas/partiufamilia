import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

class MaceioHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? badge;
  final Widget? trailing;

  const MaceioHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.badge,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badge != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: MaceioColors.coralLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge!.toUpperCase(),
                      style: MaceioTypography.badge.copyWith(
                        color: MaceioColors.coralAccent,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
                Text(title, style: MaceioTypography.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: MaceioTypography.bodyMedium),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
