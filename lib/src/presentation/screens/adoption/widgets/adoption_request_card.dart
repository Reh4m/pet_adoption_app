import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/domain/entities/adoption_request_entity.dart';
import 'package:pet_adoption_app/src/presentation/config/themes/light_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdoptionRequestCard extends StatelessWidget {
  final AdoptionRequestEntity request;
  final bool isOwnerView;
  final VoidCallback onTap;
  final VoidCallback? onViewProfile;
  final VoidCallback? onViewPet;

  const AdoptionRequestCard({
    super.key,
    required this.request,
    required this.isOwnerView,
    required this.onTap,
    this.onViewProfile,
    this.onViewPet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 20),
            _buildContent(theme),
            const SizedBox(height: 20),
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        _buildAvatar(theme),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOwnerView ? request.requesterName : request.petName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                isOwnerView
                    ? 'Interesado en ${request.petName}'
                    : 'Solicitud para adopción',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        _buildStatusBadge(theme),
      ],
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    if (isOwnerView) {
      // Mostrar avatar del solicitante
      return CircleAvatar(
        radius: 24,
        backgroundColor: theme.colorScheme.primary.withAlpha(20),
        backgroundImage:
            request.requesterPhotoUrl != null
                ? NetworkImage(request.requesterPhotoUrl!)
                : null,
        child:
            request.requesterPhotoUrl == null
                ? Text(
                  _getInitials(request.requesterName),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                )
                : null,
      );
    }

    // Mostrar imagen de la mascota
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child:
          request.petImageUrls.isNotEmpty
              ? Image.network(
                request.petImageUrls.first,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => _buildPetPlaceholder(theme),
              )
              : _buildPetPlaceholder(theme),
    );
  }

  Widget _buildPetPlaceholder(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(Icons.pets, size: 24, color: theme.colorScheme.primary),
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    final statusColor = _getStatusColor();
    final statusText = request.statusString;
    final statusIcon = _getStatusIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 5),
          Text(
            statusText,
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
    return Text(
      request.message.isNotEmpty ? request.message : 'No hay mensaje adicional',
      style: theme.textTheme.bodyMedium,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: theme.colorScheme.onSurface),
        const SizedBox(width: 5),
        Text(
          timeago.format(request.createdAt, locale: 'es'),
          style: theme.textTheme.bodySmall,
        ),
        const Spacer(),
        if (isOwnerView && onViewProfile != null)
          TextButton.icon(
            onPressed: onViewProfile,
            icon: const Icon(Icons.person, size: 16),
            label: const Text('Ver Perfil'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        if (!isOwnerView && onViewPet != null)
          TextButton.icon(
            onPressed: onViewPet,
            icon: const Icon(Icons.pets, size: 16),
            label: const Text('Ver Mascota'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (request.status) {
      case AdoptionRequestStatus.pending:
        return LightTheme.warning;
      case AdoptionRequestStatus.accepted:
        return LightTheme.success;
      case AdoptionRequestStatus.rejected:
      case AdoptionRequestStatus.cancelled:
        return LightTheme.error;
      case AdoptionRequestStatus.completed:
        return LightTheme.info;
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

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
