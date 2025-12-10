import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/presentation/providers/pet_registration_provider.dart';
import 'package:pet_adoption_app/src/presentation/screens/pets/registration/steppers/step_basic_info.dart';
import 'package:pet_adoption_app/src/presentation/screens/pets/registration/steppers/step_images.dart';
import 'package:pet_adoption_app/src/presentation/screens/pets/registration/steppers/step_location.dart';
import 'package:pet_adoption_app/src/presentation/screens/pets/registration/steppers/step_medical_behavior.dart';
import 'package:pet_adoption_app/src/presentation/screens/pets/registration/steppers/step_physical_info.dart';
import 'package:pet_adoption_app/src/presentation/screens/pets/registration/steppers/step_preview.dart';
import 'package:pet_adoption_app/src/presentation/screens/pets/registration/widgets/registration_stepper.dart';
import 'package:pet_adoption_app/src/presentation/utils/toast_notification.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_alert_dialog.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';

class PetRegistrationScreen extends StatefulWidget {
  const PetRegistrationScreen({super.key});

  @override
  State<PetRegistrationScreen> createState() => _PetRegistrationScreenState();
}

class _PetRegistrationScreenState extends State<PetRegistrationScreen> {
  late PetRegistrationProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = PetRegistrationProvider();
  }

  Future<bool> _onWillPop() async {
    // Si ya completó el registro, permitir salir
    if (_provider.isCompleted) return true;

    // Si está en el primer paso y no hay datos, permitir salir
    if (_provider.isFirstStep && _provider.formData.isEmpty) return true;

    // Mostrar diálogo de confirmación
    final shouldPop = await showDialog<bool>(
      context: context,
      builder:
          (context) => CustomAlertDialog(
            status: AlertDialogStatus.warning,
            title: '¿Salir del registro?',
            description:
                'Se perderá todo el progreso del registro de la mascota.',
            primaryButtonText: 'Salir',
            primaryButtonVariant: ButtonVariant.outline,
            onPrimaryPressed: () => Navigator.pop(context, true),
            isSecondaryButtonEnabled: true,
            secondaryButtonVariant: ButtonVariant.primary,
            onSecondaryPressed: () => Navigator.pop(context, false),
          ),
    );

    return shouldPop ?? false;
  }

  void _handleNext() {
    if (_provider.canProceedToNext) {
      if (_provider.isLastStep) {
        _submitRegistration();
      } else {
        _provider.nextStep();
      }
    } else {
      _showValidationError();
    }
  }

  void _handlePrevious() {
    _provider.previousStep();
  }

  void _showValidationError() {
    ToastNotification.show(
      context,
      title: 'Información incompleta',
      description: 'Por favor completa todos los campos obligatorios.',
      type: ToastNotificationType.warning,
    );
  }

  Future<void> _submitRegistration() async {
    final success = await _provider.createPet();

    if (!mounted) return;

    if (success) {
      _showSuccessDialog();
    } else {
      ToastNotification.show(
        context,
        title: 'Error al registrar',
        description: _provider.errorMessage ?? 'Error desconocido',
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
            title: '¡Mascota Registrada!',
            description:
                'Tu mascota ha sido publicada exitosamente y ya está disponible para adopción.',
            primaryButtonText: 'Ver en Inicio',
            primaryButtonVariant: ButtonVariant.primary,
            primaryButtonIcon: Icons.arrow_forward,
            onPrimaryPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
          ),
    );
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: _provider,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop && result == true) {
            final shouldPop = await _onWillPop();
            if (shouldPop && mounted) {
              // ignore: use_build_context_synchronously
              context.pop();
            }
          }
        },
        child: Consumer<PetRegistrationProvider>(
          builder: (_, provider, child) {
            return LoadingOverlay(
              isLoading: provider.isLoading,
              message: 'Registrando mascota...',
              child: Scaffold(
                appBar: _buildAppBar(provider, theme),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      RegistrationStepper(
                        currentStep: provider.currentStep,
                        totalSteps: PetRegistrationProvider.totalSteps,
                        progress: provider.progress,
                        stepTitle: provider.currentStepTitle,
                      ),
                      Expanded(child: _buildCurrentStep(provider)),
                      _buildNavigationButtons(provider, theme),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    PetRegistrationProvider provider,
    ThemeData theme,
  ) {
    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () async {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            context.pop();
          }
        },
      ),
      title: Text(
        'Registrar Mascota',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildCurrentStep(PetRegistrationProvider provider) {
    switch (provider.currentStep) {
      case 0:
        return const StepBasicInfo();
      case 1:
        return const StepPhysicalInfo();
      case 2:
        return const StepMedicalBehavior();
      case 3:
        return const StepImages();
      case 4:
        return const StepLocation();
      case 5:
        return const StepPreview();
      default:
        return const Center(child: Text('Paso no encontrado'));
    }
  }

  Widget _buildNavigationButtons(
    PetRegistrationProvider provider,
    ThemeData theme,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            if (!provider.isFirstStep) ...[
              Expanded(
                child: CustomButton(
                  text: 'Anterior',
                  variant: ButtonVariant.outline,
                  onPressed: _handlePrevious,
                  icon: const Icon(Icons.arrow_back, size: 20),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: CustomButton(
                text: provider.isLastStep ? 'Publicar' : 'Siguiente',
                variant: ButtonVariant.primary,
                onPressed: provider.canProceedToNext ? _handleNext : null,
                icon: Icon(
                  provider.isLastStep ? Icons.publish : Icons.arrow_forward,
                  size: 20,
                ),
                iconPosition: ButtonIconPosition.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
