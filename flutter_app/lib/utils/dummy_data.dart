import '../models/property.dart';
import '../models/property_tag.dart';
import '../models/scene.dart';
import '../models/search_filter.dart';
import '../models/vendor.dart';

/// Provides placeholder data for offline/demo experiences.
class DummyData {
  static final List<Property> properties = [
    Property(
      id: 'prop-001',
      sellerId: 'vendor-001',
      title: 'Modern Downtown Loft',
      description:
          'Bright open-plan loft with floor-to-ceiling windows, sleek finishes, and convenient access to transit.',
      propertyType: PropertyType.rent,
      price: 2700,
      sizeSqft: 950,
      bedrooms: 2,
      bathrooms: 2,
      furnished: true,
      addressLine: '123 Market Street',
      city: 'San Francisco',
      state: 'CA',
      country: 'USA',
      postalCode: '94103',
      latitude: 37.7749,
      longitude: -122.4194,
      googleMapsUrl: 'https://maps.google.com/?q=37.7749,-122.4194',
      status: PropertyStatus.available,
      viewsCount: 124,
      averageRating: 4.7,
      totalReviews: 32,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
      sellerName: 'Skyline Realty',
      companyName: 'Skyline Realty Group',
      sellerEmail: 'contact@skylinerealty.com',
      sellerPhone: '+1 415 555 0101',
      images: const [
        PropertyImage(
          id: 'prop-001-img-0',
          imageUrl:
              'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=80',
          imageOrder: 0,
          isCover: true,
        ),
        PropertyImage(
          id: 'prop-001-img-1',
          imageUrl:
              'https://images.unsplash.com/photo-1523217582562-09d0def993a6?auto=format&fit=crop&w=1200&q=80',
          imageOrder: 1,
          isCover: false,
        ),
      ],
      tags: ['City View', 'Pet Friendly', 'Loft'],
    ),
    Property(
      id: 'prop-002',
      sellerId: 'vendor-002',
      title: 'Cozy Suburban Family Home',
      description:
          'Three-bedroom craftsman with a landscaped backyard, updated kitchen, and quiet tree-lined street.',
      propertyType: PropertyType.buy,
      price: 785000,
      sizeSqft: 2100,
      bedrooms: 3,
      bathrooms: 2,
      furnished: false,
      addressLine: '48 Willow Lane',
      city: 'Portland',
      state: 'OR',
      country: 'USA',
      postalCode: '97205',
      latitude: 45.5152,
      longitude: -122.6784,
      status: PropertyStatus.available,
      viewsCount: 87,
      averageRating: 4.3,
      totalReviews: 18,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      updatedAt: DateTime.now(),
      sellerName: 'Meadow Homes',
      companyName: 'Meadow Homes',
      sellerEmail: 'hello@meadowhomes.com',
      sellerPhone: '+1 503 555 0148',
      images: const [
        PropertyImage(
          id: 'prop-002-img-0',
          imageUrl:
              'https://images.unsplash.com/photo-1554995207-c18c203602cb?auto=format&fit=crop&w=1200&q=80',
          imageOrder: 0,
          isCover: true,
        ),
        PropertyImage(
          id: 'prop-002-img-1',
          imageUrl:
              'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=80',
          imageOrder: 1,
          isCover: false,
        ),
      ],
      tags: ['Backyard', 'Family Friendly', 'Garage'],
    ),
    Property(
      id: 'prop-003',
      sellerId: 'vendor-003',
      title: 'Beachfront Retreat with Panoramic Views',
      description:
          'Luxury villa steps from the sand featuring an infinity pool, outdoor kitchen, and dedicated office.',
      propertyType: PropertyType.buy,
      price: 1850000,
      sizeSqft: 3200,
      bedrooms: 4,
      bathrooms: 3,
      furnished: true,
      addressLine: '890 Ocean Breeze Drive',
      city: 'San Diego',
      state: 'CA',
      country: 'USA',
      postalCode: '92109',
      latitude: 32.7157,
      longitude: -117.1611,
      status: PropertyStatus.available,
      viewsCount: 203,
      averageRating: 4.9,
      totalReviews: 41,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      sellerName: 'Coastal Estates',
      companyName: 'Coastal Estates',
      sellerEmail: 'info@coastalestates.com',
      sellerPhone: '+1 619 555 0199',
      images: const [
        PropertyImage(
          id: 'prop-003-img-0',
          imageUrl:
              'https://images.unsplash.com/photo-1507089947368-19c1da9775ae?auto=format&fit=crop&w=1200&q=80',
          imageOrder: 0,
          isCover: true,
        ),
        PropertyImage(
          id: 'prop-003-img-1',
          imageUrl:
              'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=1200&q=80',
          imageOrder: 1,
          isCover: false,
        ),
      ],
      tags: ['Waterfront', 'Luxury', 'Home Office'],
    ),
    Property(
      id: 'prop-004',
      sellerId: 'vendor-001',
      title: 'Stylish Midtown Studio',
      description:
          'Efficient studio with built-in storage, smart home features, and easy access to nightlife.',
      propertyType: PropertyType.rent,
      price: 1850,
      sizeSqft: 620,
      bedrooms: 1,
      bathrooms: 1,
      furnished: true,
      addressLine: '455 8th Avenue',
      city: 'New York',
      state: 'NY',
      country: 'USA',
      postalCode: '10018',
      latitude: 40.7549,
      longitude: -73.9840,
      status: PropertyStatus.available,
      viewsCount: 312,
      averageRating: 4.6,
      totalReviews: 54,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      sellerName: 'Skyline Realty',
      companyName: 'Skyline Realty Group',
      sellerEmail: 'contact@skylinerealty.com',
      sellerPhone: '+1 415 555 0101',
      images: const [
        PropertyImage(
          id: 'prop-004-img-0',
          imageUrl:
              'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=80',
          imageOrder: 0,
          isCover: true,
        ),
      ],
      tags: ['Smart Home', 'Nightlife', 'City View'],
    ),
  ];

