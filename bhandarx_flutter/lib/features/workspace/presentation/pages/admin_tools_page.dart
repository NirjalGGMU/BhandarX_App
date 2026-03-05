import 'package:bhandarx_flutter/features/workspace/data/repositories/workspace_repository.dart';
import 'package:bhandarx_flutter/features/workspace/domain/entities/workspace_entities.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/record_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminToolsPage extends ConsumerStatefulWidget {
  static const routeName = '/workspace/admin-tools';

  const AdminToolsPage({super.key});

  @override
  ConsumerState<AdminToolsPage> createState() => _AdminToolsPageState();
}

class _AdminToolsPageState extends ConsumerState<AdminToolsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Tools'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Categories'),
            Tab(text: 'Suppliers'),
            Tab(text: 'Sales'),
            Tab(text: 'Purchases'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AdminProductsTab(),
          _AdminCategoriesTab(),
          _AdminSuppliersTab(),
          _AdminSalesTab(),
          _AdminPurchasesTab(),
        ],
      ),
    );
  }
}

class _AdminProductsTab extends ConsumerStatefulWidget {
  const _AdminProductsTab();

  @override
  ConsumerState<_AdminProductsTab> createState() => _AdminProductsTabState();
}

class _AdminProductsTabState extends ConsumerState<_AdminProductsTab> {
  final _skuCtrl = TextEditingController();
  WorkspaceSummary? _summary;
  List<WorkspaceRecord> _items = const [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _skuCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(workspaceRepositoryProvider);
    final result = await repo.getProducts();
    final summaryResult = await repo.getInventorySummary();

    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (items) => setState(() {
        _items = items;
        _loading = false;
      }),
    );
    summaryResult.fold((_) {}, (s) => setState(() => _summary = s));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skuCtrl,
                  decoration: const InputDecoration(
                    labelText: 'SKU Lookup',
                    hintText: 'Enter SKU',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _lookupSku, child: const Text('Find')),
            ],
          ),
          const SizedBox(height: 10),
          if (_summary != null)
            Text(
              'Inventory Summary • Products: ${_summary!.totalTransactions} • Value: Rs ${_summary!.totalIn.toStringAsFixed(2)}',
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              FilledButton.tonal(
                onPressed: () => _showProductForm(),
                child: const Text('Create Product'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Text(_error!)
          else
            ..._items.map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle:
                      Text('${item.subtitle}\n${item.status} • ${item.amount}'),
                  isThreeLine: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecordDetailPage(
                          title: 'Product Detail', record: item),
                    ),
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        onPressed: () => _showProductForm(existing: item),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () => _delete(
                            'product',
                            item.id,
                            () => ref
                                .read(workspaceRepositoryProvider)
                                .deleteProduct(item.id)),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _lookupSku() async {
    final sku = _skuCtrl.text.trim();
    if (sku.isEmpty) return;
    final result =
        await ref.read(workspaceRepositoryProvider).getProductBySku(sku);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (record) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                RecordDetailPage(title: 'SKU Product', record: record)),
      ),
    );
  }

  Future<void> _showProductForm({WorkspaceRecord? existing}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _ProductFormDialog(existing: existing),
    );
    if (saved == true) {
      _load();
    }
  }

  Future<void> _delete(
      String label, String id, Future<dynamic> Function() action) async {
    final result = await action();
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$label deleted')));
        _load();
      },
    );
  }
}

class _ProductFormDialog extends ConsumerStatefulWidget {
  final WorkspaceRecord? existing;

  const _ProductFormDialog({this.existing});

