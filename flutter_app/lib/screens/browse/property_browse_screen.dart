import 'package:flutter/material.dart';

import '../../models/property.dart';
import '../../models/search_filter.dart';
import '../../models/user.dart';
import '../../utils/dummy_data.dart';
import '../../utils/responsive.dart';
import '../../utils/storage_helper.dart';
import '../../widgets/advanced_search_sheet.dart';
import '../../widgets/bottom_search_bar.dart';
import '../../widgets/main_navigation_bar.dart';
import '../../widgets/property_card.dart';
import '../property_detail/property_detail_screen.dart';

class PropertyBrowseScreen extends StatefulWidget {
  final SearchFilter initialFilter;
  final bool autoOpenAdvanced;

  const PropertyBrowseScreen({
    super.key,
    this.initialFilter = const SearchFilter(),
    this.autoOpenAdvanced = false,
  });

  @override
  State<PropertyBrowseScreen> createState() => _PropertyBrowseScreenState();
}

class _PropertyBrowseScreenState extends State<PropertyBrowseScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  User? _currentUser;
  late SearchFilter _filter;
  late List<Property> _allProperties;
  List<Property> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _searchController.text = _filter.query ?? '';
    _initialise();
  }

  Future<void> _initialise() async {
    final user = await StorageHelper.getUser();
    _allProperties = DummyData.properties;
    setState(() {
      _currentUser = user;
      _properties = DummyData.filterProperties(_filter, source: _allProperties);
      _isLoading = false;
    });
    if (widget.autoOpenAdvanced) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openAdvancedFilters());
    }
  }

  void _handleSearch(String value) {
    final trimmed = value.trim();
    setState(() {
      if (trimmed.isEmpty) {
        _filter = _filter.copyWith(clearQuery: true);
      } else {
        _filter = _filter.copyWith(query: trimmed);
      }
      _properties = DummyData.filterProperties(_filter, source: _allProperties);
    });
  }

  Future<void> _openAdvancedFilters() async {
    final result = await AdvancedSearchSheet.show(context, _filter);
    if (result != null) {
      setState(() {
        _filter = result;
        _searchController.text = result.query ?? '';
        _properties = DummyData.filterProperties(_filter, source: _allProperties);
      });
    }
  }

  void _setPropertyType(PropertyType? type) {
    setState(() {
      if (type == null) {
        _filter = _filter.copyWith(clearPropertyType: true);
      } else {
        _filter = _filter.copyWith(propertyType: type);
      }
      _properties = DummyData.filterProperties(_filter, source: _allProperties);
    });
  }

  void _setSort(String? sort) {
    setState(() {
      _filter = _filter.copyWith(sortBy: sort);
      _properties = DummyData.filterProperties(_filter, source: _allProperties);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: MainNavigationBar(currentUser: _currentUser),
      bottomNavigationBar: Responsive.isMobile(context)
          ? BottomSearchBar(
              controller: _searchController,
              hintText: 'Search properties',
              onSearch: _handleSearch,
              onFilterTap: _openAdvancedFilters,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop) SizedBox(width: 320, child: _buildDesktopSidebar()),
                Expanded(child: _buildContent()),
              ],
            ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: _handleSearch,
            ),
            const SizedBox(height: 24),
            const Text('Property type', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildPropertyTypeChips(),
            const SizedBox(height: 24),
            const Text('Sort by', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildSortDropdown(isDesktop: true),
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
      ),
    );
  }

  Widget _buildContent() {
    final isDesktop = Responsive.isDesktop(context);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 32 : 16,
              24,
              isDesktop ? 32 : 16,
              12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Found ${_properties.length} ${_properties.length == 1 ? 'property' : 'properties'}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                if (!isDesktop) ...[
                  _buildPropertyTypeChips(),
                  const SizedBox(height: 12),
                  _buildSortDropdown(),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _openAdvancedFilters,
                      icon: const Icon(Icons.tune),
                      label: const Text('Advanced filters'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_properties.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text('No properties match your filters. Try adjusting them.'),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.isDesktop(context) ? 32 : 16,
              vertical: 16,
            ),
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
                  final property = _properties[index];
                  return PropertyCard(
                    property: property,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PropertyDetailScreen(
                            propertyId: property.id,
                            initialProperty: property,
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: _properties.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildPropertyTypeChips() {
    final selected = _filter.propertyType;

    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: selected == null,
          onSelected: (_) => _setPropertyType(null),
        ),
        ChoiceChip(
          label: const Text('For Sale'),
          selected: selected == PropertyType.buy,
          onSelected: (_) => _setPropertyType(PropertyType.buy),
        ),
        ChoiceChip(
          label: const Text('For Rent'),
          selected: selected == PropertyType.rent,
          onSelected: (_) => _setPropertyType(PropertyType.rent),
        ),
      ],
    );
  }

  Widget _buildSortDropdown({bool isDesktop = false}) {
    final value = _filter.sortBy ?? 'relevance';
    return InputDecorator(
      decoration: InputDecoration(
        labelText: isDesktop ? null : 'Sort by',
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: _setSort,
          items: const [
            DropdownMenuItem(value: 'relevance', child: Text('Best Match')),
            DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
            DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
            DropdownMenuItem(value: 'newest', child: Text('Newest listings')),
            DropdownMenuItem(value: 'rating', child: Text('Top rated')),
            DropdownMenuItem(value: 'size_desc', child: Text('Largest homes')),
          ],
        ),
      ),
    );
  }
}
