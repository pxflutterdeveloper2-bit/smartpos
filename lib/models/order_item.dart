class OrderItem {
  const OrderItem({
    this.id,
    this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  final int? id;
  final int? orderId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;

  double get lineTotal => price * quantity;

  OrderItem copyWith({
    int? id,
    int? orderId,
    int? productId,
    String? productName,
    double? price,
    int? quantity,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as int?,
      orderId: map['order_id'] as int?,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
  }
}
