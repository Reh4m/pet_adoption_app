import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/message_entity.dart';
import 'package:pet_adoption_app/src/presentation/screens/media/messages/image_message_widget.dart';
import 'package:pet_adoption_app/src/presentation/screens/media/messages/video_message_widget.dart';
import 'package:pet_adoption_app/src/presentation/screens/media/viewers/full_screen_image_viewer.dart';
import 'package:pet_adoption_app/src/presentation/screens/media/viewers/full_screen_video_viewer.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isOwnMessage;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isOwnMessage,
  });

  void _openImageViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FullScreenImageViewer(
              imageUrl: message.imageUrl!,
              caption: message.content.isNotEmpty ? message.content : null,
            ),
      ),
    );
  }

  void _openVideoViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FullScreenVideoViewer(
              videoUrl: message.imageUrl!,
              caption: message.content.isNotEmpty ? message.content : null,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (message.isSystemMessage) {
      return _buildSystemMessage(theme);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 4),
      child: Column(
        crossAxisAlignment:
            isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          _buildMessageChip(context, theme),
          _buildMessageFooter(theme),
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

  Widget _buildMessageChip(BuildContext context, ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isOwnMessage ? theme.colorScheme.primary : theme.cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
      ),
      child: _buildMessageContent(context, theme),
    );
  }

  Widget _buildMessageContent(BuildContext context, ThemeData theme) {
    switch (message.type) {
      case MessageType.system:
      case MessageType.text:
        return Text(
          message.content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: _getTextColor(theme),
          ),
        );

      case MessageType.image:
        return ImageMessageWidget(
          imageUrl: message.imageUrl!,
          caption: message.content.isNotEmpty ? message.content : null,
          isMe: isOwnMessage,
          onTap: () => _openImageViewer(context),
        );

      case MessageType.video:
        return VideoMessageWidget(
          videoUrl: message.imageUrl!,
          // thumbnailUrl: message.thumbnailUrl,
          caption: message.content.isNotEmpty ? message.content : null,
          isMe: isOwnMessage,
          onTap: () => _openVideoViewer(context),
        );
    }
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

  Color _getTextColor(ThemeData theme) =>
      isOwnMessage ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;

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
