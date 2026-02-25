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
import 'package:intl/intl.dart';

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
      extendBodyBehindAppBar: false,
      appBar: _buildGlassAppBar(context, theme, user),
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        onRefresh: () async {
          ref.invalidate(roomStatusCountsProvider);
          ref.invalidate(todayArrivalsProvider);
          ref.invalidate(todayDeparturesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Welcome Banner
              _WelcomeBanner(user: user),
            
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid
                    roomStatusCounts.when(
                      data: (counts) {
                        final total = counts.values.fold(0, (a, b) => a + b);
                        final occupied = counts['Occupied'] ?? 0;
                        final available = counts['Available'] ?? 0;
                        final occupancyRate = total > 0
                            ? (occupied / total * 100)
                            : 0.0;

                        return GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.5,
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
                              icon: Icons.trending_up_rounded,
                              color: AppTheme.successColor,
                            ),
                            StatsCard(
                              label: 'Available',
                              value: '$available',
                              icon: Icons.check_circle_outline_rounded,
                              color: AppTheme.availableColor,
                            ),
                            StatsCard(
                              label: 'Occupied',
                              value: '$occupied',
                              icon: Icons.person_rounded,
                              color: AppTheme.occupiedColor,
                            ),
                          ],
                        );
                      },
                      loading: () => const SkeletonGrid(itemCount: 4),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),

                    const SizedBox(height: 28),

                    // Quick Actions
                    _SectionHeader(
                      title: 'Quick Actions',
                      icon: Icons.bolt_rounded,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.add_circle_rounded,
                            label: 'New Booking',
                            color: AppTheme.infoColor,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF228BE6), Color(0xFF4DABF7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => context.push('/bookings/create'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.login_rounded,
                            label: 'Check-In',
                            color: AppTheme.successColor,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF40C057), Color(0xFF69DB7C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => context.go('/bookings'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.logout_rounded,
                            label: 'Check-Out',
                            color: AppTheme.warningColor,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFAB005), Color(0xFFFFD43B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () => context.go('/bookings'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Room Status Grid
                    _SectionHeader(
                      title: 'Room Status',
                      icon: Icons.grid_view_rounded,
                      onViewAll: () => context.go('/rooms'),
                    ),
                    const SizedBox(height: 8),
                    // Legend row
                    _RoomStatusLegend(),
                    const SizedBox(height: 12),
                    ref
                        .watch(roomsProvider)
                        .when(
                          data: (rooms) {
                            if (rooms.isEmpty) {
                              return const EmptyState(
                                icon: Icons.meeting_room_outlined,
                                title: 'No rooms found',
                              );
                            }
                            final displayRooms = rooms.length > 24
                                ? rooms.sublist(0, 24)
                                : rooms;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                    childAspectRatio: 1.1,
                                  ),
                              itemCount: displayRooms.length,
                              itemBuilder: (context, index) {
                                final room = displayRooms[index];
                                final color = _getRoomStatusColor(room.status);
                                return _RoomStatusTile(
                                  room: room,
                                  color: color,
                                  onTap: () =>
                                      context.push('/rooms/${room.id}'),
                                );
                              },
                            );
                          },
                          loading: () => const SkeletonGrid(itemCount: 8),
                          error: (e, _) =>
                              Center(child: Text('Error loading rooms: $e')),
                        ),

                    const SizedBox(height: 28),

                    // Today's Arrivals
                    _SectionHeader(
                      title: "Today's Arrivals",
                      icon: Icons.flight_land_rounded,
                      onViewAll: () => context.go('/bookings'),
                    ),
                    const SizedBox(height: 12),
                    todayArrivals.when(
                      data: (arrivals) {
                        if (arrivals.isEmpty) {
                          return _EmptyBookingCard(
                            icon: Icons.flight_land_rounded,
                            message: 'No arrivals today',
                          );
                        }
                        return Column(
                          children: arrivals
                              .map(
                                (booking) => _BookingCard(
                                  booking: booking,
                                  actionLabel: 'Check In',
                                  actionColor: AppTheme.successColor,
                                  accentGradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF40C057),
                                      Color(0xFF69DB7C),
                                    ],
                                  ),
                                  onAction: () =>
                                      context.push('/bookings/${booking.id}'),
                                ),
                              )
                              .toList(),
                        );
                      },
                      loading: () => const LoadingSkeleton(itemCount: 2),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),

                    const SizedBox(height: 28),

                    // Today's Departures
                    _SectionHeader(
                      title: "Today's Departures",
                      icon: Icons.flight_takeoff_rounded,
                      onViewAll: () => context.go('/bookings'),
                    ),
                    const SizedBox(height: 12),
                    todayDepartures.when(
                      data: (departures) {
                        if (departures.isEmpty) {
                          return _EmptyBookingCard(
                            icon: Icons.flight_takeoff_rounded,
                            message: 'No departures today',
                          );
                        }
                        return Column(
                          children: departures
                              .map(
                                (booking) => _BookingCard(
                                  booking: booking,
                                  actionLabel: 'Check Out',
                                  actionColor: AppTheme.warningColor,
                                  accentGradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFAB005),
                                      Color(0xFFFFD43B),
                                    ],
                                  ),
                                  onAction: () =>
                                      context.push('/bookings/${booking.id}'),
                                ),
                              )
                              .toList(),
                        );
                      },
                      loading: () => const LoadingSkeleton(itemCount: 2),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar(
    BuildContext context,
    ThemeData theme,
    dynamic user,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF228BE6), Color(0xFF7950F2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.hotel_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HMS',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push('/notifications'),
                ),
                const SizedBox(width: 4),
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
}