  @override
  ConsumerState<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<_ProductFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _sku;
  late final TextEditingController _category;
  late final TextEditingController _supplier;
  late final TextEditingController _purchasePrice;
  late final TextEditingController _sellingPrice;
  late final TextEditingController _qty;
  late final TextEditingController _minStock;
  String _unit = 'piece';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final raw = widget.existing?.raw;
    _name = TextEditingController(text: raw?['name']?.toString() ?? '');
    _sku = TextEditingController(text: raw?['sku']?.toString() ?? '');
    _category = TextEditingController(
        text: raw?['category']?['_id']?.toString() ??
            raw?['category']?.toString() ??
            '');
    _supplier = TextEditingController(
        text: raw?['supplier']?['_id']?.toString() ??
            raw?['supplier']?.toString() ??
            '');
    _purchasePrice =
        TextEditingController(text: raw?['purchasePrice']?.toString() ?? '0');
    _sellingPrice =
        TextEditingController(text: raw?['sellingPrice']?.toString() ?? '0');
    _qty = TextEditingController(text: raw?['quantity']?.toString() ?? '0');
    _minStock =
        TextEditingController(text: raw?['minStockLevel']?.toString() ?? '0');
    _unit = raw?['unit']?.toString() ?? 'piece';
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _category.dispose();
    _supplier.dispose();
    _purchasePrice.dispose();
    _sellingPrice.dispose();
    _qty.dispose();
    _minStock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.existing == null ? 'Create Product' : 'Update Product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: _sku,
                decoration: const InputDecoration(labelText: 'SKU')),
            TextField(
                controller: _category,
                decoration: const InputDecoration(labelText: 'Category ID')),
            TextField(
                controller: _supplier,
                decoration: const InputDecoration(labelText: 'Supplier ID')),
            TextField(
                controller: _purchasePrice,
                decoration: const InputDecoration(labelText: 'Purchase Price')),
            TextField(
                controller: _sellingPrice,
                decoration: const InputDecoration(labelText: 'Selling Price')),
            TextField(
                controller: _qty,
                decoration: const InputDecoration(labelText: 'Quantity')),
            TextField(
                controller: _minStock,
                decoration: const InputDecoration(labelText: 'Min Stock')),
            DropdownButtonFormField<String>(
              initialValue: _unit,
              items: const [
                DropdownMenuItem(value: 'piece', child: Text('piece')),
                DropdownMenuItem(value: 'kg', child: Text('kg')),
                DropdownMenuItem(value: 'liter', child: Text('liter')),
                DropdownMenuItem(value: 'meter', child: Text('meter')),
                DropdownMenuItem(value: 'box', child: Text('box')),
                DropdownMenuItem(value: 'dozen', child: Text('dozen')),
                DropdownMenuItem(value: 'pack', child: Text('pack')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _unit = value);
              },
              decoration: const InputDecoration(labelText: 'Unit'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context, false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: _saving ? null : _save, child: const Text('Save')),
      ],
    );
  }

  Future<void> _save() async {
    final payload = {
      'name': _name.text.trim(),
      'sku': _sku.text.trim(),
      'category': _category.text.trim(),
      'supplier': _supplier.text.trim(),
      'purchasePrice': double.tryParse(_purchasePrice.text.trim()) ?? 0,
      'sellingPrice': double.tryParse(_sellingPrice.text.trim()) ?? 0,
      'quantity': int.tryParse(_qty.text.trim()) ?? 0,
      'minStockLevel': int.tryParse(_minStock.text.trim()) ?? 0,
      'unit': _unit,
      'status': 'active',
    };

    setState(() => _saving = true);
    final repo = ref.read(workspaceRepositoryProvider);
    final result = widget.existing == null
        ? await repo.createProduct(payload)
        : await repo.updateProduct(widget.existing!.id, payload);
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) => Navigator.pop(context, true),
    );
  }
}

class _AdminCategoriesTab extends ConsumerStatefulWidget {
  const _AdminCategoriesTab();

  @override
  ConsumerState<_AdminCategoriesTab> createState() =>
      _AdminCategoriesTabState();
}

class _AdminCategoriesTabState extends ConsumerState<_AdminCategoriesTab> {
  List<WorkspaceRecord> _items = const [];
  List<WorkspaceRecord> _roots = const [];
  List<WorkspaceRecord> _subs = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = ref.read(workspaceRepositoryProvider);
    final all = await repo.getCategories();
    final roots = await repo.getRootCategories();
    all.fold((_) {}, (r) => _items = r);
    roots.fold((_) {}, (r) => _roots = r);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => const _CategoryFormDialog());
                  if (ok == true) _load();
                },
                child: const Text('Create Category'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Root Categories: ${_roots.length}'),
          const SizedBox(height: 8),
          if (_loading) const CircularProgressIndicator(),
          ..._items.map((item) => Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.subtitle),
                  onTap: () async {
                    final subs = await ref
                        .read(workspaceRepositoryProvider)
                        .getSubcategories(item.id);
                    if (!mounted) return;
                    subs.fold(
                      (failure) => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(failure.message))),
                      (data) => setState(() => _subs = data),
                    );
                  },
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) =>
                                  _CategoryFormDialog(existing: item));
                          if (ok == true) _load();
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () async {
                          final r = await ref
                              .read(workspaceRepositoryProvider)
                              .deleteCategory(item.id);
                          if (!mounted) return;
                          r.fold(
                            (failure) => ScaffoldMessenger.of(context)
                                .showSnackBar(
                                    SnackBar(content: Text(failure.message))),
                            (_) => _load(),
                          );
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 8),
          if (_subs.isNotEmpty) ...[
            const Text('Subcategories'),
            ..._subs.map((e) =>
                ListTile(title: Text(e.title), subtitle: Text(e.subtitle))),
          ],
        ],
      ),
    );
  }
}

