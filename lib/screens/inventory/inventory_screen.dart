import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/models/inventory_category.dart';
import 'package:hms_app/models/inventory_item.dart';
import 'package:hms_app/providers/sync_provider.dart';
import 'package:hms_app/repositories/inventory_repository.dart';
import 'package:hms_app/services/connectivity_service.dart';
import 'package:hms_app/shared/empty_state.dart';
import 'package:hms_app/shared/loading_skeleton.dart';
import 'package:hms_app/utils/formatters.dart';

// ─── Providers ───────────────────────────────────────────────────────

final inventoryRepositoryProvider = Provider((ref) =>
    InventoryRepository(ref.watch(appDatabaseProvider), ConnectivityService()));

final inventoryCategoriesProvider =
    FutureProvider<List<InventoryCategory>>((ref) async {
  final repo = ref.read(inventoryRepositoryProvider);
  return repo.getCategories();
});

final inventoryItemsProvider =
    FutureProvider.family<List<InventoryItem>, int?>((ref, categoryId) async {
  final repo = ref.read(inventoryRepositoryProvider);
  return repo.getItems(categoryId: categoryId);
});

// ─── Inventory Screen ────────────────────────────────────────────────

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(inventoryCategoriesProvider);
    final itemsAsync = ref.watch(inventoryItemsProvider(_selectedCategoryId));

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
                title: const Text('Inventory'),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category filter chips
          categoriesAsync.when(
            loading: () => const SizedBox(height: 52),
            error: (_, a) => const SizedBox.shrink(),
            data: (categories) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategoryId == null,
                      onSelected: (_) =>
                          setState(() => _selectedCategoryId = null),
                    ),
                    ...categories.map((c) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: FilterChip(
                            label: Text(c.name ?? 'Category'),
                            selected: _selectedCategoryId == c.id,
                            onSelected: (_) => setState(
                              () => _selectedCategoryId =
                                  _selectedCategoryId == c.id
                                      ? null
                                      : c.id,
                            ),
                          ),
                        )),
                  ],
                ),
              );
            },
          ),

          // Items list
          Expanded(
            child: itemsAsync.when(
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
                      onPressed: () => ref.invalidate(
                          inventoryItemsProvider(_selectedCategoryId)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'No items found',
                    subtitle:
                        'Inventory items will appear here when added',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(
                      inventoryItemsProvider(_selectedCategoryId)),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, a) =>
                        const SizedBox(height: 6),
                    itemBuilder: (ctx, i) =>
                        _InventoryItemCard(item: items[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  const _InventoryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLowStock = item.currentStock != null &&
        item.minimumStock != null &&
        item.currentStock! <= item.minimumStock!;

    return Card(
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isLowStock
                ? Colors.orange.withValues(alpha: 0.12)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isLowStock
                ? Icons.warning_amber_rounded
                : Icons.inventory_2_outlined,
            color: isLowStock ? Colors.orange : null,
            size: 22,
          ),
        ),
        title: Text(
          item.name ?? 'Item',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Qty: ${item.currentStock ?? 0} ${item.unit ?? ''}'
          '${item.minimumStock != null ? ' · Reorder: ${item.minimumStock}' : ''}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: item.unitCost != null
            ? Text(
                Formatters.currency(item.unitCost!),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              )
            : null,
      ),
    );
  }
}
