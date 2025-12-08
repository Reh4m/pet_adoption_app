import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pet_adoption_app/src/core/di/index.dart' as di;
import 'package:pet_adoption_app/src/presentation/providers/adoption_request_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/chat_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/src/presentation/screens/adoption/requests_screen.dart';
import 'package:pet_adoption_app/src/presentation/screens/chats/chat_list_screen.dart';
import 'package:pet_adoption_app/src/presentation/screens/home/index.dart';
import 'package:pet_adoption_app/src/presentation/screens/user/profile/index.dart';
import 'package:provider/provider.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final PageController _pageController = PageController();

  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatListScreen(),
    const AdoptionRequestsMainScreen(),
    const CurrentUserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Inicializar providers después de que el widget se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();

      // Inicializar listener del usuario
      userProvider.startCurrentUserListener();

      // Inicializar listeners de solicitudes de adopción
      _initializeAdoptionRequestListeners(userProvider);
    });
  }

  void _initializeAdoptionRequestListeners(UserProvider userProvider) {
    final adoptionProvider = context.read<AdoptionRequestProvider>();
    final chatProvider = context.read<ChatProvider>();

    // Escuchar cambios en el usuario actual
    userProvider.addListener(() {
      final currentUser = userProvider.currentUser;

      if (currentUser != null) {
        // Iniciar listeners de solicitudes solo cuando tengamos un usuario
        adoptionProvider.startReceivedRequestsListener(currentUser.id);
        adoptionProvider.startSentRequestsListener(currentUser.id);
        // Iniciar listeners de chat
        chatProvider.startUserChatsListener(currentUser.id);
        chatProvider.loadUnreadMessagesCount(currentUser.id);
      } else {
        // Detener listeners si el usuario se desloguea
        adoptionProvider.stopAllListeners();
        chatProvider.stopUserChatsListener();
      }
    });

    // Si ya tenemos un usuario actual, inicializar inmediatamente
    final currentUser = userProvider.currentUser;
    if (currentUser != null) {
      adoptionProvider.startReceivedRequestsListener(currentUser.id);
      adoptionProvider.startSentRequestsListener(currentUser.id);
      chatProvider.startUserChatsListener(currentUser.id);
      chatProvider.loadUnreadMessagesCount(currentUser.id);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      di.sl<AdoptionRequestProvider>().stopAllListeners();
      di.sl<ChatProvider>().stopUserChatsListener();
      di.sl<UserProvider>().clearCurrentUser();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: theme.shadowColor.withAlpha(20)),
          ],
        ),
        child: Consumer<AdoptionRequestProvider>(
          builder: (context, adoptionProvider, child) {
            final pendingNotifications =
                adoptionProvider.pendingReceivedCount +
                adoptionProvider.pendingSentCount;

            return GNav(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 10.0,
              ),
              gap: 20.0,
              backgroundColor: theme.cardColor,
              rippleColor: theme.colorScheme.secondary.withAlpha(20),
              activeColor: theme.colorScheme.secondary,
              tabBackgroundColor: theme.colorScheme.secondary.withAlpha(20),
              color: theme.colorScheme.onSurface,
              duration: const Duration(milliseconds: 250),
              iconSize: 24,
              tabs: <GButton>[
                const GButton(icon: Icons.home_outlined, text: 'Home'),
                GButton(
                  icon: Icons.chat_bubble_outline,
                  text: 'Chats',
                  leading: Consumer<ChatProvider>(
                    builder: (context, chatProvider, child) {
                      final unreadCount = chatProvider.totalUnreadCount;

                      if (unreadCount > 0) {
                        return Stack(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 24,
                              color:
                                  _currentIndex == 1
                                      ? theme.colorScheme.secondary
                                      : theme.colorScheme.onSurface,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 12,
                                  minHeight: 12,
                                ),
                                child: Text(
                                  unreadCount > 9 ? '9+' : '$unreadCount',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSecondary,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return Icon(
                        Icons.chat_bubble_outline,
                        size: 24,
                        color:
                            _currentIndex == 1
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.onSurface,
                      );
                    },
                  ),
                ),
                GButton(
                  icon:
                      pendingNotifications > 0
                          ? Icons.notifications_active
                          : Icons.notifications_outlined,
                  text: 'Solicitudes',
                  leading:
                      pendingNotifications > 0
                          ? Stack(
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                size: 24,
                                color:
                                    _currentIndex == 2
                                        ? theme.colorScheme.secondary
                                        : theme.colorScheme.onSurface,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 12,
                                    minHeight: 12,
                                  ),
                                  child: Text(
                                    pendingNotifications > 9
                                        ? '9+'
                                        : '$pendingNotifications',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : null,
                ),
                const GButton(icon: Icons.person_outline, text: 'Perfil'),
              ],
              selectedIndex: _currentIndex,
              onTabChange: _onItemTapped,
            );
          },
        ),
      ),
    );
  }
}

// Widget temporal para las pantallas no implementadas
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '$title próximamente',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta funcionalidad estará disponible pronto.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
