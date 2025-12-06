import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/chat_entity.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatListItem extends StatelessWidget {
  final ChatEntity chat;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final otherParticipantName = chat.getOtherParticipantName(currentUserId);
    final otherParticipantPhoto = chat.getOtherParticipantPhoto(currentUserId);
    final unreadCount = chat.getUnreadCount(currentUserId);
    final hasUnread = unreadCount > 0;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildPetAvatar(theme),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherParticipantName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight:
                                hasUnread ? FontWeight.w700 : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.lastMessageTimestamp != null)
                        Text(
                          timeago.format(
                            chat.lastMessageTimestamp!,
                            locale: 'es',
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                hasUnread
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withAlpha(
                                      150,
                                    ),
                            fontWeight:
                                hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.pets,
                        size: 14,
                        color: theme.colorScheme.onSurface.withAlpha(150),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        chat.petName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(child: _buildLastMessage(theme, hasUnread)),
                      if (hasUnread) _buildUnreadBadge(theme, unreadCount),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildUserAvatar(
              theme,
              otherParticipantPhoto,
              otherParticipantName,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetAvatar(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.primary.withAlpha(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            chat.petImageUrls.isNotEmpty
                ? Image.network(
                  chat.petImageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          _buildPetPlaceholder(theme),
                )
                : _buildPetPlaceholder(theme),
      ),
    );
  }

  Widget _buildPetPlaceholder(ThemeData theme) {
    return Icon(Icons.pets, color: theme.colorScheme.primary, size: 24);
  }

  Widget _buildUserAvatar(ThemeData theme, String? photoUrl, String name) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.secondary.withAlpha(20),
      ),
      child:
          photoUrl != null && photoUrl.isNotEmpty
              ? ClipOval(
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          _buildUserInitials(theme, name),
                ),
              )
              : _buildUserInitials(theme, name),
    );
  }

  Widget _buildUserInitials(ThemeData theme, String name) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Center(
      child: Text(
        initials,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLastMessage(ThemeData theme, bool hasUnread) {
    if (chat.lastMessageText == null || chat.lastMessageText!.isEmpty) {
      return Text(
        'Chat iniciado',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withAlpha(150),
          fontStyle: FontStyle.italic,
          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final isSystemMessage = chat.lastMessageSenderId == 'system';
    final isOwnMessage = chat.lastMessageSenderId == currentUserId;

    String messagePrefix = '';
    if (!isSystemMessage) {
      messagePrefix = isOwnMessage ? 'Tú: ' : '';
    }

    return Text(
      '$messagePrefix${chat.lastMessageText!}',
      style: theme.textTheme.bodyMedium?.copyWith(
        color:
            isSystemMessage
                ? theme.colorScheme.primary
                : hasUnread
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withAlpha(150),
        fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
        fontStyle: isSystemMessage ? FontStyle.italic : null,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildUnreadBadge(ThemeData theme, int count) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
