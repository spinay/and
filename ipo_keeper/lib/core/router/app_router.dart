import 'package:go_router/go_router.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/ipo_list/ipo_list_screen.dart';
import '../../presentation/ipo_detail/ipo_detail_screen.dart';
import '../../presentation/my_ipo/my_ipo_screen.dart';
import '../../presentation/calendar/calendar_screen.dart';
import '../../presentation/profit/profit_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/subscription_form/subscription_form_screen.dart';
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
    // 신규 청약 기록 추가. 선택적으로 ?ipoId=... 로 종목 프리픽스 가능.
    GoRoute(
      path: '/subscription/new',
      builder: (ctx, state) => SubscriptionFormScreen(
        initialIpoId: state.uri.queryParameters['ipoId'],
      ),
    ),
    // 수정. ?focus=allocation|sale 로 진입 섹션 지정 가능.
    GoRoute(
      path: '/subscription/edit/:id',
      builder: (ctx, state) => SubscriptionFormScreen(
        editingId: int.parse(state.pathParameters['id']!),
        initialFocus:
            _parseFocus(state.uri.queryParameters['focus']),
      ),
    ),
    GoRoute(path: '/settings', builder: (ctx, _) => const SettingsScreen()),
  ],
);

SubscriptionFormFocus _parseFocus(String? raw) {
  switch (raw) {
    case 'allocation':
      return SubscriptionFormFocus.allocation;
    case 'sale':
      return SubscriptionFormFocus.sale;
    default:
      return SubscriptionFormFocus.basic;
  }
}
