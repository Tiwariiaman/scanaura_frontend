import 'models/customer_selection_item.dart';

class CustomerSelectionController {
  CustomerSelectionController({
    Map<String, CustomerSelectionItem>? initialItems,
  }) : _items = Map<String, CustomerSelectionItem>.from(
    initialItems ?? <String, CustomerSelectionItem>{},
  );

  final Map<String, CustomerSelectionItem> _items;

  Map<String, CustomerSelectionItem> get items =>
      Map.unmodifiable(_items);

  List<CustomerSelectionItem> get selectedItems =>
      List.unmodifiable(_items.values);

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  int get selectedItemCount => _items.length;

  int get totalUnitCount => _items.values.fold<int>(
    0,
        (total, item) => total + item.quantity,
  );

  bool contains(String selectionId) {
    return _items.containsKey(selectionId);
  }

  CustomerSelectionItem? item(String selectionId) {
    return _items[selectionId];
  }

  double get estimatedTotal => _items.values.fold<double>(
    0,
        (total, item) => total + item.estimatedTotal,
  );

  bool get hasPricedItems => _items.values.any(
        (item) => item.hasPrice,
  );

  void toggleItem({
    required String selectionId,
    required String itemName,
    required double unitPrice,
  }) {
    if (_items.containsKey(selectionId)) {
      _items.remove(selectionId);
      return;
    }

    _items[selectionId] = CustomerSelectionItem(
      selectionId: selectionId,
      itemName: itemName,
      unitPrice: unitPrice,
    );
  }

  void selectItem({
    required String selectionId,
    required String itemName,
    required double unitPrice,
  }) {
    if (_items.containsKey(selectionId)) {
      return;
    }

    _items[selectionId] = CustomerSelectionItem(
      selectionId: selectionId,
      itemName: itemName,
      unitPrice: unitPrice,
    );
  }

  void removeItem(String selectionId) {
    _items.remove(selectionId);
  }

  void increaseQuantity(String selectionId) {
    final selectedItem = _items[selectionId];

    if (selectedItem == null) {
      return;
    }

    _items[selectionId] = selectedItem.increaseQuantity();
  }

  void decreaseQuantity(String selectionId) {
    final selectedItem = _items[selectionId];

    if (selectedItem == null) {
      return;
    }

    if (selectedItem.quantity <= 1) {
      _items.remove(selectionId);
      return;
    }

    _items[selectionId] = selectedItem.decreaseQuantity();
  }

  void setQuantity(
      String selectionId,
      int quantity,
      ) {
    final selectedItem = _items[selectionId];

    if (selectedItem == null) {
      return;
    }

    if (quantity <= 0) {
      _items.remove(selectionId);
      return;
    }

    _items[selectionId] = selectedItem.copyWith(
      quantity: quantity,
    );
  }

  void clear() {
    _items.clear();
  }
}