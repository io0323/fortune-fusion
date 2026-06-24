import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/app_error_widget.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/loading_widget.dart';
import '../../../../../shared/widgets/section_card.dart';
import '../../../fortune/presentation/providers/fortune_provider.dart';
import '../../../meishiki/domain/engines/kyusei_board_calculator.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/direction_result.dart';
import '../../domain/usecases/calculate_direction_usecase.dart';
import '../providers/direction_provider.dart';

class DirectionPage extends ConsumerStatefulWidget {
  const DirectionPage({super.key});

  @override
  ConsumerState<DirectionPage> createState() => _DirectionPageState();
}

class _DirectionPageState extends ConsumerState<DirectionPage> {
  KyuseiBoardType _boardType = KyuseiBoardType.month;
  AsyncValue<DirectionResult>? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _result = const AsyncValue.loading();
    });
    try {
      final profile = await ref.read(currentProfileProvider(1).future);
      if (profile == null) {
        setState(() {
          _result = AsyncValue.error(
            StateError('Profile not found'),
            StackTrace.current,
          );
        });
        return;
      }
      final r = CalculateDirectionUsecase(
        kyuseiEngine: ref.read(kyuseiEngineProvider),
        boardCalculator: ref.read(directionBoardCalculatorProvider),
      ).call(profile, DateTime.now(), boardType: _boardType);
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
      appBar: AppBar(title: const Text('方位鑑定')),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SegmentedButton<KyuseiBoardType>(
              segments: const [
                ButtonSegment(value: KyuseiBoardType.year, label: Text('年盤')),
                ButtonSegment(value: KyuseiBoardType.month, label: Text('月盤')),
                ButtonSegment(value: KyuseiBoardType.day, label: Text('日盤')),
              ],
              selected: {_boardType},
              onSelectionChanged: (s) {
                setState(() => _boardType = s.first);
                _load();
              },
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (_result == null || _result!.isLoading) {
                  return const LoadingWidget();
                }
                if (_result!.hasError) {
                  return AppErrorWidget(error: _result!.error!);
                }
                return _DirectionGrid(_result!.value!.directions);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionGrid extends StatelessWidget {
  const _DirectionGrid(this.directions);

  final List<DirectionInfo> directions;

  static const _gridDirections = [
    '北西', '北', '北東',
    '西', null, '東',
    '南西', '南', '東南',
  ];

  Color _rankColor(DirectionRank rank) {
    return switch (rank) {
      DirectionRank.daikichi => AppColors.primary,
      DirectionRank.kichi => const Color(0xFFC9A961),
      DirectionRank.chuyou => AppColors.secondary,
      DirectionRank.kyo => Colors.orange,
      DirectionRank.daikyo => Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: _gridDirections.map((dirName) {
        if (dirName == null) {
          return Container(
            alignment: Alignment.center,
            child: Text(
              '中',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.secondary,
                  ),
              textAlign: TextAlign.center,
            ),
          );
        }
        final info = directions.where((d) => d.direction == dirName).firstOrNull;
        return SectionCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dirName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: info != null ? _rankColor(info.rank) : AppColors.secondary,
                    ),
                textAlign: TextAlign.center,
              ),
              if (info != null)
                Text(
                  info.reason,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                      ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
