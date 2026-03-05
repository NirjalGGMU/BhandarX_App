import 'package:bhandarx_flutter/features/workspace/data/repositories/workspace_repository.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/_records_list_page.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/record_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchasesPage extends ConsumerWidget {
  static const routeName = '/workspace/purchases';

  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RecordsListPage(
      title: 'Purchases',
      loader: () async {
        final result =
            await ref.read(workspaceRepositoryProvider).getPurchases();
        return result.fold((l) => throw Exception(l.message), (r) => r);
      },
      onItemTap: (context, item) async {
        final detailResult = await ref
            .read(workspaceRepositoryProvider)
            .getPurchaseById(item.id);
        if (!context.mounted) {
          return;
        }
        detailResult.fold(
          (failure) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message))),
          (record) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RecordDetailPage(title: 'Purchase Detail', record: record),
            ),
          ),
        );
      },
    );
  }
}
