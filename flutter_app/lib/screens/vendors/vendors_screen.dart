import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/property_browse_arguments.dart';
import '../../models/search_filter.dart';
import '../../models/user.dart';
import '../../models/vendor.dart';
import '../../utils/dummy_data.dart';
import '../../utils/responsive.dart';
import '../../utils/storage_helper.dart';
import '../../widgets/bottom_search_bar.dart';
import '../../widgets/main_navigation_bar.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late List<Vendor> _allVendors;
  List<Vendor> _vendors = const [];
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _allVendors = DummyData.vendors;
    _vendors = _allVendors;
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageHelper.getUser();
    setState(() => _currentUser = user);
  }

  void _filterVendors(String query) {
    final trimmed = query.trim().toLowerCase();
    setState(() {
      if (trimmed.isEmpty) {
        _vendors = _allVendors;
      } else {
        _vendors = _allVendors
            .where(
              (vendor) =>
                  vendor.fullName.toLowerCase().contains(trimmed) ||
                  (vendor.companyName ?? '').toLowerCase().contains(trimmed),
            )
            .toList();
      }
    });
  }

  void _openVendor(Vendor vendor) {
    Get.toNamed(
      '/properties',
      arguments: PropertyBrowseArguments(
        filter: SearchFilter(sellerId: vendor.id),
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
              hintText: 'Search vendors',
              onSearch: _filterVendors,
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
          Expanded(child: _buildContent(context)),
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
              labelText: 'Search vendors',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: _filterVendors,
          ),
          const SizedBox(height: 16),
          Text(
            'Vendors are trusted sellers with immersive tours. Choose one to see their listings.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_vendors.isEmpty) {
      return const Center(child: Text('No vendors match your search.'));
    }

    final horizontalPadding = Responsive.isDesktop(context) ? 48.0 : 16.0;

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
      itemCount: _vendors.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vendor = _vendors[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.shade50,
              foregroundColor: Colors.indigo,
              child: Text(
                vendor.fullName.isNotEmpty ? vendor.fullName[0].toUpperCase() : '?',
              ),
            ),
            title: Text(vendor.fullName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vendor.companyName != null && vendor.companyName!.isNotEmpty)
                  Text(vendor.companyName!),
                Text('${vendor.propertyCount} active listings'),
                Text('Average price: \$${vendor.averagePrice.toStringAsFixed(0)}'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openVendor(vendor),
          ),
        );
      },
    );
  }
}
