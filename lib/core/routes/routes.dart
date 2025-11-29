import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/pos/presentation/pages/pos_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/inventory/presentation/pages/add_edit_product_page.dart';
import '../../features/pos/data/models/product.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/data/repositories/firebase_auth_repository.dart';

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
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/pos',
        builder: (context, state) => const PosPage(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryPage(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddEditProductPage(),
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final product = state.extra as Product;
              return AddEditProductPage(product: product);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsPage(),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSigningUp = state.uri.toString() == '/signup';

      if (authState.isLoading) return null; // Wait for auth state to determine

      if (!isLoggedIn && !isLoggingIn && !isSigningUp) return '/login';
      if (isLoggedIn && (isLoggingIn || isSigningUp)) return '/pos';

      return null;
    },
  );
});
