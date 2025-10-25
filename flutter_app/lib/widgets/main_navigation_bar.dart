import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_theme.dart';
import '../models/property_browse_arguments.dart';
import '../models/search_filter.dart';
import '../models/user.dart';
import '../utils/responsive.dart';
import '../utils/storage_helper.dart';

class MainNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final User? currentUser;

  const MainNavigationBar({super.key, this.currentUser});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _goHome() {
    Get.offAllNamed('/home');
  }

  void _goToProperties({PropertyBrowseArguments? args}) {
    if (Get.currentRoute == '/properties' && args == null) return;
    Get.toNamed('/properties', arguments: args);
  }

  void _goToTags() {
    if (Get.currentRoute == '/tags') return;
    Get.toNamed('/tags');
  }

  void _goToVendors() {
    if (Get.currentRoute == '/vendors') return;
    Get.toNamed('/vendors');
  }

  void _goToLogin() {
    if (Get.currentRoute == '/login') return;
    Get.toNamed('/login');
  }

  void _goToRegister() {
    if (Get.currentRoute == '/register') return;
    Get.toNamed('/register');
  }

  Future<void> _logout() async {
    await StorageHelper.clearAll();
    Get.offAllNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = !Responsive.isDesktop(context);
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      titleSpacing: isCompact ? 8 : 24,
      title: Row(
        children: [
          const Icon(Icons.home_work, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            'Real Estate Platform',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: isCompact ? _buildMobileActions(context) : _buildDesktopActions(context),
    );
  }

  List<Widget> _buildDesktopActions(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return [
      _NavButton(label: 'Home', onTap: _goHome, style: textStyle),
      _NavButton(
        label: 'Listings',
        onTap: () => _goToProperties(),
        style: textStyle,
      ),
      _NavButton(
        label: 'Tags',
        onTap: _goToTags,
        style: textStyle,
      ),
      _NavButton(
        label: 'Vendors',
        onTap: _goToVendors,
        style: textStyle,
      ),
      _NavButton(
        label: 'Advanced Search',
        onTap: () => _goToProperties(
          args: const PropertyBrowseArguments(
            autoOpenAdvanced: true,
            filter: SearchFilter(),
          ),
        ),
        style: textStyle,
      ),
      const SizedBox(width: 12),
      if (currentUser == null) ...[
        TextButton(
          onPressed: _goToLogin,
          child: const Text('Login'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _goToRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Register'),
        ),
        const SizedBox(width: 16),
      ] else ...[
        PopupMenuButton<String>(
          tooltip: 'Account',
          onSelected: (value) {
            if (value == 'logout') {
              _logout();
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: const [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
          child: CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            foregroundColor: AppTheme.primaryColor,
            child: Text(
              _initials(currentUser!.fullName),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    ];
  }

  List<Widget> _buildMobileActions(BuildContext context) {
    return [
      PopupMenuButton<String>(
        icon: const Icon(Icons.menu),
        onSelected: (value) {
          switch (value) {
            case 'home':
              _goHome();
              break;
            case 'listings':
              _goToProperties();
              break;
            case 'tags':
              _goToTags();
              break;
            case 'vendors':
              _goToVendors();
              break;
            case 'advanced':
              _goToProperties(
                args: const PropertyBrowseArguments(
                  autoOpenAdvanced: true,
                ),
              );
              break;
            case 'login':
              _goToLogin();
              break;
            case 'register':
              _goToRegister();
              break;
            case 'logout':
              _logout();
              break;
          }
        },
        itemBuilder: (_) {
          final entries = <PopupMenuEntry<String>>[
            const PopupMenuItem(value: 'home', child: Text('Home')),
            const PopupMenuItem(value: 'listings', child: Text('Listings')),
            const PopupMenuItem(value: 'tags', child: Text('Tags')),
            const PopupMenuItem(value: 'vendors', child: Text('Vendors')),
            const PopupMenuItem(value: 'advanced', child: Text('Advanced search')),
          ];
          if (currentUser == null) {
            entries.addAll(const [
              PopupMenuDivider(),
              PopupMenuItem(value: 'login', child: Text('Login')),
              PopupMenuItem(value: 'register', child: Text('Register')),
            ]);
          } else {
            entries.addAll(const [
              PopupMenuDivider(),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ]);
          }
          return entries;
        },
      ),
      const SizedBox(width: 8),
    ];
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final TextStyle? style;

  const _NavButton({
    required this.label,
    required this.onTap,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(label, style: style),
    );
  }
}
