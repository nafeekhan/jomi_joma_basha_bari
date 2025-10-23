import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/property.dart';
import '../config/api_config.dart';
import 'api_service.dart';

/// Property Service
class PropertyService {
  final ApiService _apiService;

  PropertyService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Get all properties with filters
  Future<List<Property>> getProperties({
    String? search,
    PropertyType? propertyType,
    double? minPrice,
    double? maxPrice,
    double? minSize,
    double? maxSize,
    int? bedrooms,
    int? bathrooms,
    bool? furnished,
    List<String>? tags,
    double? latitude,
    double? longitude,
    double? radius,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null) queryParams['search'] = search;
      if (propertyType != null) queryParams['property_type'] = propertyType.name;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (minSize != null) queryParams['min_size'] = minSize.toString();
      if (maxSize != null) queryParams['max_size'] = maxSize.toString();
      if (bedrooms != null) queryParams['bedrooms'] = bedrooms.toString();
      if (bathrooms != null) queryParams['bathrooms'] = bathrooms.toString();
      if (furnished != null) queryParams['furnished'] = furnished.toString();
      if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags.join(',');
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (radius != null) queryParams['radius'] = radius.toString();
      if (sortBy != null) queryParams['sort_by'] = sortBy;

      final response = await _apiService.get(
        ApiConfig.properties,
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final propertiesList = data['properties'] as List;
        return propertiesList
            .map((p) => Property.fromJson(p as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to fetch properties');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Get properties error: $e');
    }
  }

  /// Get property by ID
  Future<Property> getPropertyById(String id) async {
    try {
      final response = await _apiService.get(ApiConfig.propertyById(id));

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return Property.fromJson(data['property'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to fetch property');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Get property error: $e');
    }
  }

  /// Create new property
  Future<Property> createProperty({
    required String title,
    String? description,
    required PropertyType propertyType,
    required double price,
    double? sizeSqft,
    int? bedrooms,
    int? bathrooms,
    bool furnished = false,
    required String addressLine,
    required String city,
    String? state,
    required String country,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? googleMapsUrl,
    List<String>? tags,
  }) async {
    try {
      final body = {
        'title': title,
        if (description != null) 'description': description,
        'property_type': propertyType.name,
        'price': price,
        if (sizeSqft != null) 'size_sqft': sizeSqft,
        if (bedrooms != null) 'bedrooms': bedrooms,
        if (bathrooms != null) 'bathrooms': bathrooms,
        'furnished': furnished,
        'address_line': addressLine,
        'city': city,
        if (state != null) 'state': state,
        'country': country,
        if (postalCode != null) 'postal_code': postalCode,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (googleMapsUrl != null) 'google_maps_url': googleMapsUrl,
        if (tags != null) 'tags': tags,
      };

      final response = await _apiService.post(
        ApiConfig.properties,
        body: body,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return Property.fromJson(data['property'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to create property');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Create property error: $e');
    }
  }

  /// Update property
  Future<Property> updateProperty(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.put(
        ApiConfig.propertyById(id),
        body: updates,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return Property.fromJson(data['property'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to update property');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Update property error: $e');
    }
  }

  /// Delete property
  Future<void> deleteProperty(String id) async {
    try {
      final response = await _apiService.delete(
        ApiConfig.propertyById(id),
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw ApiException(response['message'] as String? ?? 'Failed to delete property');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Delete property error: $e');
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}

