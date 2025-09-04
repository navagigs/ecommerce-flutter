class Favorite {
  final String? favoriteId;
  final String? userId;
  final int? item_id;
  final double? price;
  final List<String>? sizes;
  final double? rating;
  final List<String>? tags;
  final String? image;
  final List<String>? colors;
  final String? description;
  final String? name;

  Favorite({
    this.favoriteId,
    this.userId,
    this.item_id,
    this.price,
    this.sizes,
    this.rating,
    this.tags,
    this.image,
    this.colors,
    this.description,
    this.name,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      favoriteId: json['favorite_od'],
      userId: json['user_id'],
      item_id: int.tryParse(json['item_id'].toString()),
      price: double.tryParse(json['price'].toString()),
      sizes: json['sizes']?.toString().split(',').map((e) => e.trim()).toList(),
      rating: double.tryParse(json['rating'].toString()),
      tags: json['tags']?.toString().split(',').map((e) => e.trim()).toList(),
      image: json['image'],
      colors:
          json['colors']?.toString().split(',').map((e) => e.trim()).toList(),
      description: json['description'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favorite_od': favoriteId,
      'user_id': userId,
      'item_id': item_id,
      'price': price.toString(),
      'sizes': sizes?.join(', '),
      'rating': rating.toString(),
      'tags': tags?.join(','),
      'image': image,
      'colors': colors?.join(', '),
      'description': description,
      'name': name,
    };
  }
}
