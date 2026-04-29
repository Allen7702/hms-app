import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hms_app/models/guest.dart';
import 'package:hms_app/models/booking.dart';
import 'package:hms_app/providers/guest_provider.dart';
import 'package:hms_app/providers/booking_provider.dart';
import 'package:hms_app/shared/empty_state.dart';
import 'package:hms_app/shared/loading_skeleton.dart';
import 'package:hms_app/shared/status_badge.dart';
import 'package:hms_app/utils/constants.dart';
import 'package:hms_app/utils/formatters.dart';
import 'package:hms_app/config/theme.dart';

// ─── Guest Bookings Provider ─────────────────────────────────────────────────

final guestBookingsProvider =
    FutureProvider.family<List<Booking>, int>((ref, guestId) async {
  final repo = ref.read(bookingRepositoryProvider);
  return repo.getByGuestId(guestId);
});

// ─── Guests List Screen ──────────────────────────────────────────────────────

class GuestsListScreen extends ConsumerStatefulWidget {
  const GuestsListScreen({super.key});

  @override
  ConsumerState<GuestsListScreen> createState() => _GuestsListScreenState();
}

class _GuestsListScreenState extends ConsumerState<GuestsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guestsAsync = ref.watch(guestsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
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
                ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _buildGlassAppBar(context, theme, isDark),
        body: Column(
          children: [
            // ── Spacing for AppBar ──
            SizedBox(height: topPadding + 12),

            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                        hintText: 'Search by name, email or phone...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
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
                            horizontal: 16, vertical: 14),
                      ),
                      onChanged: (v) =>
                          setState(() => _searchQuery = v.trim()),
                    ),
                  ),
                ),
              ),
            ),

            // ── Guest List ──
            Expanded(
              child: guestsAsync.when(
                loading: () => const LoadingSkeleton(),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer
                              .withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.error_outline_rounded,
                            size: 40,
                            color: theme.colorScheme.error),
                      ),
                      const SizedBox(height: 16),
                      Text('Failed to load guests',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Please check your connection and try again',
                          style: theme.textTheme.bodySmall),
                      const SizedBox(height: 20),
                      FilledButton.tonalIcon(
                        onPressed: () => ref.invalidate(guestsProvider),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (guests) {
                  var filtered = guests;
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    filtered = guests.where((g) {
                      return (g.name?.toLowerCase().contains(q) ?? false) ||
                          (g.email?.toLowerCase().contains(q) ?? false) ||
                          (g.phone?.contains(q) ?? false);
                    }).toList();
                  }

                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: Icons.people_outlined,
                      title: _searchQuery.isNotEmpty
                          ? 'No matching guests'
                          : 'No guests yet',
                      subtitle: _searchQuery.isNotEmpty
                          ? 'Try a different search term'
                          : 'Guests will appear here once bookings are created',
                    );
                  }

                  return RefreshIndicator(
                    color: theme.colorScheme.primary,
                    onRefresh: () async => ref.invalidate(guestsProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (ctx, i) =>
                          _GuestCard(guest: filtered[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar(
      BuildContext context, ThemeData theme, bool isDark) {
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
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.navyMid, AppTheme.navyLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.gold, width: 0.8),
                    ),
                    child: const Icon(Icons.people_rounded,
                        color: AppTheme.gold, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text('Guests'),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '',
                    key: const ValueKey('guest-count'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Guest Card ──────────────────────────────────────────────────────────────

class _GuestCard extends StatelessWidget {
  final Guest guest;
  const _GuestCard({required this.guest});

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  List<Color> _tierGradient(LoyaltyTier tier) => switch (tier) {
        LoyaltyTier.bronze => [const Color(0xFFCD7F32), const Color(0xFFE8A87C)],
        LoyaltyTier.silver => [const Color(0xFF9E9E9E), const Color(0xFFBDBDBD)],
        LoyaltyTier.gold => [const Color(0xFFFCC419), const Color(0xFFFFD43B)],
        _ => [AppTheme.navyMid, AppTheme.navyLight],
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loyaltyEnum =
        LoyaltyTier.values.where((t) => t.label == guest.loyaltyTier);
    final tier =
        loyaltyEnum.isNotEmpty ? loyaltyEnum.first : LoyaltyTier.none;
    final gradient = _tierGradient(tier);

    final contactLine = [guest.email, guest.phone]
        .where((e) => e != null && e.isNotEmpty)
        .join('  ·  ');

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
              onTap: () => context.push('/guests/${guest.id}'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // ── Avatar ──
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: gradient.first.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initials(guest.name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // ── Info ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  guest.name ?? 'Unknown',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (tier != LoyaltyTier.none) ...[
                                const SizedBox(width: 6),
                                Icon(tier.icon,
                                    size: 15, color: tier.color),
                              ],
                            ],
                          ),
                          if (contactLine.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              contactLine,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (guest.nationality != null &&
                              guest.nationality!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  Icons.public_rounded,
                                  size: 12,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  guest.nationality!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ── Loyalty Tier Badge + Chevron ──
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (tier != LoyaltyTier.none)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tier.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.3),
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

// ─── Guest Detail Screen ─────────────────────────────────────────────────────

class GuestDetailScreen extends ConsumerWidget {
  final int guestId;
  const GuestDetailScreen({super.key, required this.guestId});

  List<Color> _tierGradient(LoyaltyTier tier) => switch (tier) {
        LoyaltyTier.bronze => [const Color(0xFFCD7F32), const Color(0xFFE8A87C)],
        LoyaltyTier.silver => [const Color(0xFF9E9E9E), const Color(0xFFBDBDBD)],
        LoyaltyTier.gold => [const Color(0xFFFCC419), const Color(0xFFFFD43B)],
        _ => [AppTheme.navyMid, AppTheme.navyLight],
      };

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final guestAsync = ref.watch(guestDetailProvider(guestId));
    final bookingsAsync = ref.watch(guestBookingsProvider(guestId));

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
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
                ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _buildGlassAppBar(context, theme, isDark),
        body: guestAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 12),
                Text('Error: $err'),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () =>
                      ref.invalidate(guestDetailProvider(guestId)),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (guest) {
            if (guest == null) {
              return const Center(child: Text('Guest not found'));
            }

            final loyaltyEnum =
                LoyaltyTier.values.where((t) => t.label == guest.loyaltyTier);
            final tier = loyaltyEnum.isNotEmpty
                ? loyaltyEnum.first
                : LoyaltyTier.none;
            final gradient = _tierGradient(tier);

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── Profile Hero ──
                _ProfileHero(
                  guest: guest,
                  tier: tier,
                  gradient: gradient,
                  initials: _initials(guest.name),
                  isDark: isDark,
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Contact & ID ──
                      _DetailSection(
                        title: 'Contact Information',
                        icon: Icons.contact_phone_outlined,
                        children: [
                          _InfoRow(
                              icon: Icons.phone_outlined,
                              label: 'Phone',
                              value: Formatters.phone(guest.phone)),
                          _InfoRow(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: guest.email ?? '-'),
                          _InfoRow(
                              icon: Icons.location_on_outlined,
                              label: 'Address',
                              value: guest.address ?? '-'),
                          _InfoRow(
                              icon: Icons.public_rounded,
                              label: 'Nationality',
                              value: guest.nationality ?? '-'),
                          _InfoRow(
                              icon: Icons.badge_outlined,
                              label: 'ID Number',
                              value: guest.idNumber ?? '-'),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Loyalty ──
                      _DetailSection(
                        title: 'Loyalty Program',
                        icon: Icons.card_giftcard_outlined,
                        children: [
                          _InfoRow(
                            icon: Icons.star_outline_rounded,
                            label: 'Tier',
                            value: tier.label,
                            valueWidget: tier != LoyaltyTier.none
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: gradient),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(tier.icon,
                                            size: 13,
                                            color: Colors.white),
                                        const SizedBox(width: 4),
                                        Text(
                                          tier.label,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                          _InfoRow(
                              icon: Icons.toll_outlined,
                              label: 'Points',
                              value:
                                  '${guest.loyaltyPoints ?? 0} pts'),
                          _InfoRow(
                              icon: Icons.verified_user_outlined,
                              label: 'GDPR Consent',
                              value:
                                  guest.gdprConsent == true ? 'Yes' : 'No'),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Record Info ──
                      _DetailSection(
                        title: 'Record Info',
                        icon: Icons.info_outline_rounded,
                        children: [
                          _InfoRow(
                              icon: Icons.tag_rounded,
                              label: 'Guest ID',
                              value: '#${guest.id}'),
                          _InfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Created',
                            value: Formatters.dateTime(
                              guest.createdAt != null
                                  ? DateTime.tryParse(guest.createdAt!)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Booking History ──
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.history_rounded,
                                size: 16,
                                color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 10),
                          Text('Booking History',
                              style: theme.textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 12),

                      bookingsAsync.when(
                        loading: () => const Center(
                            child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        )),
                        error: (e, _) => _DetailSection(
                          title: '',
                          icon: Icons.error_outline,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('Failed to load bookings: $e'),
                            )
                          ],
                        ),
                        data: (bookings) {
                          if (bookings.isEmpty) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white
                                            .withValues(alpha: 0.05)
                                        : Colors.white
                                            .withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white
                                              .withValues(alpha: 0.1)
                                          : Colors.white
                                              .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.book_outlined,
                                          size: 36,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.2)),
                                      const SizedBox(width: 16),
                                      Text('No bookings yet',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                  color: theme
                                                      .colorScheme.onSurface
                                                      .withValues(alpha: 0.45))),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: bookings.map((b) {
                              final checkIn = b.checkIn != null
                                  ? DateTime.tryParse(b.checkIn!)
                                  : null;
                              final checkOut = b.checkOut != null
                                  ? DateTime.tryParse(b.checkOut!)
                                  : null;
                              final statusEnum = BookingStatus.values
                                  .where((s) => s.label == b.status);
                              final bStatus = statusEnum.isNotEmpty
                                  ? statusEnum.first
                                  : BookingStatus.pending;

                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 10),
                                child: _BookingHistoryCard(
                                  booking: b,
                                  bStatus: bStatus,
                                  checkIn: checkIn,
                                  checkOut: checkOut,
                                  isDark: isDark,
                                  onTap: () => context
                                      .push('/bookings/${b.id}'),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar(
      BuildContext context, ThemeData theme, bool isDark) {
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
              title: const Text('Guest Profile'),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Profile Hero ─────────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  final dynamic guest;
  final LoyaltyTier tier;
  final List<Color> gradient;
  final String initials;
  final bool isDark;

  const _ProfileHero({
    required this.guest,
    required this.tier,
    required this.gradient,
    required this.initials,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, statusBarHeight + kToolbarHeight + 24, 20, 28),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1A2A4A), Color(0xFF1A1B2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [AppTheme.navyDeep, AppTheme.navyMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -40,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 50,
            top: 50,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Content
          Row(
            children: [
              // Avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guest.name ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (guest.email != null &&
                        guest.email!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email_outlined,
                              size: 13,
                              color:
                                  Colors.white.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              guest.email!,
                              style: TextStyle(
                                color:
                                    Colors.white.withValues(alpha: 0.75),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (guest.phone != null &&
                        guest.phone!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined,
                              size: 13,
                              color:
                                  Colors.white.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            Formatters.phone(guest.phone),
                            style: TextStyle(
                              color:
                                  Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (tier != LoyaltyTier.none) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tier.icon,
                                size: 13, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${tier.label} Member',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Detail Section ───────────────────────────────────────────────────────────

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon,
                            size: 15,
                            color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.08),
                  ),
                  const SizedBox(height: 12),
                ],
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? valueWidget;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: valueWidget ??
                Text(
                  value,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Booking History Card ─────────────────────────────────────────────────────

class _BookingHistoryCard extends StatelessWidget {
  final dynamic booking;
  final BookingStatus bStatus;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final bool isDark;
  final VoidCallback onTap;

  const _BookingHistoryCard({
    required this.booking,
    required this.bStatus,
    required this.checkIn,
    required this.checkOut,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Status icon
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: bStatus.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: bStatus.color.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Icon(bStatus.icon,
                          color: bStatus.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Room ${booking.room?.roomNumber ?? '-'}',
                                style:
                                    theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '· #${booking.id}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 12,
                                  color: theme.textTheme.bodySmall?.color),
                              const SizedBox(width: 4),
                              Text(
                                '${Formatters.date(checkIn)}  →  ${Formatters.date(checkOut)}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status badge + chevron
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StatusBadge(
                            label: bStatus.label,
                            color: bStatus.color,
                            fontSize: 10),
                        const SizedBox(height: 6),
                        Icon(Icons.chevron_right_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.3)),
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
