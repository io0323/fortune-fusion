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

class YearlyFortunePage extends ConsumerWidget {
  const YearlyFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider(1));
    return profileAsync.when(
      loading: () => AppScaffold(
        appBar: AppBar(title: const Text('今年の運勢')),
        child: const LoadingWidget(),
      ),
      error: (e, _) => AppScaffold(
        appBar: AppBar(title: const Text('今年の運勢')),
        child: AppErrorWidget(error: e),
      ),
      data: (profile) {
        if (profile == null) {
          return AppScaffold(
            appBar: AppBar(title: const Text('今年の運勢')),
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
        final now = DateTime.now();
        final yearlyAsync = ref.watch(yearlyFortuneProvider(1, now.year));
        return yearlyAsync.when(
          loading: () => AppScaffold(
            appBar: AppBar(title: const Text('今年の運勢')),
            child: const LoadingWidget(),
          ),
          error: (e, _) => AppScaffold(
            appBar: AppBar(title: const Text('今年の運勢')),
            child: AppErrorWidget(error: e),
          ),
          data: (results) {
            int maxIdx = 0;
            int minIdx = 0;
            for (int i = 1; i < results.length; i++) {
              if (results[i].overall > results[maxIdx].overall) maxIdx = i;
              if (results[i].overall < results[minIdx].overall) minIdx = i;
            }

            return AppScaffold(
              appBar: AppBar(title: const Text('今年の運勢')),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '年間運勢',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'チャンス月: ${maxIdx + 1}月 ★',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.primary,
                                      ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '注意月: ${minIdx + 1}月',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.red.shade400,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '月別総合運',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 100,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(results.length, (i) {
                                final result = results[i];
                                final barHeight = result.overall / 5 * 60;
                                final Color barColor;
                                if (result.advice.contains('チャンス')) {
                                  barColor = AppColors.primary;
                                } else if (result.advice.contains('注意')) {
                                  barColor = Colors.red.shade400;
                                } else {
                                  barColor = AppColors.secondary.withOpacity(0.6);
                                }
                                return Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: barHeight,
                                        decoration: BoxDecoration(
                                          color: barColor,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      Text(
                                        '${i + 1}月',
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
