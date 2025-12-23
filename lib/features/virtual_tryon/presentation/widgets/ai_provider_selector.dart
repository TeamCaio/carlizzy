import 'package:flutter/material.dart';
import '../../../../core/ai_providers/ai_provider.dart';
import '../../../../core/constants/theme_constants.dart';

/// Simple provider badge showing FitRoom is active
class AIProviderSelector extends StatelessWidget {
  final AIProviderType selected;
  final List<AIProviderType> available;
  final ValueChanged<AIProviderType>? onChanged;

  const AIProviderSelector({
    super.key,
    required this.selected,
    required this.available,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMedium,
        vertical: ThemeConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: ThemeConstants.backgroundColor,
        borderRadius: BorderRadius.circular(ThemeConstants.radiusRound),
        border: Border.all(color: ThemeConstants.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.checkroom,
            size: 16,
            color: ThemeConstants.primaryColor,
          ),
          const SizedBox(width: ThemeConstants.spacingSmall),
          Text(
            'FitRoom',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ThemeConstants.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
