// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/loan_detail_screen.dart';
import 'screens/payment_screen.dart';

final apiService = ApiService();

void main() {
  runApp(const LoanTrackApp());
}

class LoanTrackApp extends StatelessWidget {
  const LoanTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LoanTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (ctx, _) => const LoginScreen()),
    GoRoute(path: '/dashboard', builder: (ctx, _) => const DashboardScreen()),
    GoRoute(
      path: '/loans/:id',
      builder: (ctx, state) => LoanDetailScreen(
        loanId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/loans/:id/pay',
      builder: (ctx, state) => PaymentScreen(
        loanId: int.parse(state.pathParameters['id']!),
      ),
    ),
  ],
);
