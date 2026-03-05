import 'package:bhandarx_flutter/app/themes/app_colors.dart';
import 'package:bhandarx_flutter/core/localization/app_localizations.dart';
import 'package:bhandarx_flutter/features/workspace/domain/entities/workspace_entities.dart';
import 'package:flutter/material.dart';

class RecordsListPage extends StatefulWidget {
  final String title;
  final Future<List<WorkspaceRecord>> Function() loader;
  final Widget Function(BuildContext context, WorkspaceRecord item)?
      trailingBuilder;
  final Future<void> Function(BuildContext context, WorkspaceRecord item)?
      onItemTap;
  final VoidCallback? fabAction;
  final String? fabLabel;
  final List<Widget> appBarActions;

  const RecordsListPage({
    super.key,
    required this.title,
    required this.loader,
    this.trailingBuilder,
    this.onItemTap,
    this.fabAction,
    this.fabLabel,
    this.appBarActions = const [],
  });

  @override
  State<RecordsListPage> createState() => _RecordsListPageState();
}

class _RecordsListPageState extends State<RecordsListPage> {
  late Future<List<WorkspaceRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  void _reload() {
    setState(() {
      _future = widget.loader();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ...widget.appBarActions,
          IconButton(
              onPressed: _reload, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: FutureBuilder<List<WorkspaceRecord>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('${l10n.tr('failed_to_load')} ${widget.title}'));
          }
          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return Center(child: Text(l10n.tr('no_items_found')));
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: widget.onItemTap == null
                      ? null
                      : () => widget.onItemTap!(context, item),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkBorder
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title,
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 4),
                              Text(item.subtitle,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _pill(_statusLabel(l10n, item.status)),
                                  _pill(item.amount),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (widget.trailingBuilder != null)
                          widget.trailingBuilder!(context, item),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: widget.fabAction == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                widget.fabAction!.call();
              },
              label: Text(widget.fabLabel ?? l10n.tr('add')),
              icon: const Icon(Icons.add_rounded),
            ),
    );
  }

  String _statusLabel(AppLocalizations l10n, String value) {
    final upper = value.toUpperCase();
    if (upper.startsWith('SALE • ')) {
      final raw = value.split('•').last.trim();
      return '${l10n.tr('sale')} • ${_statusWord(l10n, raw)}';
    }
    return _statusWord(l10n, value);
  }

  String _statusWord(AppLocalizations l10n, String value) {
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

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
