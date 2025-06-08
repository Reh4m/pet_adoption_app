import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/presentation/config/routes/auth_guard.dart';
import 'package:pet_adoption_app/src/presentation/screens/auth/email_verification_screen.dart';
import 'package:pet_adoption_app/src/presentation/screens/auth/forgot_password_screen.dart';
import 'package:pet_adoption_app/src/presentation/screens/auth/sign_in_screen.dart';
import 'package:pet_adoption_app/src/presentation/screens/auth/sign_up_screen.dart';
import 'package:pet_adoption_app/src/presentation/screens/onboarding/index.dart';
import 'package:pet_adoption_app/src/presentation/screens/root_screen.dart';

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
    ],
  );
}
