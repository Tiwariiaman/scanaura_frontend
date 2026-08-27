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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.maxWidth < 520;

        final imageSize =
        isCompact ? 76.0 : 90.0;

        return Card(
          clipBehavior:
          Clip.antiAlias,
          child: Padding(
            padding:
            EdgeInsets.all(
              isCompact ? 10 : 12,
            ),
            child: isCompact
                ? _buildCompactLayout(
              context,
              imageSize,
            )
                : _buildWideLayout(
              context,
              imageSize,
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // WIDE LAYOUT
  // ============================================================

  Widget _buildWideLayout(
      BuildContext context,
      double imageSize,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        _buildImage(
          context,
          imageSize,
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: _buildContent(
            context,
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        _buildActions(
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
      double imageSize,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _buildImage(
              context,
              imageSize,
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: _buildCompactHeader(
                context,
              ),
            ),

            const SizedBox(
              width: 4,
            ),

            _buildPopupMenu(
              context,
            ),
          ],
        ),

        const SizedBox(
          height: 10,
        ),

        _buildContent(
          context,
          compact: true,
        ),

        const SizedBox(
          height: 10,
        ),

        _buildMobileAvailability(
          context,
        ),
      ],
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(
      BuildContext context, {
        bool compact = false,
      }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        // Name
        Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.name,
                maxLines: compact ? 2 : 2,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),

            if (compact)
              const SizedBox(
                width: 4,
              ),

            if (compact && showVegIndicator)
              _vegIndicator(),
          ],
        ),

        if (!compact)
          const SizedBox(
            height: 4,
          ),

        if (item.description != null &&
            item.description!
                .trim()
                .isNotEmpty) ...[
          const SizedBox(
            height: 5,
          ),
          Text(
            item.description!,
            maxLines: compact ? 3 : 2,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              color:
              Colors.grey.shade600,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],

        const SizedBox(
          height: 8,
        ),

        Text(
          '₹${item.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight:
            FontWeight.w700,
          ),
        ),

        if (!compact) ...[
          const SizedBox(
            height: 8,
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _buildTags(),
          ),
        ] else ...[
          const SizedBox(
            height: 8,
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _buildTags(),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactHeader(
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.name,
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(
              width: 6,
            ),

            if (showVegIndicator)
              _vegIndicator(),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // ACTIONS - DESKTOP
  // ============================================================

  Widget _buildActions(
      BuildContext context,
      ) {
    return SizedBox(
      width: 110,
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        crossAxisAlignment:
        CrossAxisAlignment.end,
        children: [
          _buildPopupMenu(
            context,
          ),

          Switch.adaptive(
            value: item.available,
            onChanged:
            onAvailabilityChanged,
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            item.available
                ? 'Available'
                : 'Unavailable',
            textAlign:
            TextAlign.end,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
              FontWeight.w600,
              color: item.available
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS - MOBILE
  // ============================================================

  Widget _buildMobileAvailability(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            item.available
                ? Icons
                .check_circle_outline
                : Icons
                .visibility_off_outlined,
            size: 18,
            color: item.available
                ? Colors.green
                : Colors.red,
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Text(
              item.available
                  ? 'Available'
                  : 'Unavailable',
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                FontWeight.w600,
                color: item.available
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ),

          Switch.adaptive(
            value: item.available,
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
      tooltip: 'More options',
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
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
              SizedBox(width: 10),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
              ),
              SizedBox(width: 10),
              Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IMAGE
  // ============================================================

  Widget _buildImage(
      BuildContext context,
      double size,
      ) {
    final imageUrl =
    item.imageUrl?.trim();

    if (imageUrl == null ||
        imageUrl.isEmpty) {
      return _imagePlaceholder(
        context,
        size,
        Icons.restaurant_menu,
      );
    }

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (
            _,
            _,
            _,
            ) {
          return _imagePlaceholder(
            context,
            size,
            Icons
                .broken_image_outlined,
          );
        },
      ),
    );
  }

  Widget _imagePlaceholder(
      BuildContext context,
      double size,
      IconData icon,
      ) {
    return Container(
      width: size,
      height: size,
      decoration:
      BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: size * 0.35,
      ),
    );
  }

  // ============================================================
  // VEG / NON-VEG
  // ============================================================

  Widget _vegIndicator() {
    final color =
    item.veg
        ? Colors.green
        : Colors.red;

    return Container(
      width: 18,
      height: 18,
      decoration:
      BoxDecoration(
        border: Border.all(
          width: 1.5,
          color: color,
        ),
        borderRadius:
        BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          width: 7,
          height: 7,
          decoration:
          BoxDecoration(
            shape:
            BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TAGS
  // ============================================================

  List<Widget> _buildTags() {
    return [
      if (item.bestSeller)
        const _Tag(
          label: 'Best Seller',
          icon: Icons.star,
        ),

      if (item.recommended)
        const _Tag(
          label: 'Recommended',
          icon: Icons
              .thumb_up_alt_outlined,
        ),

      if (!item.available)
        const _Tag(
          label: 'Unavailable',
          icon: Icons
              .visibility_off_outlined,
        ),
    ];
  }
}

// ============================================================
// TAG
// ============================================================

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration:
      BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
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
            size: 13,
          ),

          const SizedBox(
            width: 4,
          ),

          Text(
            label,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}