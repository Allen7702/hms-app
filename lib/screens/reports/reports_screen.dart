import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/providers/booking_provider.dart';
import 'package:hms_app/providers/room_provider.dart';
import 'package:hms_app/utils/formatters.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static const _statusColors = <String, Color>{
    'available': Colors.green,
    'occupied': Colors.blue,
    'maintenance': Colors.orange,
    'dirty': Colors.brown,
  };

  static const _statusLabels = <String, String>{
    'available': 'Available',
    'occupied': 'Occupied',
    'maintenance': 'Maintenance',
    'dirty': 'Dirty',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final roomStatusAsync = ref.watch(roomStatusCountsProvider);
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
                title: const Text('Reports'),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Room Occupancy Pie Chart ──────────────────────
          Text('Room Status Overview',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: roomStatusAsync.when(
                loading: () => const SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SizedBox(
                    height: 220,
                    child: Center(child: Text('Error: $e'))),
                data: (counts) {
                  final total = counts.values.fold<int>(0, (a, b) => a + b);
                  if (total == 0) {
                    return const SizedBox(
                      height: 220,
                      child: Center(child: Text('No room data')),
                    );
                  }

                  final entries = counts.entries
                      .where((e) => e.value > 0)
                      .toList();

                  return SizedBox(
                    height: 220,
                    child: Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 36,
                              sections: entries.map((e) {
                                final color =
                                    _statusColors[e.key] ??
                                        Colors.grey;
                                final pct = (e.value / total * 100).round();
                                return PieChartSectionData(
                                  value: e.value.toDouble(),
                                  color: color,
                                  radius: 50,
                                  title: '$pct%',
                                  titleStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: entries.map((e) {
                            final color =
                                _statusColors[e.key] ??
                                    Colors.grey;
                            final label =
                                _statusLabels[e.key] ?? e.key;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius:
                                          BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('$label (${e.value})',
                                      style: theme.textTheme.bodySmall),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Booking Source Breakdown ──────────────────────
          Text('Booking Sources',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: bookingsAsync.when(
                loading: () => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SizedBox(
                    height: 200,
                    child: Center(child: Text('Error: $e'))),
                data: (bookings) {
                  // Count by source
                  final sourceCounts = <String, int>{};
                  for (final b in bookings) {
                    final src = b.source ?? 'unknown';
                    sourceCounts[src] = (sourceCounts[src] ?? 0) + 1;
                  }

                  if (sourceCounts.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Text('No booking data')),
                    );
                  }

                  final sorted = sourceCounts.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  final colors = [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.teal,
                    Colors.red,
                    Colors.amber,
                  ];

                  return Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (sorted.first.value * 1.2),
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipItem: (group, groupIndex, rod,
                                    rodIndex) {
                                  return BarTooltipItem(
                                    '${sorted[groupIndex].key}\n${rod.toY.round()}',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx < sorted.length) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8),
                                        child: Text(
                                          sorted[idx]
                                              .key
                                              .replaceAll('_', '\n'),
                                          style: const TextStyle(
                                              fontSize: 10),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                  reservedSize: 36,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  getTitlesWidget: (value, _) => Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: sorted.asMap().entries.map((entry) {
                              return BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.value.toDouble(),
                                    color: colors[
                                        entry.key % colors.length],
                                    width: 22,
                                    borderRadius:
                                        const BorderRadius.vertical(
                                            top: Radius.circular(4)),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── Revenue Summary ──────────────────────────────
          Text('Revenue Summary',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          bookingsAsync.when(
            loading: () => const Card(
                child: SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()))),
            error: (e, _) => Card(
                child: SizedBox(
                    height: 100,
                    child: Center(child: Text('Error: $e')))),
            data: (bookings) {
              var totalRevenue = 0.0;
              var checkedInRevenue = 0.0;
              var pendingRevenue = 0.0;
              for (final b in bookings) {
                final amount = (b.rateApplied ?? 0).toDouble();
                totalRevenue += amount;
                if (b.status == 'checked_in' || b.status == 'checked_out') {
                  checkedInRevenue += amount;
                }
                if (b.status == 'pending' || b.status == 'confirmed') {
                  pendingRevenue += amount;
                }
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _RevenueRow(
                          label: 'Total Bookings Revenue',
                          amount: totalRevenue,
                          color: theme.colorScheme.primary),
                      const SizedBox(height: 12),
                      _RevenueRow(
                          label: 'Realized Revenue',
                          amount: checkedInRevenue,
                          color: Colors.green),
                      const SizedBox(height: 12),
                      _RevenueRow(
                          label: 'Pending Revenue',
                          amount: pendingRevenue,
                          color: Colors.orange),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
    );
  }
}

class _RevenueRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _RevenueRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              Text(
                Formatters.currency(amount),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
