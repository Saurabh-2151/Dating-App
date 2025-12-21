import 'package:dating_app/presentation/screens/home_screen.dart';
import 'package:dating_app/presentation/features/auth/google_signin/google_signin_screen.dart';
import 'package:dating_app/presentation/features/onboarding/onboarding_flow_screen.dart';
import 'package:dating_app/presentation/features/auth/splash/splash_screen.dart';
import 'package:dating_app/data/providers/auth_provider.dart';
import 'package:dating_app/data/providers/onboarding_provider.dart';
import 'package:dating_app/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.cardDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SparkMatchApp());
}

class SparkMatchApp extends StatelessWidget {
  const SparkMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
      ],
      child: MaterialApp(
        title: 'SparkMatch',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
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
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show loading screen while checking auth state
        if (authProvider.isLoading && authProvider.user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show home screen if authenticated (or guest), otherwise show sign-in
        if (authProvider.isGuest) {
          return const HomeScreen();
        }

        if (authProvider.isAuthenticated && !authProvider.hasCompletedOnboarding) {
          return const OnboardingFlowScreen();
        }

        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        return const GoogleSignInScreen();
      },
    );
  }
}
