
class Part {
  final int? id;
  final String name;
  final String? category;
  final double price;
  final int stockQty;
  final int minStock;
  final List<String> compatibleModels;

  Part({
    this.id,
    required this.name,
    this.category,
    required this.price,
    required this.stockQty,
    this.minStock = 0,
    this.compatibleModels = const [],
  });


  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (category != null) 'category': category,
      'price': price,
      'stock_qty': stockQty,
      'min_stock': minStock,
      'compatible_models': compatibleModels, 
    };
  }


  factory Part.fromMap(Map<String, dynamic> map) {
    return Part(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: (map['price'] as num).toDouble(),
      stockQty: map['stock_qty'] ?? 0,
      minStock: map['min_stock'] ?? 0,

      compatibleModels: List<String>.from(map['compatible_models'] ?? []),
    );
  }


  Part copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    int? stockQty,
    int? minStock,
    List<String>? compatibleModels,
  }) {
    return Part(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stockQty: stockQty ?? this.stockQty,
      minStock: minStock ?? this.minStock,
      compatibleModels: compatibleModels ?? this.compatibleModels,
    );
  }
}