import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompatibilityPage extends ConsumerWidget {
  const CompatibilityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('相性診断')),
      body: const Center(child: Text('CompatibilityPage')),
    );
  }
}
