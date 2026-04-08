import 'package:go_router/go_router.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/ipo_list/ipo_list_screen.dart';
import '../../presentation/ipo_detail/ipo_detail_screen.dart';
import '../../presentation/my_ipo/my_ipo_screen.dart';
import '../../presentation/calendar/calendar_screen.dart';
import '../../presentation/profit/profit_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../shell/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (ctx, _) => const HomeScreen()),
        GoRoute(path: '/list', builder: (ctx, _) => const IPOListScreen()),
        GoRoute(path: '/my', builder: (ctx, _) => const MyIPOScreen()),
        GoRoute(path: '/calendar', builder: (ctx, _) => const CalendarScreen()),
        GoRoute(path: '/profit', builder: (ctx, _) => const ProfitScreen()),
      ],
    ),
    GoRoute(
      path: '/detail/:id',
      builder: (ctx, state) =>
          IPODetailScreen(ipoId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/settings', builder: (ctx, _) => const SettingsScreen()),
  ],
);
