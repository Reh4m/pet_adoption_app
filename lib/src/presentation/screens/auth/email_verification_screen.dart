import 'dart:async';
import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/core/di/index.dart' as di;
import 'package:pet_adoption_app/src/domain/usecases/authentication_usecases.dart';
import 'package:pet_adoption_app/src/presentation/providers/authentication_provider.dart';
import 'package:pet_adoption_app/src/presentation/utils/toast_notification.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_alert_dialog.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final firebaseAuth = di.sl<FirebaseAuth>();
  SignOutUseCase get _signOutUseCase => di.sl<SignOutUseCase>();

  Timer? _verificationTimer;
  Timer? _cooldownTimer;
  bool _canResend = false;
  int _resendCooldown = 60;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldown = 60;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _startVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    final provider = context.read<AuthenticationProvider>();

    if (provider.state == AuthState.loading) return;

    final isVerified = await provider.checkEmailVerification();

    if (!mounted) return;

    if (provider.state == AuthState.error && provider.errorMessage != null) {
      _showToast(
        title: 'Error de verificación',
        description: provider.errorMessage!,
        type: ToastNotificationType.error,
      );
      return;
    }

    if (isVerified) {
      _verificationTimer?.cancel();

      final created = await provider.saveUserDataToFirestore();

      if (!mounted) return;

      if (created) {
        _showSuccessDialog();
      } else if (provider.errorMessage != null) {
        _showToast(
          title: 'Error al crear usuario',
          description: provider.errorMessage!,
          type: ToastNotificationType.error,
        );
      }
    }
  }

  Future<void> _manualCheckVerification() async {
    final provider = context.read<AuthenticationProvider>();

    final isVerified = await provider.checkEmailVerification();

    if (!mounted) return;

    if (isVerified) {
      final created = await provider.saveUserDataToFirestore();

      if (created) {
        _showSuccessDialog();
      } else if (provider.errorMessage != null) {
        _showToast(
          title: 'Error',
          description: provider.errorMessage!,
          type: ToastNotificationType.error,
        );
      }
    } else {
      _showToast(
        title: 'Email no verificado',
        description:
            'Tu correo aún no ha sido verificado. Revisa tu bandeja de entrada.',
        type: ToastNotificationType.warning,
      );
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResend) return;

    final provider = context.read<AuthenticationProvider>();
    await provider.sendEmailVerification();

    if (!mounted) return;

    if (provider.state != AuthState.error) {
      _showToast(
        title: 'Correo reenviado',
        description: 'Te hemos enviado un nuevo correo de verificación.',
        type: ToastNotificationType.success,
      );
      _startResendCooldown();
    } else if (provider.errorMessage != null) {
      _showToast(
        title: 'Error',
        description: provider.errorMessage!,
        type: ToastNotificationType.error,
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CustomAlertDialog(
            status: AlertDialogStatus.success,
            title: '¡Email Verificado!',
            description:
                'Tu correo electrónico ha sido verificado exitosamente. Ya puedes acceder a todos nuestros servicios.',
            primaryButtonVariant: ButtonVariant.primary,
            primaryButtonText: 'Continuar',
            primaryButtonIcon: Icons.arrow_forward_rounded,
            onPrimaryPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
          ),
    );
  }

  void _backToLogin() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => CustomAlertDialog(
            status: AlertDialogStatus.warning,
            title: 'Volver al Login',
            description:
                '¿Estás seguro de que quieres volver a la pantalla de inicio de sesión?',
            primaryButtonVariant: ButtonVariant.outline,
            primaryButtonText: 'Sí, Volver',
            onPrimaryPressed: () async {
              Navigator.of(dialogContext).pop();

              await _signOutUseCase();

              if (mounted) {
                context.go('/login');
              }
            },
            isSecondaryButtonEnabled: true,
            secondaryButtonVariant: ButtonVariant.primary,
            onSecondaryPressed: () => Navigator.of(context).pop(),
          ),
    );
  }

  void _changeEmail() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => CustomAlertDialog(
            status: AlertDialogStatus.warning,
            title: 'Cambiar Email',
            description:
                'Para cambiar tu correo electrónico necesitas cerrar sesión y crear una nueva cuenta.',
            primaryButtonVariant: ButtonVariant.outline,
            primaryButtonText: 'Cerrar Sesión',
            onPrimaryPressed: () async {
              Navigator.of(dialogContext).pop();

              await _signOutUseCase();

              if (mounted) {
                context.go('/login');
              }
            },
            isSecondaryButtonEnabled: true,
            secondaryButtonVariant: ButtonVariant.primary,
            onSecondaryPressed: () => Navigator.of(context).pop(),
          ),
    );
  }

  void _showToast({
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
    final theme = Theme.of(context);

    return Scaffold(
      body: Consumer<AuthenticationProvider>(
        builder: (_, authProvider, __) {
          final isLoading = authProvider.state == AuthState.loading;
          final userEmail = firebaseAuth.currentUser?.email;

          return LoadingOverlay(
            isLoading: isLoading,
            message: 'Verificando...',
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 20),
                    _buildEmailIcon(theme),
                    const SizedBox(height: 20),
                    _buildTitle(theme),
                    const SizedBox(height: 5),
                    _buildDescription(theme),
                    const SizedBox(height: 20),
                    _buildEmailInfo(theme, userEmail: userEmail),
                    const SizedBox(height: 20),
                    _buildActionButtons(isLoading),
                    const SizedBox(height: 20),
                    _buildFooter(theme),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          onPressed: _backToLogin,
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        ),
        const Spacer(),
        TextButton(
          onPressed: _changeEmail,
          child: Text(
            'Cambiar Email',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailIcon(ThemeData theme) {
    return Blob.random(
      size: 130,
      minGrowth: 10,
      styles: BlobStyles(color: theme.primaryColorLight.withAlpha(100)),
      child: Icon(
        Icons.mark_email_read_outlined,
        size: 60,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      'Verifica tu Email',
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      'Te hemos enviado un enlace de verificación a tu correo electrónico. Haz clic en el enlace para activar tu cuenta.',
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailInfo(ThemeData theme, {required String? userEmail}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(
            Icons.email_outlined,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Correo enviado a:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  userEmail ?? 'No disponible',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Column(
      children: [
        CustomButton(
          text: 'Ya Verifiqué mi Email',
          onPressed: _manualCheckVerification,
          isLoading: isLoading,
          width: double.infinity,
          icon: const Icon(Icons.refresh, size: 20),
        ),
        const SizedBox(height: 20),
        CustomButton(
          text:
              _canResend
                  ? 'Reenviar Correo'
                  : 'Reenviar en ${_resendCooldown}s',
          onPressed: _canResend ? _resendVerificationEmail : null,
          isLoading: isLoading,
          variant: ButtonVariant.outline,
          width: double.infinity,
          icon: const Icon(Icons.send, size: 20),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Text(
      '¿No recibiste el correo? Revisa tu carpeta de spam',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }
}
