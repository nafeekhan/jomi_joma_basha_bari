import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/property_browse_arguments.dart';
import '../../models/property_tag.dart';
import '../../models/search_filter.dart';
import '../../models/user.dart';
import '../../utils/dummy_data.dart';
import '../../utils/responsive.dart';
import '../../utils/storage_helper.dart';
import '../../widgets/bottom_search_bar.dart';
import '../../widgets/main_navigation_bar.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<PropertyTag> _allTags;
  List<PropertyTag> _tags = const [];
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _allTags = DummyData.tags;
    _tags = _allTags;
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageHelper.getUser();
    setState(() => _currentUser = user);
  }

  void _filterTags(String query) {
    final trimmed = query.trim().toLowerCase();
    setState(() {
      if (trimmed.isEmpty) {
        _tags = _allTags;
      } else {
        _tags = _allTags
            .where((tag) => tag.name.toLowerCase().contains(trimmed))
            .toList();
      }
    });
  }

  void _openTag(PropertyTag tag) {
    Get.toNamed(
      '/properties',
      arguments: PropertyBrowseArguments(
        filter: SearchFilter(tags: [tag.name]),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      appBar: MainNavigationBar(currentUser: _currentUser),
      bottomNavigationBar: isMobile
          ? BottomSearchBar(
              controller: _searchController,
              hintText: 'Search tags',
              onSearch: _filterTags,
            )
          : null,
      body: Row(
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
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search tags',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: _filterTags,
          ),
          const SizedBox(height: 16),
          Text(
            'Tags help buyers discover listings by feature, style, or amenity. Pick one to see matching properties.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_tags.isEmpty) {
      return const Center(child: Text('No tags match your search.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      itemCount: _tags.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final tag = _tags[index];
        return ListTile(
          leading: const Icon(Icons.label_outline),
          title: Text(tag.name),
          subtitle: Text('${tag.propertyCount} properties'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _openTag(tag),
        );
      },
    );
  }
}
