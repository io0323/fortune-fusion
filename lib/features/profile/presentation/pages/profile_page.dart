import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_form_widget.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider(1));
    final saveState = ref.watch(profileNotifierProvider);

    ref.listen(profileNotifierProvider, (_, next) {
      if (next is AsyncData<dynamic> && next.value != null) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      }
    });

    final isSaving = saveState is AsyncLoading;

    return AppScaffold(
      appBar: AppBar(title: const Text('プロフィール')),
      child: profileAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, st) => AppErrorWidget(
          error: e,
          onRetry: () => ref.invalidate(currentProfileProvider(1)),
        ),
        data: (profile) => ProfileFormWidget(
          initialProfile: profile,
          isSaving: isSaving,
          onSave: (p) =>
              ref.read(profileNotifierProvider.notifier).save(p),
        ),
      ),
    );
  }
}
