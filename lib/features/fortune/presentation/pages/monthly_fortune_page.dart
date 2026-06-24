import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/app_error_widget.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../../../shared/widgets/section_card.dart';
import '../../../../../shared/widgets/star_rating.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/fortune_provider.dart';

class MonthlyFortunePage extends ConsumerWidget {
  const MonthlyFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider(1));
    return profileAsync.when(
      loading: () => AppScaffold(
        appBar: AppBar(title: const Text('今月の運勢')),
        child: const LoadingWidget(),
      ),
      error: (e, _) => AppScaffold(
        appBar: AppBar(title: const Text('今月の運勢')),
        child: AppErrorWidget(error: e),
      ),
      data: (profile) {
        if (profile == null) {
          return AppScaffold(
            appBar: AppBar(title: const Text('今月の運勢')),
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
        final monthlyAsync = ref.watch(monthlyFortuneProvider(1, now.year, now.month));
        return monthlyAsync.when(
          loading: () => AppScaffold(
            appBar: AppBar(title: const Text('今月の運勢')),
            child: const LoadingWidget(),
          ),
          error: (e, _) => AppScaffold(
            appBar: AppBar(title: const Text('今月の運勢')),
            child: AppErrorWidget(error: e),
          ),
          data: (results) {
            final avgOverall = results.isEmpty
                ? 0.0
                : results.map((r) => r.overall).reduce((a, b) => a + b) / results.length;
            final avgLove = results.isEmpty
                ? 0.0
                : results.map((r) => r.love).reduce((a, b) => a + b) / results.length;
            final avgWork = results.isEmpty
                ? 0.0
                : results.map((r) => r.work).reduce((a, b) => a + b) / results.length;
            final avgMoney = results.isEmpty
                ? 0.0
                : results.map((r) => r.money).reduce((a, b) => a + b) / results.length;

            return AppScaffold(
              appBar: AppBar(title: const Text('今月の運勢')),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionCard(
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              '${now.year}年${now.month}月',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.secondary,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _CategoryRow(label: '総合', stars: avgOverall),
                          _CategoryRow(label: '恋愛', stars: avgLove),
                          _CategoryRow(label: '仕事', stars: avgWork),
                          _CategoryRow(label: '金運', stars: avgMoney),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '日別運勢',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: results.length,
                            itemBuilder: (context, i) {
                              return Row(
                                children: [
                                  Text(
                                    '${i + 1}日',
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                  const Spacer(),
                                  StarRating(
                                    rating: results[i].overall.toDouble(),
                                    size: 14,
                                  ),
                                ],
                              );
                            },
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

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.label, required this.stars});

  final String label;
  final double stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        StarRating(rating: stars, size: 18),
      ],
    );
  }
}