// ─── Welcome Banner ───────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  final dynamic user;
  const _WelcomeBanner({this.user});

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(now);
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';
    final name = user?.fullName ?? user?.username ?? 'there';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1A2A4A), Color(0xFF1A1B2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF228BE6), Color(0xFF7950F2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: Stack(
        children: [
          // Decorative circles — positioned relative to full banner edges
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 180,
              // height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x337950F2), // purple
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: 30,
            child: Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x3374C7F7), // cyan
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x2CF06595), // pink
              ),
            ),
          ),
          // Content — padding lives here so circles are unconstrained
          Padding(
            padding: EdgeInsets.fromLTRB(20, statusBarHeight + 20, 20, 28),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 7,
                          color: Colors.green.shade300,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '$greeting,',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Here's your hotel overview for today",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Room Status Tile ─────────────────────────────────────────────────────────

class _RoomStatusTile extends StatelessWidget {
  final dynamic room;
  final Color color;
  final VoidCallback onTap;

  const _RoomStatusTile({
    required this.room,
    required this.color,
    required this.onTap,
  });

  IconData _getIcon(String? status) => switch (status) {
    'Available' => Icons.check_circle_outline_rounded,
    'Occupied' => Icons.person_rounded,
    'Maintenance' => Icons.build_outlined,
    'Dirty' => Icons.cleaning_services_outlined,
    _ => Icons.help_outline,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getIcon(room.status), size: 16, color: color),
              const SizedBox(height: 3),
              Text(
                room.roomNumber ?? '?',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Room Status Legend ───────────────────────────────────────────────────────

class _RoomStatusLegend extends StatelessWidget {
  static const _items = [
    ('Available', AppTheme.availableColor),
    ('Occupied', AppTheme.occupiedColor),
    ('Dirty', AppTheme.dirtyColor),
    ('Maintenance', AppTheme.maintenanceColor),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: _items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: item.$2, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              item.$1,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ─── Quick Action Button ──────────────────────────────────────────────────────

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.gradient,
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
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.7),
              width: 0.8,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 8,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF343A40),
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

// ─── Section Header ───────────────────────────────────────────────────────────

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
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Text(title, style: theme.textTheme.titleMedium),
        const Spacer(),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('View All', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Booking Card ─────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final dynamic booking;
  final String actionLabel;
  final Color actionColor;
  final LinearGradient accentGradient;
  final VoidCallback onAction;

  const _BookingCard({
    required this.booking,
    required this.actionLabel,
    required this.actionColor,
    required this.accentGradient,
    required this.onAction,
  });

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Color _getBookingStatusColor(String? status) => switch (status) {
    'Confirmed' => AppTheme.confirmedColor,
    'Pending' => AppTheme.pendingColor,
    'CheckedIn' => AppTheme.checkedInColor,
    'CheckedOut' => AppTheme.checkedOutColor,
    'Cancelled' => AppTheme.cancelledColor,
    _ => AppTheme.noInvoiceColor,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guestName = booking.guest?.name ?? 'Guest';
    final roomNum = booking.room?.roomNumber ?? '-';
    final roomType = booking.room?.roomType?.name ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onAction,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: accentGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(guestName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guestName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.meeting_room_outlined,
                          size: 13,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 3),
                        Text('Room $roomNum', style: theme.textTheme.bodySmall),
                        if (roomType.isNotEmpty) ...[
                          Text('  ·  ', style: theme.textTheme.bodySmall),
                          Text(roomType, style: theme.textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right side: status + action button
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(
                    label: booking.status ?? '',
                    color: _getBookingStatusColor(booking.status),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: accentGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: actionColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        actionLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty Booking Card ───────────────────────────────────────────────────────

class _EmptyBookingCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyBookingCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Row(
          children: [
            Icon(
              icon,
              size: 36,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 16),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
