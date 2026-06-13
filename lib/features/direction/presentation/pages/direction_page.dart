import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DirectionPage extends ConsumerWidget {
  const DirectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('吉方位')),
      body: const Center(child: Text('DirectionPage')),
    );
  }
}
