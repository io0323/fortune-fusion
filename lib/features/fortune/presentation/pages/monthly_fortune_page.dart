import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MonthlyFortunePage extends ConsumerWidget {
  const MonthlyFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('今月の運勢')),
      body: const Center(child: Text('MonthlyFortunePage')),
    );
  }
}
