import 'package:flutter/material.dart';

import '../../../core/models/product.dart';
import '../../../core/theme/app_theme.dart';

// Static fallback categories with icons for when Medusa returns none
const _fallbackCategories = [
  _FallbackCategory('Vegetables', Icons.grass_rounded, Color(0xFF43A047)),
  _FallbackCategory('Fruits', Icons.apple_rounded, Color(0xFFE53935)),
  _FallbackCategory('Dairy', Icons.water_drop_rounded, Color(0xFF1E88E5)),
  _FallbackCategory('Meat & Fish', Icons.set_meal_rounded, Color(0xFFEF6C00)),
  _FallbackCategory('Bakery', Icons.bakery_dining_rounded, Color(0xFF8D6E63)),
  _FallbackCategory('Beverages', Icons.local_drink_rounded, Color(0xFF00ACC1)),
  _FallbackCategory('Grains', Icons.grain_rounded, Color(0xFFFDD835)),
  _FallbackCategory('Herbs', Icons.spa_rounded, Color(0xFF00897B)),
];

class _FallbackCategory {
  final String name;
  final IconData icon;
  final Color color;
  const _FallbackCategory(this.name, this.icon, this.color);
}

class CategoryGrid extends StatelessWidget {
  final List<ProductCategory> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final items = categories.isNotEmpty
        ? categories
        : _fallbackCategories
            .map((f) => ProductCategory(id: f.name, name: f.name, handle: f.name.toLowerCase()))
            .toList();

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final cat = items[i];
          final fallback = i < _fallbackCategories.length
              ? _fallbackCategories[i]
              : _fallbackCategories.last;
          final isSelected = selectedId == cat.id;

          return GestureDetector(
            onTap: () => onSelect(isSelected ? null : cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.divider,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    fallback.icon,
                    color: isSelected ? Colors.white : fallback.color,
                    size: 26,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
