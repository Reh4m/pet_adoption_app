import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/domain/entities/adoption_request_entity.dart';
import 'package:pet_adoption_app/src/presentation/config/themes/color_palette.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:timeago/timeago.dart' as timeago;

class RequestDetailDialog extends StatelessWidget {
  final AdoptionRequestEntity request;
  final bool isOwner;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;

  const RequestDetailDialog({
    super.key,
    required this.request,
    required this.isOwner,
    this.onAccept,
    this.onReject,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildContent(theme),
              ),
            ),
            _buildActions(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solicitud de Adopción',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isOwner
                      ? 'De ${request.requesterName}'
                      : 'Para ${request.petName}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusChip(theme),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 5),
          Text(
            request.statusString,
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoSection(theme),
        const SizedBox(height: 20),
        _buildMessageSection(theme),
        if (request.rejectionReason != null) ...[
          const SizedBox(height: 20),
          _buildRejectionSection(theme),
        ],
        if (request.notes != null) ...[
          const SizedBox(height: 20),
          _buildNotesSection(theme),
        ],
        const SizedBox(height: 20),
        _buildTimelineSection(theme),
      ],
    );
  }

  Widget _buildInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Text(
              'Información',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildInfoRow(theme, 'Mascota:', request.petName),
        _buildInfoRow(
          theme,
          isOwner ? 'Solicitante:' : 'Dueño:',
          isOwner ? request.requesterName : request.ownerName,
        ),
        _buildInfoRow(
          theme,
          'Fecha de solicitud:',
          _formatDate(request.createdAt),
        ),
        if (request.responseDate != null)
          _buildInfoRow(
            theme,
            'Fecha de respuesta:',
            _formatDate(request.responseDate!),
          ),
      ],
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(width: 5),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.message_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Text(
              'Mensaje del solicitante',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline.withAlpha(50)),
          ),
          child: Text(
            request.message,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildRejectionSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.cancel_outlined,
              size: 20,
              color: ColorPalette.error,
            ),
            const SizedBox(width: 10),
            Text(
              'Motivo del rechazo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorPalette.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: ColorPalette.error.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            request.rejectionReason ??
                'No se proporcionó un motivo de rechazo.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: ColorPalette.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.note_outlined, size: 20, color: ColorPalette.info),
            const SizedBox(width: 10),
            Text(
              'Notas adicionales',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorPalette.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: ColorPalette.info.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            request.notes ?? 'No hay notas adicionales.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: ColorPalette.info,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Text(
              'Cronología',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildTimelineItem(
          theme,
          'Solicitud enviada',
          timeago.format(request.createdAt, locale: 'es'),
          ColorPalette.info,
          Icons.send,
          true,
        ),
        if (request.responseDate != null)
          _buildTimelineItem(
            theme,
            request.isAccepted ? 'Solicitud aceptada' : 'Solicitud rechazada',
            timeago.format(request.responseDate!, locale: 'es'),
            request.isAccepted ? ColorPalette.success : ColorPalette.error,
            request.isAccepted ? Icons.check_circle : Icons.cancel,
            true,
          ),
      ],
    );
  }

  Widget _buildTimelineItem(
    ThemeData theme,
    String title,
    String time,
    Color color,
    IconData icon,
    bool isCompleted,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? color : color.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: isCompleted ? Colors.white : color,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(time, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(100),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        children: [
          if (isOwner && request.isPending) ...[
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'No',
                    variant: ButtonVariant.outline,
                    onPressed: onReject,
                    icon: const Icon(Icons.cancel, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text: 'Sí',
                    variant: ButtonVariant.primary,
                    onPressed: onAccept,
                    icon: const Icon(Icons.check_circle, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (!isOwner && request.canBeCancelled && onCancel != null) ...[
            CustomButton(
              text: 'Cancelar Solicitud',
              variant: ButtonVariant.outline,
              onPressed: onCancel,
              width: double.infinity,
              icon: const Icon(Icons.close, size: 20),
            ),
            const SizedBox(height: 10),
          ],
          CustomButton(
            text: 'Cerrar',
            variant: ButtonVariant.text,
            onPressed: () => Navigator.pop(context),
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (request.status) {
      case AdoptionRequestStatus.pending:
        return ColorPalette.warning;
      case AdoptionRequestStatus.accepted:
        return ColorPalette.success;
      case AdoptionRequestStatus.rejected:
      case AdoptionRequestStatus.cancelled:
        return ColorPalette.error;
      case AdoptionRequestStatus.completed:
        return ColorPalette.info;
    }
  }

  IconData _getStatusIcon() {
    switch (request.status) {
      case AdoptionRequestStatus.pending:
        return Icons.schedule;
      case AdoptionRequestStatus.accepted:
        return Icons.check_circle;
      case AdoptionRequestStatus.rejected:
        return Icons.cancel;
      case AdoptionRequestStatus.cancelled:
        return Icons.close;
      case AdoptionRequestStatus.completed:
        return Icons.home;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
