import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/providers/app_providers.dart';
import '../data/models/catalog_request.dart';
import '../data/models/catalog_response.dart';
import 'providers/menu_notifier.dart';
import 'providers/menu_state.dart';

class AddMenuItemScreen extends ConsumerStatefulWidget {
  const AddMenuItemScreen({
    super.key,
    this.item,
  });

  final CatalogResponse? item;

  bool get isEditing => item != null;

  @override
  ConsumerState<AddMenuItemScreen> createState() =>
      _AddMenuItemScreenState();
}

class _AddMenuItemScreenState
    extends ConsumerState<AddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _displayOrderController;

  String? _categoryId;

  bool _veg = true;
  bool _available = true;
  bool _bestSeller = false;
  bool _recommended = false;

  XFile? _selectedImage;
  Uint8List? _imageBytes;
  String? _imageUrl;

  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _nameController = TextEditingController(
      text: item?.name ?? '',
    );

    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );

    _priceController = TextEditingController(
      text: item?.price.toString() ?? '',
    );

    _displayOrderController = TextEditingController(
      text: item?.displayOrder.toString() ?? '0',
    );

    _categoryId = item?.categoryId;

    _veg = item?.veg ?? true;
    _available = item?.available ?? true;
    _bestSeller = item?.bestSeller ?? false;
    _recommended = item?.recommended ?? false;

    _imageUrl = item?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _displayOrderController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(menuNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Edit Menu Item'
              : 'Add Menu Item',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildImageSection(),

            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item name',
                hintText: 'e.g. Paneer Butter Masala',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Item name is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the menu item',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final price =
                double.tryParse(value ?? '');

                if (price == null || price <= 0) {
                  return 'Enter a valid price';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildCategoryDropdown(
              state,
            ),

            const SizedBox(height: 12),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Vegetarian'),
              value: _veg,
              onChanged: (value) {
                setState(() {
                  _veg = value;
                });
              },
            ),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Available'),
              subtitle: const Text(
                'Turn off to hide this item from customers.',
              ),
              value: _available,
              onChanged: (value) {
                setState(() {
                  _available = value;
                });
              },
            ),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Best Seller'),
              value: _bestSeller,
              onChanged: (value) {
                setState(() {
                  _bestSeller = value;
                });
              },
            ),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recommended'),
              value: _recommended,
              onChanged: (value) {
                setState(() {
                  _recommended = value;
                });
              },
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller: _displayOrderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Display order',
                hintText: '0',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 28),

            FilledButton(
              onPressed:
              state.status == MenuStatus.loading ||
                  _uploadingImage
                  ? null
                  : _saveItem,
              child:
              state.status == MenuStatus.loading ||
                  _uploadingImage
                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : Text(
                widget.isEditing
                    ? 'Save Changes'
                    : 'Save Menu Item',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(
      MenuState state,
      ) {
    if (state.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return DropdownButtonFormField<String?>(
      initialValue: _categoryId,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('No category'),
        ),
        ...state.categories.map(
              (category) {
            return DropdownMenuItem<String?>(
              value: category.id,
              child: Text(category.name),
            );
          },
        ),
      ],
      onChanged: (value) {
        setState(() {
          _categoryId = value;
        });
      },
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _uploadingImage
          ? null
          : _pickImage,
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _imageBytes != null
            ? Image.memory(
          _imageBytes!,
          fit: BoxFit.cover,
        )
            : _imageUrl != null &&
            _imageUrl!.isNotEmpty
            ? Image.network(
          _imageUrl!,
          fit: BoxFit.cover,
          errorBuilder:
              (_, _, _) {
            return _emptyImage();
          },
        )
            : _emptyImage(),
      ),
    );
  }

  Widget _emptyImage() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
        ),
        SizedBox(height: 8),
        Text(
          'Add Item Image',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text('Tap to select image'),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();

    setState(() {
      _selectedImage = image;
      _imageBytes = bytes;
      _imageUrl = null;
    });
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.tryParse(
      _priceController.text.trim(),
    );

    if (price == null || price <= 0) {
      return;
    }

    final displayOrder =
        int.tryParse(
          _displayOrderController.text.trim(),
        ) ??
            0;

    String? imageUrl = _imageUrl;

    if (_imageBytes != null &&
        _selectedImage != null) {
      setState(() {
        _uploadingImage = true;
      });

      try {
        final imageService =
        ref.read(
          imageUploadServiceProvider,
        );

        final response =
        await imageService.uploadCatalogImage(
          _imageBytes!,
          _selectedImage!.name,
        );

        imageUrl = response.imageUrl;
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _uploadingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst(
                'Exception: ',
                '',
              ),
            ),
          ),
        );

        return;
      }

      if (mounted) {
        setState(() {
          _uploadingImage = false;
        });
      }
    }

    final request = CatalogRequest(
      categoryId: _categoryId,
      name: _nameController.text.trim(),
      description:
      _descriptionController.text.trim(),
      price: price,
      imageUrl: imageUrl,
      veg: _veg,
      available: _available,
      bestSeller: _bestSeller,
      recommended: _recommended,
      displayOrder: displayOrder,
    );

    final notifier =
    ref.read(
      menuNotifierProvider.notifier,
    );

    final success = widget.isEditing
        ? await notifier.updateCatalog(
      widget.item!.id,
      request,
    )
        : await notifier.createCatalog(
      request,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Menu item updated successfully.'
                : 'Menu item added successfully.',
          ),
        ),
      );

      Navigator.of(context).pop();
      return;
    }

    final error =
        ref.read(menuNotifierProvider).errorMessage;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
    }
  }
}