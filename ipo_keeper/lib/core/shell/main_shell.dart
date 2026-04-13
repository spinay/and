import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/list')) return 1;
    if (location.startsWith('/my')) return 2;
    if (location.startsWith('/profit')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    const paths = ['/home', '/list', '/my', '/profit'];
    context.go(paths[index]);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.list_outlined), activeIcon: Icon(Icons.list), label: '공모주'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), activeIcon: Icon(Icons.bookmark), label: '내 청약'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: '수익'),
        ],
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        backgroundColor: AppColors.surface,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
