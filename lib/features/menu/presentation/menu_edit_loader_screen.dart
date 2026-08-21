import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add_menu_item_screen.dart';
import '../data/menu_repository.dart';
import '../../../core/providers/app_providers.dart';

class MenuEditLoaderScreen
    extends ConsumerStatefulWidget {
  const MenuEditLoaderScreen({
    super.key,
    required this.catalogId,
  });

  final String catalogId;

  @override
  ConsumerState<MenuEditLoaderScreen>
  createState() =>
      _MenuEditLoaderScreenState();
}

class _MenuEditLoaderScreenState
    extends ConsumerState<MenuEditLoaderScreen> {

  late final MenuRepository _repository;

  @override
  void initState() {
    super.initState();

    _repository =
        ref.read(menuRepositoryProvider);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _repository.getCatalog(
        widget.catalogId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child:
              CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title:
              const Text('Edit Menu Item'),
            ),
            body: Center(
              child: Text(
                snapshot.error
                    ?.toString() ??
                    'Unable to load menu item.',
              ),
            ),
          );
        }

        return AddMenuItemScreen(
          item: snapshot.data,
        );
      },
    );
  }
}