  static bool isDummyPropertyId(String id) {
    return properties.any((property) => property.id == id);
  }

  static Property? findPropertyById(String id) {
    try {
      return properties.firstWhere((property) => property.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Scene> scenesForProperty(String id) {
    return _buildDemoScenes();
  }

  static final List<PropertyTag> tags = [
    const PropertyTag(name: 'City View', propertyCount: 12),
    const PropertyTag(name: 'Pet Friendly', propertyCount: 8),
    const PropertyTag(name: 'Luxury', propertyCount: 6),
    const PropertyTag(name: 'Backyard', propertyCount: 10),
    const PropertyTag(name: 'Smart Home', propertyCount: 7),
  ];

  static final List<Vendor> vendors = [
    const Vendor(
      id: 'vendor-001',
      fullName: 'Skyline Realty Group',
      companyName: 'Skyline Realty Group',
      email: 'contact@skylinerealty.com',
      phone: '+1 415 555 0101',
      propertyCount: 24,
      averagePrice: 920000,
    ),
    const Vendor(
      id: 'vendor-002',
      fullName: 'Meadow Homes',
      companyName: 'Meadow Homes',
      email: 'hello@meadowhomes.com',
      phone: '+1 503 555 0148',
      propertyCount: 16,
      averagePrice: 615000,
    ),
    const Vendor(
      id: 'vendor-003',
      fullName: 'Coastal Estates',
      companyName: 'Coastal Estates',
      email: 'info@coastalestates.com',
      phone: '+1 619 555 0199',
      propertyCount: 9,
      averagePrice: 1450000,
    ),
  ];

  /// Returns a filtered list of properties based on the supplied [filter].
  static List<Property> filterProperties(
    SearchFilter filter, {
    List<Property>? source,
  }) {
    final List<Property> data = List<Property>.from(source ?? properties);
    final query = filter.query?.toLowerCase();

    return data.where((property) {
      final matchesQuery = query == null ||
          property.title.toLowerCase().contains(query) ||
          (property.description ?? '').toLowerCase().contains(query) ||
          property.city.toLowerCase().contains(query) ||
          property.tags?.any((tag) => tag.toLowerCase().contains(query)) == true;

      final matchesType = filter.propertyType == null ||
          property.propertyType == filter.propertyType;

      final matchesMinPrice =
          filter.minPrice == null || property.price >= filter.minPrice!;
      final matchesMaxPrice =
          filter.maxPrice == null || property.price <= filter.maxPrice!;

      final matchesBedrooms = filter.bedrooms == null ||
          (property.bedrooms ?? 0) >= filter.bedrooms!;
      final matchesBathrooms = filter.bathrooms == null ||
          (property.bathrooms ?? 0) >= filter.bathrooms!;

      final matchesFurnished = filter.furnished == null ||
          property.furnished == filter.furnished;

      final matchesTags = filter.tags.isEmpty ||
          property.tags?.any((tag) =>
                  filter.tags.any((selected) =>
                      tag.toLowerCase() == selected.toLowerCase())) ==
              true;

      final matchesMustTags = filter.mustTags.isEmpty ||
          filter.mustTags.every((requiredTag) =>
              property.tags?.any(
                (tag) => tag.toLowerCase() == requiredTag.toLowerCase(),
              ) ==
              true);

      final matchesSeller = filter.sellerId == null ||
          property.sellerId == filter.sellerId;

      return matchesQuery &&
          matchesType &&
          matchesMinPrice &&
          matchesMaxPrice &&
          matchesBedrooms &&
          matchesBathrooms &&
          matchesFurnished &&
          matchesTags &&
          matchesMustTags &&
          matchesSeller;
    }).toList()
      ..sort((a, b) {
        switch (filter.sortBy) {
          case 'price_asc':
            return a.price.compareTo(b.price);
          case 'price_desc':
            return b.price.compareTo(a.price);
          case 'newest':
            return b.createdAt.compareTo(a.createdAt);
          case 'rating':
            return b.averageRating.compareTo(a.averageRating);
          case 'size_desc':
            final aSize = a.sizeSqft ?? 0;
            final bSize = b.sizeSqft ?? 0;
            return bSize.compareTo(aSize);
          default:
            return 0;
        }
      });
  }

  static List<Scene> _buildDemoScenes() {
    final livingRoom = Scene.localDraft(
      id: 'tour-living-room',
      name: 'Living Room',
      sceneOrder: 0,
      imagePaths: const ['assets/virtual_tour/living-room.jpg'],
    );

    final kitchen = Scene.localDraft(
      id: 'tour-kitchen',
      name: 'Kitchen',
      sceneOrder: 1,
      imagePaths: const ['assets/virtual_tour/kitchen.jpg'],
    );

    final bedroom = Scene.localDraft(
      id: 'tour-bedroom',
      name: 'Bedroom',
      sceneOrder: 2,
      imagePaths: const ['assets/virtual_tour/bedroom.jpg'],
    );

    final livingWithHotspots = livingRoom.copyWith(hotspots: [
      Hotspot(
        id: 'living-to-kitchen',
        sceneId: livingRoom.id,
        hotspotType: HotspotType.navigation,
        targetSceneId: kitchen.id,
        targetSceneName: kitchen.name,
        yaw: 1.3,
        pitch: 0.1,
        title: 'Go to Kitchen',
      ),
      Hotspot(
        id: 'living-to-bedroom',
        sceneId: livingRoom.id,
        hotspotType: HotspotType.navigation,
        targetSceneId: bedroom.id,
        targetSceneName: bedroom.name,
        yaw: -1.2,
        pitch: 0.05,
        title: 'Go to Bedroom',
      ),
    ]);

    final kitchenWithHotspot = kitchen.copyWith(hotspots: [
      Hotspot(
        id: 'kitchen-to-living',
        sceneId: kitchen.id,
        hotspotType: HotspotType.navigation,
        targetSceneId: livingRoom.id,
        targetSceneName: livingRoom.name,
        yaw: -2.6,
        pitch: 0.08,
        title: 'Back to Living Room',
      ),
    ]);

    final bedroomWithHotspot = bedroom.copyWith(hotspots: [
      Hotspot(
        id: 'bedroom-to-living',
        sceneId: bedroom.id,
        hotspotType: HotspotType.navigation,
        targetSceneId: livingRoom.id,
        targetSceneName: livingRoom.name,
        yaw: 0.35,
        pitch: 0.12,
        title: 'Back to Living Room',
      ),
    ]);

    return [livingWithHotspots, kitchenWithHotspot, bedroomWithHotspot];
  }
}
