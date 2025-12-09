import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/core/di/index.dart' as di;
import 'package:pet_adoption_app/src/domain/entities/chat/chat_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/message_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/user_entity.dart';
import 'package:pet_adoption_app/src/presentation/providers/chat_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/media_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/src/presentation/screens/chats/widgets/message_bubble.dart';
import 'package:pet_adoption_app/src/presentation/screens/chats/widgets/message_input.dart';
import 'package:pet_adoption_app/src/presentation/screens/media/index.dart';
import 'package:pet_adoption_app/src/presentation/utils/image_picker_service.dart';
import 'package:pet_adoption_app/src/presentation/utils/toast_notification.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final ChatEntity? chat;

  const ChatScreen({super.key, required this.chatId, this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  ChatEntity? _currentChat;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();

      _currentChat = widget.chat;

      if (_currentChat != null) {
        chatProvider.setCurrentChat(_currentChat);
      } else {
        chatProvider.loadChatById(widget.chatId);
      }

      // Iniciar listener de mensajes
      chatProvider.startChatMessagesListener(widget.chatId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Disposing ChatScreen for chatId: ${widget.chatId}');
      di.sl<ChatProvider>().stopChatMessagesListener(widget.chatId);
      di.sl<ChatProvider>().clearCurrentChat();
    });

    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final userProvider = context.read<UserProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      ToastNotification.show(
        context,
        title: 'Error',
        description: 'Debes estar autenticado para enviar mensajes.',
        type: ToastNotificationType.error,
      );
      return;
    }

    // Limpiar el campo de texto inmediatamente
    _messageController.clear();

    final success = await chatProvider.sendMessage(
      chatId: widget.chatId,
      senderId: currentUser.id,
      senderName: currentUser.displayName,
      senderPhotoUrl: currentUser.photoUrl,
      content: messageText,
    );

    if (success) {
      _scrollToBottom();
    } else {
      // Si falló, restaurar el mensaje
      _messageController.text = messageText;

      if (mounted) {
        ToastNotification.show(
          context,
          title: 'Error al enviar',
          description:
              chatProvider.sendMessageError ?? 'No se pudo enviar el mensaje.',
          type: ToastNotificationType.error,
        );
      }
    }
  }

  Future<void> _handleAttachmentTap() async {
    await ImagePickerService.showMediaPickerDialog(
      context,
      onMediaSelected: (file, mediaType) async {
        if (file == null) return;

        // Mostrar preview
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    MediaPreviewScreen(file: file, mediaType: mediaType),
          ),
        );

        if (result == null) return;

        final File selectedFile = result['file'];
        final String caption = result['caption'] ?? '';

        // Subir archivo según su tipo
        await _uploadAndSendMedia(
          file: selectedFile,
          mediaType: mediaType,
          caption: caption,
        );
      },
    );
  }

  Future<void> _uploadAndSendMedia({
    required File file,
    required MediaType mediaType,
    required String caption,
  }) async {
    final currentUserId = context.read<UserProvider>().currentUser?.id;
    if (currentUserId == null) return;

    final mediaProvider = context.read<MediaProvider>();
    String? mediaUrl;

    // Subir el archivo según su tipo
    switch (mediaType) {
      case MediaType.image:
        mediaUrl = await mediaProvider.uploadImage(
          image: file,
          chatId: widget.chatId,
          senderId: currentUserId,
        );
        break;
      case MediaType.video:
        mediaUrl = await mediaProvider.uploadVideo(
          video: file,
          chatId: widget.chatId,
          senderId: currentUserId,
        );
        break;
    }

    if (mediaUrl == null && mounted) {
      _showToast(
        title: 'Error',
        description: mediaProvider.error ?? 'No se pudo subir el archivo',
        type: ToastNotificationType.error,
      );
      return;
    }

    // Crear y enviar mensaje
    final userProvider = context.read<UserProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      ToastNotification.show(
        context,
        title: 'Error',
        description: 'Debes estar autenticado para enviar mensajes.',
        type: ToastNotificationType.error,
      );
      return;
    }

    final mediaTypeString = _getMediaTypeString(mediaType);
    final messageContent = caption.isNotEmpty ? caption : mediaTypeString;

    final success = await chatProvider.sendMessage(
      chatId: widget.chatId,
      senderId: currentUserId,
      senderName: currentUser.displayName,
      senderPhotoUrl: currentUser.photoUrl,
      type: _getMessageType(mediaType),
      content: messageContent,
      imageUrl: mediaUrl,
    );

    if (!success && mounted) {
      _showToast(
        title: 'Error',
        description:
            chatProvider.operationError ?? 'No se pudo enviar el mensaje',
        type: ToastNotificationType.error,
      );
    }
  }

  String _getMediaTypeString(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.image:
        return 'Imagen';
      case MediaType.video:
        return 'Video';
    }
  }

  MessageType _getMessageType(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.image:
        return MessageType.image;
      case MediaType.video:
        return MessageType.video;
    }
  }

  void _showToast({
    required String title,
    required String description,
    required ToastNotificationType type,
  }) {
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
      appBar: _buildAppBar(theme),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          // Actualizar chat actual si es necesario
          if (chatProvider.currentChat != null && _currentChat == null) {
            _currentChat = chatProvider.currentChat;
          }

          if (_currentChat == null &&
              chatProvider.operationState == ChatState.loading) {
            return _buildLoadingState();
          }

          if (_currentChat == null) {
            return _buildNotFoundState(theme);
          }

          return Column(
            children: [
              _buildChatHeader(theme, _currentChat!.petId),
              Expanded(child: _buildMessagesSection(chatProvider)),
              MessageInput(
                controller: _messageController,
                focusNode: _messageFocusNode,
                onSend: _sendMessage,
                onAttachment: _handleAttachmentTap,
                isLoading: chatProvider.sendMessageState == ChatState.loading,
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: Consumer<ChatProvider>(
        builder: (_, chatProvider, __) {
          final chat = chatProvider.currentChat;

          if (chat == null) {
            return Text(
              'Chat',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimary,
              ),
            );
          }

          final currentUserId = context.read<UserProvider>().currentUser?.id;

          if (currentUserId == null) {
            return Text(
              'Error cargando usuario',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            );
          }

          final otherUserId = chatProvider.getParticipantId(
            chat,
            currentUserId,
          );
          final otherUser =
              otherUserId != null
                  ? chatProvider.getParticipantInfo(otherUserId)
                  : null;

          return InkWell(
            onTap: () => context.push('/user/$otherUserId'),
            child: Row(
              children: [
                _buildAppBarAvatar(theme, otherUser),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        otherUser?.displayName ?? 'Usuario desconocido',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Adoptando: ${chat.petName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary.withAlpha(200),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBarAvatar(ThemeData theme, UserEntity? otherUser) {
    final otherParticipantInitials = otherUser?.initials ?? 'U';
    final otherParticipantPhoto = otherUser?.photoUrl;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.onPrimary.withAlpha(20),
      ),
      child:
          otherParticipantPhoto != null && otherParticipantPhoto.isNotEmpty
              ? ClipOval(
                child: Image.network(
                  otherParticipantPhoto,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          _buildInitials(theme, otherParticipantInitials),
                ),
              )
              : _buildInitials(theme, otherParticipantInitials),
    );
  }

  Widget _buildInitials(ThemeData theme, String initals) {
    return Center(
      child: Text(
        initals,
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando chat...'),
        ],
      ),
    );
  }

  Widget _buildNotFoundState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Chat no encontrado',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este chat no existe o no tienes acceso a él.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader(ThemeData theme, String petId) {
    if (_currentChat == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha(20)),
      child: InkWell(
        onTap: () => context.push('/pets/${petId}'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildPetImage(theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentChat!.petName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toca para ver detalles de la mascota',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetImage(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.primary.withAlpha(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child:
            _currentChat!.petImageUrls.isNotEmpty
                ? Image.network(
                  _currentChat!.petImageUrls.first,
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

  Widget _buildMessagesSection(ChatProvider chatProvider) {
    if (chatProvider.messagesState == ChatState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatProvider.messagesState == ChatState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error al cargar mensajes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(chatProvider.messagesError ?? 'Error desconocido'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                chatProvider.stopChatMessagesListener(widget.chatId);
                chatProvider.startChatMessagesListener(widget.chatId);
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final messages = chatProvider.getChatMessages(widget.chatId);
    final currentUserId = context.read<UserProvider>().currentUser?.id;

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin mensajes aún',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text('¡Envía el primer mensaje!'),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == currentUserId;

        return MessageBubble(message: message, isOwnMessage: isMe);
      },
    );
  }
}