class _CategoryFormDialog extends ConsumerStatefulWidget {
  final WorkspaceRecord? existing;

  const _CategoryFormDialog({this.existing});

  @override
  ConsumerState<_CategoryFormDialog> createState() =>
      _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<_CategoryFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _desc;
  late final TextEditingController _parent;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final raw = widget.existing?.raw;
    _name = TextEditingController(text: raw?['name']?.toString() ?? '');
    _code = TextEditingController(text: raw?['code']?.toString() ?? '');
    _desc = TextEditingController(text: raw?['description']?.toString() ?? '');
    _parent = TextEditingController(
        text: raw?['parentCategory']?['_id']?.toString() ??
            raw?['parentCategory']?.toString() ??
            '');
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _desc.dispose();
    _parent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.existing == null ? 'Create Category' : 'Update Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: _code,
                decoration: const InputDecoration(labelText: 'Code')),
            TextField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Description')),
            TextField(
                controller: _parent,
                decoration: const InputDecoration(
                    labelText: 'Parent Category ID (optional)')),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context, false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: _saving ? null : _save, child: const Text('Save')),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final payload = {
      'name': _name.text.trim(),
      'code': _code.text.trim(),
      'description': _desc.text.trim(),
      if (_parent.text.trim().isNotEmpty) 'parentCategory': _parent.text.trim(),
      'isActive': true,
    };
    final repo = ref.read(workspaceRepositoryProvider);
    final result = widget.existing == null
        ? await repo.createCategory(payload)
        : await repo.updateCategory(widget.existing!.id, payload);
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) => Navigator.pop(context, true),
    );
  }
}

class _AdminSuppliersTab extends ConsumerStatefulWidget {
  const _AdminSuppliersTab();

  @override
  ConsumerState<_AdminSuppliersTab> createState() => _AdminSuppliersTabState();
}

class _AdminSuppliersTabState extends ConsumerState<_AdminSuppliersTab> {
  List<WorkspaceRecord> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await ref.read(workspaceRepositoryProvider).getSuppliers();
    if (!mounted) return;
    result.fold((_) {}, (data) => setState(() => _items = data));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.tonal(
            onPressed: () async {
              final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => const _SupplierFormDialog());
              if (ok == true) _load();
            },
            child: const Text('Create Supplier'),
          ),
          const SizedBox(height: 8),
          ..._items.map((item) => Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.subtitle),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) =>
                                  _SupplierFormDialog(existing: item));
                          if (ok == true) _load();
                        },
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () async {
                          final r = await ref
                              .read(workspaceRepositoryProvider)
                              .deleteSupplier(item.id);
                          if (!mounted) return;
                          r.fold(
                            (failure) => ScaffoldMessenger.of(context)
                                .showSnackBar(
                                    SnackBar(content: Text(failure.message))),
                            (_) => _load(),
                          );
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _SupplierFormDialog extends ConsumerStatefulWidget {
  final WorkspaceRecord? existing;

  const _SupplierFormDialog({this.existing});

  @override
  ConsumerState<_SupplierFormDialog> createState() =>
      _SupplierFormDialogState();
}

class _SupplierFormDialogState extends ConsumerState<_SupplierFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final raw = widget.existing?.raw;
    _name = TextEditingController(text: raw?['name']?.toString() ?? '');
    _code = TextEditingController(text: raw?['code']?.toString() ?? '');
    _email = TextEditingController(text: raw?['email']?.toString() ?? '');
    _phone = TextEditingController(text: raw?['phone']?.toString() ?? '');
    _address = TextEditingController(text: raw?['address']?.toString() ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.existing == null ? 'Create Supplier' : 'Update Supplier'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: _code,
                decoration: const InputDecoration(labelText: 'Code')),
            TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone')),
            TextField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Address')),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context, false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: _saving ? null : _save, child: const Text('Save')),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final payload = {
      'name': _name.text.trim(),
      'code': _code.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'address': _address.text.trim(),
      'status': 'active',
    };
    final repo = ref.read(workspaceRepositoryProvider);
    final result = widget.existing == null
        ? await repo.createSupplier(payload)
        : await repo.updateSupplier(widget.existing!.id, payload);
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) => Navigator.pop(context, true),
    );
  }
}

