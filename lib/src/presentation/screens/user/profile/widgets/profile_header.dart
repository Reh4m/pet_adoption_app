import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/domain/entities/user_entity.dart';

class ProfileHeader extends StatelessWidget {
  final UserEntity user;
  final bool isCurrentUser;
  final VoidCallback? onChangePhoto;

  const ProfileHeader({
    super.key,
    required this.user,
    this.isCurrentUser = false,
    this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 40, left: 0, right: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProfileImage(theme),
            const SizedBox(height: 20),
            _buildUserInfo(theme),
            if (user.hasBio) ...[const SizedBox(height: 20), _buildBio(theme)],
            const SizedBox(height: 20),
            _buildUserBadges(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(ThemeData theme) {
    return Stack(
      children: [
        InkWell(
          onTap: isCurrentUser && user.canEditPhoto ? onChangePhoto : null,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.onPrimary, width: 3),
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.onPrimary.withAlpha(50),
              backgroundImage:
                  user.hasPhoto ? NetworkImage(user.photoUrl!) : null,
              child:
                  !user.hasPhoto
                      ? Text(
                        user.initials,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
          ),
        ),
        if (isCurrentUser && user.canEditPhoto)
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: onChangePhoto,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.onPrimary,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: theme.colorScheme.onSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo(ThemeData theme) {
    return Column(
      children: [
        Text(
          user.displayName,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          user.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary.withAlpha(200),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBio(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        user.bio!,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildUserBadges(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildBadge(
          theme,
          icon: Icons.pets,
          label:
              '${user.petsPosted} ${user.petsPosted == 1 ? 'Publicado' : 'Publicados'}',
          color: theme.colorScheme.onPrimary,
        ),
        _buildBadge(
          theme,
          icon: Icons.favorite,
          label:
              '${user.petsAdopted} ${user.petsAdopted == 1 ? 'Adoptado' : 'Adoptados'}',
          color: theme.colorScheme.onPrimary,
        ),
      ],
    );
  }

  Widget _buildBadge(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
