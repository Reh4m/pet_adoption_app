import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/presentation/providers/authentication_provider.dart';
import 'package:pet_adoption_app/src/presentation/utils/toast_notification.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:provider/provider.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  Future<void> _onGoogleSignIn(BuildContext context) async {
    final authProvider = context.read<AuthenticationProvider>();
    await authProvider.signInWithGoogle();

    if (!context.mounted) return;

    switch (authProvider.state) {
      case AuthState.success:
        await authProvider.createUserAfterEmailVerification();

        context.go('/home');
        break;
      case AuthState.error:
        _showToast(
          context,
          title: authProvider.errorMessage ?? 'Error al iniciar sesión',
          description:
              'Por favor, verifica tus credenciales e intenta nuevamente.',
          type: ToastNotificationType.error,
        );
        break;
      default:
        break;
    }
  }

  void _showToast(
    BuildContext context, {
    required String title,
    required String description,
    required ToastNotificationType type,
  }) {
    ToastNotification.show(
      context,
      title: title,
      description: description,
      type: type,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, child) {
        return CustomButton(
          text: 'Continuar con Google',
          onPressed:
              authProvider.state == AuthState.loading
                  ? null
                  : () => _onGoogleSignIn(context),
          isLoading: authProvider.state == AuthState.loading,
          variant: ButtonVariant.outline,
          width: double.infinity,
          height: 56,
          icon: Padding(
            padding: const EdgeInsets.all(2),
            child: Image.asset(
              'assets/icons/google_logo.png',
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.g_mobiledata,
                  size: 24,
                  color: Colors.blue,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
