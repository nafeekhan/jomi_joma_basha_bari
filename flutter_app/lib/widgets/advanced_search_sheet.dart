import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../config/app_theme.dart';
import '../models/property.dart';
import '../models/search_filter.dart';

class AdvancedSearchSheet extends StatefulWidget {
  final SearchFilter initialFilter;

  const AdvancedSearchSheet({super.key, required this.initialFilter});

  static Future<SearchFilter?> show(BuildContext context, SearchFilter initialFilter) {
    return showModalBottomSheet<SearchFilter>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (context, controller) => AdvancedSearchSheet(
          initialFilter: initialFilter,
        ),
      ),
    );
  }

  @override
  State<AdvancedSearchSheet> createState() => _AdvancedSearchSheetState();
}

class _AdvancedSearchSheetState extends State<AdvancedSearchSheet> {
  late SearchFilter _filter;
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  late final TextEditingController _minSizeController;
  late final TextEditingController _maxSizeController;
  late final TextEditingController _bedroomsController;
  late final TextEditingController _bathroomsController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _radiusController;
  late final TextEditingController _tagsController;
  late final TextEditingController _mustTagsController;
  late final TextEditingController _optionalTagsController;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
    _minPriceController = TextEditingController(text: _filter.minPrice?.toString() ?? '');
    _maxPriceController = TextEditingController(text: _filter.maxPrice?.toString() ?? '');
    _minSizeController = TextEditingController(text: _filter.minSize?.toString() ?? '');
    _maxSizeController = TextEditingController(text: _filter.maxSize?.toString() ?? '');
    _bedroomsController = TextEditingController(text: _filter.bedrooms?.toString() ?? '');
    _bathroomsController = TextEditingController(text: _filter.bathrooms?.toString() ?? '');
    _latitudeController = TextEditingController(text: _filter.latitude?.toStringAsFixed(5) ?? '');
    _longitudeController = TextEditingController(text: _filter.longitude?.toStringAsFixed(5) ?? '');
    _radiusController = TextEditingController(text: _filter.radiusKm?.toString() ?? '');
    _tagsController = TextEditingController(text: _filter.tags.join(', '));
    _mustTagsController = TextEditingController(text: _filter.mustTags.join(', '));
    _optionalTagsController = TextEditingController(text: _filter.optionalTags.join(', '));
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minSizeController.dispose();
    _maxSizeController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    _tagsController.dispose();
    _mustTagsController.dispose();
    _optionalTagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Advanced Search',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ChoiceChip(
                    label: const Text('All Properties'),
                    selected: _filter.propertyType == null,
                    onSelected: (_) => setState(() {
                      _filter = _filter.copyWith(propertyType: null);
                    }),
                  ),
                  ChoiceChip(
                    label: const Text('For Sale'),
                    selected: _filter.propertyType == PropertyType.buy,
                    onSelected: (_) => setState(() {
                      _filter = _filter.copyWith(propertyType: PropertyType.buy);
                    }),
                  ),
                  ChoiceChip(
                    label: const Text('For Rent'),
                    selected: _filter.propertyType == PropertyType.rent,
                    onSelected: (_) => setState(() {
                      _filter = _filter.copyWith(propertyType: PropertyType.rent);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildNumberRow('Price Range ()', _minPriceController, _maxPriceController),
              const SizedBox(height: 16),
              _buildNumberRow('Size Range (sqft)', _minSizeController, _maxSizeController),
              const SizedBox(height: 16),
              _buildNumberRow('Bedrooms', _bedroomsController, null, isInteger: true),
              const SizedBox(height: 16),
              _buildNumberRow('Bathrooms', _bathroomsController, null, isInteger: true),
              const SizedBox(height: 16),
              _buildFurnishedSelector(),
              const SizedBox(height: 24),
              _buildTagSection('Tags (Any)', _tagsController),
              const SizedBox(height: 16),
              _buildTagSection('Must Have Tags', _mustTagsController),
              const SizedBox(height: 16),
              _buildTagSection('Optional Tags', _optionalTagsController),
              const SizedBox(height: 24),
              _buildLocationSection(context),
              const SizedBox(height: 24),
              _buildSortSelector(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetFilters,
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _apply,
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberRow(String label, TextEditingController minController, TextEditingController? maxController,{bool isInteger = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: minController,
                keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
                decoration: const InputDecoration(labelText: 'Min'),
              ),
            ),
            if (maxController != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: maxController,
                  keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
                  decoration: const InputDecoration(labelText: 'Max'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFurnishedSelector() {
    final options = <String, bool?>{
      'Any': null,
      'Furnished': true,
      'Unfurnished': false,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Furnishing', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: options.entries.map((entry) {
            final selected = _filter.furnished == entry.value;
            return ChoiceChip(
              label: Text(entry.key),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _filter = _filter.copyWith(furnished: entry.value);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagSection(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Comma separated values',
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Location', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _latitudeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Latitude'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _longitudeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Longitude'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _radiusController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Radius (km)'),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _useCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Use current'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortSelector() {
    const options = {
      'relevance': 'Best Match',
      'closeness': 'Closest',
      'price_asc': 'Price: Low to High',
      'price_desc': 'Price: High to Low',
      'newest': 'Newest',
      'rating': 'Top Rated',
      'size_desc': 'Largest',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _filter.sortBy ?? 'relevance',
          items: options.entries
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _filter = _filter.copyWith(sortBy: value);
            });
          },
        ),
      ],
    );
  }

  Future<void> _useCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(5);
        _longitudeController.text = position.longitude.toStringAsFixed(5);
        _filter = _filter.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to get location: $e')),
      );
    }
  }

  void _resetFilters() {
    setState(() {
      _filter = const SearchFilter();
      _minPriceController.clear();
      _maxPriceController.clear();
      _minSizeController.clear();
      _maxSizeController.clear();
      _bedroomsController.clear();
      _bathroomsController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
      _radiusController.clear();
      _tagsController.clear();
      _mustTagsController.clear();
      _optionalTagsController.clear();
    });
  }

  void _apply() {
    final filter = _filter.copyWith(
      minPrice: _parseDouble(_minPriceController.text),
      maxPrice: _parseDouble(_maxPriceController.text),
      minSize: _parseDouble(_minSizeController.text),
      maxSize: _parseDouble(_maxSizeController.text),
      bedrooms: _parseInt(_bedroomsController.text),
      bathrooms: _parseInt(_bathroomsController.text),
      latitude: _parseDouble(_latitudeController.text),
      longitude: _parseDouble(_longitudeController.text),
      radiusKm: _parseDouble(_radiusController.text),
      tags: _splitTags(_tagsController.text),
      mustTags: _splitTags(_mustTagsController.text),
      optionalTags: _splitTags(_optionalTagsController.text),
    );
    Navigator.pop(context, filter);
  }

  double? _parseDouble(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.trim());
  }

  int? _parseInt(String value) {
    if (value.trim().isEmpty) return null;
    return int.tryParse(value.trim());
  }

  List<String> _splitTags(String value) {
    if (value.trim().isEmpty) return [];
    return value
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }
}
