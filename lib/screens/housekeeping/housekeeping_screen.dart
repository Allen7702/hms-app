import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/models/housekeeping.dart';
import 'package:hms_app/providers/housekeeping_provider.dart';
import 'package:hms_app/shared/empty_state.dart';
import 'package:hms_app/shared/loading_skeleton.dart';
import 'package:hms_app/shared/status_badge.dart';
import 'package:hms_app/utils/constants.dart';
import 'package:hms_app/utils/formatters.dart';

class HousekeepingScreen extends ConsumerStatefulWidget {
  const HousekeepingScreen({super.key});

  @override
  ConsumerState<HousekeepingScreen> createState() =>
      _HousekeepingScreenState();
}

class _HousekeepingScreenState extends ConsumerState<HousekeepingScreen> {
  String? _selectedStatus;

  Future<void> _completeTask(Housekeeping task) async {
    try {
      final repo = ref.read(housekeepingRepositoryProvider);
      await repo.complete(task.id);
      ref.invalidate(housekeepingProvider);
      ref.invalidate(housekeepingStatusCountsProvider);
      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task marked as completed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _updateStatus(Housekeeping task, String status) async {
    try {
      final repo = ref.read(housekeepingRepositoryProvider);
      final data = {'status': status};
      if (status == 'Completed') {
        data['completed_at'] = DateTime.now().toIso8601String();
      }
      await repo.update(task.id, data);
      ref.invalidate(housekeepingProvider);
      ref.invalidate(housekeepingStatusCountsProvider);
      if (mounted) {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(housekeepingProvider);
    final countsAsync = ref.watch(housekeepingStatusCountsProvider);

    return Column(
      children: [
        // Status filter chips
        countsAsync.when(
          loading: () => const SizedBox(height: 52),
          error: (_, a) => const SizedBox.shrink(),
          data: (counts) {
            final total = counts.values.fold(0, (a, b) => a + b);
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  FilterChip(
                    label: Text('All ($total)'),
                    selected: _selectedStatus == null,
                    onSelected: (_) =>
                        setState(() => _selectedStatus = null),
                  ),
                  ...HousekeepingStatus.values.map((s) {
                    final count = counts[s.label] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: Text('${s.label} ($count)'),
                        selected: _selectedStatus == s.label,
                        onSelected: (_) => setState(
                          () => _selectedStatus =
                              _selectedStatus == s.label ? null : s.label,
                        ),
                        avatar: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: s.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),

        // Task list
        Expanded(
          child: tasksAsync.when(
            loading: () => const LoadingSkeleton(),
            error: (err, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  Text('Failed to load tasks'),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        ref.invalidate(housekeepingProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (tasks) {
              var filtered = tasks;
              if (_selectedStatus != null) {
                filtered = filtered
                    .where((t) => t.status == _selectedStatus)
                    .toList();
              }

              if (filtered.isEmpty) {
                return const EmptyState(
                  icon: Icons.cleaning_services_outlined,
                  title: 'No housekeeping tasks',
                  subtitle: 'All rooms are clean!',
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(housekeepingProvider);
                  ref.invalidate(housekeepingStatusCountsProvider);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: filtered.length,
                  separatorBuilder: (_, a) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) =>
                      _HousekeepingCard(
                        task: filtered[i],
                        onComplete: () => _completeTask(filtered[i]),
                        onStatusUpdate: (status) =>
                            _updateStatus(filtered[i], status),
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HousekeepingCard extends StatelessWidget {
  final Housekeeping task;
  final VoidCallback onComplete;
  final ValueChanged<String> onStatusUpdate;

  const _HousekeepingCard({
    required this.task,
    required this.onComplete,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusEnum =
        HousekeepingStatus.values.where((s) => s.label == task.status);
    final status = statusEnum.isNotEmpty
        ? statusEnum.first
        : HousekeepingStatus.pending;
    final scheduledDate = task.scheduledDate != null
        ? DateTime.tryParse(task.scheduledDate!)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.cleaning_services_outlined,
                      color: status.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room ${task.roomId ?? '-'} · #${task.id}',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (scheduledDate != null)
                        Text(
                          'Scheduled: ${Formatters.date(scheduledDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: status.label,
                  color: status.color,
                  fontSize: 11,
                ),
              ],
            ),
            if (task.notes != null && task.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.notes!,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (status != HousekeepingStatus.completed) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (status == HousekeepingStatus.pending)
                    TextButton.icon(
                      onPressed: () => onStatusUpdate('In Progress'),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Start'),
                    ),
                  if (status == HousekeepingStatus.pending ||
                      status == HousekeepingStatus.inProgress)
                    FilledButton.tonalIcon(
                      onPressed: onComplete,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Complete'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
