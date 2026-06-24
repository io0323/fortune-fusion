import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/app_error_widget.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../../../shared/widgets/section_card.dart';
import '../../../../../shared/widgets/star_rating.dart';
import '../../../fortune/presentation/providers/fortune_provider.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/compatibility_result.dart';
import '../../domain/usecases/calculate_compatibility_usecase.dart';

class CompatibilityPage extends ConsumerStatefulWidget {
  const CompatibilityPage({super.key});

  @override
  ConsumerState<CompatibilityPage> createState() => _CompatibilityPageState();
}

class _CompatibilityPageState extends ConsumerState<CompatibilityPage> {
  final _yearCtrl = TextEditingController();
  final _monthCtrl = TextEditingController();
  final _dayCtrl = TextEditingController();
  bool _hasTime = false;
  final _hourCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  AsyncValue<CompatibilityResult>? _result;

  @override
  void dispose() {
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  Future<void> _diagnose() async {
    final year = int.tryParse(_yearCtrl.text);
    final month = int.tryParse(_monthCtrl.text);
    final day = int.tryParse(_dayCtrl.text);
    if (year == null || month == null || day == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('生年月日を入力してください')),
      );
      return;
    }
    final hour = _hasTime ? int.tryParse(_hourCtrl.text) : null;
    final min = _hasTime ? int.tryParse(_minCtrl.text) : null;
    final now = DateTime.now();
    final partnerBirthTime =
        _hasTime && hour != null && min != null ? DateTime(year, month, day, hour, min) : null;
    final partnerProfile = Profile(
      id: -1,
      nickname: '相手',
      gender: 'unknown',
      birthDate: DateTime(year, month, day),
      birthTime: partnerBirthTime,
      birthPlace: '',
      birthLat: 0,
      birthLng: 0,
      createdAt: now,
      updatedAt: now,
    );
    final userProfile = await ref.read(currentProfileProvider(1).future);
    if (userProfile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('プロフィールを登録してください')),
        );
      }
      return;
    }
    setState(() {
      _result = const AsyncValue.loading();
    });
    try {
      final usecase = CalculateCompatibilityUsecase(
        shichuEngine: ref.read(shichuEngineProvider),
        seizaEngine: ref.read(seizaEngineProvider),
        kyuseiEngine: ref.read(kyuseiEngineProvider),
      );
      final r = usecase.call(userProfile, partnerProfile);
      setState(() {
        _result = AsyncValue.data(r);
      });
    } catch (e, st) {
      setState(() {
        _result = AsyncValue.error(e, st);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('相性診断')),
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
                    '相手の生年月日',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _yearCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: '年'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _monthCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: '月'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _dayCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: '日'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Switch(
                        value: _hasTime,
                        onChanged: (v) => setState(() => _hasTime = v),
                      ),
                      Text('出生時刻あり', style: Theme.of(context).textTheme.bodyMedium),
                      if (_hasTime) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _hourCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '時'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _minCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '分'),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _diagnose,
                    child: const Text('診断する'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_result == null) const SizedBox.shrink(),
            if (_result != null && _result!.isLoading) const LoadingWidget(),
            if (_result != null && _result!.hasError)
              AppErrorWidget(error: _result!.error!),
            if (_result != null && _result!.hasValue) ...[
              if (_result!.value!.isPartnerTimeUncertain)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '※出生時刻不明のため恋愛相性の精度が低下します',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondary,
                        ),
                  ),
                ),
              _CompatCard(
                label: '恋愛',
                score: _result!.value!.loveScore,
                stars: _result!.value!.loveStars,
                comment: _result!.value!.loveComment,
              ),
              const SizedBox(height: 12),
              _CompatCard(
                label: '仕事',
                score: _result!.value!.workScore,
                stars: _result!.value!.workStars,
                comment: _result!.value!.workComment,
              ),
              const SizedBox(height: 12),
              _CompatCard(
                label: '友人',
                score: _result!.value!.friendScore,
                stars: _result!.value!.friendStars,
                comment: _result!.value!.friendComment,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompatCard extends StatelessWidget {
  const _CompatCard({
    required this.label,
    required this.score,
    required this.stars,
    required this.comment,
  });

  final String label;
  final int score;
  final int stars;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              StarRating(rating: stars.toDouble(), size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(80, 80),
                    painter: _RingPainter(score),
                  ),
                  Text(
                    '$score%',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.score);

  final int score;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawArc(rect, 0, 2 * pi, false, bgPaint);

    final progressPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -pi / 2,
      score / 100 * 2 * pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.score != score;
}
