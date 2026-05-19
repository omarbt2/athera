import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../shared/providers/monuments_provider.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);

    final categories = [
      {'title': 'الكل', 'icon': Icons.grid_view_rounded, 'color': AppColors.primary, 'value': null},
      {'title': 'أثرية', 'icon': Icons.account_balance_rounded, 'color': const Color(0xFF934B00), 'value': 'archaeological'},
      {'title': 'إسلامية', 'icon': Icons.mosque_rounded, 'color': const Color(0xFF006243), 'value': 'islamic'},
      {'title': 'طبيعية', 'icon': Icons.landscape_rounded, 'color': const Color(0xFF004AC6), 'value': 'natural'},
      {'title': 'متاحف', 'icon': Icons.museum_rounded, 'color': const Color(0xFF9333EA), 'value': 'museum'},
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final color = cat['color'] as Color;
          final value = cat['value'] as String?;
          final isSelected = selected == value;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(selectedCategoryProvider.notifier).state = value;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.1),
                borderRadius: AppRadius.chipRadius,
                border: Border.all(
                  color: isSelected ? color : color.withValues(alpha: 0.25),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      color: isSelected ? Colors.white : color,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat['title'] as String,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
