import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/config/theme.dart';
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

  static const _tabTitles = [
    'Dashboard',
    'Bookings',
    'Rooms',
    'Operations',
    'More',
  ];

  static bool _isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 768;

  void _listenSync(BuildContext context, SyncState? prev, SyncState next) {
    if (!mounted) return;
    if (next.status == SyncStatus.success &&
        prev?.status == SyncStatus.syncing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Sync complete'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () =>
                ref.read(syncNotifierProvider.notifier).triggerSync(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SyncState>(
      syncNotifierProvider,
      (prev, next) => _listenSync(context, prev, next),
    );

    final isOnline = ref.watch(isOnlineProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = widget.navigationShell.currentIndex;
    final isDesktop = _isDesktop(context);

    void onBranchTap(int index) => widget.navigationShell.goBranch(
      index,
      initialLocation: index == currentIndex,
    );

    final offlineBanner = _OfflineBanner(isOnline: isOnline);
    final bgColor = isDark ? const Color(0xFF0A1628) : const Color(0xFFF4F7FB);

    if (isDesktop) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: AppTheme.navyDeep,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: bgColor,
          body: Row(
            children: [
              _DesktopSidebar(
                currentIndex: currentIndex,
                onBranchTap: onBranchTap,
              ),
              Expanded(
                child: Column(
                  children: [
                    offlineBanner,
                    Expanded(child: widget.navigationShell),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppTheme.navyMid,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: _buildShellAppBar(context, isDark, currentIndex),
        body: Column(
          children: [
            offlineBanner,
            Expanded(child: widget.navigationShell),
          ],
        ),
        bottomNavigationBar: _SyncNavBar(
          currentIndex: currentIndex,
          onTap: onBranchTap,
        ),
        drawer: _buildGlassDrawer(context),
      ),
    );
  }

  PreferredSizeWidget _buildShellAppBar(
    BuildContext context,
    bool isDark,
    int currentIndex,
  ) {
    return AppBar(
      backgroundColor: AppTheme.navyMid,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.hotel_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'HMS Admin',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                _tabTitles[currentIndex],
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        const _SyncStatusAction(),
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => ctx.push('/notifications'),
          ),
        ),
        const SizedBox(width: 4),
      ],
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
                        ? [const Color(0xFF0A1628), const Color(0xFF1A2E5A)]
                        : [const Color(0xFF1A2E5A), const Color(0xFF2D4A8A)],
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
                    fontWeight: FontWeight.w500,
                  ),
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
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
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
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
        subtitle: syncState.pendingCount > 0
            ? Text(
                '${syncState.pendingCount} pending',
                style: const TextStyle(fontSize: 11),
              )
            : syncState.lastSyncedAt != null && !isSyncing
            ? Text(
                'Last synced ${_formatTime(syncState.lastSyncedAt!)}',
                style: const TextStyle(fontSize: 11),
              )
            : null,
        onTap: isSyncing
            ? null
            : () => ref.read(syncNotifierProvider.notifier).triggerSync(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

// ─── Sync status AppBar action ────────────────────────────────────────────────

class _SyncStatusAction extends ConsumerWidget {
  const _SyncStatusAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    final isSyncing = status == SyncStatus.syncing;
    final isError = status == SyncStatus.error;

    if (isSyncing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
      );
    }

    if (isError) {
      return IconButton(
        icon: const Icon(
          Icons.sync_problem_outlined,
          color: Colors.orangeAccent,
          size: 22,
        ),
        tooltip: 'Sync failed — tap to retry',
        onPressed: () => ref.read(syncNotifierProvider.notifier).triggerSync(),
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── Sync-aware nav bar ───────────────────────────────────────────────────────

class _SyncNavBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SyncNavBar({required this.currentIndex, required this.onTap});

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

  const _GlassNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                ? const Color(0xFF0D1628).withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.96),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : AppTheme.navyMid.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                                color: AppTheme.navyMid.withValues(
                                  alpha: isDark ? 0.35 : 0.10,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected
                                  ? AppTheme.navyMid
                                  : isDark
                                  ? Colors.white.withValues(alpha: 0.45)
                                  : AppTheme.navyMid.withValues(alpha: 0.40),
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
                                    ? AppTheme.navyMid
                                    : isDark
                                    ? Colors.white.withValues(alpha: 0.45)
                                    : AppTheme.navyMid.withValues(alpha: 0.40),
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

// ─── Desktop sidebar ──────────────────────────────────────────────────────────

class _DesktopSidebar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onBranchTap;

  const _DesktopSidebar({
    required this.currentIndex,
    required this.onBranchTap,
  });

  static const double _width = 240;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Container(
      width: _width,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1628) : AppTheme.navyMid,
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── App header ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.hotel_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'HMS Admin',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Management System',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white54,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Navigation items ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SidebarSectionLabel('MAIN'),
                  _SidebarBranchTile(
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard,
                    label: 'Dashboard',
                    isSelected: currentIndex == 0,
                    onTap: () => onBranchTap(0),
                  ),
                  _SidebarBranchTile(
                    icon: Icons.book_online_outlined,
                    selectedIcon: Icons.book_online,
                    label: 'Bookings',
                    isSelected: currentIndex == 1,
                    onTap: () => onBranchTap(1),
                  ),
                  _SidebarBranchTile(
                    icon: Icons.meeting_room_outlined,
                    selectedIcon: Icons.meeting_room,
                    label: 'Rooms',
                    isSelected: currentIndex == 2,
                    onTap: () => onBranchTap(2),
                  ),
                  _SidebarBranchTile(
                    icon: Icons.engineering_outlined,
                    selectedIcon: Icons.engineering,
                    label: 'Operations',
                    isSelected: currentIndex == 3,
                    onTap: () => onBranchTap(3),
                  ),
                  const SizedBox(height: 8),
                  _SidebarSectionLabel('FEATURES'),
                  _SidebarRouteTile(
                    icon: Icons.people_outlined,
                    label: 'Guests',
                    route: '/guests',
                  ),
                  _SidebarRouteTile(
                    icon: Icons.receipt_long_outlined,
                    label: 'Billing',
                    route: '/billing',
                  ),
                  _SidebarRouteTile(
                    icon: Icons.inventory_2_outlined,
                    label: 'Inventory',
                    route: '/inventory',
                  ),
                  _SidebarRouteTile(
                    icon: Icons.calendar_month_outlined,
                    label: 'Calendar',
                    route: '/calendar',
                  ),
                  _SidebarRouteTile(
                    icon: Icons.bar_chart_outlined,
                    label: 'Reports',
                    route: '/reports',
                  ),
                  _SidebarRouteTile(
                    icon: Icons.history,
                    label: 'Audit Trail',
                    route: '/audit',
                  ),
                  _SidebarRouteTile(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    route: '/notifications',
                  ),
                ],
              ),
            ),
          ),

          // ── Footer ──
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
              ),
            ),
            child: Column(
              children: [
                const _SyncDrawerItem(),
                _SidebarRouteTile(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  route: '/settings',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      child: Text(
                        (user?.fullName ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(
                      user?.fullName ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      user?.role?.toUpperCase() ?? '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 10,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.logout,
                        size: 18,
                        color: theme.colorScheme.error.withValues(alpha: 0.85),
                      ),
                      tooltip: 'Sign Out',
                      onPressed: () =>
                          ref.read(authProvider.notifier).signOut(),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarSectionLabel extends StatelessWidget {
  final String label;
  const _SidebarSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.40),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SidebarBranchTile extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarBranchTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          dense: true,
          leading: Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.55),
            size: 20,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.70),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13.5,
            ),
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class _SidebarRouteTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _SidebarRouteTile({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.55),
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.70),
            fontWeight: FontWeight.w400,
            fontSize: 13.5,
          ),
        ),
        onTap: () => context.push(route),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
