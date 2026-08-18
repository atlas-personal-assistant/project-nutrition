import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/space/screens/create_space_screen.dart';
import '../../features/space/screens/join_space_screen.dart';
import '../../features/space/screens/space_detail_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

// Custom Listenable that bridges Riverpod to GoRouter
class AuthRefreshNotifier extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  
  AuthStatus get status => _status;
  
  void update(AuthStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }
}

final authRefreshProvider = Provider<AuthRefreshNotifier>((ref) {
  return AuthRefreshNotifier();
});

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = authNotifier.state;
      final isLoading = authState.status == AuthStatus.loading;
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      
      final isLogin = state.matchedLocation == '/login';
      final isRegister = state.matchedLocation == '/register';
      final isAuthRoute = isLogin || isRegister;
      
      // Während loading: keine Umleitung
      if (isLoading) return null;
      
      // Nicht eingeloggt → Login
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }
      
      // Eingeloggt → Home
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
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
        path: '/space/create',
        builder: (context, state) => const CreateSpaceScreen(),
      ),
      GoRoute(
        path: '/space/join',
        builder: (context, state) => const JoinSpaceScreen(),
      ),
      GoRoute(
        path: '/space/:id',
        builder: (context, state) => SpaceDetailScreen(
          spaceId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});