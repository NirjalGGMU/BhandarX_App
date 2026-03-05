import 'package:bhandarx_flutter/features/workspace/data/repositories/workspace_repository.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/_records_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoriesPage extends ConsumerWidget {
  static const routeName = '/workspace/categories';

  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RecordsListPage(
      title: 'Categories',
      loader: () async {
        final result =
            await ref.read(workspaceRepositoryProvider).getCategories();
        return result.fold((l) => throw Exception(l.message), (r) => r);
      },
    );
  }
}
