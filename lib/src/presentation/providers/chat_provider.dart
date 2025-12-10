import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/core/di/index.dart';
import 'package:pet_adoption_app/src/core/di/index.dart' as di;
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/chat_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/message_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/user_entity.dart';
import 'package:pet_adoption_app/src/domain/usecases/chat_usecases.dart';
import 'package:pet_adoption_app/src/domain/usecases/user_usecases.dart';

enum ChatState { initial, loading, success, error }

class ChatProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = di.sl<FirebaseAuth>();
  final CreateOrGetChatUseCase _createOrGetChatUseCase =
      sl<CreateOrGetChatUseCase>();
  final GetUserChatsStreamUseCase _getUserChatsStreamUseCase =
      sl<GetUserChatsStreamUseCase>();
  final GetChatByIdUseCase _getChatByIdUseCase = sl<GetChatByIdUseCase>();
  final SendMessageUseCase _sendMessageUseCase = sl<SendMessageUseCase>();
  final GetChatMessagesStreamUseCase _getChatMessagesStreamUseCase =
      sl<GetChatMessagesStreamUseCase>();
  final MarkAllMessagesAsReadUseCase _markAllMessagesAsReadUseCase =
      sl<MarkAllMessagesAsReadUseCase>();
  final MarkAllMessagesAsDeliveredUseCase _markAllMessagesAsDeliveredUseCase =
      sl<MarkAllMessagesAsDeliveredUseCase>();
  final GetUnreadMessagesCountUseCase _getUnreadMessagesCountUseCase =
      sl<GetUnreadMessagesCountUseCase>();
  final ArchiveChatUseCase _archiveChatUseCase = sl<ArchiveChatUseCase>();
  final DeleteChatUseCase _deleteChatUseCase = sl<DeleteChatUseCase>();
  final SendSystemMessageUseCase _sendSystemMessageUseCase =
      sl<SendSystemMessageUseCase>();
  final GetUserByIdUseCase _getUserByIdUseCase = sl<GetUserByIdUseCase>();

  ChatState _chatsState = ChatState.initial;
  ChatState _messagesState = ChatState.initial;
  ChatState _sendMessageState = ChatState.initial;
  ChatState _operationState = ChatState.initial;

  String? _chatsError;
  String? _messagesError;
  String? _sendMessageError;
  String? _operationError;

  List<ChatEntity> _userChats = [];
  final Map<String, UserEntity> _chatParticipants = {};
  final Map<String, List<MessageEntity>> _chatMessages = {};
  ChatEntity? _currentChat;
  int _totalUnreadCount = 0;

  StreamSubscription? _userChatsSubscription;
  final Map<String, StreamSubscription> _messageSubscriptions = {};

  bool _isDisposed = false;

  ChatState get chatsState => _chatsState;
  ChatState get messagesState => _messagesState;
  ChatState get sendMessageState => _sendMessageState;
  ChatState get operationState => _operationState;

  String? get chatsError => _chatsError;
  String? get messagesError => _messagesError;
  String? get sendMessageError => _sendMessageError;
  String? get operationError => _operationError;

  List<ChatEntity> get userChats => List.from(_userChats);
  Map<String, UserEntity> get chatParticipants => _chatParticipants;
  ChatEntity? get currentChat => _currentChat;
  int get totalUnreadCount => _totalUnreadCount;

  List<MessageEntity> getChatMessages(String chatId) {
    return List.from(_chatMessages[chatId] ?? []);
  }

  int getChatUnreadCount(String chatId, String userId) {
    final chat = _userChats.firstWhere(
      (c) => c.id == chatId,
      orElse: () => _currentChat!,
    );
    return chat.getUnreadCount(userId);
  }

  Future<ChatEntity?> createOrGetChat({
    required String adoptionRequestId,
    required String petId,
    required String petName,
    required List<String> petImageUrls,
    required String requesterId,
    required String requesterName,
    String? requesterPhotoUrl,
    required String ownerId,
    required String ownerName,
    String? ownerPhotoUrl,
  }) async {
    _setOperationState(ChatState.loading);

    final result = await _createOrGetChatUseCase(
      adoptionRequestId: adoptionRequestId,
      petId: petId,
      petName: petName,
      petImageUrls: petImageUrls,
      requesterId: requesterId,
      requesterName: requesterName,
      requesterPhotoUrl: requesterPhotoUrl,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerPhotoUrl: ownerPhotoUrl,
    );

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return null;
      },
      (chat) {
        _setOperationState(ChatState.success);
        return chat;
      },
    );
  }

  void startUserChatsListener(String userId) {
    _setChatsState(ChatState.loading);

    _userChatsSubscription = _getUserChatsStreamUseCase(userId).listen((
      either,
    ) {
      either.fold((failure) => _setChatsError(_mapFailureToMessage(failure)), (
        chats,
      ) async {
        _userChats = chats;

        _calculateTotalUnreadCount(userId);

        await _loadChatParticipants(chats);

        for (final chat in chats) {
          _markAllMessagesAsDelivered(chat.id);
        }

        _setChatsState(ChatState.success);
      });
    }, onError: (error) => _setChatsError('Error de conexión: $error'));
  }

  Future<void> _loadChatParticipants(List<ChatEntity> chats) async {
    for (final chat in chats) {
      for (final userId in chat.participantIds) {
        if (!_chatParticipants.containsKey(userId)) {
          final result = await _getUserByIdUseCase(userId);
          result.fold((_) => null, (user) => _chatParticipants[userId] = user);
        }
      }
    }
  }

  void stopUserChatsListener() {
    _userChatsSubscription?.cancel();
    _userChatsSubscription = null;
  }

  Future<void> loadChatById(String chatId) async {
    _setOperationState(ChatState.loading);

    final result = await _getChatByIdUseCase(chatId);

    result.fold(
      (failure) => _setOperationError(_mapFailureToMessage(failure)),
      (chat) {
        _currentChat = chat;
        _setOperationState(ChatState.success);
      },
    );
  }

  void startChatMessagesListener(String chatId) {
    // Evitar múltiples listeners para el mismo chat
    if (_messageSubscriptions.containsKey(chatId)) return;

    _setMessagesState(ChatState.loading);

    _messageSubscriptions[chatId] = _getChatMessagesStreamUseCase(
      chatId,
    ).listen(
      (either) {
        if (_isDisposed) return;

        either.fold(
          (failure) => _setMessagesError(_mapFailureToMessage(failure)),
          (messages) async {
            _chatMessages[chatId] = messages;

            await _markAllMessagesAsRead(chatId);

            _setMessagesState(ChatState.success);
          },
        );
      },
      onError: (error) {
        if (_isDisposed) return;
        _setMessagesError('Error de conexión: $error');
      },
    );
  }

  void stopChatMessagesListener(String chatId) {
    _messageSubscriptions[chatId]?.cancel();
    _messageSubscriptions.remove(chatId);
  }

  void stopAllMessageListeners() {
    for (final subscription in _messageSubscriptions.values) {
      subscription.cancel();
    }
    _messageSubscriptions.clear();
  }

  // Message operations
  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    String? senderPhotoUrl,
    required String content,
    MessageType type = MessageType.text,
    String? imageUrl,
  }) async {
    if (content.trim().isEmpty && type == MessageType.text) return false;

    _setSendMessageState(ChatState.loading);

    final result = await _sendMessageUseCase(
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderPhotoUrl: senderPhotoUrl,
      content: content,
      type: type,
      imageUrl: imageUrl,
    );

    return result.fold(
      (failure) {
        _setSendMessageError(_mapFailureToMessage(failure));
        return false;
      },
      (messageId) {
        _setSendMessageState(ChatState.success);
        return true;
      },
    );
  }

  Future<void> _markAllMessagesAsRead(String chatId) async {
    if (_isDisposed) return;

    final userId = firebaseAuth.currentUser?.uid;

    if (userId == null) return;

    final result = await _markAllMessagesAsReadUseCase(chatId, userId);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
      },
      (_) {
        // Actualizar el estado local
        final chatIndex = _userChats.indexWhere((c) => c.id == chatId);
        if (chatIndex != -1) {
          final updatedUnreadCounts = Map<String, int>.from(
            _userChats[chatIndex].unreadCounts,
          );
          updatedUnreadCounts[userId] = 0;

          _userChats[chatIndex] = _userChats[chatIndex].copyWith(
            unreadCounts: updatedUnreadCounts,
          );

          _calculateTotalUnreadCount(userId);
          notifyListeners();
        }
      },
    );
  }

  Future<void> _markAllMessagesAsDelivered(String chatId) async {
    final userId = firebaseAuth.currentUser?.uid;

    if (userId == null) return;

    await _markAllMessagesAsDeliveredUseCase(chatId, userId);
  }

  Future<void> loadUnreadMessagesCount(String userId) async {
    final result = await _getUnreadMessagesCountUseCase(userId);

    result.fold(
      (failure) => _setOperationError(_mapFailureToMessage(failure)),
      (count) {
        _totalUnreadCount = count;
        notifyListeners();
      },
    );
  }

  Future<bool> archiveChat(String chatId) async {
    _setOperationState(ChatState.loading);

    final result = await _archiveChatUseCase(chatId);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setOperationState(ChatState.success);
        // Remover el chat de la lista local
        _userChats.removeWhere((chat) => chat.id == chatId);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> deleteChat(String chatId) async {
    _setOperationState(ChatState.loading);

    final result = await _deleteChatUseCase(chatId);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setOperationState(ChatState.success);
        // Remover el chat de la lista local y sus mensajes
        _userChats.removeWhere((chat) => chat.id == chatId);
        _chatMessages.remove(chatId);
        stopChatMessagesListener(chatId);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> sendSystemMessage({
    required String chatId,
    required String content,
  }) async {
    final result = await _sendSystemMessageUseCase(
      chatId: chatId,
      content: content,
    );

    return result.fold((failure) {
      _setOperationError(_mapFailureToMessage(failure));
      return false;
    }, (_) => true);
  }

  // Helper methods
  void _calculateTotalUnreadCount(String userId) {
    _totalUnreadCount = _userChats.fold(
      0,
      (total, chat) => total + chat.getUnreadCount(userId),
    );
  }

  ChatEntity? findChatByAdoptionRequestId(String adoptionRequestId) {
    try {
      return _userChats.firstWhere(
        (chat) => chat.adoptionRequestId == adoptionRequestId,
      );
    } catch (e) {
      return null;
    }
  }

  List<ChatEntity> getActiveChats() {
    return _userChats.where((chat) => chat.isActive).toList();
  }

  List<ChatEntity> getChatsWithUnreadMessages(String userId) {
    return _userChats.where((chat) => chat.getUnreadCount(userId) > 0).toList();
  }

  UserEntity? getParticipantInfo(String userId) {
    return _chatParticipants[userId];
  }

  String? getParticipantId(ChatEntity chat, String currentUserId) {
    return chat.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  void setCurrentChat(ChatEntity? chat) {
    _currentChat = chat;
    notifyListeners();
  }

  void clearCurrentChat() {
    _currentChat = null;
    notifyListeners();
  }

  // State setters
  void _setChatsState(ChatState newState) {
    _chatsState = newState;
    if (newState != ChatState.error) {
      _chatsError = null;
    }
    notifyListeners();
  }

  void _setChatsError(String message) {
    _chatsError = message;
    _setChatsState(ChatState.error);
  }

  void _setMessagesState(ChatState newState) {
    _messagesState = newState;
    if (newState != ChatState.error) {
      _messagesError = null;
    }
    notifyListeners();
  }

  void _setMessagesError(String message) {
    _messagesError = message;
    _setMessagesState(ChatState.error);
  }

  void _setSendMessageState(ChatState newState) {
    _sendMessageState = newState;
    if (newState != ChatState.error) {
      _sendMessageError = null;
    }
    notifyListeners();
  }

  void _setSendMessageError(String message) {
    _sendMessageError = message;
    _setSendMessageState(ChatState.error);
  }

  void _setOperationState(ChatState newState) {
    _operationState = newState;
    if (newState != ChatState.error) {
      _operationError = null;
    }
    notifyListeners();
  }

  void _setOperationError(String message) {
    _operationError = message;
    _setOperationState(ChatState.error);
  }

  // Clear methods
  void clearChatsError() {
    _chatsError = null;
    notifyListeners();
  }

  void clearMessagesError() {
    _messagesError = null;
    notifyListeners();
  }

  void clearSendMessageError() {
    _sendMessageError = null;
    notifyListeners();
  }

  void clearOperationError() {
    _operationError = null;
    notifyListeners();
  }

  void clearSendMessageState() {
    _sendMessageState = ChatState.initial;
    _sendMessageError = null;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return 'Sin conexión a internet';
      case const (ServerFailure):
        return 'Error del servidor';
      case const (ChatNotFoundFailure):
        return 'Chat no encontrado';
      default:
        return 'Error inesperado';
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    stopUserChatsListener();
    stopAllMessageListeners();
    super.dispose();
  }
}
