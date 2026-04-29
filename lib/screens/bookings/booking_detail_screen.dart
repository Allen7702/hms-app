import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hms_app/models/booking.dart';
import 'package:hms_app/providers/booking_provider.dart';
import 'package:hms_app/shared/status_badge.dart';
import 'package:hms_app/shared/currency_text.dart';
import 'package:hms_app/shared/confirm_dialog.dart';
import 'package:hms_app/utils/constants.dart';
import 'package:hms_app/utils/formatters.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  bool _isActioning = false;

  BookingStatus _parseStatus(String? status) {
    final match = BookingStatus.values.where((s) => s.label == status);
    return match.isNotEmpty ? match.first : BookingStatus.pending;
  }

  Future<void> _performAction(
    String action,
    Future<void> Function() callback,
  ) async {
    if (_isActioning) return;
    setState(() => _isActioning = true);
    try {
      await callback();
      ref.invalidate(bookingDetailProvider(widget.bookingId));
      ref.invalidate(bookingsProvider(null));
      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$action successful')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to $action: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActioning = false);
    }
  }

  Future<void> _checkIn() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Check In Guest',
      message:
          'Are you sure you want to check in this guest? The room status will be updated to Occupied.',
      confirmLabel: 'Check In',
      icon: Icons.login,
    );
    if (confirmed != true) return;
    await _performAction('Check-in', () async {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.checkIn(widget.bookingId);
    });
  }

  Future<void> _checkOut() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Check Out Guest',
      message:
          'Are you sure you want to check out this guest? Please ensure all charges have been settled.',
      confirmLabel: 'Check Out',
      icon: Icons.logout,
    );
    if (confirmed != true) return;
    await _performAction('Check-out', () async {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.checkOut(widget.bookingId);
    });
  }

  Future<void> _cancel() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Cancel Booking',
      message:
          'Are you sure you want to cancel this booking? This action cannot be easily undone.',
      confirmLabel: 'Cancel Booking',
      icon: Icons.cancel_outlined,
      isDestructive: true,
    );
    if (confirmed != true) return;
    await _performAction('Cancellation', () async {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.cancel(widget.bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingDetailProvider(widget.bookingId));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0A0E21), const Color(0xFF0D1B3E), const Color(0xFF132043), const Color(0xFF0A0E21)]
              : [const Color(0xFFE8F4FD), const Color(0xFFF0E6FF), const Color(0xFFE6F7FF), const Color(0xFFF5F0FF)],
        ),
      ),
      child: Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
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
                title: Text('Booking #${widget.bookingId}'),
                actions: [
          bookingAsync.whenOrNull(
                data: (booking) {
                  if (booking == null) return const SizedBox.shrink();
                  return PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'checkin':
                          _checkIn();
                        case 'checkout':
                          _checkOut();
                        case 'cancel':
                          _cancel();
                      }
                    },
                    itemBuilder: (ctx) {
                      final status = _parseStatus(booking.status);
                      return [
                        if (status == BookingStatus.confirmed ||
                            status == BookingStatus.pending)
                          const PopupMenuItem(
                            value: 'checkin',
                            child: ListTile(
                              leading: Icon(Icons.login),
                              title: Text('Check In'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        if (status == BookingStatus.checkedIn)
                          const PopupMenuItem(
                            value: 'checkout',
                            child: ListTile(
                              leading: Icon(Icons.logout),
                              title: Text('Check Out'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        if (status != BookingStatus.cancelled &&
                            status != BookingStatus.checkedOut)
                          const PopupMenuItem(
                            value: 'cancel',
                            child: ListTile(
                              leading:
                                  Icon(Icons.cancel_outlined, color: Colors.red),
                              title: Text('Cancel',
                                  style: TextStyle(color: Colors.red)),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                      ];
                    },
                  );
                },
              ) ??
              const SizedBox.shrink(),
        ],
      ),
            ),
          ),
        ),
      ),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text('Failed to load booking'),
              const SizedBox(height: 4),
              Text(err.toString(), style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () =>
                    ref.invalidate(bookingDetailProvider(widget.bookingId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (booking) {
          if (booking == null) {
            return const Center(child: Text('Booking not found'));
          }
          return _BookingDetailBody(
            booking: booking,
            isActioning: _isActioning,
            onCheckIn: _checkIn,
            onCheckOut: _checkOut,
            onCancel: _cancel,
          );
        },
      ),
    ),
    );
  }
}

class _BookingDetailBody extends StatelessWidget {
  final Booking booking;
  final bool isActioning;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onCancel;

  const _BookingDetailBody({
    required this.booking,
    required this.isActioning,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onCancel,
  });

