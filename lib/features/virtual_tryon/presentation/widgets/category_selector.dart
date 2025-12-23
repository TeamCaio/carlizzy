import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';

class CategorySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const CategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _categories = [
    ('upper_body', 'Top', Icons.checkroom_outlined),
    ('lower_body', 'Bottom', Icons.accessibility_new_outlined),
    ('dresses', 'Dress', Icons.woman_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _categories.map((category) {
        final (value, label, icon) = category;
        final isSelected = selected == value;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(value),
            child: Container(
              margin: EdgeInsets.only(
                right: category != _categories.last
                    ? ThemeConstants.spacingSmall
                    : 0,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: ThemeConstants.spacingMedium,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? ThemeConstants.primaryColor
                    : ThemeConstants.surfaceColor,
                borderRadius: BorderRadius.circular(ThemeConstants.radiusSmall),
                border: Border.all(
                  color: isSelected
                      ? ThemeConstants.primaryColor
                      : ThemeConstants.borderColor,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: isSelected
                        ? Colors.white
                        : ThemeConstants.textSecondaryColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : ThemeConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
