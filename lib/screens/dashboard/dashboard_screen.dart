import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/providers/auth_provider.dart';
import 'package:hms_app/providers/booking_provider.dart';
import 'package:hms_app/providers/room_provider.dart';
import 'package:hms_app/shared/stats_card.dart';
import 'package:hms_app/shared/status_badge.dart';
import 'package:hms_app/shared/loading_skeleton.dart';
import 'package:hms_app/shared/empty_state.dart';
import 'package:hms_app/config/theme.dart';
import 'package:hms_app/utils/formatters.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final roomStatusCounts = ref.watch(roomStatusCountsProvider);
    final todayArrivals = ref.watch(todayArrivalsProvider);
    final todayDepartures = ref.watch(todayDeparturesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(context, theme, user),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(roomStatusCountsProvider);
          ref.invalidate(todayArrivalsProvider);
          ref.invalidate(todayDeparturesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + kToolbarHeight + 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid
              roomStatusCounts.when(
                data: (counts) {
                  final total = counts.values.fold(0, (a, b) => a + b);
                  final occupied = counts['Occupied'] ?? 0;
                  final available = counts['Available'] ?? 0;
                  final occupancyRate = total > 0 ? (occupied / total * 100) : 0.0;

                  return GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.4,
                    children: [
                      StatsCard(
                        label: 'Total Rooms',
                        value: '$total',
                        icon: Icons.meeting_room_outlined,
                        color: AppTheme.infoColor,
                      ),
                      StatsCard(
                        label: 'Occupancy Rate',
                        value: Formatters.percentage(occupancyRate),
                        icon: Icons.trending_up,
                        color: AppTheme.successColor,
                      ),
                      StatsCard(
                        label: 'Available',
                        value: '$available',
                        icon: Icons.check_circle_outline,
                        color: AppTheme.availableColor,
                      ),
                      StatsCard(
                        label: 'Occupied',
                        value: '$occupied',
                        icon: Icons.person,
                        color: AppTheme.occupiedColor,
                      ),
                    ],
                  );
                },
                loading: () => const SkeletonGrid(itemCount: 4),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              Text('Quick Actions', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'New Booking',
                      color: AppTheme.infoColor,
                      onTap: () => context.push('/bookings/create'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.login,
                      label: 'Check-In',
                      color: AppTheme.successColor,
                      onTap: () => context.go('/bookings'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.logout,
                      label: 'Check-Out',
                      color: AppTheme.warningColor,
                      onTap: () => context.go('/bookings'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Room Status Grid
              Text('Room Status', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              ref.watch(roomsProvider).when(
                data: (rooms) {
                  if (rooms.isEmpty) {
                    return const EmptyState(
                      icon: Icons.meeting_room_outlined,
                      title: 'No rooms found',
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: rooms.length > 20 ? 20 : rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      final color = _getRoomStatusColor(room.status);
                      return InkWell(
                        onTap: () => context.push('/rooms/${room.id}'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                room.roomNumber ?? '?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Icon(
                                _getRoomStatusIcon(room.status),
                                size: 14,
                                color: color,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const SkeletonGrid(itemCount: 8),
                error: (e, _) => Center(child: Text('Error loading rooms: $e')),
              ),

              const SizedBox(height: 24),

              // Today's Arrivals
              _SectionHeader(
                title: "Today's Arrivals",
                icon: Icons.flight_land,
                onViewAll: () => context.go('/bookings'),
              ),
              const SizedBox(height: 12),
              todayArrivals.when(
                data: (arrivals) {
                  if (arrivals.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: EmptyState(
                          icon: Icons.flight_land,
                          title: 'No arrivals today',
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: arrivals.map((booking) => _BookingCard(
                      booking: booking,
                      actionLabel: 'Check In',
                      actionColor: AppTheme.successColor,
                      onAction: () => context.push('/bookings/${booking.id}'),
                    )).toList(),
                  );
                },
                loading: () => const LoadingSkeleton(itemCount: 2),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),

              const SizedBox(height: 24),

              // Today's Departures
              _SectionHeader(
                title: "Today's Departures",
                icon: Icons.flight_takeoff,
                onViewAll: () => context.go('/bookings'),
              ),
              const SizedBox(height: 12),
              todayDepartures.when(
                data: (departures) {
                  if (departures.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: EmptyState(
                          icon: Icons.flight_takeoff,
                          title: 'No departures today',
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: departures.map((booking) => _BookingCard(
                      booking: booking,
                      actionLabel: 'Check Out',
                      actionColor: AppTheme.warningColor,
                      onAction: () => context.push('/bookings/${booking.id}'),
                    )).toList(),
                  );
                },
                loading: () => const LoadingSkeleton(itemCount: 2),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar(BuildContext context, ThemeData theme, dynamic user) {
    final isDark = theme.brightness == Brightness.dark;
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.5),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.6),
                  width: 0.5,
                ),
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dashboard'),
                  if (user != null)
                    Text(
                      'Welcome, ${user.fullName ?? user.username ?? 'User'}',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push('/notifications'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoomStatusColor(String? status) => switch (status) {
    'Available' => AppTheme.availableColor,
    'Occupied' => AppTheme.occupiedColor,
    'Maintenance' => AppTheme.maintenanceColor,
    'Dirty' => AppTheme.dirtyColor,
    _ => AppTheme.noInvoiceColor,
  };

  IconData _getRoomStatusIcon(String? status) => switch (status) {
    'Available' => Icons.check_circle_outline,
    'Occupied' => Icons.person,
    'Maintenance' => Icons.build_outlined,
    'Dirty' => Icons.cleaning_services_outlined,
    _ => Icons.help_outline,
  };
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.6),
              width: 0.8,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  children: [
                    Icon(icon, color: color, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onViewAll;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleMedium),
        const Spacer(),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text('View All'),
          ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final dynamic booking;
  final String actionLabel;
  final Color actionColor;
  final VoidCallback onAction;

  const _BookingCard({
    required this.booking,
    required this.actionLabel,
    required this.actionColor,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onAction,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.guest?.name ?? 'Guest',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Room ${booking.room?.roomNumber ?? '-'} • ${booking.room?.roomType?.name ?? ''}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: booking.status ?? '',
                color: _getBookingStatusColor(booking.status),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBookingStatusColor(String? status) => switch (status) {
    'Confirmed' => AppTheme.confirmedColor,
    'Pending' => AppTheme.pendingColor,
    'CheckedIn' => AppTheme.checkedInColor,
    'CheckedOut' => AppTheme.checkedOutColor,
    'Cancelled' => AppTheme.cancelledColor,
    _ => AppTheme.noInvoiceColor,
  };
}
