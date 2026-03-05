import 'package:bhandarx_flutter/core/localization/app_localizations.dart';
import 'package:bhandarx_flutter/core/services/connectivity/network_info.dart';
import 'package:bhandarx_flutter/features/workspace/data/repositories/workspace_repository.dart';
import 'package:bhandarx_flutter/features/workspace/domain/entities/workspace_entities.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/_records_list_page.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/record_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SalesPage extends ConsumerStatefulWidget {
  static const routeName = '/workspace/sales';

  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

enum _DateFilter { all, today, week, month }

class _SalesPageState extends ConsumerState<SalesPage> {
  Key _listKey = UniqueKey();
  String _search = '';
  _DateFilter _dateFilter = _DateFilter.all;

  void _refresh() {
    setState(() {
      _listKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RecordsListPage(
      key: _listKey,
      title: l10n.tr('sales_page'),
      loader: () async {
        final result = await ref
            .read(workspaceRepositoryProvider)
            .getSales(search: _search);
        return result.fold((l) => throw Exception(l.message), (r) {
          return r.where(_matchesDateFilter).toList();
        });
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
        final detailResult =
            await ref.read(workspaceRepositoryProvider).getSaleById(item.id);
        if (!mounted) {
          return;
        }
        detailResult.fold(
          (failure) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message))),
          (record) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecordDetailPage(
                  title: l10n.tr('sale_detail'), record: record),
            ),
          ),
        );
      },
      fabLabel: l10n.tr('new_sale'),
      fabAction: () async {
        final didSave = await showDialog<bool>(
          context: context,
          builder: (_) => const _CreateSaleDialog(),
        );
        if (didSave == true) {
          _refresh();
        }
      },
      trailingBuilder: (context, item) {
        return IconButton(
          onPressed: () async {
            final didSave = await showDialog<bool>(
              context: context,
              builder: (_) => _UpdatePaymentDialog(saleId: item.id),
            );
            if (didSave == true) {
              _refresh();
            }
          },
          icon: const Icon(Icons.payments_outlined),
        );
      },
    );
  }

  Future<void> _openSearch(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _search);
    final value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.tr('search_sales')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.tr('search_sales'),
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
}

class _CreateSaleDialog extends ConsumerStatefulWidget {
  const _CreateSaleDialog();

  @override
  ConsumerState<_CreateSaleDialog> createState() => _CreateSaleDialogState();
}

class _CreateSaleDialogState extends ConsumerState<_CreateSaleDialog> {
  late final Future<List<WorkspaceRecord>> _customersFuture;
  late final Future<List<WorkspaceRecord>> _productsFuture;

  final _productName = TextEditingController();
  final _sku = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  final _unitPrice = TextEditingController(text: '0');
  final _paidAmount = TextEditingController(text: '0');
  String _paymentMethod = 'CASH';
  String? _customerId;
  String? _productId;
  int _availableQty = 0;
  bool _saving = false;

  double get _totalAmount {
    final qty = int.tryParse(_quantity.text.trim()) ?? 0;
    final unit = double.tryParse(_unitPrice.text.trim()) ?? 0;
    return qty * unit;
  }

  void _onPriceInputsChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  String _paymentLabel(AppLocalizations l10n, String value) {
    switch (value) {
      case 'CASH':
        return l10n.tr('cash');
      case 'CARD':
        return l10n.tr('card');
      case 'BANK_TRANSFER':
        return l10n.tr('bank_transfer');
      case 'CREDIT':
        return l10n.tr('credit');
      case 'QR':
        return l10n.tr('qr');
      default:
        return value;
    }
  }

  @override
  void initState() {
    super.initState();
    _customersFuture = _loadCustomers();
    _productsFuture = _loadProducts();
    _quantity.addListener(_onPriceInputsChanged);
    _unitPrice.addListener(_onPriceInputsChanged);
  }

