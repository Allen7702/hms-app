import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/providers/auth_provider.dart';
import 'package:hms_app/providers/sync_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(syncNotifierProvider.notifier).triggerSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sync status toast
    ref.listen<SyncState>(syncNotifierProvider, (prev, next) {
      if (!mounted) return;
      if (next.status == SyncStatus.success &&
          prev?.status == SyncStatus.syncing) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Sync complete'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else if (next.status == SyncStatus.error &&
          prev?.status != SyncStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.sync_problem, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sync failed: ${next.errorMessage ?? 'Unknown error'}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () =>
                  ref.read(syncNotifierProvider.notifier).triggerSync(),
            ),
          ),
        );
      }
    });

    final isOnline = ref.watch(isOnlineProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? [
            const Color(0xFF070D1A),
            const Color(0xFF0C1628),
            const Color(0xFF0F1E38),
            const Color(0xFF070D1A),
          ]
        : [
            const Color(0xFFF7F4EF),
            const Color(0xFFEDF2F8),
            const Color(0xFFF4EFE8),
            const Color(0xFFEEF2F8),
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
        body: Column(
          children: [
            _OfflineBanner(isOnline: isOnline),
            Expanded(child: widget.navigationShell),
          ],
        ),
        bottomNavigationBar: _SyncNavBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: (index) {
            widget.navigationShell.goBranch(
              index,
              initialLocation: index == widget.navigationShell.currentIndex,
            );
          },
        ),
        drawer: _buildGlassDrawer(context),
      ),
    );
  }

  Widget _buildGlassDrawer(BuildContext context) {
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
                    colors: isDark
                        ? [
                            const Color(0xFF0C1628),
                            const Color(0xFF1B2A4A),
                          ]
                        : [
                            const Color(0xFF1B2A4A),
                            const Color(0xFF2C4170),
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
              _SyncDrawerItem(),
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

// ─── Offline banner ───────────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  final bool isOnline;
  const _OfflineBanner({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isOnline ? 0 : 36,
      color: Colors.orange.shade800,
      child: isOnline
          ? const SizedBox.shrink()
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  'You\'re offline — changes will sync when reconnected',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
    );
  }
}

// ─── Drawer items ─────────────────────────────────────────────────────────────

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

// ─── Sync drawer item ─────────────────────────────────────────────────────────

class _SyncDrawerItem extends ConsumerWidget {
  const _SyncDrawerItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncNotifierProvider);
    final isSyncing = syncState.status == SyncStatus.syncing;
    final hasError = syncState.status == SyncStatus.error;
    final theme = Theme.of(context);

    final color = hasError
        ? theme.colorScheme.error
        : isSyncing
            ? theme.colorScheme.primary
            : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: isSyncing
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                hasError ? Icons.sync_problem_outlined : Icons.sync_outlined,
                color: color,
                size: 22,
              ),
        title: Text(
          isSyncing ? 'Syncing…' : 'Sync Now',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: syncState.pendingCount > 0
            ? Text('${syncState.pendingCount} pending',
                style: const TextStyle(fontSize: 11))
            : syncState.lastSyncedAt != null && !isSyncing
                ? Text(
                    'Last synced ${_formatTime(syncState.lastSyncedAt!)}',
                    style: const TextStyle(fontSize: 11),
                  )
                : null,
        onTap: isSyncing
            ? null
            : () => ref.read(syncNotifierProvider.notifier).triggerSync(),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dense: true,
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

// ─── Sync-aware nav bar ───────────────────────────────────────────────────────

class _SyncNavBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SyncNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);

    final stripColor = switch (status) {
      SyncStatus.syncing => Colors.blue,
      SyncStatus.success => Colors.green,
      SyncStatus.error => Colors.red,
      SyncStatus.idle => Colors.transparent,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          height: 2,
          color: stripColor,
        ),
        _GlassNavBar(currentIndex: currentIndex, onTap: onTap),
      ],
    );
  }
}

// ─── Glass nav bar ────────────────────────────────────────────────────────────

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
