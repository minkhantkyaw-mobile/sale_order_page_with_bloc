class ProductCategory {
  final int id;
  final String name;


  ProductCategory({
    required this.id,
    required this.name,
  });

  ProductCategory copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
  factory ProductCategory.fromMap(Map<String, dynamic> map) {
    return ProductCategory(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

}
