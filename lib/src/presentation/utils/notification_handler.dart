import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/presentation/providers/notification_provider.dart';
import 'package:provider/provider.dart';

class NotificationHandler extends StatefulWidget {
  final Widget child;

  const NotificationHandler({super.key, required this.child});

  @override
  State<NotificationHandler> createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  @override
  void initState() {
    super.initState();
    _setupNotificationNavigation();
  }

  void _setupNotificationNavigation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = context.read<NotificationProvider>();

      notificationProvider.onNotificationTapped = (message) {
        _navigateFromNotification(message);
      };
    });
  }

  void _navigateFromNotification(RemoteMessage message) {
    final data = message.data;
    final notificationType = NotificationProvider.getNotificationType(data);

    switch (notificationType) {
      case AdoptionNotificationType.newRequest:
        // Nueva solicitud de adopción - navegar a solicitudes recibidas
        _navigateToReceivedRequests();
        break;

      case AdoptionNotificationType.requestAccepted:
      case AdoptionNotificationType.requestRejected:
        // Solicitud aceptada/rechazada - navegar a solicitudes enviadas
        _navigateToSentRequests();
        break;

      case AdoptionNotificationType.adoptionCompleted:
        // Adopción completada - navegar a detalles de la mascota
        final petId = data['petId'] as String?;
        if (petId != null) {
          _navigateToPetDetails(petId);
        } else {
          _navigateToSentRequests();
        }
        break;

      case AdoptionNotificationType.newMessage:
        // Nuevo mensaje - navegar al chat
        final chatId = data['chatId'] as String?;
        if (chatId != null) {
          _navigateToChat(chatId);
        } else {
          _navigateToChatList();
        }
        break;

      case AdoptionNotificationType.unknown:
        // Tipo desconocido - navegar a home
        _navigateToHome();
        break;
    }
  }

  void _navigateToReceivedRequests() {
    if (!mounted) return;
    context.push('/adoption/received');
  }

  void _navigateToSentRequests() {
    if (!mounted) return;
    context.push('/adoption/sent');
  }

  void _navigateToPetDetails(String petId) {
    if (!mounted) return;
    context.push('/pets/$petId');
  }

  void _navigateToChat(String chatId) {
    if (!mounted) return;
    context.push('/chat/$chatId');
  }

  void _navigateToChatList() {
    if (!mounted) return;
    context.push('/chats');
  }

  void _navigateToHome() {
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
