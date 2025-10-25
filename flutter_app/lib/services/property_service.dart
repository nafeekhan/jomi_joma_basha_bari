import '../models/property.dart';
import '../models/property_tag.dart';
import '../models/search_filter.dart';
import '../models/vendor.dart';
import '../config/api_config.dart';
import '../utils/dummy_data.dart';
import 'api_service.dart';

/// Property Service
class PropertyService {
  final ApiService _apiService;

  PropertyService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Get all properties with filters
  Future<List<Property>> getProperties({
    SearchFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = filter?.toQueryParameters(page: page, limit: limit) ??
          {
            'page': page.toString(),
            'limit': limit.toString(),
          };

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
      final fallbackFilter = filter ?? const SearchFilter();
      final fallback = DummyData.filterProperties(fallbackFilter);
      if (fallback.isNotEmpty) {
        return fallback.take(limit).toList();
      }
      return DummyData.properties.take(limit).toList();
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
      for (final property in DummyData.properties) {
        if (property.id == id) {
          return property;
        }
      }
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

  /// Fetch available property tags with counts
  Future<List<PropertyTag>> getPropertyTags({String? search}) async {
    try {
      final response = await _apiService.get(
        ApiConfig.propertyTags,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final tags = response['data']['tags'] as List<dynamic>;
        return tags
            .map((tag) => PropertyTag.fromJson(tag as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to fetch tags');
      }
    } catch (e) {
      final lower = search?.toLowerCase() ?? '';
      final fallback = lower.isEmpty
          ? DummyData.tags
          : DummyData.tags
              .where((tag) => tag.name.toLowerCase().contains(lower))
              .toList();
      if (fallback.isNotEmpty) {
        return fallback;
      }
      if (e is ApiException) rethrow;
      throw ApiException('Get tags error: $e');
    }
  }

  /// Fetch vendor (seller) leaderboard
  Future<List<Vendor>> getVendors({String? search}) async {
    try {
      final response = await _apiService.get(
        ApiConfig.propertyVendors,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final vendors = response['data']['vendors'] as List<dynamic>;
        return vendors
            .map((vendor) => Vendor.fromJson(vendor as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to fetch vendors');
      }
    } catch (e) {
      final lower = search?.toLowerCase() ?? '';
      final fallback = lower.isEmpty
          ? DummyData.vendors
          : DummyData.vendors
              .where((vendor) =>
                  vendor.fullName.toLowerCase().contains(lower) ||
                  (vendor.companyName ?? '')
                      .toLowerCase()
                      .contains(lower))
              .toList();
      if (fallback.isNotEmpty) {
        return fallback;
      }
      if (e is ApiException) rethrow;
      throw ApiException('Get vendors error: $e');
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}
