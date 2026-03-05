import 'package:bhandarx_flutter/core/localization/app_localizations.dart';
import 'package:bhandarx_flutter/core/services/connectivity/network_info.dart';
import 'package:bhandarx_flutter/features/workspace/data/repositories/workspace_repository.dart';
import 'package:bhandarx_flutter/features/workspace/domain/entities/workspace_entities.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/_records_list_page.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/record_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomersPage extends ConsumerStatefulWidget {
  static const routeName = '/workspace/customers';

  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  Key _listKey = UniqueKey();
  String _search = '';

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
      title: l10n.tr('customers_page'),
      loader: () async {
        final result = await ref
            .read(workspaceRepositoryProvider)
            .getCustomers(search: _search);
        return result.fold((l) => throw Exception(l.message), (r) => r);
      },
      appBarActions: [
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
        final detailResult = await ref
            .read(workspaceRepositoryProvider)
            .getCustomerById(item.id);
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
                  title: l10n.tr('customer_detail'), record: record),
            ),
          ),
        );
      },
      fabLabel: l10n.tr('create_btn'),
      fabAction: () async {
        final didSave = await showDialog<bool>(
          context: context,
          builder: (_) => const _CustomerFormDialog(),
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
              builder: (_) => _CustomerFormDialog(existing: item),
            );
            if (didSave == true) {
              _refresh();
            }
          },
          icon: const Icon(Icons.edit_outlined),
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
        title: Text(l10n.tr('search_customers')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.tr('search_customers'),
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
}

class _CustomerFormDialog extends ConsumerStatefulWidget {
  final WorkspaceRecord? existing;

  const _CustomerFormDialog({this.existing});

  @override
  ConsumerState<_CustomerFormDialog> createState() =>
      _CustomerFormDialogState();
}

class _CustomerFormDialogState extends ConsumerState<_CustomerFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  String _type = 'RETAIL';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final raw = widget.existing?.raw;
    _name = TextEditingController(text: raw?['name']?.toString() ?? '');
    _phone = TextEditingController(text: raw?['phone']?.toString() ?? '');
    _email = TextEditingController(text: raw?['email']?.toString() ?? '');
    _address = TextEditingController(text: raw?['address']?.toString() ?? '');
    _type = raw?['customerType']?.toString() ?? 'RETAIL';
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        widget.existing == null
            ? l10n.tr('create_customer')
            : l10n.tr('edit_customer'),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.tr('name'))),
            const SizedBox(height: 8),
            TextField(
                controller: _phone,
                decoration: InputDecoration(labelText: l10n.tr('phone'))),
            const SizedBox(height: 8),
            TextField(
                controller: _email,
                decoration: InputDecoration(labelText: l10n.tr('email'))),
            const SizedBox(height: 8),
            TextField(
                controller: _address,
                decoration: InputDecoration(labelText: l10n.tr('address'))),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _type,
              items: [
                DropdownMenuItem(
                    value: 'RETAIL', child: Text(l10n.tr('retail'))),
                DropdownMenuItem(
                    value: 'WHOLESALE', child: Text(l10n.tr('wholesale'))),
                DropdownMenuItem(
                    value: 'CORPORATE', child: Text(l10n.tr('corporate'))),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _type = value;
                  });
                }
              },
              decoration: InputDecoration(labelText: l10n.tr('customer_type')),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: Text(l10n.tr('cancel')),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.tr('save')),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final isOnline = await ref.read(networkInfoProvider).isConnected;
    if (!mounted) {
      return;
    }
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final email = _email.text.trim();
    final address = _address.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tr('name_phone_required'))));
      return;
    }

    final phoneRegex = RegExp(r'^[0-9+\-() ]{7,20}$');
    if (!phoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('valid_phone_required'))),
      );
      return;
    }

    if (email.isNotEmpty) {
      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      if (!emailRegex.hasMatch(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tr('valid_email_required'))),
        );
        return;
      }
    }

    setState(() {
      _saving = true;
    });

    final payload = CustomerPayload(
      name: name,
      phone: phone,
      email: email,
      address: address,
      customerType: _type,
    );

    final repository = ref.read(workspaceRepositoryProvider);
    final result = widget.existing == null
        ? await repository.createCustomer(payload)
        : await repository.updateCustomer(widget.existing!.id, payload);

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
                  ? l10n.tr('customer_saved')
                  : l10n.tr('saved_offline_will_sync'),
              ),
            ),
        );
        Navigator.pop(context, true);
      },
    );
  }
}
