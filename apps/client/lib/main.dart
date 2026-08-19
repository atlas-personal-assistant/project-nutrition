import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/space/screens/create_space_screen.dart';
import 'features/space/screens/join_space_screen.dart';
import 'features/space/screens/space_detail_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait for now
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const ProviderScope(child: MyApp()));
}

// Global refresh notifier for GoRouter
final _routerRefreshNotifier = ValueNotifier<AuthStatus>(AuthStatus.initial);

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    
    // Initiales Auth-Check beim App-Start
    // Verzögert, damit Provider bereits initialisiert ist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).checkAuthStatus();
    });
    
    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: _routerRefreshNotifier,
      redirect: (context, state) {
        final authState = _routerRefreshNotifier.value;
        final isLoading = authState == AuthStatus.loading;
        final isAuthenticated = authState == AuthStatus.authenticated;
        
        final isLogin = state.matchedLocation == '/login';
        final isRegister = state.matchedLocation == '/register';
        final isAuthRoute = isLogin || isRegister;
        
        if (isLoading) return null;
        if (!isAuthenticated && !isAuthRoute) return '/login';
        if (isAuthenticated && isAuthRoute) return '/';
        
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
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth changes and update the global notifier
    final authState = ref.watch(authProvider).state;
    
    // Update notifier when auth changes (triggers GoRouter redirect)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_routerRefreshNotifier.value != authState.status) {
        _routerRefreshNotifier.value = authState.status;
      }
    });

    return MaterialApp.router(
      title: 'Project Nutrition',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}