import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/compatibility_provider.dart';

class CompatibilityPage extends ConsumerWidget {
  const CompatibilityPage({
    super.key,
    this.profileAId = 1,
    this.profileBId = 2,
  });

  final int profileAId;
  final int profileBId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(compatibilityProvider(profileAId, profileBId));
    return Scaffold(
      appBar: AppBar(title: const Text('相性診断')),
      body: result.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (r) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ScoreRow('恋愛', r.loveScore, r.loveStars),
            _ScoreRow('仕事', r.workScore, r.workStars),
            _ScoreRow('友情', r.friendScore, r.friendStars),
          ],
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow(this.label, this.score, this.stars);

  final String label;
  final int score;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text('${'★' * stars}${'☆' * (5 - stars)}'),
      trailing: Text('$score点'),
    );
  }
}
