import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hms_app/models/room.dart';
import 'package:hms_app/providers/room_provider.dart';
import 'package:hms_app/shared/empty_state.dart';
import 'package:hms_app/shared/loading_skeleton.dart';
import 'package:hms_app/shared/status_badge.dart';
import 'package:hms_app/utils/constants.dart';
import 'package:hms_app/utils/formatters.dart';

class RoomsListScreen extends ConsumerStatefulWidget {
  const RoomsListScreen({super.key});

  @override
  ConsumerState<RoomsListScreen> createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends ConsumerState<RoomsListScreen> {
  String? _selectedFloor;
  String? _selectedStatus;
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);
    final floorsAsync = ref.watch(roomFloorsProvider);
    final statusCountsAsync = ref.watch(roomStatusCountsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // View toggle row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
            child: Row(
              children: [
                const Spacer(),
                IconButton(
                  icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                  tooltip: _isGridView ? 'List view' : 'Grid view',
                  onPressed: () => setState(() => _isGridView = !_isGridView),
                ),
              ],
            ),
          ),
          // Status count chips
          statusCountsAsync.when(
            loading: () => const SizedBox(height: 52),
            error: (_, a) => const SizedBox.shrink(),
            data: (counts) {
              final total = counts.values.fold(0, (a, b) => a + b);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text('All ($total)'),
                      selected: _selectedStatus == null,
                      onSelected: (_) => setState(() => _selectedStatus = null),
                    ),
                    ...RoomStatus.values.map((s) {
                      final count = counts[s.label] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: FilterChip(
                          avatar: Icon(s.icon, size: 16, color: s.color),
                          label: Text('${s.label} ($count)'),
                          selected: _selectedStatus == s.label,
                          onSelected: (_) => setState(
                            () => _selectedStatus = _selectedStatus == s.label
                                ? null
                                : s.label,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),

          // Floor filter
          floorsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, a) => const SizedBox.shrink(),
            data: (floors) {
              if (floors.isEmpty) return const SizedBox.shrink();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All Floors'),
                      selected: _selectedFloor == null,
                      onSelected: (_) => setState(() => _selectedFloor = null),
                    ),
                    ...floors.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          label: Text('Floor $f'),
                          selected: _selectedFloor == f,
                          onSelected: (_) => setState(
                            () =>
                                _selectedFloor = _selectedFloor == f ? null : f,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Room grid/list
          Expanded(
            child: roomsAsync.when(
              loading: () => const LoadingSkeleton(),
              error: (err, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text('Failed to load rooms'),
                    const SizedBox(height: 16),
                    FilledButton.tonalIcon(
                      onPressed: () => ref.invalidate(roomsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (rooms) {
                var filtered = rooms;
                if (_selectedStatus != null) {
                  filtered = filtered
                      .where((r) => r.status == _selectedStatus)
                      .toList();
                }
                if (_selectedFloor != null) {
                  filtered = filtered
                      .where((r) => r.floor == _selectedFloor)
                      .toList();
                }

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.meeting_room_outlined,
                    title: 'No rooms found',
                    subtitle: 'No rooms match the selected filters',
                    actionLabel: 'Clear Filters',
                    onAction: () => setState(() {
                      _selectedStatus = null;
                      _selectedFloor = null;
                    }),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(roomsProvider);
                    ref.invalidate(roomStatusCountsProvider);
                  },
                  child: _isGridView
                      ? _RoomGrid(rooms: filtered)
                      : _RoomList(rooms: filtered),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomGrid extends StatelessWidget {
  final List<Room> rooms;
  const _RoomGrid({required this.rooms});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) => _RoomGridTile(room: rooms[index]),
    );
  }
}

class _RoomGridTile extends StatelessWidget {
  final Room room;
  const _RoomGridTile({required this.room});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusEnum = RoomStatus.values.where((s) => s.label == room.status);
    final status = statusEnum.isNotEmpty
        ? statusEnum.first
        : RoomStatus.available;

    return InkWell(
      onTap: () => context.push('/rooms/${room.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: status.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: status.color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(status.icon, color: status.color, size: 24),
            const SizedBox(height: 4),
            Text(
              room.roomNumber ?? '-',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: status.color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              room.roomType?.name ?? '',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomList extends StatelessWidget {
  final List<Room> rooms;
  const _RoomList({required this.rooms});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: rooms.length,
      separatorBuilder: (_, a) => const SizedBox(height: 6),
      itemBuilder: (ctx, i) => _RoomListItem(room: rooms[i]),
    );
  }
}

class _RoomListItem extends StatelessWidget {
  final Room room;
  const _RoomListItem({required this.room});

  @override
  Widget build(BuildContext context) {
    final statusEnum = RoomStatus.values.where((s) => s.label == room.status);
    final status = statusEnum.isNotEmpty
        ? statusEnum.first
        : RoomStatus.available;

    return Card(
      child: ListTile(
        onTap: () => context.push('/rooms/${room.id}'),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: status.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: status.color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              room.roomNumber ?? '-',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: status.color,
              ),
            ),
          ),
        ),
        title: Text(
          '${room.roomType?.name ?? 'Room'} · Floor ${room.floor ?? '-'}',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: room.roomType?.price != null
            ? Text('${Formatters.currency(room.roomType!.price!)} /night')
            : null,
        trailing: StatusBadge(
          label: status.label,
          color: status.color,
          icon: status.icon,
          fontSize: 11,
        ),
      ),
    );
  }
}

class RoomDetailScreen extends ConsumerStatefulWidget {
  final int roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  ConsumerState<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends ConsumerState<RoomDetailScreen> {
  bool _isUpdating = false;

  Future<void> _updateStatus(String newStatus) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    try {
      final repo = ref.read(roomRepositoryProvider);
      await repo.updateStatus(widget.roomId, newStatus);
      ref.invalidate(roomDetailProvider(widget.roomId));
      ref.invalidate(roomsProvider);
      ref.invalidate(roomStatusCountsProvider);
      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Room status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roomAsync = ref.watch(roomDetailProvider(widget.roomId));

    return Scaffold(
      appBar: AppBar(title: Text('Room #${widget.roomId}')),
      body: roomAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text('Error: $err'),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () =>
                    ref.invalidate(roomDetailProvider(widget.roomId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (room) {
          if (room == null) {
            return const Center(child: Text('Room not found'));
          }

          final statusEnum = RoomStatus.values.where(
            (s) => s.label == room.status,
          );
          final status = statusEnum.isNotEmpty
              ? statusEnum.first
              : RoomStatus.available;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Status header
              Card(
                color: status.color.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: status.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            room.roomNumber ?? '-',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: status.color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.roomType?.name ?? 'Room',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Floor ${room.floor ?? '-'}',
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
              ),
              const SizedBox(height: 16),

              // Room info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Room Information',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _DetailRow('Room Number', room.roomNumber ?? '-'),
                      _DetailRow('Type', room.roomType?.name ?? '-'),
                      _DetailRow('Floor', room.floor ?? '-'),
                      if (room.roomType?.capacity != null)
                        _DetailRow(
                          'Capacity',
                          '${room.roomType!.capacity} guests',
                        ),
                      if (room.roomType?.price != null)
                        _DetailRow(
                          'Rate',
                          '${Formatters.currency(room.roomType!.price!)} /night',
                        ),
                      if (room.roomType?.description != null)
                        _DetailRow('Description', room.roomType!.description!),
                      if (room.lastCleaned != null)
                        _DetailRow(
                          'Last Cleaned',
                          Formatters.relative(
                            DateTime.tryParse(room.lastCleaned!),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Features
              if (room.features != null && room.features!.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_outline,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Features',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: room.features!.entries.map((e) {
                            return Chip(
                              label: Text('${e.key}: ${e.value}'),
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Status update
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.swap_horiz,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Update Status',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: RoomStatus.values.map((s) {
                          final isCurrentStatus = s.label == room.status;
                          return FilledButton.tonalIcon(
                            onPressed: isCurrentStatus || _isUpdating
                                ? null
                                : () => _updateStatus(s.label),
                            icon: Icon(s.icon, size: 18),
                            label: Text(s.label),
                            style: FilledButton.styleFrom(
                              backgroundColor: isCurrentStatus
                                  ? s.color.withValues(alpha: 0.15)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

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
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
