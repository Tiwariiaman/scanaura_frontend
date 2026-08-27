import 'package:flutter/material.dart';

class MenuSearchBar extends StatefulWidget {
  const MenuSearchBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<MenuSearchBar> createState() =>
      _MenuSearchBarState();
}

class _MenuSearchBarState
    extends State<MenuSearchBar> {
  late final TextEditingController
  _controller;

  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller =
        TextEditingController(
          text: widget.value,
        );

    _controller.selection =
        TextSelection.collapsed(
          offset: _controller.text.length,
        );

    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(
      covariant MenuSearchBar oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (widget.value !=
        _controller.text) {
      _controller.value =
          TextEditingValue(
            text: widget.value,
            selection:
            TextSelection.collapsed(
              offset: widget.value.length,
            ),
          );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final width =
        MediaQuery.sizeOf(context).width;

    final compact =
        width < 400;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textInputAction:
      TextInputAction.search,
      textCapitalization:
      TextCapitalization.none,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText:
        compact
            ? 'Search menu...'
            : 'Search menu items...',
        prefixIcon: const Icon(
          Icons.search_rounded,
        ),
        suffixIcon:
        widget.value.isEmpty
            ? null
            : IconButton(
          tooltip: 'Clear',
          onPressed: _clear,
          icon: const Icon(
            Icons.clear_rounded,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14),
        ),
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}