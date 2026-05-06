import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/providers/sync_provider.dart';

class SeedingWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const SeedingWrapper({super.key, required this.child});

  @override
  ConsumerState<SeedingWrapper> createState() => _SeedingWrapperState();
}

class _SeedingWrapperState extends ConsumerState<SeedingWrapper> {
  bool _seedingDone = false;
  bool _seedingStarted = false;

  @override
  Widget build(BuildContext context) {
    if (_seedingDone) return widget.child;

    final emptyAsync = ref.watch(isLocalDbEmptyProvider);

    return emptyAsync.when(
      loading: () => const _SeedingScreen(message: 'Checking local data…'),
      error: (_, stack) {
        // On error just show the app — don't block on seeding
        return widget.child;
      },
      data: (isEmpty) {
        if (!isEmpty) return widget.child;

        final isOnline = ref.watch(isOnlineProvider);

        if (!isOnline) {
          // Offline and empty — show the app with empty state screens
          return widget.child;
        }

        // Online and empty — trigger initial sync once
        if (!_seedingStarted) {
          _seedingStarted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _runInitialSync();
          });
        }

        final syncState = ref.watch(syncNotifierProvider);
        final isSyncing = syncState.status == SyncStatus.syncing;
        final isError = syncState.status == SyncStatus.error;

        if (isSyncing) {
          return const _SeedingScreen(message: 'Setting up offline mode…');
        }

        if (isError) {
          return _SeedingScreen(
            message: 'Could not load data.\n${syncState.errorMessage ?? ''}',
            isError: true,
            onRetry: _runInitialSync,
          );
        }

        // Sync done — only advance once sync actually succeeded
        if (_seedingStarted && syncState.status == SyncStatus.success) {
          Future.microtask(() {
            if (mounted) setState(() => _seedingDone = true);
          });
          return widget.child;
        }

        // Still waiting for sync to start or complete
        return const _SeedingScreen(message: 'Setting up offline mode…');
      },
    );
  }

  void _runInitialSync() {
    ref.read(syncNotifierProvider.notifier).triggerSync();
  }
}

class _SeedingScreen extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback? onRetry;

  const _SeedingScreen({
    required this.message,
    this.isError = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0E21) : const Color(0xFFE8F4FD);

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isError ? Icons.cloud_off_outlined : Icons.cloud_sync_outlined,
                size: 64,
                color: isError
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                isError ? 'Setup Failed' : 'One moment…',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? Colors.white60
                          : Colors.black54,
                    ),
              ),
              const SizedBox(height: 32),
              if (!isError)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              if (isError && onRetry != null)
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
