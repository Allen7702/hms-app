import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hms_app/models/invoice.dart';
import 'package:hms_app/providers/sync_provider.dart';
import 'package:hms_app/repositories/invoice_repository.dart';
import 'package:hms_app/services/connectivity_service.dart';
import 'package:hms_app/shared/empty_state.dart';
import 'package:hms_app/shared/loading_skeleton.dart';
import 'package:hms_app/shared/status_badge.dart';
import 'package:hms_app/shared/currency_text.dart';
import 'package:hms_app/utils/constants.dart';
import 'package:hms_app/utils/formatters.dart';

// ─── Providers ───────────────────────────────────────────────────────

final invoiceRepositoryProvider = Provider((ref) =>
    InvoiceRepository(ref.watch(appDatabaseProvider), ConnectivityService()));

final invoicesProvider =
    FutureProvider.family<List<Invoice>, String?>((ref, status) async {
  final repo = ref.read(invoiceRepositoryProvider);
  return repo.getAll(status: status);
});

final invoiceDetailProvider =
    FutureProvider.family<Invoice?, int>((ref, id) async {
  final repo = ref.read(invoiceRepositoryProvider);
  return repo.getById(id);
});

// ─── Billing Screen ──────────────────────────────────────────────────

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const _tabs = ['All', 'Unpaid', 'Paid', 'Draft', 'Void'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        preferredSize: const Size.fromHeight(kToolbarHeight + 48),
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
                title: const Text('Invoices & Billing'),
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs
            .map((tab) => _InvoiceTabContent(
                  status: tab == 'All' ? null : tab,
                ))
            .toList(),
      ),
    ),
    );
  }
}

class _InvoiceTabContent extends ConsumerWidget {
  final String? status;
  const _InvoiceTabContent({this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider(status));
    return invoicesAsync.when(
      loading: () => const LoadingSkeleton(),
      error: (err, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text('Failed to load invoices'),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () => ref.invalidate(invoicesProvider(status)),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (invoices) {
        if (invoices.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No invoices',
            subtitle: 'Invoices will appear here when created',
          );
        }

        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(invoicesProvider(status)),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            separatorBuilder: (_, a) => const SizedBox(height: 6),
            itemBuilder: (ctx, i) =>
                _InvoiceCard(invoice: invoices[i]),
          ),
        );
      },
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusEnum =
        InvoiceStatus.values.where((s) => s.label == invoice.status);
    final status = statusEnum.isNotEmpty
        ? statusEnum.first
        : InvoiceStatus.draft;
    final createdAt = invoice.createdAt != null
        ? DateTime.tryParse(invoice.createdAt!)
        : null;

    return Card(
      child: ListTile(
        onTap: () => context.push('/billing/${invoice.id}'),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: status.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.receipt_long, color: status.color, size: 22),
        ),
        title: Row(
          children: [
            Text(
              'Invoice #${invoice.id}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            CurrencyText(
              amount: invoice.amount ?? 0,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              'Booking #${invoice.bookingId ?? '-'} · ${Formatters.date(createdAt)}',
              style: theme.textTheme.bodySmall,
            ),
            const Spacer(),
            StatusBadge(
              label: status.label,
              color: status.color,
              fontSize: 10,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Invoice Detail Screen ───────────────────────────────────────────

class InvoiceDetailScreen extends ConsumerWidget {
  final int invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final invoiceAsync = ref.watch(invoiceDetailProvider(invoiceId));

    return Scaffold(
      appBar: AppBar(title: Text('Invoice #$invoiceId')),
      body: invoiceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (invoice) {
          if (invoice == null) {
            return const Center(child: Text('Invoice not found'));
          }

          final statusEnum =
              InvoiceStatus.values.where((s) => s.label == invoice.status);
          final status = statusEnum.isNotEmpty
              ? statusEnum.first
              : InvoiceStatus.draft;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header card
              Card(
                color: status.color.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Invoice #${invoice.id}',
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          StatusBadge(label: status.label, color: status.color),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Amount',
                              style: theme.textTheme.bodyMedium),
                          CurrencyText(
                            amount: invoice.amount ?? 0,
                            style: theme.textTheme.headlineSmall?.copyWith(
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

              // Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Row('Booking ID', '#${invoice.bookingId ?? '-'}'),
                      _Row('Status', invoice.status ?? '-'),
                      _Row(
                        'Created',
                        Formatters.dateTime(invoice.createdAt != null
                            ? DateTime.tryParse(invoice.createdAt!)
                            : null),
                      ),
                      if (invoice.updatedAt != null)
                        _Row(
                          'Updated',
                          Formatters.relative(
                              DateTime.tryParse(invoice.updatedAt!)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
