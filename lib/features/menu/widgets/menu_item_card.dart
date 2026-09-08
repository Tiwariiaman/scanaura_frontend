import 'package:flutter/material.dart';

import '../data/models/catalog_response.dart';

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.item,
    required this.showVegIndicator,
    required this.onEdit,
    required this.onDelete,
    required this.onAvailabilityChanged,
  });

  final CatalogResponse item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onAvailabilityChanged;
  final bool showVegIndicator;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final compact =
                constraints.maxWidth < 620;

            if (compact) {
              return _buildCompactLayout(
                context,
              );
            }

            return _buildWideLayout(
              context,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // WIDE LAYOUT
  // ============================================================

  Widget _buildWideLayout(
      BuildContext context,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildMainContent(
            context,
          ),
        ),
        const SizedBox(
          width: 24,
        ),
        _buildWideActions(
          context,
        ),
      ],
    );
  }

  // ============================================================
  // COMPACT / MOBILE LAYOUT
  // ============================================================

  Widget _buildCompactLayout(
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        _buildCompactTopRow(
          context,
        ),

        const SizedBox(
          height: 12,
        ),

        _buildMainContent(
          context,
        ),

        const SizedBox(
          height: 14,
        ),

        _buildMobileAvailability(
          context,
        ),
      ],
    );
  }

  // ============================================================
  // COMPACT TOP ROW
  // ============================================================

  Widget _buildCompactTopRow(
      BuildContext context,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildTitle(
            context,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        _buildPopupMenu(
          context,
        ),
      ],
    );
  }

  // ============================================================
  // MAIN CONTENT
  // ============================================================

  Widget _buildMainContent(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        // --------------------------------------------------------
        // TITLE
        // --------------------------------------------------------

        Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTitle(
                context,
              ),
            ),

            if (showVegIndicator &&
                MediaQuery.sizeOf(context).width >=
                    620) ...[
              const SizedBox(
                width: 10,
              ),
              _vegIndicator(
                context,
              ),
            ],
          ],
        ),

        // --------------------------------------------------------
        // DESCRIPTION
        // --------------------------------------------------------

        if (item.description != null &&
            item.description!
                .trim()
                .isNotEmpty) ...[
          const SizedBox(
            height: 6,
          ),
          Text(
            item.description!,
            maxLines: 3,
            overflow:
            TextOverflow.ellipsis,
            style:
            theme.textTheme.bodyMedium
                ?.copyWith(
              color: theme
                  .colorScheme
                  .onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],

        const SizedBox(
          height: 12,
        ),

        // --------------------------------------------------------
        // PRICE + VEG
        // --------------------------------------------------------

        Row(
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: [
            Text(
              '₹${item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            if (showVegIndicator &&
                MediaQuery.sizeOf(context).width <
                    620) ...[
              const SizedBox(
                width: 10,
              ),
              _vegLabel(
                context,
              ),
            ],
          ],
        ),

        // --------------------------------------------------------
        // TAGS
        // --------------------------------------------------------

        if (_hasTags) ...[
          const SizedBox(
            height: 10,
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
            _buildTags(context),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget _buildTitle(
      BuildContext context,
      ) {
    return Text(
      item.name,
      maxLines: 2,
      overflow:
      TextOverflow.ellipsis,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(
        fontWeight:
        FontWeight.w800,
        height: 1.2,
      ),
    );
  }

  // ============================================================
  // WIDE ACTIONS
  // ============================================================

  Widget _buildWideActions(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit item',
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                ),
              ),
              IconButton(
                tooltip: 'Delete item',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          InkWell(
            borderRadius:
            BorderRadius.circular(12),
            onTap: () =>
                onAvailabilityChanged(
                  !item.available,
                ),
            child: Container(
              width:
              double.infinity,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 9,
              ),
              decoration:
              BoxDecoration(
                color: item.available
                    ? theme
                    .colorScheme
                    .secondaryContainer
                    : theme
                    .colorScheme
                    .errorContainer,
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    item.available
                        ? Icons.check_circle_outline_rounded
                        : Icons.visibility_off_outlined,
                    size: 19,
                    color: item.available
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onErrorContainer,
                  ),

                  const SizedBox(width: 7),

                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.available ? 'Available' : 'Hidden',
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: item.available
                              ? theme.colorScheme.onSecondaryContainer
                              : theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Switch.adaptive(
                    value: item.available,
                    onChanged: onAvailabilityChanged,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            item.available
                ? 'Visible to customers'
                : 'Not visible to customers',
            textAlign:
            TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              color: theme
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE AVAILABILITY
  // ============================================================

  Widget _buildMobileAvailability(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final backgroundColor =
    item.available
        ? theme
        .colorScheme
        .secondaryContainer
        : theme
        .colorScheme
        .errorContainer;

    final foregroundColor =
    item.available
        ? theme
        .colorScheme
        .onSecondaryContainer
        : theme
        .colorScheme
        .onErrorContainer;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration:
      BoxDecoration(
        color: backgroundColor,
        borderRadius:
        BorderRadius.circular(
          12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            item.available
                ? Icons
                .check_circle_outline_rounded
                : Icons
                .visibility_off_outlined,
            size: 19,
            color:
            foregroundColor,
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item.available
                      ? 'Available'
                      : 'Hidden',
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    color:
                    foregroundColor,
                  ),
                ),
                const SizedBox(
                  height: 1,
                ),
                Text(
                  item.available
                      ? 'Customers can see this item'
                      : 'Customers cannot see this item',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  TextStyle(
                    fontSize: 11,
                    color:
                    foregroundColor,
                  ),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value:
            item.available,
            onChanged:
            onAvailabilityChanged,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // POPUP MENU
  // ============================================================

  Widget _buildPopupMenu(
      BuildContext context,
      ) {
    return PopupMenuButton<String>(
      tooltip:
      'Item actions',
      icon: const Icon(
        Icons.more_vert_rounded,
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) =>
      const [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
              ),
              SizedBox(
                width: 10,
              ),
              Text('Edit item'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons
                    .delete_outline_rounded,
              ),
              SizedBox(
                width: 10,
              ),
              Text('Delete item'),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // VEG / NON-VEG
  // ============================================================

  Widget _vegIndicator(
      BuildContext context,
      ) {
    final color =
    item.veg
        ? Colors.green
        : Colors.red;

    return Container(
      width: 24,
      height: 24,
      decoration:
      BoxDecoration(
        border: Border.all(
          color: color,
          width: 1.5,
        ),
        borderRadius:
        BorderRadius.circular(
          6,
        ),
      ),
      alignment:
      Alignment.center,
      child: Container(
        width: 9,
        height: 9,
        decoration:
        BoxDecoration(
          color: color,
          shape:
          BoxShape.circle,
        ),
      ),
    );
  }

  Widget _vegLabel(
      BuildContext context,
      ) {
    final color =
    item.veg
        ? Colors.green
        : Colors.red;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration:
      BoxDecoration(
        color:
        color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        border:
        Border.all(
          color:
          color.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          _vegIndicator(
            context,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            item.veg
                ? 'Veg'
                : 'Non-Veg',
            style:
            TextStyle(
              fontSize: 12,
              fontWeight:
              FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAGS
  // ============================================================

  bool get _hasTags =>
      item.bestSeller ||
          item.recommended ||
          !item.available;

  List<Widget> _buildTags(
      BuildContext context,
      ) {
    return [
      if (item.bestSeller)
        _Tag(
          label: 'Best Seller',
          icon:
          Icons.star_rounded,
          iconColor:
          Colors.orange,
          backgroundColor:
          Colors.orange.withValues(
            alpha: 0.10,
          ),
          foregroundColor:
          Colors.orange.shade800,
        ),

      if (item.recommended)
        _Tag(
          label: 'Recommended',
          icon: Icons
              .thumb_up_alt_outlined,
          iconColor:
          Theme.of(context)
              .colorScheme
              .primary,
          backgroundColor:
          Theme.of(context)
              .colorScheme
              .primary
              .withValues(
            alpha: 0.08,
          ),
          foregroundColor:
          Theme.of(context)
              .colorScheme
              .primary,
        ),

      if (!item.available)
        _Tag(
          label: 'Currently Hidden',
          icon: Icons
              .visibility_off_outlined,
          iconColor:
          Theme.of(context)
              .colorScheme
              .error,
          backgroundColor:
          Theme.of(context)
              .colorScheme
              .error
              .withValues(
            alpha: 0.08,
          ),
          foregroundColor:
          Theme.of(context)
              .colorScheme
              .error,
        ),
    ];
  }
}

// ================================================================
// TAG
// ================================================================

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration:
      BoxDecoration(
        color: backgroundColor,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            label,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
              FontWeight.w700,
              color:
              foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}