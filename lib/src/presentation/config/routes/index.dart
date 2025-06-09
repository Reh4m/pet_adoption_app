import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/presentation/config/routes/auth_guard.dart';
import 'package:pet_adoption_app/src/presentation/screens/auth/email_verification_screen.dart';
import 'package:pet_adoption_app/src/presentation/screens/auth/forgot_password_screen.dart';
import 'package:pet_adoption_app/src/presentation/screens/auth/sign_in_screen.dart';
import 'package:pet_adoption_app/src/presentation/screens/auth/sign_up_screen.dart';
import 'package:pet_adoption_app/src/presentation/screens/onboarding/index.dart';
import 'package:pet_adoption_app/src/presentation/screens/pets/details/index.dart';
import 'package:pet_adoption_app/src/presentation/screens/pets/registration/index.dart';
import 'package:pet_adoption_app/src/presentation/screens/root_screen.dart';
import 'package:pet_adoption_app/src/presentation/screens/user/profile/edit_profile_screen.dart';
import 'package:pet_adoption_app/src/presentation/screens/user/profile/edit_user_settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    redirect: authGuard,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/email-verification',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const RootScreen()),
      GoRoute(
        path: '/pet-registration',
        builder: (context, state) => const PetRegistrationScreen(),
      ),
      GoRoute(
        path: '/pets/:petId',
        builder:
            (context, state) =>
                PetDetailsScreen(petId: state.pathParameters['petId']!),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) {
          final user =
              state.extra != null ? (state.extra as Map)['user'] : null;

          if (user == null) {
            return const Scaffold(
              body: Center(child: Text('No se pudo cargar el perfil')),
            );
          }

          return EditProfileScreen(user: user);
        },
      ),
      GoRoute(
        path: '/profile/settings',
        builder: (context, state) {
          final user =
              state.extra != null ? (state.extra as Map)['user'] : null;

          if (user == null) {
            return const Scaffold(
              body: Center(child: Text('No se pudo cargar el perfil')),
            );
          }

          return EditUserSettingsScreen(user: user);
        },
      ),
    ],
  );
}
