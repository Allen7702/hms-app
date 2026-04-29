import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/models/audit_log.dart';
import 'package:hms_app/providers/sync_provider.dart';
import 'package:hms_app/repositories/audit_repository.dart';
import 'package:hms_app/services/connectivity_service.dart';
import 'package:hms_app/shared/empty_state.dart';
import 'package:hms_app/shared/loading_skeleton.dart';
import 'package:hms_app/utils/formatters.dart';

// ─── Providers ───────────────────────────────────────────────────────

final auditRepositoryProvider = Provider((ref) =>
    AuditRepository(ref.watch(appDatabaseProvider), ConnectivityService()));

final auditLogsProvider = FutureProvider<List<AuditLog>>((ref) async {
  final repo = ref.read(auditRepositoryProvider);
  return repo.getAll();
});

// ─── Audit Screen ────────────────────────────────────────────────────

class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  IconData _actionIcon(String? action) {
    return switch (action?.toLowerCase()) {
      'create' || 'insert' => Icons.add_circle_outline,
      'update' || 'edit' => Icons.edit_outlined,
      'delete' || 'remove' => Icons.delete_outline,
      'login' || 'sign_in' => Icons.login,
      'logout' || 'sign_out' => Icons.logout,
      'check_in' || 'checkin' => Icons.login,
      'check_out' || 'checkout' => Icons.logout,
      _ => Icons.history,
    };
  }

  Color _actionColor(BuildContext context, String? action) {
    final theme = Theme.of(context);
    return switch (action?.toLowerCase()) {
      'create' || 'insert' => Colors.green,
      'update' || 'edit' => theme.colorScheme.primary,
      'delete' || 'remove' => theme.colorScheme.error,
      _ => theme.colorScheme.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logsAsync = ref.watch(auditLogsProvider);

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
                title: const Text('Audit Trail'),
              ),
            ),
          ),
        ),
      ),
      body: logsAsync.when(
        loading: () => const LoadingSkeleton(),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text('Error: $err'),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () => ref.invalidate(auditLogsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (logs) {
          if (logs.isEmpty) {
            return const EmptyState(
              icon: Icons.history,
              title: 'No audit logs',
              subtitle: 'Activity will be recorded here',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(auditLogsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              separatorBuilder: (_, a) => const SizedBox(height: 4),
              itemBuilder: (ctx, i) {
                final log = logs[i];
                final createdAt = log.createdAt != null
                    ? DateTime.tryParse(log.createdAt!)
                    : null;
                final color = _actionColor(context, log.action);

                return Card(
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_actionIcon(log.action),
                          color: color, size: 20),
                    ),
                    title: Text(
                      '${log.action ?? 'Action'} on ${log.entityType ?? 'record'}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'User #${log.userId ?? '-'} · ${Formatters.relative(createdAt)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Text(
                      'ID: ${log.entityId ?? '-'}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    ),
    );
  }
}
