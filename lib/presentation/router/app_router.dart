import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/email_verification_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/trousseau/trousseau_detail_screen.dart';
import '../screens/trousseau/create_trousseau_screen.dart';
import '../screens/trousseau/edit_trousseau_screen.dart';
import '../screens/trousseau/share_trousseau_screen.dart';
import '../screens/trousseau/trousseau_management_screen.dart';
import '../screens/product/product_list_screen.dart';
import '../screens/product/add_product_screen.dart';
import '../screens/product/edit_product_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/product/category_management_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/theme_settings_screen.dart';
import '../screens/settings/change_password_screen.dart';
import '../screens/settings/feedback_screen.dart';
import '../screens/settings/feedback_history_screen.dart';
import '../screens/settings/kac_saat_settings_screen.dart';
import '../screens/trousseau/shared_trousseau_list_screen.dart';
import '../screens/onboarding/new_onboarding_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  
  static String? _lastRedirect;
  static DateTime? _lastRedirectTime;
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) async {
      // Debounce: aynı redirect'ı 500ms içinde tekrar yapma
      final now = DateTime.now();
      if (_lastRedirect != null && _lastRedirect == state.matchedLocation && _lastRedirectTime != null && now.difference(_lastRedirectTime!).inMilliseconds < 500) {
        return null;
      }

      String currentLoc = state.matchedLocation;

      // ═════════════════════════════════════════════════════════════════
      // ONBOARDING CHECK
      // İlk kez açan kullanıcılar için onboarding göster
      // ═════════════════════════════════════════════════════════════════
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      
      if (!onboardingCompleted && currentLoc != '/onboarding') {
        _lastRedirect = '/onboarding';
        _lastRedirectTime = now;
        return '/onboarding';
      }

      // Auth
      final user = FirebaseAuth.instance.currentUser;
      final isAuthenticated = user != null;
      final isAuthRoute = currentLoc == '/login' ||
          currentLoc == '/register' ||
          currentLoc == '/forgot-password' ||
          currentLoc == '/onboarding' ||
          currentLoc.startsWith('/verify-email');

      // Email verification
      if (isAuthenticated && !user.emailVerified) {
        final encodedEmail = Uri.encodeComponent(user.email ?? '');
        if (!currentLoc.startsWith('/verify-email')) {
          _lastRedirect = '/verify-email/$encodedEmail';
          _lastRedirectTime = now;
          return '/verify-email/$encodedEmail';
        }
        return null;
      }

      // Not authenticated
      if (!isAuthenticated && !isAuthRoute) {
        _lastRedirect = '/login';
        _lastRedirectTime = now;
        return '/login';
      }

      // Authenticated and on auth route
      if (isAuthenticated && isAuthRoute && user.emailVerified) {
        _lastRedirect = '/';
        _lastRedirectTime = now;
        return '/';
      }

      _lastRedirect = null;
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Trousseau routes
          GoRoute(
            path: 'create-trousseau',
            builder: (context, state) => const CreateTrousseauScreen(),
          ),
          GoRoute(
            path: 'trousseau/:id',
            builder: (context, state) {
              final trousseauId = state.pathParameters['id']!;
              final hideSelector = state.uri.queryParameters['hideSelector'] == 'true';
              return TrousseauDetailScreen(
                trousseauId: trousseauId,
                hideSelector: hideSelector,
              );
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
                path: 'manage',
                builder: (context, state) {
                  final trousseauId = state.pathParameters['id']!;
                  return TrousseauManagementScreen(trousseauId: trousseauId);
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
                    path: 'categories',
                    builder: (context, state) {
                      final trousseauId = state.pathParameters['id']!;
                      return CategoryManagementScreen(trousseauId: trousseauId);
                    },
                  ),
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
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'theme',
                builder: (context, state) => const ThemeSettingsScreen(),
              ),
              GoRoute(
                path: 'change-password',
                builder: (context, state) => const ChangePasswordScreen(),
              ),
              GoRoute(
                path: 'kac-saat',
                builder: (context, state) => const KacSaatSettingsScreen(),
              ),
              GoRoute(
                path: 'feedback',
                builder: (context, state) => const FeedbackScreen(),
                routes: [
                  GoRoute(
                    path: 'history',
                    builder: (context, state) => const FeedbackHistoryScreen(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'shared-trousseaus',
            builder: (context, state) => const SharedTrousseauListScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const NewOnboardingScreen(),
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
      GoRoute(
        path: '/verify-email/:email',
        builder: (context, state) {
          final email = state.pathParameters['email']!;
          return EmailVerificationScreen(email: Uri.decodeComponent(email));
        },
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

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}