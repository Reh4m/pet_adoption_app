import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/message_entity.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isOwnMessage;
  final bool isConsecutive;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isOwnMessage,
    this.isConsecutive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (message.isSystemMessage) {
      return _buildSystemMessage(theme);
    }

    return Container(
      margin: EdgeInsets.only(
        bottom: isConsecutive ? 2 : 8,
        top: isConsecutive ? 0 : 4,
      ),
      child: Column(
        crossAxisAlignment:
            isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          _buildMessageContent(theme),
          if (!isConsecutive) _buildMessageFooter(theme),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message.content,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isOwnMessage ? theme.colorScheme.primary : theme.cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
      ),
      child:
          message.isImageMessage
              ? _buildImageMessage(theme)
              : _buildTextMessage(theme),
    );
  }

  Widget _buildTextMessage(ThemeData theme) {
    return Text(
      message.content,
      style: theme.textTheme.bodyMedium?.copyWith(
        color:
            isOwnMessage
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
        height: 1.4,
      ),
    );
  }

  Widget _buildImageMessage(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              message.imageUrl!,
              width: 200,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    width: 200,
                    height: 150,
                    color: theme.colorScheme.onSurface.withAlpha(20),
                    child: const Icon(Icons.broken_image),
                  ),
            ),
          ),
        if (message.content.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  isOwnMessage
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMessageFooter(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(
        left: isOwnMessage ? 0 : 12,
        right: isOwnMessage ? 12 : 0,
        top: 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            timeago.format(message.timestamp, locale: 'es'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(120),
              fontSize: 11,
            ),
          ),
          if (isOwnMessage) ...[
            const SizedBox(width: 4),
            _buildMessageStatus(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageStatus(ThemeData theme) {
    IconData icon;
    Color color;

    switch (message.status) {
      case MessageStatus.sent:
        icon = Icons.check;
        color = theme.colorScheme.onSurface.withAlpha(120);
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = theme.colorScheme.onSurface.withAlpha(120);
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = theme.colorScheme.secondary;
        break;
    }

    return Icon(icon, size: 14, color: color);
  }
}
