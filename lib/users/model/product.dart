class Product {
  final String name;
  final String imageUrl;
  final String price;
  final int stock;

  const Product({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        name: json['name'] as String,
        imageUrl: json['image_url'] as String,
        price: json['price'] as String,
        stock: json['stock'] as int,
      );
}
