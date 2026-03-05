import 'package:bhandarx_flutter/app/themes/app_colors.dart';
import 'package:bhandarx_flutter/core/localization/app_localizations.dart';
import 'package:bhandarx_flutter/features/notifications/domain/entities/notification_entity.dart';
import 'package:bhandarx_flutter/features/notifications/presentation/state/notifications_state.dart';
import 'package:bhandarx_flutter/features/notifications/presentation/view_model/notifications_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  static const routeName = '/notifications';
  final bool embedded;

  const NotificationsScreen({super.key, this.embedded = false});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(notificationsViewModelProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(notificationsViewModelProvider);

    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<NotificationFilter>(
                  selected: {state.filter},
                  onSelectionChanged: (selection) {
                    ref
                        .read(notificationsViewModelProvider.notifier)
                        .setFilter(selection.first);
                  },
                  segments: [
                    ButtonSegment(
                        value: NotificationFilter.all,
                        label: Text(l10n.tr('all'))),
                    ButtonSegment(
                        value: NotificationFilter.unread,
                        label: Text(l10n.tr('unread'))),
                    ButtonSegment(
                        value: NotificationFilter.read,
                        label: Text(l10n.tr('read'))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: state.items.isEmpty
                    ? null
                    : () => ref
                        .read(notificationsViewModelProvider.notifier)
                        .markAllAsRead(),
                child: Text(l10n.tr('mark_all_read')),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(notificationsViewModelProvider.notifier).load(),
            child: _Body(state: state),
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('notifications'))),
      body: content,
    );
  }
}

class _Body extends ConsumerWidget {
  final NotificationsState state;

  const _Body({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 140),
          Center(child: Text(state.error!)),
        ],
      );
    }

    if (state.items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 140),
          Center(child: Text(l10n.tr('notifications_empty'))),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final item = state.items[index];
        final color = _priorityColor(item.priority);
        return InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: item.isRead
              ? null
              : () => ref
                  .read(notificationsViewModelProvider.notifier)
                  .markAsRead(item.id),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorder
                    : AppColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.14),
                  child: Icon(_typeIcon(item), color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontSize: 16),
                            ),
                          ),
                          _Badge(label: item.priority, color: color),
                          const SizedBox(width: 6),
                          _Badge(
                            label: item.isRead
                                ? l10n.tr('read')
                                : l10n.tr('unread'),
                            color:
                                item.isRead ? Colors.grey : AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(item.message,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: state.items.length,
    );
  }

  IconData _typeIcon(NotificationEntity item) {
    switch (item.type) {
      case 'LOW_STOCK':
      case 'OUT_OF_STOCK':
        return Icons.inventory_2_outlined;
      case 'PAYMENT_DUE':
      case 'PAYMENT_OVERDUE':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'CRITICAL':
      case 'HIGH':
        return AppColors.danger;
      case 'MEDIUM':
        return AppColors.info;
      default:
        return AppColors.warning;
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