  BookingStatus get _status {
    final match = BookingStatus.values.where((s) => s.label == booking.status);
    return match.isNotEmpty ? match.first : BookingStatus.pending;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkIn = booking.checkIn != null
        ? DateTime.tryParse(booking.checkIn!)
        : null;
    final checkOut = booking.checkOut != null
        ? DateTime.tryParse(booking.checkOut!)
        : null;
    final nights = (checkIn != null && checkOut != null)
        ? Formatters.nightCount(checkIn, checkOut)
        : 0;
    final totalAmount = (booking.rateApplied ?? 0) * nights;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status header card
        _StatusCard(booking: booking, status: _status),
        const SizedBox(height: 16),

        // Guest information
        _SectionCard(
          title: 'Guest Information',
          icon: Icons.person_outline,
          children: [
            _InfoRow(
              label: 'Name',
              value: booking.guest?.name ?? 'Unknown',
              trailing: booking.guest != null
                  ? IconButton(
                      icon: const Icon(Icons.open_in_new, size: 18),
                      onPressed: () =>
                          context.push('/guests/${booking.guest!.id}'),
                      tooltip: 'View Guest Profile',
                    )
                  : null,
            ),
            _InfoRow(label: 'Email', value: booking.guest?.email ?? '-'),
            _InfoRow(
              label: 'Phone',
              value: Formatters.phone(booking.guest?.phone),
            ),
            if (booking.guest?.nationality != null)
              _InfoRow(
                  label: 'Nationality', value: booking.guest!.nationality!),
            if (booking.guest?.loyaltyTier != null &&
                booking.guest!.loyaltyTier != 'None')
              _InfoRow(
                label: 'Loyalty',
                value:
                    '${booking.guest!.loyaltyTier} (${booking.guest!.loyaltyPoints ?? 0} pts)',
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Room information
        _SectionCard(
          title: 'Room Details',
          icon: Icons.door_back_door_outlined,
          children: [
            _InfoRow(
              label: 'Room',
              value: booking.room?.roomNumber ?? '-',
              trailing: booking.room != null
                  ? IconButton(
                      icon: const Icon(Icons.open_in_new, size: 18),
                      onPressed: () =>
                          context.push('/rooms/${booking.room!.id}'),
                      tooltip: 'View Room',
                    )
                  : null,
            ),
            _InfoRow(
              label: 'Type',
              value: booking.room?.roomType?.name ?? '-',
            ),
            _InfoRow(
              label: 'Floor',
              value: booking.room?.floor ?? '-',
            ),
            if (booking.room?.roomType?.capacity != null)
              _InfoRow(
                label: 'Capacity',
                value: '${booking.room!.roomType!.capacity} guests',
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Stay details
        _SectionCard(
          title: 'Stay Details',
          icon: Icons.calendar_month_outlined,
          children: [
            _InfoRow(label: 'Check-in', value: Formatters.dateTime(checkIn)),
            _InfoRow(label: 'Check-out', value: Formatters.dateTime(checkOut)),
            _InfoRow(
                label: 'Duration',
                value: '$nights ${nights == 1 ? 'night' : 'nights'}'),
            _InfoRow(
              label: 'Guests',
              value:
                  '${booking.adults ?? 1} adult${(booking.adults ?? 1) > 1 ? 's' : ''}${booking.children != null && booking.children! > 0 ? ', ${booking.children} child${booking.children! > 1 ? 'ren' : ''}' : ''}',
            ),
            if (booking.source != null)
              _InfoRow(label: 'Source', value: booking.source!),
          ],
        ),
        const SizedBox(height: 12),

        // Billing summary
        _SectionCard(
          title: 'Billing Summary',
          icon: Icons.receipt_long_outlined,
          children: [
            _InfoRow(
              label: 'Nightly Rate',
              value: Formatters.currency(booking.rateApplied ?? 0),
            ),
            _InfoRow(
              label: 'Nights',
              value: nights.toString(),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                CurrencyText(
                  amount: totalAmount,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Payment Status',
              valueWidget: StatusBadge(
                label: booking.paymentStatus ?? 'Pending',
                color: PaymentStatus.values
                    .where((s) => s.label == booking.paymentStatus)
                    .firstOrNull
                    ?.color ??
                    PaymentStatus.pending.color,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Special requests & notes
        if (booking.specialRequests != null ||
            booking.notes != null)
          _SectionCard(
            title: 'Notes & Requests',
            icon: Icons.note_alt_outlined,
            children: [
              if (booking.specialRequests != null)
                _InfoRow(
                    label: 'Special Requests',
                    value: booking.specialRequests!),
              if (booking.notes != null)
                _InfoRow(label: 'Notes', value: booking.notes!),
            ],
          ),
        const SizedBox(height: 12),

        // Metadata
        _SectionCard(
          title: 'Metadata',
          icon: Icons.info_outline,
          children: [
            _InfoRow(label: 'Booking ID', value: '#${booking.id}'),
            _InfoRow(
              label: 'Created',
              value: Formatters.dateTime(
                booking.createdAt != null
                    ? DateTime.tryParse(booking.createdAt!)
                    : null,
              ),
            ),
            if (booking.updatedAt != null)
              _InfoRow(
                label: 'Last Updated',
                value: Formatters.relative(DateTime.tryParse(booking.updatedAt!)),
              ),
          ],
        ),
        const SizedBox(height: 24),

        // Action buttons
        if (_status != BookingStatus.cancelled &&
            _status != BookingStatus.checkedOut)
          _ActionButtons(
            status: _status,
            isActioning: isActioning,
            onCheckIn: onCheckIn,
            onCheckOut: onCheckOut,
            onCancel: onCancel,
          ),

        const SizedBox(height: 40),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final Booking booking;
  final BookingStatus status;

  const _StatusCard({required this.booking, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: status.color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(status.icon, color: status.color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.guest?.name ?? 'Guest',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Room ${booking.room?.roomNumber ?? '-'} · ${booking.room?.roomType?.name ?? ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(
              label: status.label,
              color: status.color,
              icon: status.icon,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final Widget? trailing;

  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? '-',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final BookingStatus status;
  final bool isActioning;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onCancel;

  const _ActionButtons({
    required this.status,
    required this.isActioning,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary action
        if (status == BookingStatus.confirmed ||
            status == BookingStatus.pending)
          FilledButton.icon(
            onPressed: isActioning ? null : onCheckIn,
            icon: isActioning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login),
            label: const Text('Check In'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),

        if (status == BookingStatus.checkedIn)
          FilledButton.icon(
            onPressed: isActioning ? null : onCheckOut,
            icon: isActioning
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: const Text('Check Out'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),

        const SizedBox(height: 8),

        // Cancel button
        OutlinedButton.icon(
          onPressed: isActioning ? null : onCancel,
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancel Booking'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}
