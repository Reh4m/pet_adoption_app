import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/domain/entities/user_entity.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/src/presentation/utils/toast_notification.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_text_field.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final UserEntity user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _phoneController = TextEditingController(
      text: widget.user.phoneNumber ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) return;

    final updatedUser = widget.user.copyWith(
      name: _nameController.text.trim(),
      bio:
          _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
      phoneNumber:
          _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
      updatedAt: DateTime.now(),
    );

    final success = await userProvider.updateCurrentUserProfile(updatedUser);

    if (success) {
      // ignore: use_build_context_synchronously
      context.pop();
      _showToast(
        'Perfil actualizado',
        'Tu perfil se ha actualizado correctamente.',
        ToastNotificationType.success,
      );
    } else {
      _showToast(
        'Error',
        userProvider.operationError ?? 'Error al actualizar el perfil.',
        ToastNotificationType.error,
      );
    }
  }

  void _showToast(
    String title,
    String description,
    ToastNotificationType type,
  ) {
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
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(
          'Editar Perfil',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Selector<UserProvider, UserState>(
        selector: (_, userProvider) => userProvider.operationState,
        builder: (_, userState, child) {
          return LoadingOverlay(
            isLoading: userState == UserState.loading,
            message: 'Actualizando perfil...',
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Form(key: _formKey, child: _buildBasicInfo()),
                    const SizedBox(height: 20),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      children: [
        CustomTextField(
          label: 'Nombre *',
          hint: 'Tu nombre completo',
          controller: _nameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es obligatorio';
            }
            if (value.trim().length < 2) {
              return 'El nombre debe tener al menos 2 caracteres';
            }
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Biografía',
          hint: 'Cuéntanos un poco sobre ti...',
          controller: _bioController,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Teléfono',
          hint: 'Tu número de teléfono (opcional)',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Cancelar',
            variant: ButtonVariant.outline,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: CustomButton(text: 'Guardar', onPressed: _handleSave)),
      ],
    );
  }
}
