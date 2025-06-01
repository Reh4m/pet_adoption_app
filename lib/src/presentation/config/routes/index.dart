import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_adoption_app/src/presentation/screens/auth/forgot_password_screen.dart';
import 'package:pet_adoption_app/src/presentation/screens/auth/sign_in_screen.dart';
import 'package:pet_adoption_app/src/presentation/screens/home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isAuthenticated = user != null;

      final publicRoutes = ['/login', '/register', '/forgot-password'];
      final isPublicRoute = publicRoutes.contains(state.uri.path);

      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      if (isAuthenticated && isPublicRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      GoRoute(
        path: '/login',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
}
