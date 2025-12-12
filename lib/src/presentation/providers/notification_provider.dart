import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/core/di/index.dart';
import 'package:pet_adoption_app/src/domain/usecases/notification_usecases.dart';

enum NotificationState { initial, loading, ready, error }

enum AdoptionNotificationType {
  newRequest,
  requestAccepted,
  requestRejected,
  adoptionCompleted,
  newMessage,
  unknown,
}

class NotificationProvider extends ChangeNotifier {
  final InitializeNotificationsUseCase _initializeUseCase =
      sl<InitializeNotificationsUseCase>();
  final RequestNotificationPermissionUseCase _requestPermissionUseCase =
      sl<RequestNotificationPermissionUseCase>();
  final GetAndSaveTokenUseCase _getAndSaveTokenUseCase =
      sl<GetAndSaveTokenUseCase>();
  final RemoveNotificationTokenUseCase _removeTokenUseCase =
      sl<RemoveNotificationTokenUseCase>();
  final GetInitialMessageUseCase _getInitialMessageUseCase =
      sl<GetInitialMessageUseCase>();
  final GetTokenRefreshStreamUseCase _tokenRefreshStreamUseCase =
      sl<GetTokenRefreshStreamUseCase>();
  final GetForegroundMessageStreamUseCase _foregroundMessageStreamUseCase =
      sl<GetForegroundMessageStreamUseCase>();
  final GetMessageOpenedAppStreamUseCase _messageOpenedAppStreamUseCase =
      sl<GetMessageOpenedAppStreamUseCase>();

  NotificationState _state = NotificationState.initial;
  String? _errorMessage;
  String? _currentUserId;

  // Subscriptions
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSubscription;

  // Callback para manejar la navegación cuando se toca una notificación
  void Function(RemoteMessage message)? onNotificationTapped;

  NotificationState get state => _state;
  String? get errorMessage => _errorMessage;

  /// Inicializa el sistema de notificaciones
  Future<void> initialize() async {
    _setState(NotificationState.loading);

    // 1. Inicializar el servicio
    final initResult = await _initializeUseCase();

    await initResult.fold(
      (failure) async {
        _setError('Error al inicializar notificaciones');
      },
      (_) async {
        // 2. Solicitar permisos
        final permissionResult = await _requestPermissionUseCase();

        permissionResult.fold(
          (failure) => _setError('Error al solicitar permisos'),
          (granted) {
            if (!granted) {
              _setError('Permisos de notificación denegados');
            }
          },
        );

        // 3. Configurar listeners
        _setupListeners();

        // 4. Verificar si hay un mensaje inicial
        await _checkInitialMessage();

        _setState(NotificationState.ready);
      },
    );
  }

  /// Configura los listeners de notificaciones
  void _setupListeners() {
    // Listener para refresh de token
    _tokenRefreshSubscription = _tokenRefreshStreamUseCase().listen((token) {
      if (_currentUserId != null) {
        _getAndSaveTokenUseCase(_currentUserId!);
      }
    });

    // Listener para mensajes en foreground
    _foregroundMessageSubscription = _foregroundMessageStreamUseCase().listen(
      _handleForegroundMessage,
    );

    // Listener para mensajes que abren la app
    _messageOpenedAppSubscription = _messageOpenedAppStreamUseCase().listen(
      _handleMessageOpenedApp,
    );
  }

  /// Verifica si la app se abrió desde una notificación
  Future<void> _checkInitialMessage() async {
    final result = await _getInitialMessageUseCase();

    result.fold((failure) {}, (message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });
  }

  /// Maneja mensajes recibidos en foreground
  void _handleForegroundMessage(RemoteMessage message) {
    // El servicio ya muestra la notificación local
    // Aquí podemos agregar lógica adicional si es necesario
    debugPrint('📬 Notificación en foreground: ${message.notification?.title}');
  }

  /// Maneja cuando se abre la app desde una notificación
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('🔔 App abierta desde notificación: ${message.data}');

    // Llamar al callback de navegación si está configurado
    if (onNotificationTapped != null) {
      onNotificationTapped!(message);
    }
  }

  /// Obtiene el tipo de notificación desde los datos del mensaje
  static AdoptionNotificationType getNotificationType(
    Map<String, dynamic> data,
  ) {
    final type = data['type'] as String?;

    switch (type) {
      case 'new_request':
        return AdoptionNotificationType.newRequest;
      case 'request_accepted':
        return AdoptionNotificationType.requestAccepted;
      case 'request_rejected':
        return AdoptionNotificationType.requestRejected;
      case 'adoption_completed':
        return AdoptionNotificationType.adoptionCompleted;
      case 'new_message':
        return AdoptionNotificationType.newMessage;
      default:
        return AdoptionNotificationType.unknown;
    }
  }

  /// Se llama cuando el usuario inicia sesión
  Future<void> onUserLogin(String userId) async {
    _currentUserId = userId;

    final result = await _getAndSaveTokenUseCase(userId);

    result.fold(
      (failure) => debugPrint('❌ Error al guardar token FCM'),
      (token) =>
          debugPrint('✅ Token FCM guardado: ${token.substring(0, 20)}...'),
    );
  }

  /// Se llama cuando el usuario cierra sesión
  Future<void> onUserLogout(String userId) async {
    final result = await _removeTokenUseCase(userId);

    result.fold(
      (failure) => debugPrint('❌ Error al eliminar token FCM'),
      (_) => debugPrint('✅ Token FCM eliminado'),
    );

    _currentUserId = null;
  }

  void _setState(NotificationState newState) {
    _state = newState;
    if (newState != NotificationState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(NotificationState.error);
  }

  @override
  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundMessageSubscription?.cancel();
    _messageOpenedAppSubscription?.cancel();
    super.dispose();
  }
}
