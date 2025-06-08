import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/presentation/config/themes/light_theme.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';

enum AlertDialogStatus { success, error, warning, info }

class CustomAlertDialog extends StatelessWidget {
  final AlertDialogStatus status;
  final String title;
  final String description;
  final String primaryButtonText;
  final ButtonVariant primaryButtonVariant;
  final IconData? primaryButtonIcon;
  final VoidCallback onPrimaryPressed;
  final bool? isSecondaryButtonEnabled;
  final ButtonVariant? secondaryButtonVariant;
  final VoidCallback? onSecondaryPressed;

  const CustomAlertDialog({
    super.key,
    required this.status,
    required this.title,
    required this.description,
    required this.primaryButtonVariant,
    required this.primaryButtonText,
    this.primaryButtonIcon,
    required this.onPrimaryPressed,
    this.isSecondaryButtonEnabled = false,
    this.secondaryButtonVariant,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: Center(child: _buildIcon()),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        description,
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      actions: [
        if (isSecondaryButtonEnabled == true && onSecondaryPressed != null) ...[
          CustomButton(
            text: 'Cancelar',
            variant: secondaryButtonVariant ?? ButtonVariant.outline,
            width: double.infinity,
            onPressed: onSecondaryPressed,
          ),
          const SizedBox(height: 10),
        ],
        CustomButton(
          text: primaryButtonText,
          variant: primaryButtonVariant,
          width: double.infinity,
          icon:
              primaryButtonIcon != null
                  ? Icon(primaryButtonIcon, size: 20)
                  : null,
          iconPosition: ButtonIconPosition.right,
          onPressed: onPrimaryPressed,
        ),
      ],
    );
  }

  Widget _buildIcon() {
    switch (status) {
      case AlertDialogStatus.success:
        return Blob.random(
          size: 130,
          minGrowth: 8,
          styles: BlobStyles(color: LightTheme.successLight),
          child: Icon(
            Icons.check_circle_outline,
            size: 60,
            color: LightTheme.success,
          ),
        );
      case AlertDialogStatus.error:
        return Blob.random(
          size: 130,
          minGrowth: 8,
          styles: BlobStyles(color: LightTheme.errorLight),
          child: Icon(Icons.error_outline, size: 60, color: LightTheme.error),
        );
      case AlertDialogStatus.warning:
        return Blob.random(
          size: 130,
          minGrowth: 8,
          styles: BlobStyles(color: LightTheme.warningLight),
          child: Icon(
            Icons.warning_amber_outlined,
            size: 60,
            color: LightTheme.warning,
          ),
        );
      case AlertDialogStatus.info:
        return Blob.random(
          size: 130,
          minGrowth: 8,
          styles: BlobStyles(color: LightTheme.infoLight),
          child: Icon(Icons.info_outline, size: 60, color: LightTheme.info),
        );
    }
  }
}
