import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class YearlyFortunePage extends ConsumerWidget {
  const YearlyFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('今年の運勢')),
      body: const Center(child: Text('YearlyFortunePage')),
    );
  }
}
