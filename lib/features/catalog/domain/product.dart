class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String category;
  final int stock;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final double rating;
  final int reviewCount;
  final String? collection;
  final String? sellerId;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    required this.stock,
    this.images = const [],
    this.sizes = const [],
    this.colors = const [],
    this.rating = 0,
    this.reviewCount = 0,
    this.collection,
    this.sellerId,
    this.createdAt,
  });

  bool get inStock => stock > 0;

  String get displayImage =>
      images.isNotEmpty ? images.first : (imageUrl ?? '');

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      sizes: json['sizes'] != null
          ? List<String>.from(json['sizes'])
          : [],
      colors: json['colors'] != null
          ? List<String>.from(json['colors'])
          : [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      collection: json['collection'] as String?,
      sellerId: json['seller_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
