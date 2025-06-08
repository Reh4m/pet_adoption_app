import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

FutureOr<String?> authGuard(BuildContext context, GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;

  final isAuthenticated = user != null;
  final isEmailVerified = user?.emailVerified ?? false;

  final publicRoutes = ['/auth', '/login', '/register', '/forgot-password'];
  final isPublicRoute = publicRoutes.contains(state.uri.path);

  if (!isAuthenticated && !isPublicRoute) {
    return '/auth';
  }

  if (isAuthenticated &&
      !isEmailVerified &&
      state.uri.path != '/email-verification') {
    return '/email-verification';
  }

  if (isAuthenticated && isEmailVerified && isPublicRoute) {
    return '/home';
  }

  return null;
}
