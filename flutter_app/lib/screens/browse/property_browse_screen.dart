import 'package:flutter/material.dart';

import '../../models/property.dart';
import '../../models/search_filter.dart';
import '../../services/property_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/advanced_search_sheet.dart';
import '../../widgets/property_card.dart';
import '../property_detail/property_detail_screen.dart';

class PropertyBrowseScreen extends StatefulWidget {
  final SearchFilter initialFilter;

  const PropertyBrowseScreen({super.key, this.initialFilter = const SearchFilter()});

  @override
  State<PropertyBrowseScreen> createState() => _PropertyBrowseScreenState();
}

class _PropertyBrowseScreenState extends State<PropertyBrowseScreen> {
  final PropertyService _propertyService = PropertyService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Property> _properties = [];
  SearchFilter _filter = const SearchFilter();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _searchController.text = _filter.query ?? '';
    _fetchProperties(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _propertyService.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _fetchProperties();
      }
    }
  }

  Future<void> _fetchProperties({bool reset = false}) async {
    try {
      if (reset) {
        setState(() {
          _isLoading = true;
          _error = null;
          _page = 1;
          _hasMore = true;
        });
      } else {
        if (!_hasMore) return;
        setState(() {
          _isLoadingMore = true;
        });
      }

      final results = await _propertyService.getProperties(
        filter: _filter,
        page: _page,
        limit: 12,
      );

      setState(() {
        if (reset) {
          _properties = results;
        } else {
          _properties = [..._properties, ...results];
        }
        _hasMore = results.length == 12;
        _page += 1;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _error = e.toString();
      });
    }
  }

  void _openAdvancedFilters() async {
    final result = await AdvancedSearchSheet.show(context, _filter);
    if (result != null) {
      setState(() {
        _filter = result;
        _searchController.text = result.query ?? '';
      });
      _fetchProperties(reset: true);
    }
  }

  void _applyQuickFilter(SearchFilter filter) {
    setState(() {
      _filter = filter;
      _searchController.text = filter.query ?? '';
    });
    _fetchProperties(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Advanced filters',
            onPressed: _openAdvancedFilters,
          ),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 280,
              child: _buildFilterPane(showAdvanced: false),
            ),
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton.extended(
              onPressed: _openAdvancedFilters,
              icon: const Icon(Icons.tune),
              label: const Text('Filters'),
            ),
    );
  }

  Widget _buildFilterPane({bool showAdvanced = true}) {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ListView(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              _filter = _filter.copyWith(query: value.trim().isEmpty ? null : value.trim());
              _fetchProperties(reset: true);
            },
          ),
          const SizedBox(height: 20),
          const Text('Property type', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _filter.propertyType == null,
                onSelected: (_) => _applyQuickFilter(_filter.copyWith(propertyType: null)),
              ),
              ChoiceChip(
                label: const Text('For Sale'),
                selected: _filter.propertyType == PropertyType.buy,
                onSelected: (_) => _applyQuickFilter(_filter.copyWith(propertyType: PropertyType.buy)),
              ),
              ChoiceChip(
                label: const Text('For Rent'),
                selected: _filter.propertyType == PropertyType.rent,
                onSelected: (_) => _applyQuickFilter(_filter.copyWith(propertyType: PropertyType.rent)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Sort by', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _filter.sortBy ?? 'relevance',
            items: const [
              DropdownMenuItem(value: 'relevance', child: Text('Best Match')),
              DropdownMenuItem(value: 'closeness', child: Text('Closest')),
              DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
              DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
              DropdownMenuItem(value: 'newest', child: Text('Newest listings')),
              DropdownMenuItem(value: 'rating', child: Text('Top rated')),
            ],
            onChanged: (value) {
              _applyQuickFilter(_filter.copyWith(sortBy: value));
            },
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.tune),
            title: const Text('Advanced filters'),
            subtitle: const Text('Price, tags, location, and more'),
            onTap: _openAdvancedFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _fetchProperties(reset: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_properties.isEmpty) {
      return const Center(
        child: Text('No results found. Adjust filters and try again.'),
      );
    }

    final isDesktop = Responsive.isDesktop(context);
    final crossAxisCount = isDesktop
        ? 3
        : Responsive.isTablet(context)
            ? 2
            : 1;

    return RefreshIndicator(
      onRefresh: () => _fetchProperties(reset: true),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (!isDesktop)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search properties',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (value) {
                        _filter = _filter.copyWith(query: value.trim().isEmpty ? null : value.trim());
                        _fetchProperties(reset: true);
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _filter.propertyType == null,
                          onSelected: (_) => _applyQuickFilter(_filter.copyWith(propertyType: null)),
                        ),
                        ChoiceChip(
                          label: const Text('For Sale'),
                          selected: _filter.propertyType == PropertyType.buy,
                          onSelected: (_) => _applyQuickFilter(_filter.copyWith(propertyType: PropertyType.buy)),
                        ),
                        ChoiceChip(
                          label: const Text('For Rent'),
                          selected: _filter.propertyType == PropertyType.rent,
                          onSelected: (_) => _applyQuickFilter(_filter.copyWith(propertyType: PropertyType.rent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _filter.sortBy ?? 'relevance',
                            decoration: const InputDecoration(labelText: 'Sort by'),
                            items: const [
                              DropdownMenuItem(value: 'relevance', child: Text('Best Match')),
                              DropdownMenuItem(value: 'closeness', child: Text('Closest')),
                              DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                              DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                              DropdownMenuItem(value: 'newest', child: Text('Newest listings')),
                            ],
                            onChanged: (value) => _applyQuickFilter(_filter.copyWith(sortBy: value)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _openAdvancedFilters,
                          icon: const Icon(Icons.filter_alt),
                          label: const Text('Advanced'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.isDesktop(context) ? 32 : 16,
              vertical: 24,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final property = _properties[index];
                  return PropertyCard(
                    property: property,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyDetailScreen(propertyId: property.id),
                        ),
                      );
                    },
                  );
                },
                childCount: _properties.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: _isLoadingMore
                    ? const CircularProgressIndicator()
                    : _hasMore
                        ? OutlinedButton(
                            onPressed: () => _fetchProperties(),
                            child: const Text('Load more'),
                          )
                        : const Text('You have reached the end of the list'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