  @override
  void dispose() {
    _productName.dispose();
    _sku.dispose();
    _quantity.dispose();
    _unitPrice.dispose();
    _paidAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<List<WorkspaceRecord>>>(
      future: Future.wait([_customersFuture, _productsFuture]),
      builder: (context, snapshot) {
        final customers =
            snapshot.hasData ? snapshot.data!.first : const <WorkspaceRecord>[];
        final products =
            snapshot.hasData ? snapshot.data!.last : const <WorkspaceRecord>[];

        return AlertDialog(
          title: Text(l10n.tr('create_sale')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _customerId,
                  decoration:
                      InputDecoration(labelText: l10n.tr('customers_page')),
                  items: customers
                      .map((e) =>
                          DropdownMenuItem(value: e.id, child: Text(e.title)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _customerId = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _productId,
                  decoration:
                      InputDecoration(labelText: l10n.tr('products_page')),
                  items: products
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(
                            e.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _productId = value;
                    });
                    if (value == null) {
                      return;
                    }
                    final selected = products.firstWhere(
                      (p) => p.id == value,
                      orElse: () => const WorkspaceRecord(
                        id: '',
                        title: '',
                        subtitle: '',
                        status: '',
                        amount: '',
                        raw: {},
                      ),
                    );
                    if (selected.id.isEmpty) {
                      return;
                    }
                    _productName.text = selected.title;
                    final rawQty = selected.raw['quantity'];
                    if (rawQty is num) {
                      _availableQty = rawQty.toInt();
                    } else {
                      _availableQty = 0;
                    }
                    final rawSku = selected.raw['sku']?.toString() ?? '';
                    if (rawSku.isNotEmpty) {
                      _sku.text = rawSku;
                    }
                    final rawPrice = selected.raw['sellingPrice'] ??
                        selected.raw['salePrice'] ??
                        selected.raw['price'] ??
                        selected.raw['unitPrice'];
                    if (rawPrice is num) {
                      _unitPrice.text = rawPrice.toString();
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                    controller: _productName,
                    decoration:
                        InputDecoration(labelText: l10n.tr('product_name')),
                    readOnly: true),
                const SizedBox(height: 8),
                TextField(
                    controller: _sku,
                    decoration: const InputDecoration(labelText: 'SKU'),
                    readOnly: true),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${l10n.tr('available_stock')}: $_availableQty',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _quantity,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.tr('quantity')),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _unitPrice,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l10n.tr('unit_price')),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _paidAmount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      InputDecoration(labelText: l10n.tr('paid_amount')),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${l10n.tr('total_amount')}: Rs ${_totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${l10n.tr('due_amount')}: Rs ${((_totalAmount - (double.tryParse(_paidAmount.text.trim()) ?? 0) < 0 ? 0 : _totalAmount - (double.tryParse(_paidAmount.text.trim()) ?? 0))).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      _paidAmount.text = _totalAmount.toStringAsFixed(2);
                      setState(() {});
                    },
                    icon: const Icon(Icons.payments_rounded),
                    label: Text(l10n.tr('fill_full_payment')),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  decoration:
                      InputDecoration(labelText: l10n.tr('payment_method')),
                  items: [
                    DropdownMenuItem(
                        value: 'CASH', child: Text(_paymentLabel(l10n, 'CASH'))),
                    DropdownMenuItem(
                        value: 'CARD', child: Text(_paymentLabel(l10n, 'CARD'))),
                    DropdownMenuItem(
                        value: 'BANK_TRANSFER',
                        child: Text(_paymentLabel(l10n, 'BANK_TRANSFER'))),
                    DropdownMenuItem(
                        value: 'CREDIT',
                        child: Text(_paymentLabel(l10n, 'CREDIT'))),
                    DropdownMenuItem(
                        value: 'QR', child: Text(_paymentLabel(l10n, 'QR'))),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _paymentMethod = value;
                      });
                    }
                  },
                ),
                if (_paymentMethod == 'QR') ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _totalAmount > 0 ? _showQrPaymentSheet : null,
                      icon: const Icon(Icons.qr_code_rounded),
                      label: Text(l10n.tr('show_qr')),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: _saving ? null : () => Navigator.pop(context, false),
                child: Text(l10n.tr('cancel'))),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.tr('create_btn')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final isOnline = await ref.read(networkInfoProvider).isConnected;
    if (!mounted) {
      return;
    }
    if (_customerId == null ||
        _productName.text.trim().isEmpty ||
        _sku.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tr('select_customer_product'))));
      return;
    }

    final quantity = int.tryParse(_quantity.text.trim()) ?? 0;
    final unitPrice = double.tryParse(_unitPrice.text.trim()) ?? 0;
    final paidAmount = double.tryParse(_paidAmount.text.trim()) ?? 0;
    final totalAmount = quantity * unitPrice;
    if (quantity <= 0 || unitPrice < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tr('enter_valid_qty_price'))));
      return;
    }
    if (paidAmount > totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('paid_cannot_exceed_total'))),
      );
      return;
    }
    if (_availableQty > 0 && quantity > _availableQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n
              .tr('only_items_available')
              .replaceAll('{count}', _availableQty.toString())),
        ),
      );
      return;
    }
    if (_availableQty == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('selected_product_out_stock'))),
      );
      return;
    }

    String? resolvedProductId = _productId;
    if (resolvedProductId == null) {
      final bySku = await ref
          .read(workspaceRepositoryProvider)
          .getProductBySku(_sku.text.trim());
      if (!mounted) {
        return;
      }
      bySku.fold(
        (_) {},
        (record) {
          resolvedProductId = record.id;
        },
      );
    }
    if (resolvedProductId == null || resolvedProductId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('product_id_missing'))),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    final payload = CreateSalePayload(
      customerId: _customerId!,
      items: [
        SaleItemPayload(
          product: resolvedProductId!,
          productName: _productName.text.trim(),
          sku: _sku.text.trim(),
          quantity: quantity,
          unitPrice: unitPrice,
        ),
      ],
      paidAmount: paidAmount,
      paymentMethod: _paymentMethod,
    );

    final result =
        await ref.read(workspaceRepositoryProvider).createSale(payload);
    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        setState(() {
          _saving = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                isOnline
                  ? l10n.tr('sale_saved')
                  : l10n.tr('saved_offline_will_sync'),
              ),
            ),
        );
        Navigator.pop(context, true);
      },
    );
  }

  Future<void> _showQrPaymentSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final qrAmount = _totalAmount > 0 ? _totalAmount : 0;
    final payload =
        'bhandarx://pay?type=sale&method=QR&amount=${qrAmount.toStringAsFixed(2)}&sku=${Uri.encodeComponent(_sku.text.trim())}&product=${Uri.encodeComponent(_productName.text.trim())}&ts=${DateTime.now().millisecondsSinceEpoch}';

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.tr('pay_by_qr'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.tr('scan_qr_to_pay'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: payload,
                    size: 220,
                    version: QrVersions.auto,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Rs ${qrAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.tr('cancel')),
                      ),
                    ),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(context, true),
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: Text(l10n.tr('mark_qr_paid')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      _paidAmount.text = qrAmount.toStringAsFixed(2);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('qr_payment_ready'))),
      );
      setState(() {});
    }
  }

  Future<List<WorkspaceRecord>> _loadCustomers() async {
    final result = await ref.read(workspaceRepositoryProvider).getCustomers();
    return result.fold((_) => <WorkspaceRecord>[], (r) => r);
  }

  Future<List<WorkspaceRecord>> _loadProducts() async {
    final result = await ref.read(workspaceRepositoryProvider).getProducts();
    return result.fold((_) => <WorkspaceRecord>[], (r) => r);
  }
}

