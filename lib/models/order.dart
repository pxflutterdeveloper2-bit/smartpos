class PosOrder {
  const PosOrder({
    this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.customerName,
  });

  final int? id;
  final String orderNumber;
  final double totalAmount;
  final String status;
  final String createdAt;
  final String? customerName;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'total_amount': totalAmount,
      'status': status,
      'created_at': createdAt,
      'customer_name': customerName,
    };
  }

  factory PosOrder.fromMap(Map<String, dynamic> map) {
    return PosOrder(
      id: map['id'] as int?,
      orderNumber: map['order_number'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: map['created_at'] as String,
      customerName: map['customer_name'] as String?,
    );
  }
}
