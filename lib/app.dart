import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/compatibility/presentation/pages/compatibility_page.dart';
import 'features/direction/presentation/pages/direction_page.dart';
import 'features/fortune/presentation/pages/daily_fortune_page.dart';
import 'features/fortune/presentation/pages/fortune_home_page.dart';
import 'features/fortune/presentation/pages/monthly_fortune_page.dart';
import 'features/fortune/presentation/pages/integrated_reading_page.dart';
import 'features/fortune/presentation/pages/yearly_fortune_page.dart';
import 'features/meishiki/presentation/pages/meishiki_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

final _router = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _ShellScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (_, __) => const FortuneHomePage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/meishiki', builder: (_, __) => const MeishikiPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/compatibility',
              builder: (_, __) => const CompatibilityPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/direction', builder: (_, __) => const DirectionPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/settings', builder: (_, __) => const SettingsPage()),
        ]),
      ],
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
    GoRoute(path: '/daily', builder: (_, __) => const DailyFortunePage()),
    GoRoute(path: '/monthly', builder: (_, __) => const MonthlyFortunePage()),
    GoRoute(path: '/yearly', builder: (_, __) => const YearlyFortunePage()),
    GoRoute(path: '/reading', builder: (_, __) => const IntegratedReadingPage()),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fortune Fusion',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: '命式',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: '相性',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: '方位',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
