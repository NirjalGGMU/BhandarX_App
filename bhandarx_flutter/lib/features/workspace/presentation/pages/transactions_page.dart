import 'package:bhandarx_flutter/core/localization/app_localizations.dart';
import 'package:bhandarx_flutter/features/workspace/data/repositories/workspace_repository.dart';
import 'package:bhandarx_flutter/features/workspace/domain/entities/workspace_entities.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/_records_list_page.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/record_detail_page.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/transaction_insights_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _DateFilter { all, today, week, month }

class TransactionsPage extends ConsumerStatefulWidget {
  static const routeName = '/workspace/transactions';

  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  Key _listKey = UniqueKey();
  String _search = '';
  _DateFilter _dateFilter = _DateFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RecordsListPage(
      key: _listKey,
      title: l10n.tr('transactions_page'),
      loader: () async {
        final repo = ref.read(workspaceRepositoryProvider);
        final result = await repo.getTransactions(search: _search);
        final records = result.fold((l) => <WorkspaceRecord>[], (r) => r);
        if (records.isNotEmpty) {
          return records.where(_matchesDateFilter).toList();
        }

        // Fallback: backend sales do not always write to transaction collection.
        final salesResult = await repo.getSales();
        final sales = salesResult.fold((l) => <WorkspaceRecord>[], (r) => r);
        final mapped = sales.map(_mapSaleToTransactionRecord).toList();
        final filteredByDate = mapped.where(_matchesDateFilter).toList();
        if (_search.isEmpty) {
          return filteredByDate;
        }
        final q = _search.toLowerCase();
        return filteredByDate.where((item) {
          return item.title.toLowerCase().contains(q) ||
              item.subtitle.toLowerCase().contains(q) ||
              item.status.toLowerCase().contains(q) ||
              item.amount.toLowerCase().contains(q);
        }).toList();
      },
      appBarActions: [
        PopupMenuButton<_DateFilter>(
          initialValue: _dateFilter,
          onSelected: (value) {
            setState(() {
              _dateFilter = value;
              _listKey = UniqueKey();
            });
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _DateFilter.all,
              child: Text(l10n.tr('all_time')),
            ),
            PopupMenuItem(
              value: _DateFilter.today,
              child: Text(l10n.tr('today')),
            ),
            PopupMenuItem(
              value: _DateFilter.week,
              child: Text(l10n.tr('last_7_days')),
            ),
            PopupMenuItem(
              value: _DateFilter.month,
              child: Text(l10n.tr('last_30_days')),
            ),
          ],
          icon: const Icon(Icons.filter_alt_outlined),
        ),
        IconButton(
          onPressed: () => _openSearch(context),
          icon: const Icon(Icons.search_rounded),
        ),
        if (_search.isNotEmpty)
          IconButton(
            onPressed: () {
              setState(() {
                _search = '';
                _listKey = UniqueKey();
              });
            },
            tooltip: l10n.tr('clear_search'),
            icon: const Icon(Icons.close_rounded),
          ),
      ],
      onItemTap: (context, item) async {
        final isSaleRecord = item.raw['invoiceNumber'] != null ||
            item.raw['_source'] == 'sale_fallback';
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecordDetailPage(
              title: isSaleRecord
                  ? l10n.tr('sale_detail')
                  : l10n.tr('transaction_detail'),
              record: item,
            ),
          ),
        );
      },
      fabLabel: l10n.tr('recent_summary'),
      fabAction: () {
        Navigator.pushNamed(context, TransactionInsightsPage.routeName);
      },
    );
  }

  Future<void> _openSearch(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _search);
    final value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.tr('search_transactions')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.tr('search_transactions'),
            prefixIcon: const Icon(Icons.search_rounded),
          ),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.tr('search_btn')),
          ),
        ],
      ),
    );
    if (!mounted || value == null) {
      return;
    }
    setState(() {
      _search = value.trim();
      _listKey = UniqueKey();
    });
  }

  bool _matchesDateFilter(WorkspaceRecord item) {
    if (_dateFilter == _DateFilter.all) {
      return true;
    }
    final rawDate = item.raw['createdAt'] ??
        item.raw['transactionDate'] ??
        item.raw['updatedAt'];
    if (rawDate is! String) {
      return true;
    }
    final parsed = DateTime.tryParse(rawDate)?.toLocal();
    if (parsed == null) {
      return true;
    }
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    if (_dateFilter == _DateFilter.today) {
      return !parsed.isBefore(todayStart);
    }
    if (_dateFilter == _DateFilter.week) {
      return !parsed.isBefore(todayStart.subtract(const Duration(days: 6)));
    }
    return !parsed.isBefore(todayStart.subtract(const Duration(days: 29)));
  }

  WorkspaceRecord _mapSaleToTransactionRecord(WorkspaceRecord sale) {
    final raw = <String, dynamic>{...sale.raw, '_source': 'sale_fallback'};
    return WorkspaceRecord(
      id: sale.id,
      title: sale.title,
      subtitle: sale.subtitle,
      status: 'SALE • ${sale.status}',
      amount: sale.amount,
      raw: raw,
    );
  }
}
