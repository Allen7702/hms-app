import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/models/app_notification.dart';
import 'package:hms_app/providers/sync_provider.dart';
import 'package:hms_app/repositories/notification_repository.dart';
import 'package:hms_app/services/connectivity_service.dart';
import 'package:hms_app/shared/empty_state.dart';
import 'package:hms_app/shared/loading_skeleton.dart';
import 'package:hms_app/utils/formatters.dart';

// ─── Providers ───────────────────────────────────────────────────────

final notificationRepositoryProvider = Provider((ref) =>
    NotificationRepository(ref.watch(appDatabaseProvider), ConnectivityService()));

final notificationsProvider =
    FutureProvider<List<AppNotification>>((ref) async {
  final repo = ref.read(notificationRepositoryProvider);
  return repo.getAll();
});

// ─── Notifications Screen ────────────────────────────────────────────

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _typeIcon(String? type) {
    return switch (type?.toLowerCase()) {
      'booking' => Icons.calendar_today,
      'checkin' || 'check_in' => Icons.login,
      'checkout' || 'check_out' => Icons.logout,
      'payment' => Icons.payment,
      'housekeeping' => Icons.cleaning_services_outlined,
      'maintenance' => Icons.build_outlined,
      'alert' || 'warning' => Icons.warning_amber_outlined,
      'system' => Icons.settings_outlined,
      _ => Icons.notifications_outlined,
    };
  }

  Color _typeColor(BuildContext context, String? type) {
    return switch (type?.toLowerCase()) {
      'booking' => Colors.blue,
      'checkin' || 'check_in' => Colors.green,
      'checkout' || 'check_out' => Colors.orange,
      'payment' => Colors.teal,
      'housekeeping' => Colors.purple,
      'maintenance' => Colors.amber.shade700,
      'alert' || 'warning' => Colors.red,
      _ => Theme.of(context).colorScheme.primary,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(notificationsProvider);

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
                title: const Text('Notifications'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => ref.invalidate(notificationsProvider),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: notificationsAsync.when(
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
                onPressed: () => ref.invalidate(notificationsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'No notifications',
              subtitle: 'You\'re all caught up!',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, a) => const SizedBox(height: 4),
              itemBuilder: (ctx, i) {
                final n = notifications[i];
                final createdAt = n.createdAt != null
                    ? DateTime.tryParse(n.createdAt!)
                    : null;
                final color = _typeColor(context, n.type);
                final isSent = n.status?.toLowerCase() == 'sent' ||
                    n.status?.toLowerCase() == 'read';

                return Card(
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_typeIcon(n.type),
                          color: color, size: 20),
                    ),
                    title: Text(
                      n.message ?? 'Notification',
                      style: TextStyle(
                        fontWeight:
                            isSent ? FontWeight.w400 : FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          if (n.type != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                n.type!.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            Formatters.relative(createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    trailing: isSent
                        ? null
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
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
