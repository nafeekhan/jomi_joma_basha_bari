import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app_theme.dart';
import '../../models/property.dart';
import '../../models/property_browse_arguments.dart';
import '../../models/search_filter.dart';
import '../../models/user.dart';
import '../../utils/dummy_data.dart';
import '../../utils/responsive.dart';
import '../../utils/storage_helper.dart';
import '../../widgets/bottom_search_bar.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/property_card.dart';
import '../property_detail/property_detail_screen.dart';
import '../upload/property_upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Property> _properties = DummyData.properties;
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialise();
  }

  Future<void> _initialise() async {
    final user = await StorageHelper.getUser();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String value) {
    final trimmed = value.trim();
    Get.toNamed(
      '/properties',
      arguments: PropertyBrowseArguments(
        filter: SearchFilter(query: trimmed.isEmpty ? null : trimmed),
      ),
    );
  }

  void _openProperty(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(
          propertyId: property.id,
          initialProperty: property,
        ),
      ),
    );
  }

  void _viewAllProperties() {
    Get.toNamed('/properties');
  }

  void _viewTag(String tag) {
    Get.toNamed(
      '/properties',
      arguments: PropertyBrowseArguments(
        filter: SearchFilter(tags: [tag]),
      ),
    );
  }

  void _viewVendor(String vendorId) {
    Get.toNamed(
      '/properties',
      arguments: PropertyBrowseArguments(
        filter: SearchFilter(sellerId: vendorId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      appBar: MainNavigationBar(currentUser: _currentUser),
      bottomNavigationBar: isMobile
          ? BottomSearchBar(
              controller: _searchController,
              hintText: 'Search by city, feature, or listing',
              onSearch: _handleSearch,
              onFilterTap: () => Get.toNamed(
                '/properties',
                arguments: const PropertyBrowseArguments(autoOpenAdvanced: true),
              ),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Responsive.isDesktop(context))
                  SizedBox(
                    width: 320,
                    child: _buildDesktopSidebar(),
                  ),
                Expanded(child: _buildContent()),
              ],
            ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search listings',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: _handleSearch,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _viewAllProperties,
            icon: const Icon(Icons.apartment),
            label: const Text('Browse properties'),
          ),
          const SizedBox(height: 24),
          const Text('Popular tags', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: DummyData.tags
                .map(
                  (tag) => ActionChip(
                    label: Text(tag.name),
                    onPressed: () => _viewTag(tag.name),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text('Trusted vendors', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...DummyData.vendors.map(
            (vendor) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                foregroundColor: AppTheme.primaryColor,
                child: Text(
                  vendor.fullName.substring(0, 1).toUpperCase(),
                ),
              ),
              title: Text(vendor.fullName),
              subtitle: Text('${vendor.propertyCount} listings'),
              onTap: () => _viewVendor(vendor.id),
            ),
          ),
          if (_currentUser?.userType == UserType.seller) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PropertyUploadScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.upload),
              label: const Text('Upload a property'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeroSection(),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured homes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: _viewAllProperties,
                  child: const Text('View all'),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.isDesktop(context)
                  ? 3
                  : Responsive.isTablet(context)
                      ? 2
                      : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.78,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final property = _properties[index % _properties.length];
                return PropertyCard(
                  property: property,
                  onTap: () => _openProperty(property),
                );
              },
              childCount: _properties.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse by tags',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: DummyData.tags
                      .map(
                        (tag) => ActionChip(
                          label: Text('${tag.name} (${tag.propertyCount})'),
                          onPressed: () => _viewTag(tag.name),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    final theme = Theme.of(context);
    final isSeller = _currentUser?.userType == UserType.seller;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore immersive property tours',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Discover homes with guided 360° walkthroughs and organise them with intuitive tags and vendors.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: [
              ElevatedButton(
                onPressed: _viewAllProperties,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Start browsing'),
              ),
              if (isSeller)
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PropertyUploadScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('Upload a property'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
