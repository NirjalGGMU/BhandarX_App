import 'package:bhandarx_flutter/app/themes/app_colors.dart';
import 'package:bhandarx_flutter/core/localization/app_localizations.dart';
import 'package:bhandarx_flutter/features/workspace/domain/entities/workspace_entities.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RecordDetailPage extends StatelessWidget {
  final String title;
  final WorkspaceRecord record;

  const RecordDetailPage({
    super.key,
    required this.title,
    required this.record,
  });

  bool _isSaleRecord() {
    return record.raw['invoiceNumber'] != null ||
        record.raw['items'] is List ||
        record.raw['paymentMethod'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return _isSaleRecord()
        ? _SaleDetailView(title: title, record: record)
        : _GenericDetailView(title: title, record: record);
  }
}

class _SaleDetailView extends StatelessWidget {
  final String title;
  final WorkspaceRecord record;

  const _SaleDetailView({
    required this.title,
    required this.record,
  });

  double _num(dynamic v) {
    if (v is num) {
      return v.toDouble();
    }
    if (v is String) {
      return double.tryParse(v) ?? 0;
    }
    return 0;
  }

  DateTime? _date(dynamic v) {
    if (v is String) {
      return DateTime.tryParse(v)?.toLocal();
    }
    return null;
  }

  String _money(num value) => 'Rs ${value.toStringAsFixed(2)}';

  String _paymentLabel(AppLocalizations l10n, String value) {
    switch (value.toUpperCase()) {
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

  String _statusLabel(AppLocalizations l10n, String value) {
    switch (value.toUpperCase()) {
      case 'PAID':
        return l10n.tr('paid');
      case 'UNPAID':
      case 'PENDING':
        return l10n.tr('pending');
      case 'PARTIAL':
        return l10n.tr('partial');
      case 'COMPLETED':
        return l10n.tr('completed');
      case 'CANCELLED':
        return l10n.tr('cancelled');
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final raw = record.raw;
    final invoice = raw['invoiceNumber']?.toString() ?? record.title;
    final customer = raw['customer'];
    final customerName = customer is Map
        ? customer['name']?.toString() ?? record.subtitle
        : record.subtitle;
    final paymentMethod = raw['paymentMethod']?.toString() ?? '';
    final paymentStatus = raw['paymentStatus']?.toString() ?? record.status;
    final saleDate = _date(raw['saleDate'] ?? raw['createdAt']);
    final totalAmount = _num(raw['totalAmount']);
    final paidAmount = _num(raw['paidAmount']);
    final balanceAmount = _num(raw['balanceAmount']);
    final items =
        (raw['items'] is List ? raw['items'] as List<dynamic> : const []);

    final qrData =
        'bhandarx://receipt?invoice=${Uri.encodeComponent(invoice)}&amount=${totalAmount.toStringAsFixed(2)}&paymentMethod=${Uri.encodeComponent(paymentMethod)}';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(customerName, style: Theme.of(context).textTheme.bodyLarge),
                if (saleDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('yyyy-MM-dd hh:mm a').format(saleDate),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pill(
                      context,
                      '${l10n.tr('payment_method')}: ${_paymentLabel(l10n, paymentMethod)}',
                      AppColors.info,
                    ),
                    _pill(
                      context,
                      '${l10n.tr('status')}: ${_statusLabel(l10n, paymentStatus)}',
                      AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            context,
            child: Column(
              children: [
                _amountRow(context, l10n.tr('total_amount'), _money(totalAmount),
                    bold: true),
                _amountRow(context, l10n.tr('paid_amount'), _money(paidAmount)),
                _amountRow(context, l10n.tr('due_amount'), _money(balanceAmount)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (items.isNotEmpty)
            _card(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tr('items'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  ...items
                      .whereType<Map>()
                      .map((item) => _saleItemTile(context, item)),
                ],
              ),
            ),
          if (paymentMethod.toUpperCase() == 'QR') ...[
            const SizedBox(height: 12),
            _card(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.tr('payment_method')}: ${l10n.tr('qr')}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.tr('scan_qr_to_pay'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: qrData,
                        size: 180,
                        version: QrVersions.auto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _saleItemTile(BuildContext context, Map item) {
    final name = item['productName']?.toString() ??
        (item['product'] is Map ? item['product']['name']?.toString() : null) ??
        'Item';
    final sku = item['sku']?.toString() ?? '-';
    final qty = _num(item['quantity']).toInt();
    final unitPrice = _num(item['unitPrice']);
    final lineTotal = _num(item['lineTotal']);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkBackground.withValues(alpha: 0.35)
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 2),
          Text('SKU: $sku', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: Text('Qty: $qty')),
              Expanded(
                  child: Text('Unit: ${_money(unitPrice)}',
                      textAlign: TextAlign.center)),
              Expanded(
                  child: Text(
                _money(lineTotal > 0 ? lineTotal : (unitPrice * qty)),
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w700),
              )),
            ],
          )
        ],
      ),
    );
  }

  Widget _amountRow(
    BuildContext context,
    String label,
    String value, {
    bool bold = false,
  }) {
    final style = bold
        ? Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700)
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.border,
        ),
      ),
      child: child,
    );
  }
}

class _GenericDetailView extends StatelessWidget {
  final String title;
  final WorkspaceRecord record;

  const _GenericDetailView({
    required this.title,
    required this.record,
  });

  String _statusLabel(AppLocalizations l10n, String value) {
    switch (value.toUpperCase()) {
      case 'PAID':
        return l10n.tr('paid');
      case 'PENDING':
        return l10n.tr('pending');
      case 'PARTIAL':
        return l10n.tr('partial');
      case 'COMPLETED':
        return l10n.tr('completed');
      case 'CANCELLED':
        return l10n.tr('cancelled');
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = record.raw.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
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
                Text(record.title,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(record.subtitle),
                const SizedBox(height: 8),
                Text('${l10n.tr('status')}: ${_statusLabel(l10n, record.status)}'),
                Text(record.amount),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...entries.map((entry) => _kv(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _kv(String key, dynamic value) {
    final output = (value is Map || value is List)
        ? value.toString()
        : (value ?? '').toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              key,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(output)),
        ],
      ),
    );
  }
}
