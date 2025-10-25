import 'package:equatable/equatable.dart';

/// Property type enum
enum PropertyType {
  buy,
  rent;

  String get displayName {
    switch (this) {
      case PropertyType.buy:
        return 'For Sale';
      case PropertyType.rent:
        return 'For Rent';
    }
  }
}

/// Property status enum
enum PropertyStatus {
  available,
  sold,
  rented,
  pending;

  String get displayName {
    switch (this) {
      case PropertyStatus.available:
        return 'Available';
      case PropertyStatus.sold:
        return 'Sold';
      case PropertyStatus.rented:
        return 'Rented';
      case PropertyStatus.pending:
        return 'Pending';
    }
  }
}

/// Property image model
class PropertyImage extends Equatable {
  final String id;
  final String imageUrl;
  final int imageOrder;
  final bool isCover;

  const PropertyImage({
    required this.id,
    required this.imageUrl,
    required this.imageOrder,
    required this.isCover,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      imageOrder: json['image_order'] as int? ?? 0,
      isCover: json['is_cover'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, imageUrl, imageOrder, isCover];
}

/// Review model
class Review extends Equatable {
  final String id;
  final String propertyId;
  final String buyerId;
  final String? reviewerName;
  final int rating;
  final String? reviewText;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.propertyId,
    required this.buyerId,
    this.reviewerName,
    required this.rating,
    this.reviewText,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      buyerId: json['buyer_id'] as String,
      reviewerName: json['reviewer_name'] as String?,
      rating: json['rating'] as int,
      reviewText: json['review_text'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, propertyId, buyerId, reviewerName, rating, reviewText, createdAt];
}

/// Property model
class Property extends Equatable {
  final String id;
  final String sellerId;
  final String title;
  final String? description;
  final PropertyType propertyType;
  final double price;
  final double? sizeSqft;
  final int? bedrooms;
  final int? bathrooms;
  final bool furnished;
  final String addressLine;
  final String city;
  final String? state;
  final String country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? googleMapsUrl;
  final PropertyStatus status;
  final int viewsCount;
  final double averageRating;
  final int totalReviews;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields from joins
  final String? sellerName;
  final String? companyName;
  final String? sellerEmail;
  final String? sellerPhone;
  final List<PropertyImage>? images;
  final List<String>? tags;
  final List<Review>? reviews;

  const Property({
    required this.id,
    required this.sellerId,
    required this.title,
    this.description,
    required this.propertyType,
    required this.price,
    this.sizeSqft,
    this.bedrooms,
    this.bathrooms,
    required this.furnished,
    required this.addressLine,
    required this.city,
    this.state,
    required this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.googleMapsUrl,
    required this.status,
    required this.viewsCount,
    required this.averageRating,
    required this.totalReviews,
    required this.createdAt,
    required this.updatedAt,
    this.sellerName,
    this.companyName,
    this.sellerEmail,
    this.sellerPhone,
    this.images,
    this.tags,
    this.reviews,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      propertyType: PropertyType.values.firstWhere(
        (e) => e.name == json['property_type'],
        orElse: () => PropertyType.buy,
      ),
      price: (json['price'] as num).toDouble(),
      sizeSqft: json['size_sqft'] != null ? (json['size_sqft'] as num).toDouble() : null,
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms'] as int?,
      furnished: json['furnished'] as bool? ?? false,
      addressLine: json['address_line'] as String,
      city: json['city'] as String,
      state: json['state'] as String?,
      country: json['country'] as String,
      postalCode: json['postal_code'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      googleMapsUrl: json['google_maps_url'] as String?,
      status: PropertyStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PropertyStatus.available,
      ),
      viewsCount: json['views_count'] as int? ?? 0,
      averageRating: json['average_rating'] != null ? (json['average_rating'] as num).toDouble() : 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sellerName: json['seller_name'] as String?,
      companyName: json['company_name'] as String?,
      sellerEmail: json['seller_email'] as String?,
      sellerPhone: json['seller_phone'] as String?,
      images: json['images'] != null
          ? (json['images'] as List).map((i) => PropertyImage.fromJson(i as Map<String, dynamic>)).toList()
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((r) => Review.fromJson(r as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'title': title,
      'description': description,
      'property_type': propertyType.name,
      'price': price,
      'size_sqft': sizeSqft,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'furnished': furnished,
      'address_line': addressLine,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'google_maps_url': googleMapsUrl,
      'status': status.name,
      'views_count': viewsCount,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullAddress {
    final parts = <String>[addressLine, city];
    if (state != null) parts.add(state!);
    parts.add(country);
    if (postalCode != null) parts.add(postalCode!);
    return parts.join(', ');
  }

  String get formattedPrice {
    if (price >= 1000000) {
      return '\$${(price / 1000000).toStringAsFixed(2)}M';
    } else if (price >= 1000) {
      return '\$${(price / 1000).toStringAsFixed(0)}K';
    }
    return '\$${price.toStringAsFixed(0)}';
  }

  /// Returns the cover image if marked, otherwise the first image.
  PropertyImage? get coverImage {
    final imageList = images;
    if (imageList == null || imageList.isEmpty) return null;

    try {
      return imageList.firstWhere((image) => image.isCover);
    } catch (_) {
      return imageList.first;
    }
  }

  /// Relative URL for the cover image if available.
  String? get coverImageUrl => coverImage?.imageUrl;

  @override
  List<Object?> get props => [
        id,
        sellerId,
        title,
        description,
        propertyType,
        price,
        sizeSqft,
        bedrooms,
        bathrooms,
        furnished,
        addressLine,
        city,
        state,
        country,
        postalCode,
        latitude,
        longitude,
        googleMapsUrl,
        status,
        viewsCount,
        averageRating,
        totalReviews,
        createdAt,
        updatedAt,
      ];
}