class _UpdatePaymentDialog extends ConsumerStatefulWidget {
  final String saleId;

  const _UpdatePaymentDialog({required this.saleId});

  @override
  ConsumerState<_UpdatePaymentDialog> createState() =>
      _UpdatePaymentDialogState();
}

class _UpdatePaymentDialogState extends ConsumerState<_UpdatePaymentDialog> {
  final _amount = TextEditingController(text: '0');
  String _paymentMethod = 'CASH';
  bool _saving = false;

  String _paymentLabel(AppLocalizations l10n, String value) {
    switch (value) {
      case 'CASH':
        return l10n.tr('cash');
      case 'CARD':
        return l10n.tr('card');
      case 'BANK_TRANSFER':
        return l10n.tr('bank_transfer');
      case 'CREDIT':
        return l10n.tr('credit');
      case 'QR':
        return l10n.tr('qr');
      default:
        return value;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.tr('update_payment')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.tr('paid_amount')),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _paymentMethod,
            decoration: InputDecoration(labelText: l10n.tr('payment_method')),
            items: [
              DropdownMenuItem(
                  value: 'CASH', child: Text(_paymentLabel(l10n, 'CASH'))),
              DropdownMenuItem(
                  value: 'CARD', child: Text(_paymentLabel(l10n, 'CARD'))),
              DropdownMenuItem(
                  value: 'BANK_TRANSFER',
                  child: Text(_paymentLabel(l10n, 'BANK_TRANSFER'))),
              DropdownMenuItem(
                  value: 'CREDIT', child: Text(_paymentLabel(l10n, 'CREDIT'))),
              DropdownMenuItem(
                  value: 'QR', child: Text(_paymentLabel(l10n, 'QR'))),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _paymentMethod = value;
                });
              }
            },
          ),
          if (_paymentMethod == 'QR') ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _showQrPaymentSheet,
                icon: const Icon(Icons.qr_code_rounded),
                label: Text(l10n.tr('show_qr')),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context, false),
            child: Text(l10n.tr('cancel'))),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.tr('update')),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final paidAmount = double.tryParse(_amount.text.trim()) ?? -1;
    if (paidAmount < 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.tr('enter_valid_amount'))));
      return;
    }

    setState(() {
      _saving = true;
    });

    final result =
        await ref.read(workspaceRepositoryProvider).updateSalePayment(
              widget.saleId,
              UpdateSalePaymentPayload(
                  paidAmount: paidAmount, paymentMethod: _paymentMethod),
            );

    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        setState(() {
          _saving = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) => Navigator.pop(context, true),
    );
  }

  Future<void> _showQrPaymentSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    final payload =
        'bhandarx://pay?type=update_sale_payment&method=QR&amount=${amount.toStringAsFixed(2)}&saleId=${widget.saleId}&ts=${DateTime.now().millisecondsSinceEpoch}';
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.tr('pay_by_qr'),
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(l10n.tr('scan_qr_to_pay')),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: payload,
                    size: 220,
                    version: QrVersions.auto,
                  ),
                ),
                const SizedBox(height: 10),
                Text('Rs ${amount.toStringAsFixed(2)}'),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.tr('cancel')),
                      ),
                    ),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(context, true),
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: Text(l10n.tr('mark_qr_paid')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('qr_payment_ready'))),
      );
    }
  }
}
