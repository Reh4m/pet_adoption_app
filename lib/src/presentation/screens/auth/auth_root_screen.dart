import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/presentation/providers/authentication_provider.dart';
import 'package:pet_adoption_app/src/presentation/screens/auth/widgets/google_sign_in_button.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';

class AuthRootScreen extends StatelessWidget {
  const AuthRootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Selector<AuthenticationProvider, AuthState>(
        selector: (_, p) => p.state,
        builder: (_, authState, child) {
          return LoadingOverlay(
            isLoading: authState == AuthState.loading,
            message: 'Iniciando sesión...',
            child: SafeArea(
              child: Center(child: _buildAuthenticationButtons(context, theme)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthenticationButtons(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSignInButton(context),
          const SizedBox(height: 20),
          GoogleSignInButton(),
          const SizedBox(height: 10),
          _buildSignUpPrompt(context, theme),
        ],
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return CustomButton(
      text: 'Continuar con Email',
      onPressed: () => context.go('/login'),
      icon: const Icon(Icons.email_outlined, size: 24),
      width: double.infinity,
      height: 56,
    );
  }

  Widget _buildSignUpPrompt(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿No tienes cuenta?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        TextButton(
          onPressed: () {
            context.push('/register');
          },
          child: Text(
            'Regístrate',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
