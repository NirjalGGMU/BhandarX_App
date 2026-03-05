import 'package:bhandarx_flutter/app/themes/app_colors.dart';
import 'package:bhandarx_flutter/core/localization/app_localizations.dart';
import 'package:bhandarx_flutter/features/auth/presentation/pages/login_screen.dart';
import 'package:bhandarx_flutter/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:bhandarx_flutter/features/workspace/data/repositories/workspace_repository.dart';
import 'package:bhandarx_flutter/features/workspace/domain/entities/workspace_entities.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/customers_page.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/products_page.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/sales_page.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/transactions_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkspaceDashboardScreen extends ConsumerStatefulWidget {
  static const routeName = '/workspace';

  const WorkspaceDashboardScreen({super.key});

  @override
  ConsumerState<WorkspaceDashboardScreen> createState() =>
      _WorkspaceDashboardScreenState();
}

class _WorkspaceDashboardScreenState extends ConsumerState<WorkspaceDashboardScreen> {
  late Future<_DashboardMetrics> _metricsFuture;

  @override
  void initState() {
    super.initState();
    _metricsFuture = _loadMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final l10n = AppLocalizations.of(context)!;
      final result = await ref.read(workspaceRepositoryProvider).syncPendingWrites();
      if (!mounted) {
        return;
      }
      result.fold((_) {}, (count) {
        if (count > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.tr('offline_data_synced').replaceAll('{count}', '$count'),
              ),
            ),
          );
          setState(() {
            _metricsFuture = _loadMetrics();
          });
        }
      });
    });
  }

  Future<_DashboardMetrics> _loadMetrics() async {
    final repo = ref.read(workspaceRepositoryProvider);
    final salesResult = await repo.getSales();
    final productsResult = await repo.getProducts();
    final sales = salesResult.fold((_) => <WorkspaceRecord>[], (r) => r);
    final products = productsResult.fold((_) => <WorkspaceRecord>[], (r) => r);

    final now = DateTime.now();
    double todaySales = 0;
    double pendingDue = 0;
    int lowStockCount = 0;

    for (final sale in sales) {
      final raw = sale.raw;
      final total = _num(raw['totalAmount']) ?? _readRs(sale.amount);
      final paid = _num(raw['paidAmount']) ?? 0;
      if (total > 0) {
        pendingDue += (total - paid) > 0 ? (total - paid) : 0;
      }
      final createdAt = _date(raw['createdAt']);
      if (createdAt != null &&
          createdAt.year == now.year &&
          createdAt.month == now.month &&
          createdAt.day == now.day) {
        todaySales += total;
      }
    }

    for (final product in products) {
      final qty = (_num(product.raw['quantity']) ?? 0).toInt();
      final min = (_num(product.raw['minStockLevel']) ?? 0).toInt();
      if (qty <= 0) {
        lowStockCount += 1;
      } else if (min > 0 && qty <= min) {
        lowStockCount += 1;
      }
    }

    return _DashboardMetrics(
      todaySales: todaySales,
      pendingDue: pendingDue,
      lowStockCount: lowStockCount,
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
    final role = (ref.watch(authViewModelProvider).entity?.role ?? 'employee')
        .toLowerCase();
    if (role != 'employee') {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.tr('workspace_title'))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder
                      : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.danger,
                    size: 44,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.tr('unauthorized_role'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tr('employee_only_workspace'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      await ref.read(authViewModelProvider.notifier).logout();
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        LoginScreen.routeName,
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(l10n.tr('logout')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final actions = [
      (
        l10n.tr('products_page'),
        l10n.tr('search_stock_details'),
        Icons.inventory_2_outlined,
        const [Color(0xFF1FA866), Color(0xFF128D54)],
        ProductsPage.routeName
      ),
      (
        l10n.tr('customers_page'),
        l10n.tr('view_add_edit_profiles'),
        Icons.people_outline,
        const [Color(0xFF2E7DFF), Color(0xFF1564E0)],
        CustomersPage.routeName
      ),
      (
        '${l10n.tr('sales_page')} / POS',
        l10n.tr('create_sales_update_payment'),
        Icons.point_of_sale_outlined,
        const [Color(0xFFFFA726), Color(0xFFEF6C00)],
        SalesPage.routeName
      ),
      (
        l10n.tr('transactions_page'),
        l10n.tr('history_and_details'),
        Icons.receipt_long_outlined,
        const [Color(0xFF8E24AA), Color(0xFF6A1B9A)],
        TransactionsPage.routeName
      ),
    ];
    final width = MediaQuery.of(context).size.width;
    final cardAspectRatio = width < 360 ? 1.02 : 1.14;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('workspace_title')),
        actions: [
          IconButton(
            onPressed: () => setState(() => _metricsFuture = _loadMetrics()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        children: [
          FutureBuilder<_DashboardMetrics>(
            future: _metricsFuture,
            builder: (context, snapshot) {
              final metrics = snapshot.data ?? const _DashboardMetrics();
              return _DashboardChartCard(metrics: metrics);
            },
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: cardAspectRatio,
            ),
            itemBuilder: (context, index) {
              final item = actions[index];
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => Navigator.pushNamed(context, item.$5),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border:
                        Border.all(color: item.$4.first.withValues(alpha: 0.28)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        item.$4.first,
                        item.$4.last,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        top: -8,
                        child: Icon(
                          item.$3,
                          size: 84,
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      Positioned(
                        right: -24,
                        bottom: -24,
                        child: Container(
                          height: 88,
                          width: 88,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.04),
                                Colors.black.withValues(alpha: 0.30),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Icon(item.$3, color: Colors.white, size: 16),
                            ),
                            const Spacer(),
                            Text(
                              item.$1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.92),
                                        fontWeight: FontWeight.w500,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardChartCard extends StatelessWidget {
  final _DashboardMetrics metrics;

  const _DashboardChartCard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final values = <double>[
      metrics.todaySales,
      metrics.pendingDue,
      metrics.lowStockCount.toDouble(),
    ];
    final maxY = (values.reduce((a, b) => a > b ? a : b) * 1.2) + 1;

    return Container(
      padding: const EdgeInsets.all(14),
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
          Text(
            l10n.tr('dashboard_snapshot'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final label = switch (value.toInt()) {
                          0 => l10n.tr('today_sales'),
                          1 => l10n.tr('pending_due'),
                          _ => l10n.tr('low_stock_count'),
                        };
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(toY: metrics.todaySales, color: AppColors.info)
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                        toY: metrics.pendingDue, color: AppColors.warning)
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(
                        toY: metrics.lowStockCount.toDouble(),
                        color: AppColors.danger)
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetrics {
  final double todaySales;
  final double pendingDue;
  final int lowStockCount;

  const _DashboardMetrics({
    this.todaySales = 0,
    this.pendingDue = 0,
    this.lowStockCount = 0,
  });
}
