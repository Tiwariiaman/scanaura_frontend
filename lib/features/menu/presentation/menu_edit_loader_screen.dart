import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/menu_repository.dart';
import 'add_menu_item_screen.dart';

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
    extends ConsumerState<
        MenuEditLoaderScreen> {
  late final MenuRepository _repository;

  late Future<dynamic> _catalogFuture;

  @override
  void initState() {
    super.initState();

    _repository =
        ref.read(menuRepositoryProvider);

    _catalogFuture =
        _loadCatalog();
  }

  Future<dynamic> _loadCatalog() {
    return _repository.getCatalog(
      widget.catalogId,
    );
  }

  void _retry() {
    setState(() {
      _catalogFuture =
          _loadCatalog();
    });
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return FutureBuilder<dynamic>(
      future: _catalogFuture,
      builder: (
          context,
          snapshot,
          ) {
        // ==========================================================
        // LOADING
        // ==========================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Edit Menu Item',
                style: TextStyle(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
            body: const Center(
              child:
              CircularProgressIndicator(),
            ),
          );
        }

        // ==========================================================
        // ERROR
        // ==========================================================

        if (snapshot.hasError ||
            !snapshot.hasData) {
          final message =
              snapshot.error
                  ?.toString()
                  .replaceFirst(
                'Exception: ',
                '',
              ) ??
                  'Unable to load menu item.';

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Edit Menu Item',
                style: TextStyle(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
            body: SafeArea(
              child: Center(
                child:
                SingleChildScrollView(
                  padding:
                  const EdgeInsets.all(
                    24,
                  ),
                  child: ConstrainedBox(
                    constraints:
                    const BoxConstraints(
                      maxWidth: 420,
                    ),
                    child: Column(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .error_outline_rounded,
                          size: 52,
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .error,
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        const Text(
                          'Unable to load menu item',
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          message,
                          textAlign:
                          TextAlign.center,
                          style: Theme.of(
                            context,
                          )
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        SizedBox(
                          width:
                          double.infinity,
                          child:
                          FilledButton
                              .icon(
                            onPressed:
                            _retry,
                            icon:
                            const Icon(
                              Icons
                                  .refresh_rounded,
                            ),
                            label:
                            const Text(
                              'Retry',
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        SizedBox(
                          width:
                          double.infinity,
                          child:
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pop();
                            },
                            child:
                            const Text(
                              'Back',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // ==========================================================
        // SUCCESS
        // ==========================================================

        return AddMenuItemScreen(
          item: snapshot.data,
        );
      },
    );
  }
}