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

class DailyFortunePage extends ConsumerWidget {
  const DailyFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider(1));
    return profileAsync.when(
      loading: () => const AppScaffold(
        appBar: null,
        child: LoadingWidget(),
      ),
      error: (e, _) => AppScaffold(
        appBar: AppBar(title: const Text('今日の運勢')),
        child: AppErrorWidget(error: e),
      ),
      data: (profile) {
        if (profile == null) {
          return AppScaffold(
            appBar: AppBar(title: const Text('今日の運勢')),
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
        final dailyAsync = ref.watch(dailyFortuneProvider(1, now));
        return dailyAsync.when(
          loading: () => AppScaffold(
            appBar: AppBar(title: const Text('今日の運勢')),
            child: const LoadingWidget(),
          ),
          error: (e, _) => AppScaffold(
            appBar: AppBar(title: const Text('今日の運勢')),
            child: AppErrorWidget(error: e),
          ),
          data: (daily) {
            return AppScaffold(
              appBar: AppBar(title: const Text('今日の運勢')),
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
                              '${daily.date.year}年 ${daily.date.month}月${daily.date.day}日',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.secondary,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: StarRating(
                              rating: daily.result.overall.toDouble(),
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              daily.result.advice,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
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
                            'カテゴリ詳細',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            label: '仕事',
                            stars: daily.result.work,
                            comment: '集中力が高まる日。重要な仕事に取り組むのに最適です。',
                          ),
                          _DetailRow(
                            label: '金運',
                            stars: daily.result.money,
                            comment: '財運安定。計画的な支出を心がけましょう。',
                          ),
                          _DetailRow(
                            label: '恋愛',
                            stars: daily.result.love,
                            comment: '人間関係が円滑になる日。素直な気持ちを伝えて。',
                          ),
                          _DetailRow(
                            label: '健康',
                            stars: daily.result.health,
                            comment: '体調管理に注意。早めの就寝を心がけて。',
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
                            'ラッキー情報',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'カラー',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppColors.secondary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: _luckyColor(daily.result.luckyColor),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        daily.result.luckyColor,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '数字',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppColors.secondary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${daily.result.luckyNumber}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: AppColors.primary,
                                        ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '方角',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppColors.secondary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    daily.result.luckyDirection,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.stars,
    required this.comment,
  });

  final String label;
  final int stars;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            StarRating(rating: stars.toDouble(), size: 18),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Text(
            comment,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondary,
                ),
          ),
        ),
      ],
    );
  }
}

Color _luckyColor(String color) {
  return switch (color) {
    '緑' => Colors.green.shade400,
    '赤' => Colors.red.shade400,
    '黄' => Colors.amber.shade400,
    '白' => Colors.grey.shade200,
    '黒' => Colors.grey.shade800,
    _ => AppColors.primary,
  };
}
