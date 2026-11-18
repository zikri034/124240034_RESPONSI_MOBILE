class ProductDimensions {
  final double width;
  final double height;
  final double depth;

  ProductDimensions({
    this.width = 0.0,
    this.height = 0.0,
    this.depth = 0.0,
  });

  factory ProductDimensions.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProductDimensions();
    return ProductDimensions(
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      depth: (json['depth'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'depth': depth,
    };
  }
}

class ProductReview {
  final int rating;
  final String comment;
  final String date;
  final String reviewerName;
  final String reviewerEmail;

  ProductReview({
    this.rating = 0,
    this.comment = '',
    this.date = '',
    this.reviewerName = '',
    this.reviewerEmail = '',
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String? ?? '',
      date: json['date'] as String? ?? '',
      reviewerName: json['reviewerName'] as String? ?? '',
      reviewerEmail: json['reviewerEmail'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      'date': date,
      'reviewerName': reviewerName,
      'reviewerEmail': reviewerEmail,
    };
  }
}

class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String? brand;
  final int? weight;
  final ProductDimensions? dimensions;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? availabilityStatus;
  final List<ProductReview> reviews;
  final String? returnPolicy;
  final int? minimumOrderQuantity;
  final List<String> images;
  final String thumbnail;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
    required this.stock,
    this.category = '',
    this.rating = 0.0,
    this.discountPercentage = 0.0,
    this.tags = const [],
    this.brand,
    this.weight,
    this.dimensions,
    this.warrantyInformation,
    this.shippingInformation,
    this.availabilityStatus,
    this.reviews = const [],
    this.returnPolicy,
    this.minimumOrderQuantity,
    this.images = const [],
  });

  double get originalPrice {
    if (discountPercentage <= 0) return price;
    return price / (1 - (discountPercentage / 100));
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List<dynamic>? ?? [];
    final List<String> parsedImages = rawImages.map((e) => e.toString()).toList();

    // FakeStoreAPI compatibility: uses single 'image' field
    final String singleImage = json['image'] as String? ?? '';
    if (parsedImages.isEmpty && singleImage.isNotEmpty) {
      parsedImages.add(singleImage);
    }

    final rawTags = json['tags'] as List<dynamic>? ?? [];
    final List<String> parsedTags = rawTags.map((e) => e.toString()).toList();

    final rawReviews = json['reviews'] as List<dynamic>? ?? [];
    final List<ProductReview> parsedReviews = rawReviews
        .map((r) => ProductReview.fromJson(r as Map<String, dynamic>))
        .toList();

    // Rating parsing: support both double/int and FakeStoreAPI map {"rate": 3.9, "count": 120}
    double parsedRating = 0.0;
    if (json['rating'] is num) {
      parsedRating = (json['rating'] as num).toDouble();
    } else if (json['rating'] is Map) {
      parsedRating = ((json['rating'] as Map)['rate'] as num?)?.toDouble() ?? 0.0;
    }

    // Stock parsing:
    // If 'stock' exists in json, use it.
    // If coming from FakeStoreAPI (has 'image' or rating is Map), default to 20 so items can be purchased.
    // Otherwise default to 0 (handles empty json gracefully).
    int parsedStock = 0;
    if (json.containsKey('stock')) {
      parsedStock = (json['stock'] as num?)?.toInt() ?? 0;
    } else if (json.containsKey('image') || json['rating'] is Map) {
      if (json['rating'] is Map && (json['rating'] as Map)['count'] != null) {
        final count = ((json['rating'] as Map)['count'] as num?)?.toInt() ?? 20;
        parsedStock = count > 0 ? (count % 50) + 5 : 20;
      } else {
        parsedStock = 20;
      }
    }

    final String parsedThumbnail = json['thumbnail'] as String? ??
        (singleImage.isNotEmpty ? singleImage : (parsedImages.isNotEmpty ? parsedImages.first : ''));

    return Product(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: parsedRating,
      stock: parsedStock,
      tags: parsedTags,
      brand: json['brand'] as String?,
      weight: (json['weight'] as num?)?.toInt(),
      dimensions: json['dimensions'] != null
          ? ProductDimensions.fromJson(json['dimensions'] as Map<String, dynamic>?)
          : null,
      warrantyInformation: json['warrantyInformation'] as String?,
      shippingInformation: json['shippingInformation'] as String?,
      availabilityStatus: json['availabilityStatus'] as String?,
      reviews: parsedReviews,
      returnPolicy: json['returnPolicy'] as String?,
      minimumOrderQuantity: (json['minimumOrderQuantity'] as num?)?.toInt(),
      images: parsedImages,
      thumbnail: parsedThumbnail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'tags': tags,
      'brand': brand,
      'weight': weight,
      'dimensions': dimensions?.toJson(),
      'warrantyInformation': warrantyInformation,
      'shippingInformation': shippingInformation,
      'availabilityStatus': availabilityStatus,
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'returnPolicy': returnPolicy,
      'minimumOrderQuantity': minimumOrderQuantity,
      'images': images,
      'thumbnail': thumbnail,
    };
  }
}
