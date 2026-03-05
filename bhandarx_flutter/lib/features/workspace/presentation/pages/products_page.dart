import 'package:bhandarx_flutter/app/themes/app_colors.dart';
import 'package:bhandarx_flutter/core/localization/app_localizations.dart';
import 'package:bhandarx_flutter/features/workspace/data/repositories/workspace_repository.dart';
import 'package:bhandarx_flutter/features/workspace/domain/entities/workspace_entities.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/record_detail_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ProductViewMode { all, lowStock, outOfStock }

class ProductsPage extends ConsumerStatefulWidget {
  static const routeName = '/workspace/products';

  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final _searchCtrl = TextEditingController();
  ProductViewMode _mode = ProductViewMode.all;
  bool _loading = true;
  List<WorkspaceRecord> _items = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final repo = ref.read(workspaceRepositoryProvider);
    // Always use full products dataset for stock buckets so the rules are exact
    // and not affected by backend endpoint differences.
    final result =
        await repo.getProducts(search: _searchCtrl.text.trim());

    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (data) => setState(() {
        _loading = false;
        _items = _applyStockBucketRule(data);
      }),
    );
  }

  List<WorkspaceRecord> _applyStockBucketRule(List<WorkspaceRecord> data) {
    if (_mode == ProductViewMode.lowStock) {
      // Low stock means quantity < 5 and > 0.
      return data.where((item) {
        final qty = _qtyOf(item);
        return qty > 0 && qty < 5;
      }).toList();
    }
    if (_mode == ProductViewMode.outOfStock) {
      // Out of stock means quantity 0 or less.
      return data.where((item) => _qtyOf(item) <= 0).toList();
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('products_page')),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<ProductViewMode>(
              selected: {_mode},
              onSelectionChanged: (values) {
                setState(() => _mode = values.first);
                _load();
              },
              segments: [
                ButtonSegment(
                    value: ProductViewMode.all, label: Text(l10n.tr('all'))),
                ButtonSegment(
                    value: ProductViewMode.lowStock,
                    label: Text(l10n.tr('low_stock'))),
                ButtonSegment(
                    value: ProductViewMode.outOfStock,
                    label: Text(l10n.tr('out_of_stock'))),
              ],
            ),
            const SizedBox(height: 10),
            if (_mode == ProductViewMode.all)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: l10n.tr('search_name_sku'),
                        prefixIcon: const Icon(Icons.search_rounded),
                      ),
                      onSubmitted: (_) => _load(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _load,
                    child: Text(l10n.tr('search_btn')),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator()))
            else if (_error != null)
              Center(child: Text(_error!))
            else if (_items.isEmpty)
              Center(child: Text(l10n.tr('no_products_found')))
            else
              ...[
                if (_mode == ProductViewMode.all) ...[
                  _stockHealthChart(context, l10n),
                  const SizedBox(height: 10),
                ],
                ..._items.map(
                  (item) {
                    final qty = _qtyOf(item);
                    final stockColor = _stockColor(qty);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: stockColor.withValues(alpha: 0.16),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: stockColor,
                          ),
                        ),
                        title: Text(item.title),
                        subtitle: Text(
                            '${item.subtitle}\n${item.status} • ${item.amount}'),
                        isThreeLine: true,
                        tileColor: stockColor.withValues(alpha: 0.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: stockColor.withValues(alpha: 0.30),
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecordDetailPage(
                                  title: l10n.tr('product_detail'),
                                  record: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _stockHealthChart(BuildContext context, AppLocalizations l10n) {
    int inStock = 0;
    int lowStock = 0;
    int outStock = 0;
    for (final item in _items) {
      final qty = (item.raw['quantity'] is num)
          ? (item.raw['quantity'] as num).toInt()
          : int.tryParse(item.raw['quantity']?.toString() ?? '0') ?? 0;
      if (qty <= 0) {
        outStock++;
      } else if (qty < 5) {
        lowStock++;
      } else {
        inStock++;
      }
    }
    final data = [inStock.toDouble(), lowStock.toDouble(), outStock.toDouble()];
    if (data.every((e) => e == 0)) {
      return const SizedBox.shrink();
    }

    final labels = [l10n.tr('in_stock'), l10n.tr('low_stock'), l10n.tr('out_of_stock')];
    final colors = [AppColors.primary, AppColors.warning, AppColors.danger];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tr('stock_health'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 28,
                sections: [
                  for (int i = 0; i < data.length; i++)
                    PieChartSectionData(
                      color: colors[i],
                      value: data[i],
                      title: data[i].toInt().toString(),
                      radius: 52,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              for (int i = 0; i < labels.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(labels[i]),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  int _qtyOf(WorkspaceRecord item) {
    final raw = item.raw['quantity'] ??
        item.raw['stock'] ??
        item.raw['currentStock'] ??
        item.raw['availableQuantity'];
    if (raw is num) {
      return raw.toInt();
    }
    return int.tryParse(raw?.toString() ?? '0') ?? 0;
  }

  Color _stockColor(int qty) {
    if (qty <= 0) {
      return AppColors.danger;
    }
    if (qty < 5) {
      return AppColors.danger;
    }
    if (qty > 5) {
      return AppColors.primary;
    }
    return AppColors.warning;
  }
}
