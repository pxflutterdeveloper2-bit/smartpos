class Product {
  const Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.createdAt,
  });

  final int? id;
  final String name;
  final double price;
  final int stock;
  final String? createdAt;

  Product copyWith({
    int? id,
    String? name,
    double? price,
    int? stock,
    String? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'created_at': createdAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      createdAt: map['created_at'] as String?,
    );
  }
}
