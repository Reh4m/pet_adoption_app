import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/core/di/index.dart' as di;
import 'package:pet_adoption_app/src/presentation/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';

FutureOr<String?> authGuard(BuildContext context, GoRouterState state) async {
  final firebaseAuth = di.sl<FirebaseAuth>();

  final user = firebaseAuth.currentUser;
  final onboardingProvider = context.read<OnboardingProvider>();
  final hasSeenOnboarding = onboardingProvider.hasSeenOnboarding;

  final publicRoutes = [
    '/onboarding',
    '/login',
    '/register',
    '/forgot-password',
  ];
  final isPublicRoute = publicRoutes.contains(state.uri.path);

  // 1. Has the user seen the onboarding?
  if (!hasSeenOnboarding && state.uri.path != '/onboarding') {
    return '/onboarding';
  }

  // 2. Is the user authenticated?
  if (user == null && !isPublicRoute) {
    return '/login';
  }

  if (user != null) {
    final updatedUser = firebaseAuth.currentUser;

    if (updatedUser == null) return '/login';

    final isEmailVerified = updatedUser.emailVerified;

    // 3. Is the user's email verified?
    if (!isEmailVerified && state.uri.path != '/email-verification') {
      return '/email-verification';
    }

    // 4. Redirect authenticated and verified users away from public routes
    if (isPublicRoute && isEmailVerified) {
      return '/home';
    }
  }

  return null;
}
