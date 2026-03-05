import 'package:bhandarx_flutter/app/themes/app_colors.dart';
import 'package:bhandarx_flutter/core/localization/app_localizations.dart';
import 'package:bhandarx_flutter/features/workspace/data/repositories/workspace_repository.dart';
import 'package:bhandarx_flutter/features/workspace/domain/entities/workspace_entities.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionInsightsPage extends ConsumerStatefulWidget {
  static const routeName = '/workspace/transactions/insights';

  const TransactionInsightsPage({super.key});

  @override
  ConsumerState<TransactionInsightsPage> createState() =>
      _TransactionInsightsPageState();
}

class _TransactionInsightsPageState
    extends ConsumerState<TransactionInsightsPage> {
  late Future<_InsightsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_InsightsData> _load() async {
    final repo = ref.read(workspaceRepositoryProvider);
    final summaryResult = await repo.getTransactionSummary();
    final recentResult = await repo.getRecentTransactions();
    final salesResult = await repo.getSales();

    final summary = summaryResult.fold(
      (_) =>
          const WorkspaceSummary(totalIn: 0, totalOut: 0, totalTransactions: 0),
      (value) => value,
    );
    final recent =
        recentResult.fold((_) => <WorkspaceRecord>[], (value) => value);
    final sales =
        salesResult.fold((_) => <WorkspaceRecord>[], (value) => value);

    final dailySales = <DateTime, double>{};
    final paymentSplit = <String, double>{};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      dailySales[day] = 0;
    }

    for (final sale in sales) {
      final raw = sale.raw;
      final date = _date(raw['createdAt']);
      final total = _num(raw['totalAmount']) ?? _readRs(sale.amount);
      final paymentMethod =
          (raw['paymentMethod']?.toString().trim().toUpperCase() ?? 'CASH');

      if (date != null) {
        final d = DateTime(date.year, date.month, date.day);
        if (dailySales.containsKey(d)) {
          dailySales[d] = (dailySales[d] ?? 0) + total;
        }
      }

      paymentSplit[paymentMethod] = (paymentSplit[paymentMethod] ?? 0) + total;
    }

    if (recent.isNotEmpty || summary.totalTransactions > 0) {
      return _InsightsData(
        summary: summary,
        recent: recent,
        salesTrend: dailySales.values.toList(),
        paymentSplit: paymentSplit,
      );
    }

    // Fallback from sales when transaction collection is empty.
    final totalSales = sales.fold<double>(0, (sum, item) {
      final raw = item.raw['totalAmount'];
      if (raw is num) {
        return sum + raw.toDouble();
      }
      return sum;
    });
    final totalPaid = sales.fold<double>(0, (sum, item) {
      final raw = item.raw['paidAmount'];
      if (raw is num) {
        return sum + raw.toDouble();
      }
      return sum;
    });
    final fallbackSummary = WorkspaceSummary(
      totalIn: totalPaid,
      totalOut: totalSales,
      totalTransactions: sales.length,
    );
    final fallbackRecent = sales
        .take(10)
        .map((sale) => WorkspaceRecord(
              id: sale.id,
              title: sale.title,
              subtitle: sale.subtitle,
              status: 'SALE • ${sale.status}',
              amount: sale.amount,
              raw: <String, dynamic>{...sale.raw, '_source': 'sale_fallback'},
            ))
        .toList();

    return _InsightsData(
      summary: fallbackSummary,
      recent: fallbackRecent,
      salesTrend: dailySales.values.toList(),
      paymentSplit: paymentSplit,
    );
  }

  double? _num(dynamic v) {
    if (v is num) {
      return v.toDouble();
    }
    if (v is String) {
      return double.tryParse(v);
    }
    return null;
  }

  DateTime? _date(dynamic v) {
    if (v is String) {
      return DateTime.tryParse(v)?.toLocal();
    }
    return null;
  }

  double _readRs(String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(digits) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('transaction_insights'))),
      body: FutureBuilder<_InsightsData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null) {
            return Center(child: Text(l10n.tr('unable_load_insights')));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = _load();
              });
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _summaryCard(context, data.summary),
                const SizedBox(height: 14),
                _salesTrendCard(context, data.salesTrend),
                const SizedBox(height: 14),
                _paymentSplitCard(context, data.paymentSplit),
                const SizedBox(height: 14),
                Text(l10n.tr('recent_transactions'),
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (data.recent.isEmpty)
                  Text(l10n.tr('no_recent_transactions'))
                else
                  ...data.recent.map((item) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkBorder
                                    : AppColors.border,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title,
                                style: Theme.of(context).textTheme.titleMedium),
                            Text(item.subtitle),
                            const SizedBox(height: 4),
                            Text('${item.status} • ${item.amount}'),
                          ],
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryCard(BuildContext context, WorkspaceSummary summary) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.tr('summary'),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
              '${l10n.tr('total_transactions')}: ${summary.totalTransactions}'),
          Text(
              '${l10n.tr('total_in')}: Rs ${summary.totalIn.toStringAsFixed(2)}'),
          Text(
              '${l10n.tr('total_out')}: Rs ${summary.totalOut.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _salesTrendCard(BuildContext context, List<double> trend) {
    final l10n = AppLocalizations.of(context)!;
    final data = trend.isEmpty ? List<double>.filled(7, 0) : trend;
    final maxY = (data.reduce((a, b) => a > b ? a : b) * 1.2) + 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.tr('sales_trend_7d'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                ),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 3,
                    color: AppColors.info,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.info.withValues(alpha: 0.18),
                    ),
                    spots: [
                      for (int i = 0; i < data.length; i++)
                        FlSpot(i.toDouble(), data[i]),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentSplitCard(BuildContext context, Map<String, double> split) {
    final l10n = AppLocalizations.of(context)!;
    final entries = split.entries.where((e) => e.value > 0).toList();
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    final total = entries.fold<double>(0, (sum, e) => sum + e.value);
    final palette = <Color>[
      AppColors.primary,
      AppColors.info,
      AppColors.warning,
      AppColors.accentPurple,
      AppColors.danger,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.tr('payment_split'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: [
                  for (int i = 0; i < entries.length; i++)
                    PieChartSectionData(
                      color: palette[i % palette.length],
                      value: entries[i].value,
                      title:
                          '${((entries[i].value / total) * 100).toStringAsFixed(0)}%',
                      radius: 56,
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
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              for (int i = 0; i < entries.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: palette[i % palette.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(entries[i].key),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightsData {
  final WorkspaceSummary summary;
  final List<WorkspaceRecord> recent;
  final List<double> salesTrend;
  final Map<String, double> paymentSplit;

  const _InsightsData({
    required this.summary,
    required this.recent,
    required this.salesTrend,
    required this.paymentSplit,
  });
}
