import 'property.dart';

class SearchFilter {
  final String? query;
  final PropertyType? propertyType;
  final double? minPrice;
  final double? maxPrice;
  final double? minSize;
  final double? maxSize;
  final int? bedrooms;
  final int? bathrooms;
  final bool? furnished;
  final List<String> tags;
  final List<String> mustTags;
  final List<String> optionalTags;
  final String? sellerId;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final String? sortBy;

  const SearchFilter({
    this.query,
    this.propertyType,
    this.minPrice,
    this.maxPrice,
    this.minSize,
    this.maxSize,
    this.bedrooms,
    this.bathrooms,
    this.furnished,
    this.tags = const [],
    this.mustTags = const [],
    this.optionalTags = const [],
    this.sellerId,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.sortBy,
  });

  SearchFilter copyWith({
    String? query,
    PropertyType? propertyType,
    double? minPrice,
    double? maxPrice,
    double? minSize,
    double? maxSize,
    int? bedrooms,
    int? bathrooms,
    bool? furnished,
    List<String>? tags,
    List<String>? mustTags,
    List<String>? optionalTags,
    String? sellerId,
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? sortBy,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      propertyType: propertyType ?? this.propertyType,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minSize: minSize ?? this.minSize,
      maxSize: maxSize ?? this.maxSize,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      furnished: furnished ?? this.furnished,
      tags: tags ?? this.tags,
      mustTags: mustTags ?? this.mustTags,
      optionalTags: optionalTags ?? this.optionalTags,
      sellerId: sellerId ?? this.sellerId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  Map<String, String> toQueryParameters({required int page, required int limit}) {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (query?.isNotEmpty == true) params['search'] = query!;
    if (propertyType != null) params['property_type'] = propertyType!.name;
    if (minPrice != null) params['min_price'] = minPrice!.toString();
    if (maxPrice != null) params['max_price'] = maxPrice!.toString();
    if (minSize != null) params['min_size'] = minSize!.toString();
    if (maxSize != null) params['max_size'] = maxSize!.toString();
    if (bedrooms != null) params['bedrooms'] = bedrooms!.toString();
    if (bathrooms != null) params['bathrooms'] = bathrooms!.toString();
    if (furnished != null) params['furnished'] = furnished!.toString();
    if (tags.isNotEmpty) params['tags'] = tags.join(',');
    if (mustTags.isNotEmpty) params['must_tags'] = mustTags.join(',');
    if (optionalTags.isNotEmpty) params['optional_tags'] = optionalTags.join(',');
    if (sellerId?.isNotEmpty == true) params['seller_id'] = sellerId!;
    if (latitude != null && longitude != null) {
      params['latitude'] = latitude!.toString();
      params['longitude'] = longitude!.toString();
    }
    if (radiusKm != null) params['radius'] = radiusKm!.toString();
    if (sortBy?.isNotEmpty == true) params['sort_by'] = sortBy!;

    return params;
  }

  bool get hasLocation => latitude != null && longitude != null;
}
