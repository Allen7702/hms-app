import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/models/maintenance.dart';
import 'package:hms_app/providers/maintenance_provider.dart';
import 'package:hms_app/shared/empty_state.dart';
import 'package:hms_app/shared/loading_skeleton.dart';
import 'package:hms_app/shared/status_badge.dart';
import 'package:hms_app/shared/currency_text.dart';
import 'package:hms_app/utils/constants.dart';
import 'package:hms_app/utils/formatters.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() =>
      _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  String? _selectedStatus;
  String? _selectedPriority;

  Future<void> _updateStatus(Maintenance task, String status) async {
    try {
      final repo = ref.read(maintenanceRepositoryProvider);
      await repo.update(task.id, {'status': status});
      ref.invalidate(maintenanceProvider);
      if (mounted) HapticFeedback.lightImpact();
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
    final tasksAsync = ref.watch(maintenanceProvider);

    return Column(
      children: [
        // Status filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedStatus == null,
                onSelected: (_) => setState(() => _selectedStatus = null),
              ),
              ...MaintenanceStatus.values.map((s) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(s.label),
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
                  )),
            ],
          ),
        ),

        // Priority filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All Priorities'),
                selected: _selectedPriority == null,
                onSelected: (_) =>
                    setState(() => _selectedPriority = null),
              ),
              ...MaintenancePriority.values.map((p) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(p.label),
                      selected: _selectedPriority == p.label,
                      onSelected: (_) => setState(
                        () => _selectedPriority =
                            _selectedPriority == p.label ? null : p.label,
                      ),
                      avatar: Icon(p.icon, size: 16, color: p.color),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 4),

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
                        ref.invalidate(maintenanceProvider),
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
              if (_selectedPriority != null) {
                filtered = filtered
                    .where((t) => t.priority == _selectedPriority)
                    .toList();
              }

              if (filtered.isEmpty) {
                return const EmptyState(
                  icon: Icons.build_outlined,
                  title: 'No maintenance requests',
                  subtitle: 'Everything is in good shape!',
                );
              }

              return RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(maintenanceProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: filtered.length,
                  separatorBuilder: (_, a) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) => _MaintenanceCard(
                    task: filtered[i],
                    onStatusUpdate: (s) =>
                        _updateStatus(filtered[i], s),
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

class _MaintenanceCard extends StatelessWidget {
  final Maintenance task;
  final ValueChanged<String> onStatusUpdate;

  const _MaintenanceCard({
    required this.task,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusEnum =
        MaintenanceStatus.values.where((s) => s.label == task.status);
    final status = statusEnum.isNotEmpty
        ? statusEnum.first
        : MaintenanceStatus.open;
    final priorityEnum =
        MaintenancePriority.values.where((p) => p.label == task.priority);
    final priority = priorityEnum.isNotEmpty
        ? priorityEnum.first
        : MaintenancePriority.medium;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: priority.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(priority.icon,
                      color: priority.color, size: 20),
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
                      Text(
                        Formatters.relative(task.createdAt != null
                            ? DateTime.tryParse(task.createdAt!)
                            : null),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(
                      label: status.label,
                      color: status.color,
                      fontSize: 11,
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(
                      label: priority.label,
                      color: priority.color,
                      icon: priority.icon,
                      fontSize: 10,
                    ),
                  ],
                ),
              ],
            ),

            // Description
            if (task.description != null &&
                task.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.description!,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Cost info
            if (task.estimatedCost != null ||
                task.actualCost != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (task.estimatedCost != null)
                    Expanded(
                      child: Row(
                        children: [
                          Text('Est: ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant)),
                          CurrencyText(
                            amount: task.estimatedCost!,
                            style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  if (task.actualCost != null)
                    Expanded(
                      child: Row(
                        children: [
                          Text('Actual: ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant)),
                          CurrencyText(
                            amount: task.actualCost!,
                            style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],

            // Actions
            if (status != MaintenanceStatus.resolved) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (status == MaintenanceStatus.open)
                    TextButton.icon(
                      onPressed: () => onStatusUpdate('In Progress'),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Start'),
                    ),
                  if (status == MaintenanceStatus.open ||
                      status == MaintenanceStatus.inProgress)
                    FilledButton.tonalIcon(
                      onPressed: () => onStatusUpdate('Resolved'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Resolve'),
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
