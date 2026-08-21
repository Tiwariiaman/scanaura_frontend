import 'dart:ui';

import 'package:flutter/material.dart';

import '../data/models/category_response.dart';
import '../presentation/providers/menu_state.dart';

class MenuFilterChips extends StatelessWidget {
  const MenuFilterChips({
    super.key,
    required this.state,
    required this.categories,
    required this.onAllSelected,
    required this.onCategorySelected,
    required this.onVegSelected,
    required this.onNonVegSelected,
    required this.onBestSellerSelected,
    required this.onRecommendedSelected,
  });

  final MenuState state;
  final List<CategoryResponse> categories;

  final VoidCallback onAllSelected;

  final ValueChanged<String> onCategorySelected;

  final VoidCallback onVegSelected;
  final VoidCallback onNonVegSelected;
  final VoidCallback onBestSellerSelected;
  final VoidCallback onRecommendedSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            FilterChip(
              label: const Text('All'),
              selected: state.selectedCategoryId == null,
              onSelected: (_) {
                onAllSelected();
              },
            ),

            const SizedBox(width: 8),

            ...categories.map(
                  (category) {
                final selected =
                    state.selectedCategoryId == category.id;

                return Padding(
                  padding: const EdgeInsets.only(
                    right: 8,
                  ),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: selected,
                    onSelected: (_) {
                      onCategorySelected(category.id);
                    },
                  ),
                );
              },
            ),

            FilterChip(
              avatar: const Icon(
                Icons.eco_outlined,
                size: 18,
              ),
              label: const Text('Veg'),
              selected: state.showVegOnly,
              onSelected: (_) {
                onVegSelected();
              },
            ),

            const SizedBox(width: 8),

            FilterChip(
              label: const Text('Non-Veg'),
              selected: state.showNonVegOnly,
              onSelected: (_) {
                onNonVegSelected();
              },
            ),

            const SizedBox(width: 8),

            FilterChip(
              avatar: const Icon(
                Icons.star_outline,
                size: 18,
              ),
              label: const Text('Best Seller'),
              selected: state.showBestSellerOnly,
              onSelected: (_) {
                onBestSellerSelected();
              },
            ),

            const SizedBox(width: 8),

            FilterChip(
              avatar: const Icon(
                Icons.thumb_up_alt_outlined,
                size: 18,
              ),
              label: const Text('Recommended'),
              selected: state.showRecommendedOnly,
              onSelected: (_) {
                onRecommendedSelected();
              },
            ),

            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}