class _AdminSalesTab extends ConsumerStatefulWidget {
  const _AdminSalesTab();

  @override
  ConsumerState<_AdminSalesTab> createState() => _AdminSalesTabState();
}

class _AdminSalesTabState extends ConsumerState<_AdminSalesTab> {
  final _search = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  String _payment = '';
  List<WorkspaceRecord> _items = const [];
  WorkspaceSummary? _dash;
  List<WorkspaceRecord> _top = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(workspaceRepositoryProvider);
    final r = await repo.getSalesFiltered({
      if (_search.text.trim().isNotEmpty) 'search': _search.text.trim(),
      if (_start.text.trim().isNotEmpty) 'startDate': _start.text.trim(),
      if (_end.text.trim().isNotEmpty) 'endDate': _end.text.trim(),
      if (_payment.isNotEmpty) 'paymentStatus': _payment,
    });
    final dash = await repo.getDashboardSummary();
    final top = await repo.getSalesTopProducts();
    if (!mounted) return;
    r.fold((_) {}, (data) => setState(() => _items = data));
    dash.fold((_) {}, (d) => setState(() => _dash = d));
    top.fold((_) {}, (d) => setState(() => _top = d));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_dash != null)
            Text('Dashboard • Sales: Rs ${_dash!.totalIn.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          TextField(
              controller: _search,
              decoration: const InputDecoration(labelText: 'Search invoice')),
          TextField(
              controller: _start,
              decoration:
                  const InputDecoration(labelText: 'Start date (YYYY-MM-DD)')),
          TextField(
              controller: _end,
              decoration:
                  const InputDecoration(labelText: 'End date (YYYY-MM-DD)')),
          DropdownButtonFormField<String>(
            initialValue: _payment.isEmpty ? null : _payment,
            decoration: const InputDecoration(labelText: 'Payment Status'),
            items: const [
              DropdownMenuItem(value: 'PAID', child: Text('PAID')),
              DropdownMenuItem(value: 'PARTIAL', child: Text('PARTIAL')),
              DropdownMenuItem(value: 'UNPAID', child: Text('UNPAID')),
            ],
            onChanged: (v) => setState(() => _payment = v ?? ''),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _load, child: const Text('Apply Filters')),
          const SizedBox(height: 10),
          if (_top.isNotEmpty) ...[
            const Text('Top Products'),
            ..._top.take(3).map((e) => Text('${e.title}: ${e.amount}')),
            const SizedBox(height: 10),
          ],
          ..._items.map((item) => Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle:
                      Text('${item.subtitle}\n${item.status} • ${item.amount}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      final repo = ref.read(workspaceRepositoryProvider);
                      final result = switch (value) {
                        'reverse' => await repo.reverseSale(
                            item.id, 'Admin reverse from mobile'),
                        'cancel' => await repo.cancelSale(item.id),
                        'delete' => await repo.deleteSale(item.id),
                        _ => await repo.cancelSale(item.id),
                      };
                      if (!mounted) return;
                      result.fold(
                        (failure) => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(failure.message))),
                        (_) => _load(),
                      );
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'reverse', child: Text('Reverse')),
                      PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _AdminPurchasesTab extends ConsumerStatefulWidget {
  const _AdminPurchasesTab();

  @override
  ConsumerState<_AdminPurchasesTab> createState() => _AdminPurchasesTabState();
}

