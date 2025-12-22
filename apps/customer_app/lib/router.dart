import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'src/features/auth/login_screen.dart';
import 'src/features/auth/register_screen.dart';
import 'src/features/cart/cart_screen.dart';
import 'src/features/cart/checkout_screen.dart';
import 'src/features/home/home_screen.dart';
import 'src/features/onboarding/onboarding_screen.dart';
import 'src/features/orders/orders_screen.dart';
import 'src/features/profile/profile_screen.dart';
import 'src/features/restaurant/restaurant_screen.dart';
import 'src/features/tracking/tracking_screen.dart';
import 'src/services/providers/auth_providers.dart';
import 'src/widgets/bottom_navigation_shell.dart';

final onboardingCompletedProvider = StateProvider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    initialLocation: onboardingCompleted ? '/home' : '/onboarding',
    refreshListenable: _RouterRefresh(ref),
    routes: [
      GoRoute(
        path: '/onboarding',
        name: OnboardingScreen.routeName,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: RegisterScreen.routeName,
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => BottomNavigationShell(shell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: HomeScreen.routeName,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'restaurants/:id',
                    name: RestaurantScreen.routeName,
                    builder: (context, state) => RestaurantScreen(
                      restaurantId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'cart',
                    name: CartScreen.routeName,
                    builder: (context, state) => const CartScreen(),
                    routes: [
                      GoRoute(
                        path: 'checkout',
                        name: CheckoutScreen.routeName,
                        builder: (context, state) => const CheckoutScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                name: OrdersScreen.routeName,
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: ProfileScreen.routeName,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/tracking/:id',
        name: TrackingScreen.routeName,
        builder: (context, state) => TrackingScreen(orderId: state.pathParameters['id']!),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isAuth = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final isOnboarding = state.matchedLocation == '/onboarding';
      
      // Se não completou onboarding e não está na tela de onboarding
      if (!onboardingCompleted && !isOnboarding && !isAuthRoute) {
        return '/onboarding';
      }
      
      // Se completou onboarding mas está na tela de onboarding
      if (onboardingCompleted && isOnboarding) {
        return isAuth ? '/home' : '/login';
      }
      
      // Se não está autenticado e tenta acessar rotas protegidas
      if (!isAuth && !isAuthRoute && !isOnboarding) {
        return '/login';
      }
      
      // Se está autenticado e tenta acessar login/register
      if (isAuth && isAuthRoute) {
        return '/home';
      }
      
      return null;
    },
  );
});

String _getInitialLocation(bool onboardingCompleted, bool isAuthenticated) {
  if (!onboardingCompleted) return '/onboarding';
  if (!isAuthenticated) return '/login';
  return '/home';
}

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this.ref) {
    ref.listen<bool>(onboardingCompletedProvider, (_, __) => notifyListeners());
    ref.listen<AuthState>(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
