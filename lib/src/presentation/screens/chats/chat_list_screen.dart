import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/chat_entity.dart';
import 'package:pet_adoption_app/src/presentation/providers/chat_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/src/presentation/screens/chats/widgets/chat_list_item.dart';
import 'package:pet_adoption_app/src/presentation/utils/toast_notification.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  Future<void> _handleRefresh() async {
    final userProvider = context.read<UserProvider>();
    final chatProvider = context.read<ChatProvider>();

    final currentUser = userProvider.currentUser;
    if (currentUser != null) {
      chatProvider.stopUserChatsListener();
      await Future.delayed(const Duration(milliseconds: 500));
      chatProvider.startUserChatsListener(currentUser.id);
    }
  }

  void _handleChatTap(ChatEntity chat) {
    context.push('/chat/${chat.id}', extra: {'chat': chat});
  }

  void _handleChatLongPress(ChatEntity chat) {
    _showChatOptions(chat);
  }

  void _showChatOptions(ChatEntity chat) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildChatOptionsSheet(chat),
    );
  }

  Widget _buildChatOptionsSheet(ChatEntity chat) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Opciones del chat',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.archive, color: theme.colorScheme.primary),
            title: const Text('Archivar chat'),
            onTap: () {
              Navigator.pop(context);
              _archiveChat(chat);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: theme.colorScheme.error),
            title: const Text('Eliminar chat'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(chat);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ChatEntity chat) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar chat'),
            content: Text(
              '¿Estás seguro de que quieres eliminar el chat con ${chat.getOtherParticipantName(_getCurrentUserId())}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteChat(chat);
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  Future<void> _archiveChat(ChatEntity chat) async {
    final chatProvider = context.read<ChatProvider>();
    final success = await chatProvider.archiveChat(chat.id);

    if (mounted) {
      if (success) {
        ToastNotification.show(
          context,
          title: 'Chat archivado',
          description: 'El chat ha sido archivado correctamente.',
          type: ToastNotificationType.success,
        );
      } else {
        ToastNotification.show(
          context,
          title: 'Error',
          description:
              chatProvider.operationError ?? 'No se pudo archivar el chat.',
          type: ToastNotificationType.error,
        );
      }
    }
  }

  Future<void> _deleteChat(ChatEntity chat) async {
    final chatProvider = context.read<ChatProvider>();
    final success = await chatProvider.deleteChat(chat.id);

    if (mounted) {
      if (success) {
        ToastNotification.show(
          context,
          title: 'Chat eliminado',
          description: 'El chat ha sido eliminado correctamente.',
          type: ToastNotificationType.success,
        );
      } else {
        ToastNotification.show(
          context,
          title: 'Error',
          description:
              chatProvider.operationError ?? 'No se pudo eliminar el chat.',
          type: ToastNotificationType.error,
        );
      }
    }
  }

  String _getCurrentUserId() {
    return context.read<UserProvider>().currentUser?.id ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: Consumer2<ChatProvider, UserProvider>(
        builder: (context, chatProvider, userProvider, child) {
          final currentUser = userProvider.currentUser;

          if (currentUser == null) {
            return _buildNotLoggedInState(theme);
          }

          if (chatProvider.chatsState == ChatState.loading) {
            return _buildLoadingState();
          }

          if (chatProvider.chatsState == ChatState.error) {
            return _buildErrorState(theme, chatProvider.chatsError);
          }

          final chats = chatProvider.getActiveChats();

          if (chats.isEmpty) {
            return _buildEmptyState(theme);
          }

          return _buildChatsList(chats, currentUser.id);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      centerTitle: true,
      title: Text(
        'Chats',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implementar búsqueda de chats
            ToastNotification.show(
              context,
              title: 'Búsqueda',
              description: 'Función de búsqueda próximamente.',
              type: ToastNotificationType.info,
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotLoggedInState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Inicia sesión',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Necesitas iniciar sesión para ver tus mensajes.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
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
          Text('Cargando mensajes...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error al cargar mensajes',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Error desconocido',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleRefresh,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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
              'No tienes mensajes',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando alguien se interese en tus mascotas o tú muestres interés en adoptar, los chats aparecerán aquí.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.pets),
              label: const Text('Explorar mascotas'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatsList(List<ChatEntity> chats, String currentUserId) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: chats.length,
        separatorBuilder:
            (context, index) => Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outline.withAlpha(20),
            ),
        itemBuilder: (context, index) {
          final chat = chats[index];

          return ChatListItem(
            chat: chat,
            currentUserId: currentUserId,
            onTap: () => _handleChatTap(chat),
            onLongPress: () => _handleChatLongPress(chat),
          );
        },
      ),
    );
  }
}
