import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('設定')),
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('プロフィール編集'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Fortune Fusion'),
            subtitle: Text('v1.0.0'),
          ),
        ],
      ),
    );
  }
}
