import 'package:flutter/material.dart';

import '../../models/property_tag.dart';
import '../../models/search_filter.dart';
import '../../services/property_service.dart';
import '../browse/property_browse_screen.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  final PropertyService _propertyService = PropertyService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;
  List<PropertyTag> _tags = const [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  @override
  void dispose() {
    _propertyService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTags({String? search}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final tags = await _propertyService.getPropertyTags(search: search);
      setState(() {
        _tags = tags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse by Tags'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tags',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadTags();
                  },
                ),
              ),
              onSubmitted: (value) => _loadTags(search: value.trim()),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _tags.isEmpty
                        ? const Center(child: Text('No tags found'))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemBuilder: (context, index) {
                              final tag = _tags[index];
                              return ListTile(
                                leading: const Icon(Icons.label_outline),
                                title: Text(tag.name),
                                subtitle: Text('${tag.propertyCount} properties'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PropertyBrowseScreen(
                                      initialFilter: SearchFilter(tags: [tag.name]),
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemCount: _tags.length,
                          ),
          ),
        ],
      ),
    );
  }
}
