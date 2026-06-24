import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/app_error_widget.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../../../shared/widgets/section_card.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/fortune_provider.dart';

class IntegratedReadingPage extends ConsumerWidget {
  const IntegratedReadingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider(1));
    return profileAsync.when(
      loading: () => AppScaffold(
        appBar: AppBar(title: const Text('統合鑑定')),
        child: const LoadingWidget(),
      ),
      error: (e, _) => AppScaffold(
        appBar: AppBar(title: const Text('統合鑑定')),
        child: AppErrorWidget(error: e),
      ),
      data: (profile) {
        if (profile == null) {
          return AppScaffold(
            appBar: AppBar(title: const Text('統合鑑定')),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline, size: 64, color: AppColors.secondary),
                  const SizedBox(height: 16),
                  Text(
                    'プロフィールを登録してください',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/profile'),
                    child: const Text('プロフィール登録'),
                  ),
                ],
              ),
            ),
          );
        }
        final readingAsync = ref.watch(integratedReadingProvider(1));
        return readingAsync.when(
          loading: () => AppScaffold(
            appBar: AppBar(title: const Text('統合鑑定')),
            child: const LoadingWidget(),
          ),
          error: (e, _) => AppScaffold(
            appBar: AppBar(title: const Text('統合鑑定')),
            child: AppErrorWidget(error: e),
          ),
          data: (reading) {
            final tabs = [
              (label: '性格', items: reading.personality),
              (label: '適職', items: reading.aptitude),
              (label: '恋愛', items: reading.love),
              (label: '金運', items: reading.money),
              (label: '健康', items: reading.health),
            ];
            return DefaultTabController(
              length: 5,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('統合鑑定'),
                  bottom: TabBar(
                    tabs: tabs.map((t) => Tab(text: t.label)).toList(),
                  ),
                ),
                body: TabBarView(
                  children: tabs.map((t) {
                    if (t.items.isEmpty) {
                      return Center(
                        child: Text(
                          'データがありません',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.secondary,
                              ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: t.items.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: SectionCard(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    t.items[i],
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