class _AdminPurchasesTabState extends ConsumerState<_AdminPurchasesTab> {
  final _search = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  String _status = '';
  List<WorkspaceRecord> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result =
        await ref.read(workspaceRepositoryProvider).getPurchasesFiltered({
      if (_search.text.trim().isNotEmpty) 'search': _search.text.trim(),
      if (_start.text.trim().isNotEmpty) 'startDate': _start.text.trim(),
      if (_end.text.trim().isNotEmpty) 'endDate': _end.text.trim(),
      if (_status.isNotEmpty) 'status': _status,
    });
    if (!mounted) return;
    result.fold((_) {}, (data) => setState(() => _items = data));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => const _CreatePurchaseDialog());
                  if (ok == true) _load();
                },
                child: const Text('Create Purchase'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
              controller: _search,
              decoration: const InputDecoration(labelText: 'Search PO number')),
          TextField(
              controller: _start,
              decoration:
                  const InputDecoration(labelText: 'Start date (YYYY-MM-DD)')),
          TextField(
              controller: _end,
              decoration:
                  const InputDecoration(labelText: 'End date (YYYY-MM-DD)')),
          DropdownButtonFormField<String>(
            initialValue: _status.isEmpty ? null : _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'PENDING', child: Text('PENDING')),
              DropdownMenuItem(value: 'RECEIVED', child: Text('RECEIVED')),
              DropdownMenuItem(
                  value: 'PARTIAL_RECEIVED', child: Text('PARTIAL_RECEIVED')),
              DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED')),
            ],
            onChanged: (v) => setState(() => _status = v ?? ''),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _load, child: const Text('Apply Filters')),
          const SizedBox(height: 10),
          ..._items.map((item) => Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle:
                      Text('${item.subtitle}\n${item.status} • ${item.amount}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      final repo = ref.read(workspaceRepositoryProvider);
                      final result = switch (value) {
                        'update' => await repo.updatePurchase(
                            item.id, {'notes': 'Updated from mobile admin'}),
                        'receive' => await repo.receivePurchase(item.id, {
                            'items': [
                              {
                                'itemId': (((item.raw['items'] as List?)
                                            ?.isNotEmpty ??
                                        false)
                                    ? item.raw['items'][0]['_id']
                                    : ''),
                                'quantity': 1,
                              }
                            ]
                          }),
                        'payment' => await repo.updatePurchasePayment(item.id,
                            {'paidAmount': 0, 'paymentMethod': 'CASH'}),
                        'cancel' => await repo.cancelPurchase(item.id),
                        'delete' => await repo.deletePurchase(item.id),
                        _ => await repo.cancelPurchase(item.id),
                      };
                      if (!mounted) return;
                      result.fold(
                        (failure) => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(failure.message))),
                        (_) => _load(),
                      );
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'update', child: Text('Update')),
                      PopupMenuItem(
                          value: 'receive', child: Text('Receive Items')),
                      PopupMenuItem(
                          value: 'payment', child: Text('Update Payment')),
                      PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _CreatePurchaseDialog extends ConsumerStatefulWidget {
  const _CreatePurchaseDialog();

  @override
  ConsumerState<_CreatePurchaseDialog> createState() =>
      _CreatePurchaseDialogState();
}

class _CreatePurchaseDialogState extends ConsumerState<_CreatePurchaseDialog> {
  final _supplier = TextEditingController();
  final _product = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _price = TextEditingController(text: '0');
  bool _saving = false;

  @override
  void dispose() {
    _supplier.dispose();
    _product.dispose();
    _qty.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Purchase'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _supplier,
                decoration: const InputDecoration(labelText: 'Supplier ID')),
            TextField(
                controller: _product,
                decoration: const InputDecoration(labelText: 'Product ID')),
            TextField(
                controller: _qty,
                decoration: const InputDecoration(labelText: 'Quantity')),
            TextField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Unit Price')),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context, false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: _saving ? null : _save, child: const Text('Create')),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final payload = {
      'supplier': _supplier.text.trim(),
      'items': [
        {
          'product': _product.text.trim(),
          'quantity': int.tryParse(_qty.text.trim()) ?? 1,
          'unitPrice': double.tryParse(_price.text.trim()) ?? 0,
        }
      ],
      'paymentMethod': 'CASH',
    };
    final result =
        await ref.read(workspaceRepositoryProvider).createPurchase(payload);
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) => Navigator.pop(context, true),
    );
  }
}
