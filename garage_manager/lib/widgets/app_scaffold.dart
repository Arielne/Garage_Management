import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppNavItem {
  const AppNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.navItems = const [],
    this.currentIndex = 0,
    this.onNavChanged,
    this.floatingActionButton,
    this.actions,
  });

  final String title;
  final Widget body;
  final List<AppNavItem> navItems;
  final int currentIndex;
  final ValueChanged<int>? onNavChanged;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: navItems.isEmpty
          ? null
          : NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onNavChanged,
              destinations: navItems
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
