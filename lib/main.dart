import 'package:dating_app/presentation/screens/home_screen.dart';
import 'package:dating_app/presentation/features/auth/google_signin/google_signin_screen.dart';
import 'package:dating_app/presentation/features/onboarding/onboarding_flow_screen.dart';
import 'package:dating_app/data/providers/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SparkMatchApp());
}

class SparkMatchApp extends StatelessWidget {
  const SparkMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'SparkMatch',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black54),
          ),
        ),
        home: const OnboardingFlowScreen(),
      ),
    );
    
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while checking auth state
        if (authProvider.isLoading && authProvider.user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show home screen if authenticated, otherwise show sign-in
        return authProvider.isAuthenticated
            ? const HomeScreen()
            : const GoogleSignInScreen();
      },
    );
  }
}
