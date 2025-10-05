import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/trousseau/trousseau_list_screen.dart';
import '../screens/trousseau/trousseau_detail_screen.dart';
import '../screens/trousseau/create_trousseau_screen.dart';
import '../screens/trousseau/edit_trousseau_screen.dart';
import '../screens/trousseau/share_trousseau_screen.dart';
import '../screens/product/product_list_screen.dart';
import '../screens/product/add_product_screen.dart';
import '../screens/product/edit_product_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/profile_screen.dart';
import '../screens/settings/theme_settings_screen.dart';
import '../screens/settings/change_password_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';
      
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }
      
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'trousseau',
            builder: (context, state) => const TrousseauListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateTrousseauScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final trousseauId = state.pathParameters['id']!;
                  return TrousseauDetailScreen(trousseauId: trousseauId);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final trousseauId = state.pathParameters['id']!;
                      return EditTrousseauScreen(trousseauId: trousseauId);
                    },
                  ),
                  GoRoute(
                    path: 'share',
                    builder: (context, state) {
                      final trousseauId = state.pathParameters['id']!;
                      return ShareTrousseauScreen(trousseauId: trousseauId);
                    },
                  ),
                  GoRoute(
                    path: 'products',
                    builder: (context, state) {
                      final trousseauId = state.pathParameters['id']!;
                      return ProductListScreen(trousseauId: trousseauId);
                    },
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (context, state) {
                          final trousseauId = state.pathParameters['id']!;
                          return AddProductScreen(trousseauId: trousseauId);
                        },
                      ),
                      GoRoute(
                        path: ':productId',
                        builder: (context, state) {
                          final trousseauId = state.pathParameters['id']!;
                          final productId = state.pathParameters['productId']!;
                          return ProductDetailScreen(
                            trousseauId: trousseauId,
                            productId: productId,
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'edit',
                            builder: (context, state) {
                              final trousseauId = state.pathParameters['id']!;
                              final productId = state.pathParameters['productId']!;
                              return EditProductScreen(
                                trousseauId: trousseauId,
                                productId: productId,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: 'theme',
                builder: (context, state) => const ThemeSettingsScreen(),
              ),
              GoRoute(
                path: 'change-password',
                builder: (context, state) => const ChangePasswordScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Sayfa bulunamadı',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Bilinmeyen hata',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );
}