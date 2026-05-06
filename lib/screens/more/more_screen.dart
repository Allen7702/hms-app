import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// "More" tab — shows a menu grid to secondary features
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _items = <_MenuItem>[
    _MenuItem(icon: Icons.people_outlined, label: 'Guests', route: '/guests'),
    _MenuItem(
      icon: Icons.receipt_long_outlined,
      label: 'Billing',
      route: '/billing',
    ),
    _MenuItem(
      icon: Icons.inventory_2_outlined,
      label: 'Inventory',
      route: '/inventory',
    ),
    _MenuItem(
      icon: Icons.calendar_month_outlined,
      label: 'Calendar',
      route: '/calendar',
    ),
    _MenuItem(
      icon: Icons.bar_chart_outlined,
      label: 'Reports',
      route: '/reports',
    ),
    _MenuItem(icon: Icons.history, label: 'Audit Trail', route: '/audit'),
    _MenuItem(
      icon: Icons.notifications_outlined,
      label: 'Notifications',
      route: '/notifications',
    ),
    _MenuItem(
      icon: Icons.settings_outlined,
      label: 'Settings',
      route: '/settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Features',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: _items.length,
                itemBuilder: (ctx, i) {
                  final item = _items[i];
                  return _MenuCard(item: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;
  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(item.route),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
