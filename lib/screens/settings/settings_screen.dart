import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/providers/auth_provider.dart';
import 'package:hms_app/shared/confirm_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

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
                title: const Text('Settings'),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      (user?.fullName ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'User',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(user?.email ?? '',
                            style: theme.textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user?.role?.toUpperCase() ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // General section
          _SectionHeader(label: 'General'),
          const SizedBox(height: 8),
          _SettingsItem(
            icon: Icons.hotel_outlined,
            label: 'Hotel Settings',
            subtitle: 'Hotel profile, branding & policies',
            onTap: () {},
          ),
          _SettingsItem(
            icon: Icons.people_outlined,
            label: 'User Management',
            subtitle: 'Manage staff accounts & roles',
            onTap: () {},
          ),

          const SizedBox(height: 20),
          _SectionHeader(label: 'Appearance'),
          const SizedBox(height: 8),
          _SettingsItem(
            icon: Icons.dark_mode_outlined,
            label: 'Theme',
            subtitle: 'System default',
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => SimpleDialog(
                  title: const Text('Choose Theme'),
                  children: [
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('System Default'),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Light'),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Dark'),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          _SectionHeader(label: 'About'),
          const SizedBox(height: 8),
          _SettingsItem(
            icon: Icons.info_outline,
            label: 'About HMS Admin',
            subtitle: 'Version & license info',
            onTap: () async {
              try {
                final info = await PackageInfo.fromPlatform();
                if (context.mounted) {
                  showAboutDialog(
                    context: context,
                    applicationName: 'HMS Admin Mobile',
                    applicationVersion:
                        '${info.version} (${info.buildNumber})',
                    applicationLegalese: '© 2024 HMS. All rights reserved.',
                    applicationIcon: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.hotel,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  showAboutDialog(
                    context: context,
                    applicationName: 'HMS Admin Mobile',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2024 HMS. All rights reserved.',
                  );
                }
              }
            },
          ),

          const SizedBox(height: 24),
          _SettingsItem(
            icon: Icons.logout,
            label: 'Sign Out',
            isDestructive: true,
            onTap: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: 'Sign Out',
                message: 'Are you sure you want to sign out?',
                confirmLabel: 'Sign Out',
                isDestructive: true,
              );
              if (confirmed == true) {
                ref.read(authProvider.notifier).signOut();
              }
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color)),
        subtitle: subtitle != null && !isDestructive
            ? Text(subtitle!, style: theme.textTheme.bodySmall)
            : null,
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
