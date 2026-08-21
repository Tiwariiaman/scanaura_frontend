import 'package:flutter/material.dart';

class MenuEmptyState extends StatelessWidget {
  const MenuEmptyState({
    super.key,
    this.searchQuery = '',
  });

  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final searching =
        searchQuery.trim().isNotEmpty;

    return Padding(
      padding:
      const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            searching
                ? Icons.search_off
                : Icons.restaurant_menu,
            size: 56,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            searching
                ? 'No menu items found'
                : 'Your menu is empty',
            style:
            const TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searching
                ? 'Try a different search or filter.'
                : 'Add your first menu item to get started.',
            textAlign:
            TextAlign.center,
          ),
        ],
      ),
    );
  }
}