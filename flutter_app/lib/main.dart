import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/browse/property_browse_screen.dart';
import 'screens/tags/tags_screen.dart';
import 'screens/vendors/vendors_screen.dart';
import 'models/search_filter.dart';
import 'models/property_browse_arguments.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Real Estate Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(
          name: '/properties',
          page: () {
            final args = Get.arguments as PropertyBrowseArguments?;
            return PropertyBrowseScreen(
              initialFilter: args?.filter ?? const SearchFilter(),
              autoOpenAdvanced: args?.autoOpenAdvanced ?? false,
            );
          },
        ),
        GetPage(name: '/tags', page: () => const TagsScreen()),
        GetPage(name: '/vendors', page: () => const VendorsScreen()),
      ],
    );
  }
}
