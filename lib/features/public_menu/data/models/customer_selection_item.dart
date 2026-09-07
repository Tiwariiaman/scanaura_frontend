class CustomerSelectionItem {
  const CustomerSelectionItem({
    required this.selectionId,
    required this.itemName,
    required this.unitPrice,
    this.quantity = 1,
  }) : assert(quantity > 0);

  final String selectionId;
  final String itemName;
  final double unitPrice;
  final int quantity;

  bool get hasPrice => unitPrice > 0;

  double get estimatedTotal => unitPrice * quantity;

  CustomerSelectionItem copyWith({
    String? selectionId,
    String? itemName,
    double? unitPrice,
    int? quantity,
  }) {
    return CustomerSelectionItem(
      selectionId: selectionId ?? this.selectionId,
      itemName: itemName ?? this.itemName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  CustomerSelectionItem increaseQuantity() {
    return copyWith(quantity: quantity + 1);
  }

  CustomerSelectionItem decreaseQuantity() {
    if (quantity <= 1) {
      return this;
    }

    return copyWith(quantity: quantity - 1);
  }
}