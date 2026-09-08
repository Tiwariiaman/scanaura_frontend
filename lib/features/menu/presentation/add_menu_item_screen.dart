import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../business/presentation/providers/business_notifier.dart';
import '../data/models/catalog_request.dart';
import '../data/models/catalog_response.dart';
import 'providers/menu_notifier.dart';
import 'providers/menu_state.dart';

class AddMenuItemScreen
    extends ConsumerStatefulWidget {
  const AddMenuItemScreen({
    super.key,
    this.item,
  });

  final CatalogResponse? item;

  bool get isEditing =>
      item != null;

  @override
  ConsumerState<AddMenuItemScreen>
  createState() =>
      _AddMenuItemScreenState();
}

class _AddMenuItemScreenState
    extends ConsumerState<AddMenuItemScreen> {
  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _nameController;

  late final TextEditingController
  _descriptionController;

  late final TextEditingController
  _priceController;

  late final TextEditingController
  _displayOrderController;

  String? _categoryId;

  bool _veg = true;
  bool _available = true;
  bool _bestSeller = false;
  bool _recommended = false;

  String? _imageUrl;

  bool _imageRemoved = false;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _nameController =
        TextEditingController(
          text: item?.name ?? '',
        );

    _descriptionController =
        TextEditingController(
          text: item?.description ?? '',
        );

    _priceController =
        TextEditingController(
          text: item?.price.toString() ?? '',
        );

    _displayOrderController =
        TextEditingController(
          text:
          item?.displayOrder
              .toString() ??
              '0',
        );

    _categoryId =
        item?.categoryId;

    _veg =
        item?.veg ?? true;

    _available =
        item?.available ?? true;

    _bestSeller =
        item?.bestSeller ?? false;

    _recommended =
        item?.recommended ?? false;

    _imageUrl =
        item?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _displayOrderController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUSINESS TYPE
  // ============================================================

  bool get _isFoodBusiness {
    final business =
        ref
            .read(
          businessNotifierProvider,
        )
            .business;

    return business?.businessType
        .trim()
        .toUpperCase() ==
        'FOOD';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final state =
    ref.watch(
      menuNotifierProvider,
    );

    final businessState =
    ref.watch(
      businessNotifierProvider,
    );

    final showVegOption =
        businessState.business
            ?.businessType
            .trim()
            .toUpperCase() ==
            'FOOD';

    final hasExistingImage =
        widget.isEditing &&
            _imageUrl != null &&
            _imageUrl!.trim().isNotEmpty &&
            !_imageRemoved;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Edit Item'
              : 'Add Item',
          style:
          const TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final width =
                constraints.maxWidth;

            final horizontalPadding =
            width < 360
                ? 12.0
                : width < 600
                ? 16.0
                : 20.0;

            return Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
                padding:
                EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  32,
                ),
                children: [
                  Center(
                    child:
                    ConstrainedBox(
                      constraints:
                      const BoxConstraints(
                        maxWidth: 760,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,
                        children: [
                          // ==================================================
                          // EXISTING IMAGE
                          // ==================================================

                          if (hasExistingImage) ...[
                            _buildExistingImageSection(
                              context,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],

                          // ==================================================
                          // IMAGE REMOVED / NO IMAGE INFORMATION
                          // ==================================================

                          if (widget.isEditing &&
                              _imageRemoved) ...[
                            _buildImageRemovedNotice(
                              context,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],

                          // ==================================================
                          // ITEM INFORMATION
                          // ==================================================

                          _sectionTitle(
                            context,
                            'Item Information',
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          TextFormField(
                            controller:
                            _nameController,
                            textInputAction:
                            TextInputAction
                                .next,
                            textCapitalization:
                            TextCapitalization
                                .words,
                            decoration:
                            const InputDecoration(
                              labelText:
                              'Item name',
                              hintText:
                              'e.g. Product or Service Name',
                              prefixIcon:
                              Icon(
                                Icons
                                    .inventory_2_outlined,
                              ),
                            ),
                            validator:
                                (value) {
                              if (value ==
                                  null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return 'Item name is required';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          TextFormField(
                            controller:
                            _descriptionController,
                            maxLines: 3,
                            textCapitalization:
                            TextCapitalization
                                .sentences,
                            decoration:
                            const InputDecoration(
                              labelText:
                              'Description',
                              hintText:
                              'Describe this item',
                              prefixIcon:
                              Icon(
                                Icons
                                    .description_outlined,
                              ),
                              alignLabelWithHint:
                              true,
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          // ==================================================
                          // PRICE + ORDER
                          // ==================================================

                          LayoutBuilder(
                            builder: (
                                context,
                                rowConstraints,
                                ) {
                              if (rowConstraints
                                  .maxWidth <
                                  500) {
                                return Column(
                                  children: [
                                    _priceField(),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    _displayOrderField(),
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Expanded(
                                    child:
                                    _priceField(),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child:
                                    _displayOrderField(),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          // ==================================================
                          // CATEGORY
                          // ==================================================

                          _buildCategoryDropdown(
                            state,
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ==================================================
                          // OPTIONS
                          // ==================================================

                          _sectionTitle(
                            context,
                            'Options',
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          // --------------------------------------------------
                          // VEG / NON-VEG — FOOD ONLY
                          // --------------------------------------------------

                          if (showVegOption)
                            _buildOptionCard(
                              context,
                              icon:
                              Icons.eco_outlined,
                              title:
                              'Vegetarian',
                              subtitle:
                              'Mark this item as vegetarian.',
                              value: _veg,
                              activeColor:
                              Colors.green,
                              onChanged:
                                  (value) {
                                setState(() {
                                  _veg =
                                      value;
                                });
                              },
                            ),

                          // --------------------------------------------------
                          // AVAILABLE
                          // --------------------------------------------------

                          _buildOptionCard(
                            context,
                            icon: Icons
                                .visibility_outlined,
                            title:
                            'Available',
                            subtitle:
                            'Turn off to hide this item from customers.',
                            value:
                            _available,
                            activeColor:
                            Theme.of(
                              context,
                            )
                                .colorScheme
                                .primary,
                            onChanged:
                                (value) {
                              setState(() {
                                _available =
                                    value;
                              });
                            },
                          ),

                          // --------------------------------------------------
                          // BEST SELLER
                          // --------------------------------------------------

                          _buildOptionCard(
                            context,
                            icon: Icons
                                .star_outline_rounded,
                            title:
                            'Best Seller',
                            subtitle:
                            'Highlight this item as a best seller.',
                            value:
                            _bestSeller,
                            activeColor:
                            Colors.orange,
                            onChanged:
                                (value) {
                              setState(() {
                                _bestSeller =
                                    value;
                              });
                            },
                          ),

                          // --------------------------------------------------
                          // RECOMMENDED
                          // --------------------------------------------------

                          _buildOptionCard(
                            context,
                            icon: Icons
                                .thumb_up_alt_outlined,
                            title:
                            'Recommended',
                            subtitle:
                            'Mark this item as recommended.',
                            value:
                            _recommended,
                            activeColor:
                            Theme.of(
                              context,
                            )
                                .colorScheme
                                .primary,
                            onChanged:
                                (value) {
                              setState(() {
                                _recommended =
                                    value;
                              });
                            },
                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          // ==================================================
                          // SAVE BUTTON
                          // ==================================================

                          SizedBox(
                            width:
                            double.infinity,
                            height: 54,
                            child:
                            FilledButton.icon(
                              onPressed:
                              state.status ==
                                  MenuStatus
                                      .loading
                                  ? null
                                  : _saveItem,
                              icon:
                              state.status ==
                                  MenuStatus
                                      .loading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                CircularProgressIndicator(
                                  strokeWidth:
                                  2.3,
                                ),
                              )
                                  : Icon(
                                widget
                                    .isEditing
                                    ? Icons
                                    .save_outlined
                                    : Icons
                                    .check_rounded,
                              ),
                              label:
                              Text(
                                state.status ==
                                    MenuStatus
                                        .loading
                                    ? widget
                                    .isEditing
                                    ? 'Saving Changes...'
                                    : 'Saving Item...'
                                    : widget
                                    .isEditing
                                    ? 'Save Changes'
                                    : 'Save Item',
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          SizedBox(
                            width:
                            double.infinity,
                            height: 48,
                            child:
                            OutlinedButton(
                              onPressed:
                              state.status ==
                                  MenuStatus
                                      .loading
                                  ? null
                                  : () {
                                Navigator.of(
                                  context,
                                ).pop();
                              },
                              child:
                              const Text(
                                'Cancel',
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      BuildContext context,
      String title,
      ) {
    return Text(
      title,
      style:
      Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(
        fontWeight:
        FontWeight.w700,
      ),
    );
  }

  // ============================================================
  // PRICE FIELD
  // ============================================================

  Widget _priceField() {
    return TextFormField(
      controller:
      _priceController,
      keyboardType:
      const TextInputType.numberWithOptions(
        decimal: true,
      ),
      textInputAction:
      TextInputAction.next,
      decoration:
      const InputDecoration(
        labelText: 'Price',
        prefixText: '₹ ',
        prefixIcon:
        Icon(
          Icons
              .currency_rupee_outlined,
        ),
      ),
      validator: (value) {
        final price =
        double.tryParse(
          value?.trim() ?? '',
        );

        if (price == null ||
            price <= 0) {
          return 'Enter a valid price';
        }

        return null;
      },
    );
  }

  // ============================================================
  // DISPLAY ORDER
  // ============================================================

  Widget _displayOrderField() {
    return TextFormField(
      controller:
      _displayOrderController,
      keyboardType:
      TextInputType.number,
      textInputAction:
      TextInputAction.next,
      decoration:
      const InputDecoration(
        labelText:
        'Display order',
        hintText: '0',
        prefixIcon:
        Icon(
          Icons
              .format_list_numbered_rounded,
        ),
      ),
      validator: (value) {
        final order =
        int.tryParse(
          value?.trim() ?? '',
        );

        if (order == null ||
            order < 0) {
          return 'Enter a valid order';
        }

        return null;
      },
    );
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  Widget _buildCategoryDropdown(
      MenuState state,
      ) {
    if (state.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return DropdownButtonFormField<String?>(
      initialValue:
      _categoryId,
      isExpanded: true,
      decoration:
      const InputDecoration(
        labelText:
        'Category',
        prefixIcon:
        Icon(
          Icons
              .category_outlined,
        ),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child:
          Text(
            'No category',
          ),
        ),
        ...state.categories.map(
              (category) {
            return DropdownMenuItem<String?>(
              value:
              category.id,
              child:
              Text(
                category.name,
                maxLines: 1,
                overflow:
                TextOverflow
                    .ellipsis,
              ),
            );
          },
        ),
      ],
      onChanged: (value) {
        setState(() {
          _categoryId =
              value;
        });
      },
    );
  }

  // ============================================================
  // OPTION CARD
  // ============================================================

  Widget _buildOptionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required bool value,
        required Color activeColor,
        required ValueChanged<bool>
        onChanged,
      }) {
    return Card(
      elevation: 0,
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      child:
      SwitchListTile.adaptive(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 4,
        ),
        secondary:
        Container(
          width: 40,
          height: 40,
          alignment:
          Alignment.center,
          decoration:
          BoxDecoration(
            color: activeColor
                .withValues(
              alpha: 0.10,
            ),
            borderRadius:
            BorderRadius.circular(
              10,
            ),
          ),
          child:
          Icon(
            icon,
            color:
            activeColor,
            size: 21,
          ),
        ),
        title: Text(
          title,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow:
          TextOverflow.ellipsis,
        ),
        value:
        value,
        onChanged:
        onChanged,
      ),
    );
  }

  // ============================================================
  // EXISTING IMAGE
  // ============================================================

  Widget _buildExistingImageSection(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Card(
      clipBehavior:
      Clip.antiAlias,
      elevation: 0,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio:
            16 / 9,
            child:
            Image.network(
              _imageUrl!,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                  _,
                  _,
                  _,
                  ) {
                return Container(
                  color: theme
                      .colorScheme
                      .surfaceContainerHighest,
                  alignment:
                  Alignment.center,
                  child:
                  Icon(
                    Icons
                        .broken_image_outlined,
                    size: 48,
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                );
              },
              loadingBuilder:
                  (
                  context,
                  child,
                  progress,
                  ) {
                if (progress ==
                    null) {
                  return child;
                }

                return Container(
                  color: theme
                      .colorScheme
                      .surfaceContainerHighest,
                  alignment:
                  Alignment.center,
                  child:
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2.4,
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.all(
              14,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .stretch,
              children: [
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Icon(
                      Icons
                          .image_outlined,
                      size: 20,
                      color: theme
                          .colorScheme
                          .primary,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          const Text(
                            'Item Image',
                            style:
                            TextStyle(
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            'Images can no longer be replaced. You can remove the current image.',
                            style:
                            TextStyle(
                              fontSize:
                              13,
                              color: theme
                                  .colorScheme
                                  .onSurfaceVariant,
                              height:
                              1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 12,
                ),

                OutlinedButton.icon(
                  onPressed:
                  _confirmRemoveImage,
                  icon:
                  const Icon(
                    Icons
                        .delete_outline_rounded,
                  ),
                  label:
                  const Text(
                    'Remove Image',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE REMOVED NOTICE
  // ============================================================

  Widget _buildImageRemovedNotice(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Container(
      padding:
      const EdgeInsets.all(14),
      decoration:
      BoxDecoration(
        color: theme
            .colorScheme
            .errorContainer,
        borderRadius:
        BorderRadius.circular(
          14,
        ),
        border:
        Border.all(
          color: theme
              .colorScheme
              .error
              .withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          Icon(
            Icons
                .image_not_supported_outlined,
            color: theme
                .colorScheme
                .onErrorContainer,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  'Image will be removed',
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight.w700,
                    color: theme
                        .colorScheme
                        .onErrorContainer,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  'Save the item to permanently remove the image from this menu item.',
                  style:
                  TextStyle(
                    fontSize:
                    13,
                    color: theme
                        .colorScheme
                        .onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          IconButton(
            tooltip:
            'Undo remove',
            onPressed: () {
              setState(() {
                _imageRemoved =
                false;
              });
            },
            icon:
            const Icon(
              Icons.undo_rounded,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REMOVE IMAGE
  // ============================================================

  Future<void>
  _confirmRemoveImage() async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) {
        return AlertDialog(
          title:
          const Text(
            'Remove Image?',
          ),
          content:
          const Text(
            'This will remove the image from this menu item. The image file itself will not be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child:
              const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child:
              const Text(
                'Remove',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted ||
        confirmed != true) {
      return;
    }

    setState(() {
      _imageUrl = null;
      _imageRemoved = true;
    });
  }

  // ============================================================
  // SAVE ITEM
  // ============================================================

  Future<void> _saveItem() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final price =
    double.tryParse(
      _priceController.text
          .trim(),
    );

    if (price == null ||
        price <= 0) {
      return;
    }

    final displayOrder =
        int.tryParse(
          _displayOrderController
              .text
              .trim(),
        ) ??
            0;

    final String? imageUrl =
    _imageRemoved
        ? null
        : _imageUrl;

    // For non-food businesses the
    // vegetarian field is not user-facing.
    // We keep sending the existing backend
    // field for compatibility.
    final showVegOption =
        _isFoodBusiness;

    final request =
    CatalogRequest(
      categoryId:
      _categoryId,
      name:
      _nameController
          .text
          .trim(),
      description:
      _descriptionController
          .text
          .trim(),
      price:
      price,
      imageUrl:
      imageUrl,
      veg:
      showVegOption
          ? _veg
          : true,
      available:
      _available,
      bestSeller:
      _bestSeller,
      recommended:
      _recommended,
      displayOrder:
      displayOrder,
    );

    final notifier =
    ref.read(
      menuNotifierProvider
          .notifier,
    );

    final success =
    widget.isEditing
        ? await notifier
        .updateCatalog(
      widget.item!.id,
      request,
    )
        : await notifier
        .createCatalog(
      request,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          behavior:
          SnackBarBehavior
              .floating,
          content:
          Text(
            widget.isEditing
                ? 'Item updated successfully.'
                : 'Item added successfully.',
          ),
        ),
      );

      Navigator.of(
        context,
      ).pop();

      return;
    }

    final error =
        ref
            .read(
          menuNotifierProvider,
        )
            .errorMessage;

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          behavior:
          SnackBarBehavior
              .floating,
          content:
          Text(error),
        ),
      );
    }
  }
}