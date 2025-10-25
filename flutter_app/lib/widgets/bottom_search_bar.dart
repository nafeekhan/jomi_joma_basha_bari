import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class BottomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onFilterTap;

  const BottomSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onSearch,
    this.onFilterTap,
  });

  void _submit() {
    onSearch?.call(controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: onSearch,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
              child: const Icon(Icons.arrow_forward),
            ),
            if (onFilterTap != null) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Advanced filters',
                onPressed: onFilterTap,
                icon: const Icon(Icons.tune),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
