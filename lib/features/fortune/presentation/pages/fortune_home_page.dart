import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FortuneHomePage extends ConsumerWidget {
  const FortuneHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fortune Fusion')),
      body: const Center(child: Text('FortuneHomePage')),
    );
  }
}
