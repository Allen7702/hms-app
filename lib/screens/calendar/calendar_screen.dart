import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hms_app/models/booking.dart';
import 'package:hms_app/providers/booking_provider.dart';
import 'package:hms_app/shared/status_badge.dart';
import 'package:hms_app/utils/constants.dart';
import 'package:hms_app/utils/formatters.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<Booking> _getEventsForDay(DateTime day, List<Booking> bookings) {
    return bookings.where((b) {
      final checkIn = b.checkIn != null ? DateTime.tryParse(b.checkIn!) : null;
      final checkOut =
          b.checkOut != null ? DateTime.tryParse(b.checkOut!) : null;
      if (checkIn == null) return false;
      final endDate = checkOut ?? checkIn;
      return !day.isBefore(DateTime(checkIn.year, checkIn.month, checkIn.day)) &&
          !day.isAfter(DateTime(endDate.year, endDate.month, endDate.day));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingsAsync = ref.watch(bookingsProvider(null));

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
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.5),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
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
                title: const Text('Calendar'),
              ),
            ),
          ),
        ),
      ),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (bookings) {
          final selectedEvents = _selectedDay != null
              ? _getEventsForDay(_selectedDay!, bookings)
              : _getEventsForDay(_focusedDay, bookings);

          return Column(
            children: [
              TableCalendar<Booking>(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                calendarFormat: _calendarFormat,
                onFormatChanged: (fmt) =>
                    setState(() => _calendarFormat = fmt),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                onPageChanged: (focused) {
                  _focusedDay = focused;
                },
                eventLoader: (day) => _getEventsForDay(day, bookings),
                calendarStyle: CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      _selectedDay != null
                          ? Formatters.date(_selectedDay)
                          : Formatters.date(_focusedDay),
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${selectedEvents.length} booking${selectedEvents.length != 1 ? 's' : ''}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: selectedEvents.isEmpty
                    ? Center(
                        child: Text(
                          'No bookings on this day',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: selectedEvents.length,
                        itemBuilder: (ctx, i) {
                          final b = selectedEvents[i];
                          final statusEnum = BookingStatus.values
                              .where((s) => s.label == b.status);
                          final bStatus = statusEnum.isNotEmpty
                              ? statusEnum.first
                              : BookingStatus.pending;
                          return Card(
                            child: ListTile(
                              onTap: () =>
                                  context.push('/bookings/${b.id}'),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: bStatus.color
                                      .withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Icon(bStatus.icon,
                                    color: bStatus.color, size: 20),
                              ),
                              title: Text(
                                b.guest?.name ?? 'Guest',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                'Room ${b.room?.roomNumber ?? '-'} · #${b.id}',
                              ),
                              trailing: StatusBadge(
                                label: bStatus.label,
                                color: bStatus.color,
                                fontSize: 11,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    ),
    );
  }
}
