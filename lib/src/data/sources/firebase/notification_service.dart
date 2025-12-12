import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final FirebaseFirestore _firestore;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  String? _currentToken;

  // Streams para notificaciones
  final StreamController<RemoteMessage> _onMessageController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _onMessageOpenedAppController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<String> _onTokenRefreshController =
      StreamController<String>.broadcast();

  Stream<RemoteMessage> get onMessageForeground => _onMessageController.stream;
  Stream<RemoteMessage> get onMessageOpenedApp =>
      _onMessageOpenedAppController.stream;
  Stream<String> get onTokenRefresh => _onTokenRefreshController.stream;

  FirebaseNotificationService({
    required FirebaseMessaging firebaseMessaging,
    required FirebaseFirestore firestore,
    required FlutterLocalNotificationsPlugin localNotificationsPlugin,
  }) : _firebaseMessaging = firebaseMessaging,
       _firestore = firestore,
       _localNotificationsPlugin = localNotificationsPlugin;

  Future<void> initialize() async {
    // Configurar canal de notificaciones para Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pet_adoption_channel',
      'Pet Adoption Notifications',
      description: 'Notificaciones de solicitudes de adopción',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Inicializar notificaciones locales
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Configurar handlers de Firebase Messaging
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Escuchar cambios de token
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _currentToken = token;
      _onTokenRefreshController.add(token);
    });
  }

  Future<bool> requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<String?> getToken() async {
    _currentToken = await _firebaseMessaging.getToken();
    return _currentToken;
  }

  Future<void> saveTokenToFirestore(String userId) async {
    final token = await getToken();
    if (token == null) return;

    final userRef = _firestore.collection('users').doc(userId);

    await userRef.update({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'lastTokenUpdate': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeTokenFromFirestore(String userId) async {
    if (_currentToken == null) return;

    final userRef = _firestore.collection('users').doc(userId);

    await userRef.update({
      'fcmTokens': FieldValue.arrayRemove([_currentToken]),
    });

    _currentToken = null;
  }

  Future<RemoteMessage?> getInitialMessage() async {
    return await _firebaseMessaging.getInitialMessage();
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'pet_adoption_channel',
          'Pet Adoption Notifications',
          channelDescription: 'Notificaciones de solicitudes de adopción',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload != null ? jsonEncode(payload) : null,
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _onMessageController.add(message);

    // Mostrar notificación local
    if (message.notification != null) {
      showLocalNotification(
        title: message.notification!.title ?? 'Puppy Love',
        body: message.notification!.body ?? '',
        payload: message.data,
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    _onMessageOpenedAppController.add(message);
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        // Crear un RemoteMessage simulado para mantener consistencia
        final message = RemoteMessage(
          data: data.map((key, value) => MapEntry(key, value.toString())),
        );
        _onMessageOpenedAppController.add(message);
      } catch (e) {
        // Error al parsear payload
      }
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  void dispose() {
    _onMessageController.close();
    _onMessageOpenedAppController.close();
    _onTokenRefreshController.close();
  }
}
