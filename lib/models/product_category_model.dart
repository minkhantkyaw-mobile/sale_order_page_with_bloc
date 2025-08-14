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
}
