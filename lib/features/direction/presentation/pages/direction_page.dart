import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/direction_provider.dart';

class DirectionPage extends ConsumerWidget {
  const DirectionPage({
    super.key,
    this.profileId = 1,
  });

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(directionProvider(profileId, DateTime.now()));
    return Scaffold(
      appBar: AppBar(title: const Text('吉方位')),
      body: result.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (r) => ListView(
          padding: const EdgeInsets.all(16),
          children: r.directions.map((d) {
            return ListTile(
              title: Text(d.direction),
              subtitle: Text(d.reason),
              trailing: Text(d.rank.name),
            );
          }).toList(),
        ),
      ),
    );
  }
}
