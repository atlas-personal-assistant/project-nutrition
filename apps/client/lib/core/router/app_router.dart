import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/space/screens/create_space_screen.dart';
import '../../features/space/screens/join_space_screen.dart';
import '../../features/space/screens/space_detail_screen.dart';
import '../storage/secure_storage.dart';

// Router state
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final isLoggedIn = await SecureStorage().isLoggedIn();
      final isAuthRoute = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register';
      
      // Not logged in and trying to access protected route
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      
      // Logged in and trying to access auth routes
      if (isLoggedIn && isAuthRoute) {
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