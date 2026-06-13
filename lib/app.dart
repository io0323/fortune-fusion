import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/compatibility/presentation/pages/compatibility_page.dart';
import 'features/direction/presentation/pages/direction_page.dart';
import 'features/fortune/presentation/pages/daily_fortune_page.dart';
import 'features/fortune/presentation/pages/fortune_home_page.dart';
import 'features/fortune/presentation/pages/monthly_fortune_page.dart';
import 'features/fortune/presentation/pages/yearly_fortune_page.dart';
import 'features/meishiki/presentation/pages/meishiki_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const FortuneHomePage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (_, __) => const ProfilePage(),
    ),
    GoRoute(
      path: '/meishiki',
      builder: (_, __) => const MeishikiPage(),
    ),
    GoRoute(
      path: '/daily',
      builder: (_, __) => const DailyFortunePage(),
    ),
    GoRoute(
      path: '/monthly',
      builder: (_, __) => const MonthlyFortunePage(),
    ),
    GoRoute(
      path: '/yearly',
      builder: (_, __) => const YearlyFortunePage(),
    ),
    GoRoute(
      path: '/compatibility',
      builder: (_, __) => const CompatibilityPage(),
    ),
    GoRoute(
      path: '/direction',
      builder: (_, __) => const DirectionPage(),
    ),
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
      routerConfig: _router,
    );
  }
}
