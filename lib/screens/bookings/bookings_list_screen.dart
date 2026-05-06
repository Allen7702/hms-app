import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hms_app/models/booking.dart';
import 'package:hms_app/providers/booking_provider.dart';
import 'package:hms_app/shared/empty_state.dart';
import 'package:hms_app/shared/loading_skeleton.dart';
import 'package:hms_app/shared/status_badge.dart';
import 'package:hms_app/shared/currency_text.dart';
import 'package:hms_app/utils/constants.dart';
import 'package:hms_app/utils/formatters.dart';

class BookingsListScreen extends ConsumerStatefulWidget {
  const BookingsListScreen({super.key});

  @override
  ConsumerState<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends ConsumerState<BookingsListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _tabs = [
    ('All', Icons.all_inbox_rounded, null),
    ('In-House', Icons.hotel_rounded, 'CheckedIn'),
    ('Confirmed', Icons.check_circle_outline_rounded, 'Confirmed'),
    ('Pending', Icons.hourglass_empty_rounded, 'Pending'),
    ('Checked Out', Icons.logout_rounded, 'CheckedOut'),
    ('Cancelled', Icons.cancel_outlined, 'Cancelled'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const SizedBox(height: 12),

          // ── Glassmorphic search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.7),
                      width: 0.8,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Search by guest name, room or ID...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                  ),
                ),
              ),
            ),
          ),

          // ── Tab Bar ──
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              height: 36,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                splashBorderRadius: BorderRadius.circular(20),
                tabs: _tabs
                    .map(
                      (t) => Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(t.$2, size: 14),
                            const SizedBox(width: 5),
                            Text(t.$1),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Tab Content ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs
                  .map(
                    (tab) => _BookingTabContent(
                      status: tab.$3,
                      searchQuery: _searchQuery,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/bookings/create'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Booking'),
      ),
    );
  }
}

// ─── Tab Content ─────────────────────────────────────────────────────────────

class _BookingTabContent extends ConsumerWidget {
  final String? status;
  final String searchQuery;

  const _BookingTabContent({this.status, this.searchQuery = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider(status));
    final theme = Theme.of(context);

    return bookingsAsync.when(
      loading: () => const LoadingSkeleton(),
      error: (err, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text('Failed to load bookings', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              err.toString(),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () => ref.invalidate(bookingsProvider(status)),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (bookings) {
        var filtered = bookings;
        if (searchQuery.isNotEmpty) {
          final q = searchQuery.toLowerCase();
          filtered = bookings.where((b) {
            final guestName = b.guest?.name?.toLowerCase() ?? '';
            final bookingId = b.id.toString();
            final roomNumber = b.room?.roomNumber?.toLowerCase() ?? '';
            return guestName.contains(q) ||
                bookingId.contains(q) ||
                roomNumber.contains(q);
          }).toList();
        }

        if (filtered.isEmpty) {
          return EmptyState(
            icon: Icons.book_online_outlined,
            title: searchQuery.isNotEmpty
                ? 'No matching bookings'
                : 'No bookings here',
            subtitle: searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Create a new booking to get started',
            actionLabel: searchQuery.isEmpty ? 'New Booking' : null,
            onAction: searchQuery.isEmpty
                ? () => context.push('/bookings/create')
                : null,
          );
        }

        return RefreshIndicator(
          color: theme.colorScheme.primary,
          onRefresh: () async => ref.invalidate(bookingsProvider(status)),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _BookingCard(booking: filtered[index]),
          ),
        );
      },
    );
  }
}

// ─── Booking Card ─────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final guestName = booking.guest?.name ?? 'Unknown Guest';
    final roomNumber = booking.room?.roomNumber ?? '-';
    final roomTypeName = booking.room?.roomType?.name ?? '';
    final checkIn = booking.checkIn != null
        ? DateTime.tryParse(booking.checkIn!)
        : null;
    final checkOut = booking.checkOut != null
        ? DateTime.tryParse(booking.checkOut!)
        : null;
    final nights = (checkIn != null && checkOut != null)
        ? Formatters.nightCount(checkIn, checkOut)
        : 0;

    final statusEnum = BookingStatus.values.where(
      (s) => s.label == booking.status,
    );
    final bookingStatus = statusEnum.isNotEmpty
        ? statusEnum.first
        : BookingStatus.pending;

    final paymentStatusEnum = PaymentStatus.values.where(
      (s) => s.label == booking.paymentStatus,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.7),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/bookings/${booking.id}'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: bookingStatus.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: bookingStatus.color.withValues(alpha: 0.3),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _initials(guestName),
                            style: TextStyle(
                              color: bookingStatus.color,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                guestName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Booking #${booking.id}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(
                          label: bookingStatus.label,
                          color: bookingStatus.color,
                          icon: bookingStatus.icon,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Divider(
                      height: 1,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.08,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Details ──
                    Row(
                      children: [
                        // Room + type
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.meeting_room_outlined,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  'Room $roomNumber${roomTypeName.isNotEmpty ? '  ·  $roomTypeName' : ''}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Nights pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$nights ${nights == 1 ? 'night' : 'nights'}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),

                    // ── Dates ──
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${Formatters.date(checkIn)}  →  ${Formatters.date(checkOut)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── Rate + Payment ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (booking.rateApplied != null)
                          Row(
                            children: [
                              CurrencyText(
                                amount: booking.rateApplied!,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Text('/night', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        if (paymentStatusEnum.isNotEmpty)
                          StatusBadge(
                            label: paymentStatusEnum.first.label,
                            color: paymentStatusEnum.first.color,
                            fontSize: 10,
                          ),
                      ],
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
