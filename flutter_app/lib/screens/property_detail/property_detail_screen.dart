import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../models/property.dart';
import '../../models/scene.dart';
import '../../services/property_service.dart';
import '../../services/scene_service.dart';
import '../../config/app_theme.dart';
import '../../config/api_config.dart';
import 'widgets/virtual_tour_viewer.dart';
import 'package:carousel_slider/carousel_slider.dart';

/// Property Detail Screen - PRIORITY 1
/// Displays property details with 360° virtual tour using Marzipano in WebView
class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({
    Key? key,
    required this.propertyId,
  }) : super(key: key);

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen>
    with SingleTickerProviderStateMixin {
  final PropertyService _propertyService = PropertyService();
  final SceneService _sceneService = SceneService();

  Property? _property;
  List<Scene> _scenes = [];
  bool _isLoading = true;
  String? _error;
  bool _show360Tour = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPropertyDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _propertyService.dispose();
    _sceneService.dispose();
    super.dispose();
  }

  Future<void> _loadPropertyDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final property = await _propertyService.getPropertyById(widget.propertyId);
      final scenes = await _sceneService.getPropertyScenes(widget.propertyId);

      setState(() {
        _property = property;
        _scenes = scenes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openGoogleMaps() async {
    if (_property?.googleMapsUrl != null) {
      final uri = Uri.parse(_property!.googleMapsUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (_property?.latitude != null && _property?.longitude != null) {
      final url = 'https://www.google.com/maps/search/?api=1&query=${_property!.latitude},${_property!.longitude}';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _copyAddress() {
    if (_property != null) {
      Clipboard.setData(ClipboardData(text: _property!.fullAddress));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPropertyDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_property == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property Details')),
        body: const Center(child: Text('Property not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(),
                if (_scenes.isNotEmpty) _build360TourButton(),
                _buildPriceSection(),
                _buildBasicInfo(),
                _buildTabs(),
                _buildTabContent(),
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      title: Text(_property!.title),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: Implement share
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            // TODO: Implement save/favorite
          },
        ),
      ],
    );
  }

  Widget _buildImageGallery() {
    final images = _property!.images ?? [];
    
    if (images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 300,
        viewportFraction: 1.0,
        enableInfiniteScroll: images.length > 1,
      ),
      items: images.map((img) {
        return CachedNetworkImage(
          imageUrl: '${ApiConfig.baseUrl}/${img.imageUrl}',
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
      }).toList(),
    );
  }

  Widget _build360TourButton() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VirtualTourViewer(
                propertyId: widget.propertyId,
                propertyTitle: _property!.title,
              ),
            ),
          );
        },
        icon: const Icon(Icons.view_in_ar, size: 28),
        label: const Text('View 360° Virtual Tour'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.accentColor,
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _property!.formattedPrice,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                _property!.propertyType.displayName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _property!.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  ' (${_property!.totalReviews})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      child: Row(
        children: [
          if (_property!.bedrooms != null)
            _buildInfoChip(Icons.bed, '${_property!.bedrooms} Beds'),
          const SizedBox(width: 12),
          if (_property!.bathrooms != null)
            _buildInfoChip(Icons.bathtub, '${_property!.bathrooms} Baths'),
          const SizedBox(width: 12),
          if (_property!.sizeSqft != null)
            _buildInfoChip(
              Icons.square_foot,
              '${_property!.sizeSqft!.toStringAsFixed(0)} sqft',
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.only(top: AppTheme.spacingL),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primaryColor,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Location'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 400,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildLocationTab(),
          _buildReviewsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _property!.description ?? 'No description available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Features',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureChip(_property!.furnished ? 'Furnished' : 'Unfurnished'),
              if (_property!.tags != null)
                ...(_property!.tags!.map((tag) => _buildFeatureChip(tag))),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Seller Information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.business)),
            title: Text(_property!.companyName ?? _property!.sellerName ?? 'Unknown'),
            subtitle: Text(_property!.sellerEmail ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      labelStyle: const TextStyle(color: AppTheme.primaryColor),
    );
  }

  Widget _buildLocationTab() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _property!.fullAddress,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openGoogleMaps,
                  icon: const Icon(Icons.map),
                  label: const Text('Open in Maps'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _copyAddress,
                icon: const Icon(Icons.copy),
                label: const Text('Copy'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    final reviews = _property!.reviews ?? [];

    if (reviews.isEmpty) {
      return const Center(
        child: Text('No reviews yet'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Row(
            children: [
              Text(review.reviewerName ?? 'Anonymous'),
              const SizedBox(width: 8),
              RatingBarIndicator(
                rating: review.rating.toDouble(),
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 16,
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              if (review.reviewText != null) Text(review.reviewText!),
              const SizedBox(height: 4),
              Text(
                _formatDate(review.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement contact seller
                },
                icon: const Icon(Icons.phone),
                label: const Text('Contact Seller'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement schedule visit
                },
                icon: const Icon(Icons.event),
                label: const Text('Schedule Visit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.secondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

