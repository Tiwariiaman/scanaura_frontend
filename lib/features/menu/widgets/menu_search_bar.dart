import 'package:flutter/material.dart';

class MenuSearchBar extends StatelessWidget {
  const MenuSearchBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:
      TextEditingController(text: value)
        ..selection =
        TextSelection.collapsed(
          offset: value.length,
        ),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search menu items...',
        prefixIcon:
        const Icon(Icons.search),
        suffixIcon: value.isEmpty
            ? null
            : IconButton(
          onPressed: () {
            onChanged('');
          },
          icon: const Icon(
            Icons.clear,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
        ),
      ),
    );
  }
}