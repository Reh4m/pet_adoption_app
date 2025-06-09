import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/domain/entities/user_entity.dart';
import 'package:pet_adoption_app/src/presentation/providers/theme_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/src/presentation/utils/toast_notification.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';

class EditUserSettingsScreen extends StatefulWidget {
  final UserEntity user;

  const EditUserSettingsScreen({super.key, required this.user});

  @override
  State<EditUserSettingsScreen> createState() => _EditUserSettingsScreenState();
}

class _EditUserSettingsScreenState extends State<EditUserSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = widget.user.notificationsEnabled;
    _emailNotificationsEnabled = widget.user.emailNotificationsEnabled;
  }

  Future<void> _handleSave() async {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) return;

    final updatedUser = widget.user.copyWith(
      notificationsEnabled: _notificationsEnabled,
      emailNotificationsEnabled: _emailNotificationsEnabled,
      updatedAt: DateTime.now(),
    );

    final success = await userProvider.updateCurrentUserProfile(updatedUser);

    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
        _showToast(
          'Configuración actualizada',
          'Tus preferencias se han guardado correctamente.',
          ToastNotificationType.success,
        );
      }
    } else {
      _showToast(
        'Error',
        userProvider.operationError ?? 'Error al actualizar la configuración.',
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
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(
          'Configuración',
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
            message: 'Actualizando preferencias...',
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                children: [
                  Text(
                    'Notificaciones',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Notificaciones push'),
                    subtitle: const Text('Recibir notificaciones en la app'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Notificaciones por email'),
                    subtitle: const Text(
                      'Recibir notificaciones por correo electrónico',
                    ),
                    value: _emailNotificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _emailNotificationsEnabled = value;
                      });
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Apariencia',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.brightness_6),
                    title: const Text('Tema de la app'),
                    subtitle: Text(
                      _themeModeLabel(themeProvider.currentThemeMode),
                    ),
                    trailing: DropdownButton<ThemeMode>(
                      value: themeProvider.currentThemeMode,
                      onChanged: (mode) {
                        if (mode != null) {
                          themeProvider.setThemeMode(mode);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Claro'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Oscuro'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('Sistema'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Cancelar',
                          variant: ButtonVariant.outline,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: 'Guardar',
                          onPressed: _handleSave,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }
}
