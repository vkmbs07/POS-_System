import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/pos/presentation/pages/pos_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/pos',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/pos',
        builder: (context, state) => const PosPage(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryPage(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsPage(),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/pos';

      return null;
    },
  );
});
