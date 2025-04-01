import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(
          name: 'login',
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          name: 'register',
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          name: 'main',
          path: '/main',
          builder: (context, state) => MainScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      title: 'Train App',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
