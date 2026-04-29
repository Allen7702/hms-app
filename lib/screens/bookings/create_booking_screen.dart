import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hms_app/models/guest.dart';
import 'package:hms_app/models/room.dart';
import 'package:hms_app/models/room_type.dart';
import 'package:hms_app/providers/booking_provider.dart';
import 'package:hms_app/providers/guest_provider.dart';
import 'package:hms_app/providers/room_provider.dart';
import 'package:hms_app/shared/currency_text.dart';
import 'package:hms_app/utils/formatters.dart';


class CreateBookingScreen extends ConsumerStatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 1: Guest selection
  Guest? _selectedGuest;
  final _guestSearchController = TextEditingController();
  String _guestSearch = '';

  // Step 2: Room & Dates
  Room? _selectedRoom;
  RoomType? _selectedRoomType;
  DateTimeRange? _dateRange;
  int _adults = 1;
  int _children = 0;
  String _source = 'Direct';

  // Step 3: Additional info
  final _specialRequestsController = TextEditingController();
  final _notesController = TextEditingController();

  static const _sources = [
    'Direct',
    'Phone',
    'Email',
    'Walk-in',
    'Website',
    'OTA',
    'Agent',
  ];

  @override
  void dispose() {
    _guestSearchController.dispose();
    _specialRequestsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _nights {
    if (_dateRange == null) return 0;
    return _dateRange!.end.difference(_dateRange!.start).inDays;
  }

  num get _rate {
    return _selectedRoom?.roomType?.price ??
        _selectedRoomType?.price ??
        0;
  }

  num get _total => _rate * _nights;

  bool get _canProceedFromStep0 => _selectedGuest != null;
  bool get _canProceedFromStep1 =>
      _selectedRoom != null && _dateRange != null && _nights > 0;
  bool get _canSubmit =>
      _canProceedFromStep0 && _canProceedFromStep1;

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _dateRange ??
          DateTimeRange(
            start: now,
            end: now.add(const Duration(days: 1)),
          ),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx),
          child: child!,
        );
      },
    );
    if (result != null) {
      setState(() => _dateRange = result);
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final data = {
        'guest_id': _selectedGuest!.id,
        'room_id': _selectedRoom!.id,
        'check_in': _dateRange!.start.toIso8601String(),
        'check_out': _dateRange!.end.toIso8601String(),
        'status': 'Confirmed',
        'source': _source,
        'rate_applied': _rate,
        'adults': _adults,
        'children': _children,
        'payment_status': 'Pending',
        if (_specialRequestsController.text.isNotEmpty)
          'special_requests': _specialRequestsController.text,
        if (_notesController.text.isNotEmpty)
          'notes': _notesController.text,
      };

      final booking = await repo.create(data);
      // Invalidate bookings list
      ref.invalidate(bookingsProvider(null));

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking #${booking.id} created successfully'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create booking: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          preferredSize: const Size.fromHeight(kToolbarHeight + 4),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withAlpha(13)
                      : Colors.white.withAlpha(120),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white.withAlpha(26)
                          : Colors.white.withAlpha(77),
                    ),
                  ),
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  title: const Text('New Booking'),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(4),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / 3,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      body: Column(
        children: [
          // Step indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _StepIndicator(
                  step: 0,
                  label: 'Guest',
                  icon: Icons.person_outline,
                  currentStep: _currentStep,
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep > 0
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                _StepIndicator(
                  step: 1,
                  label: 'Room & Dates',
                  icon: Icons.hotel_outlined,
                  currentStep: _currentStep,
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep > 1
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                _StepIndicator(
                  step: 2,
                  label: 'Confirm',
                  icon: Icons.check_circle_outline,
                  currentStep: _currentStep,
                ),
              ],
            ),
          ),

          // Step content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: switch (_currentStep) {
                0 => _GuestStep(
                    key: const ValueKey('guest'),
                    selectedGuest: _selectedGuest,
                    searchController: _guestSearchController,
                    searchQuery: _guestSearch,
                    onSearchChanged: (v) =>
                        setState(() => _guestSearch = v),
                    onGuestSelected: (g) =>
                        setState(() => _selectedGuest = g),
                  ),
                1 => _RoomDateStep(
                    key: const ValueKey('room'),
                    selectedRoom: _selectedRoom,
                    selectedRoomType: _selectedRoomType,
                    dateRange: _dateRange,
                    adults: _adults,
                    children: _children,
                    source: _source,
                    sources: _sources,
                    onRoomSelected: (r) =>
                        setState(() => _selectedRoom = r),
                    onRoomTypeSelected: (t) =>
                        setState(() => _selectedRoomType = t),
                    onPickDateRange: _pickDateRange,
                    onAdultsChanged: (v) => setState(() => _adults = v),
                    onChildrenChanged: (v) =>
                        setState(() => _children = v),
                    onSourceChanged: (v) =>
                        setState(() => _source = v),
                  ),
                2 => _ConfirmStep(
                    key: const ValueKey('confirm'),
                    guest: _selectedGuest,
                    room: _selectedRoom,
                    dateRange: _dateRange,
                    adults: _adults,
                    children: _children,
                    source: _source,
                    nights: _nights,
                    rate: _rate,
                    total: _total,
                    specialRequestsController: _specialRequestsController,
                    notesController: _notesController,
                  ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),

          // Bottom navigation
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  OutlinedButton.icon(
                    onPressed: _prevStep,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Back'),
                  ),
                const Spacer(),
                if (_currentStep < 2)
                  FilledButton.icon(
                    onPressed: (_currentStep == 0 && _canProceedFromStep0) ||
                            (_currentStep == 1 && _canProceedFromStep1)
                        ? _nextStep
                        : null,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Next'),
                  ),
                if (_currentStep == 2)
                  FilledButton.icon(
                    onPressed: _canSubmit && !_isSubmitting ? _submit : null,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: const Text('Create Booking'),
                  ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

// ─── Step Indicator ──────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int step;
  final String label;
  final IconData icon;
  final int currentStep;

  const _StepIndicator({
    required this.step,
    required this.label,
    required this.icon,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = step <= currentStep;
    final isCurrent = step == currentStep;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ─── Step 1: Guest Selection ─────────────────────────────────────────

class _GuestStep extends ConsumerWidget {
  final Guest? selectedGuest;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Guest> onGuestSelected;

  const _GuestStep({
    super.key,
    required this.selectedGuest,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onGuestSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final guestsAsync = ref.watch(guestsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Guest',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Choose the guest for this booking',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search guests by name, email or phone...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                ),
                onChanged: onSearchChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Selected guest highlight
        if (selectedGuest != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Card(
              color: theme.colorScheme.primaryContainer,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    (selectedGuest!.name ?? '?')[0].toUpperCase(),
                    style: TextStyle(color: theme.colorScheme.onPrimary),
                  ),
                ),
                title: Text(selectedGuest!.name ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(selectedGuest!.email ?? ''),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
          ),

        const SizedBox(height: 4),

        // Guest list
        Expanded(
          child: guestsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (guests) {
              var filtered = guests;
              if (searchQuery.isNotEmpty) {
                final q = searchQuery.toLowerCase();
                filtered = guests.where((g) {
                  return (g.name?.toLowerCase().contains(q) ?? false) ||
                      (g.email?.toLowerCase().contains(q) ?? false) ||
                      (g.phone?.contains(q) ?? false);
                }).toList();
              }

              if (filtered.isEmpty) {
                return Center(
                  child: Text('No guests found',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final guest = filtered[i];
                  final isSelected = selectedGuest?.id == guest.id;
                  return Card(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.3)
                        : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          (guest.name ?? '?')[0].toUpperCase(),
                        ),
                      ),
                      title: Text(guest.name ?? 'Unknown'),
                      subtitle: Text(
                        [guest.email, guest.phone]
                            .where((e) => e != null && e.isNotEmpty)
                            .join(' · '),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle,
                              color: theme.colorScheme.primary)
                          : null,
                      onTap: () => onGuestSelected(guest),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Step 2: Room & Dates ────────────────────────────────────────────

class _RoomDateStep extends ConsumerWidget {
  final Room? selectedRoom;
  final RoomType? selectedRoomType;
  final DateTimeRange? dateRange;
  final int adults;
  final int children;
  final String source;
  final List<String> sources;
  final ValueChanged<Room> onRoomSelected;
  final ValueChanged<RoomType?> onRoomTypeSelected;
  final VoidCallback onPickDateRange;
  final ValueChanged<int> onAdultsChanged;
  final ValueChanged<int> onChildrenChanged;
  final ValueChanged<String> onSourceChanged;

  const _RoomDateStep({
    super.key,
    required this.selectedRoom,
    required this.selectedRoomType,
    required this.dateRange,
    required this.adults,
    required this.children,
    required this.source,
    required this.sources,
    required this.onRoomSelected,
    required this.onRoomTypeSelected,
    required this.onPickDateRange,
    required this.onAdultsChanged,
    required this.onChildrenChanged,
    required this.onSourceChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final roomsAsync = ref.watch(roomsProvider);
    final roomTypesAsync = ref.watch(roomTypesProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Date Range
        Text('Stay Dates',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPickDateRange,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: dateRange != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${Formatters.date(dateRange!.start)} → ${Formatters.date(dateRange!.end)}',
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${dateRange!.end.difference(dateRange!.start).inDays} nights',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        )
                      : Text(
                          'Tap to select dates',
                          style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Guest count row
        Text('Guests',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _CounterField(
                label: 'Adults',
                value: adults,
                min: 1,
                max: 10,
                onChanged: onAdultsChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CounterField(
                label: 'Children',
                value: children,
                min: 0,
                max: 10,
                onChanged: onChildrenChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Source
        Text('Booking Source',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: source,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.source_outlined),
          ),
          items: sources
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) {
            if (v != null) onSourceChanged(v);
          },
        ),
        const SizedBox(height: 20),

        // Room type filter
        Text('Room Type',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        roomTypesAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (types) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All Types'),
                    selected: selectedRoomType == null,
                    onSelected: (_) => onRoomTypeSelected(null),
                  ),
                  ...types.map((t) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: FilterChip(
                          label: Text(
                              '${t.name ?? ''} (${Formatters.currency(t.price ?? 0)})'),
                          selected: selectedRoomType?.id == t.id,
                          onSelected: (_) => onRoomTypeSelected(t),
                        ),
                      )),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Available rooms
        Text('Select Room',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        roomsAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (rooms) {
            var available = rooms
                .where((r) => r.status == 'Available')
                .toList();
            if (selectedRoomType != null) {
              available = available
                  .where((r) => r.roomTypeId == selectedRoomType!.id)
                  .toList();
            }

            if (available.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No available rooms${selectedRoomType != null ? ' for ${selectedRoomType!.name}' : ''}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: available.map((room) {
                final isSelected = selectedRoom?.id == room.id;
                return Card(
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3)
                      : null,
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          room.roomNumber ?? '-',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : null,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      '${room.roomType?.name ?? 'Room'} · Floor ${room.floor ?? '-'}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: room.roomType?.price != null
                        ? Text(
                            '${Formatters.currency(room.roomType!.price!)} /night')
                        : null,
                    trailing: isSelected
                        ? Icon(Icons.check_circle,
                            color: theme.colorScheme.primary)
                        : null,
                    onTap: () => onRoomSelected(room),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _CounterField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _CounterField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 22),
                onPressed:
                    value > min ? () => onChanged(value - 1) : null,
                visualDensity: VisualDensity.compact,
              ),
              SizedBox(
                width: 24,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 22),
                onPressed:
                    value < max ? () => onChanged(value + 1) : null,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Review & Confirm ────────────────────────────────────────

class _ConfirmStep extends StatelessWidget {
  final Guest? guest;
  final Room? room;
  final DateTimeRange? dateRange;
  final int adults;
  final int children;
  final String source;
  final int nights;
  final num rate;
  final num total;
  final TextEditingController specialRequestsController;
  final TextEditingController notesController;

  const _ConfirmStep({
    super.key,
    required this.guest,
    required this.room,
    required this.dateRange,
    required this.adults,
    required this.children,
    required this.source,
    required this.nights,
    required this.rate,
    required this.total,
    required this.specialRequestsController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Review Booking',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Please review the details before confirming',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),

        // Guest summary
        _SummarySection(
          title: 'Guest',
          icon: Icons.person_outline,
          rows: [
            _SummaryRow('Name', guest?.name ?? '-'),
            _SummaryRow('Email', guest?.email ?? '-'),
            _SummaryRow('Phone', guest?.phone ?? '-'),
          ],
        ),
        const SizedBox(height: 12),

        // Room summary
        _SummarySection(
          title: 'Room',
          icon: Icons.hotel_outlined,
          rows: [
            _SummaryRow('Room', room?.roomNumber ?? '-'),
            _SummaryRow('Type', room?.roomType?.name ?? '-'),
            _SummaryRow('Floor', room?.floor ?? '-'),
          ],
        ),
        const SizedBox(height: 12),

        // Stay summary
        _SummarySection(
          title: 'Stay',
          icon: Icons.calendar_month_outlined,
          rows: [
            _SummaryRow('Check-in', Formatters.date(dateRange?.start)),
            _SummaryRow('Check-out', Formatters.date(dateRange?.end)),
            _SummaryRow(
                'Duration', '$nights ${nights == 1 ? 'night' : 'nights'}'),
            _SummaryRow(
              'Guests',
              '$adults adult${adults > 1 ? 's' : ''}${children > 0 ? ', $children child${children > 1 ? 'ren' : ''}' : ''}',
            ),
            _SummaryRow('Source', source),
          ],
        ),
        const SizedBox(height: 12),

        // Billing summary
        Card(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nightly Rate', style: theme.textTheme.bodyMedium),
                    Text(Formatters.currency(rate)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('× $nights nights',
                        style: theme.textTheme.bodyMedium),
                    const Text(''),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    CurrencyText(
                      amount: total,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Special Requests
        Text('Special Requests',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: specialRequestsController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'e.g., Extra pillows, late check-out...',
          ),
        ),
        const SizedBox(height: 12),

        // Notes
        Text('Internal Notes',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: notesController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Notes visible to staff only...',
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _SummarySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_SummaryRow> rows;

  const _SummarySection({
    required this.title,
    required this.icon,
    required this.rows,
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
                Text(title,
                    style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 12),
            ...rows.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(r.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ),
                      Expanded(
                        child: Text(r.value,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);
}
