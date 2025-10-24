import 'package:flutter/material.dart';

import '../../models/search_filter.dart';
import '../../models/vendor.dart';
import '../../services/property_service.dart';
import '../../utils/responsive.dart';
import '../browse/property_browse_screen.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  final PropertyService _propertyService = PropertyService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;
  List<Vendor> _vendors = const [];

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  @override
  void dispose() {
    _propertyService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVendors({String? search}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final vendors = await _propertyService.getVendors(search: search);
      setState(() {
        _vendors = vendors;
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
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendors'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vendors',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadVendors();
                  },
                ),
              ),
              onSubmitted: (value) => _loadVendors(search: value.trim()),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _vendors.isEmpty
                        ? const Center(child: Text('No vendors found'))
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 48 : 16,
                              vertical: 16,
                            ),
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
                                    child: Text(vendor.fullName.isNotEmpty ? vendor.fullName[0] : '?'),
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
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PropertyBrowseScreen(
                                          initialFilter: SearchFilter(sellerId: vendor.id),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemCount: _vendors.length,
                          ),
          ),
        ],
      ),
    );
  }
}
