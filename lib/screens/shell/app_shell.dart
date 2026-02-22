import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/providers/auth_provider.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? [
            const Color(0xFF0A0E21),
            const Color(0xFF0D1B3E),
            const Color(0xFF132043),
            const Color(0xFF0A0E21),
          ]
        : [
            const Color(0xFFE8F4FD),
            const Color(0xFFF0E6FF),
            const Color(0xFFE6F7FF),
            const Color(0xFFF5F0FF),
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: navigationShell,
        bottomNavigationBar: _GlassNavBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        ),
        drawer: _buildGlassDrawer(context, ref),
      ),
    );
  }

  Widget _buildGlassDrawer(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Drawer(
          backgroundColor: isDark
              ? Colors.black.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.6),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                      theme.colorScheme.secondary.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          (user?.fullName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      user?.role?.toUpperCase() ?? '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _GlassDrawerItem(
                icon: Icons.calendar_month_outlined,
                text: 'Calendar',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/calendar');
                },
              ),
              _GlassDrawerItem(
                icon: Icons.people_outlined,
                text: 'Guests',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/guests');
                },
              ),
              _GlassDrawerItem(
                icon: Icons.inventory_2_outlined,
                text: 'Inventory',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/inventory');
                },
              ),
              _GlassDrawerItem(
                icon: Icons.receipt_long_outlined,
                text: 'Invoices',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/billing');
                },
              ),
              _GlassDrawerItem(
                icon: Icons.bar_chart_outlined,
                text: 'Reports',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/reports');
                },
              ),
              _GlassDrawerItem(
                icon: Icons.history,
                text: 'Audit Trail',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/audit');
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              _GlassDrawerItem(
                icon: Icons.settings_outlined,
                text: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/settings');
                },
              ),
              _GlassDrawerItem(
                icon: Icons.logout,
                text: 'Sign Out',
                iconColor: theme.colorScheme.error,
                textColor: theme.colorScheme.error,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassDrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _GlassDrawerItem({
    required this.icon,
    required this.text,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 22),
        title: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dense: true,
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final items = [
      _NavItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
      _NavItem(Icons.book_online_outlined, Icons.book_online, 'Bookings'),
      _NavItem(Icons.meeting_room_outlined, Icons.meeting_room, 'Rooms'),
      _NavItem(Icons.engineering_outlined, Icons.engineering, 'Operations'),
      _NavItem(Icons.more_horiz, Icons.more_horiz, 'More'),
    ];

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.55),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.7),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = currentIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: isSelected
                            ? BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : isDark
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : Colors.black.withValues(alpha: 0.4),
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : isDark
                                        ? Colors.white.withValues(alpha: 0.5)
                                        : Colors.black.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem(this.icon, this.selectedIcon, this.label);
}
