import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/core/data/pet_categories.dart';

class CategoryCard extends StatelessWidget {
  final PetCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isSelected ? category.color : category.color.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              category.icon,
              size: 30,
              color: isSelected ? theme.colorScheme.onPrimary : category.color,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          category.name,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
