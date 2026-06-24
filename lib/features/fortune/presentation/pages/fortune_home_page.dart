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

class FortuneHomePage extends ConsumerWidget {
  const FortuneHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider(1));
    return profileAsync.when(
      loading: () => const AppScaffold(child: LoadingWidget()),
      error: (e, _) => AppScaffold(child: AppErrorWidget(error: e)),
      data: (profile) {
        if (profile == null) {
          return AppScaffold(
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
        final today = DateTime.now();
        final dailyAsync = ref.watch(dailyFortuneProvider(1, today));
        return dailyAsync.when(
          loading: () => const AppScaffold(child: LoadingWidget()),
          error: (e, _) => AppScaffold(child: AppErrorWidget(error: e)),
          data: (daily) {
            return AppScaffold(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'こんにちは、${profile.nickname}さん',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          '${today.year}年 ${today.month}月${today.day}日',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.secondary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SectionCard(
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              '今日の総合運',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.secondary,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: StarRating(
                              rating: daily.result.overall.toDouble(),
                              size: 36,
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
                            'カテゴリ別運勢',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          _CategoryRow(label: '仕事', stars: daily.result.work),
                          _CategoryRow(label: '金運', stars: daily.result.money),
                          _CategoryRow(label: '恋愛', stars: daily.result.love),
                          _CategoryRow(label: '健康', stars: daily.result.health),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push('/meishiki'),
                            child: SectionCard(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.auto_awesome, size: 32, color: AppColors.primary),
                                  const SizedBox(height: 8),
                                  Text(
                                    '命式を見る',
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push('/compatibility'),
                            child: SectionCard(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.favorite, size: 32, color: AppColors.primary),
                                  const SizedBox(height: 8),
                                  Text(
                                    '相性を見る',
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),
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
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        StarRating(rating: stars.toDouble(), size: 18),
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
