import 'package:flutter/material.dart';
import '../../../../core/ai_providers/ai_provider.dart';

/// Credits indicator showing remaining credits
class AIProviderSelector extends StatelessWidget {
  final AIProviderType selected;
  final List<AIProviderType> available;
  final ValueChanged<AIProviderType>? onChanged;
  final int credits;
  final VoidCallback? onTap;

  const AIProviderSelector({
    super.key,
    required this.selected,
    required this.available,
    required this.credits,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: credits > 0 ? const Color(0xFFF5F0EB) : const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: credits > 0 ? const Color(0xFFD4C4B5) : const Color(0xFFFCA5A5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.toll_outlined,
              size: 14,
              color: credits > 0 ? const Color(0xFF8B7355) : const Color(0xFFDC2626),
            ),
            const SizedBox(width: 6),
            Text(
              '$credits',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: credits > 0 ? const Color(0xFF6B5B4F) : const Color(0xFFDC2626),
              ),
            ),
            const SizedBox(width: 2),
            Text(
              'credits',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: credits > 0 ? const Color(0xFF8B7355) : const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
