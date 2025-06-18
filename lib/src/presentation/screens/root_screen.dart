import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pet_adoption_app/src/presentation/providers/adoption_request_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/authentication_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/src/presentation/screens/adoption/requests_screen.dart';
import 'package:pet_adoption_app/src/presentation/screens/home/index.dart';
import 'package:pet_adoption_app/src/presentation/screens/user/profile/index.dart';
import 'package:provider/provider.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late final List<Widget> _pages;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const PlaceholderScreen(title: 'Favoritos'),
      const AdoptionRequestsMainScreen(),
      const CurrentUserProfileScreen(),
    ];

    // Inicializar UserProvider y sincronizar con Auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final authProvider = context.read<AuthenticationProvider>();

      // Sincronizar usuario actual con Firestore si existe
      authProvider.syncCurrentUserWithFirestore();

      // Inicializar listener del usuario
      userProvider.startCurrentUserListener();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
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
                const GButton(icon: Icons.favorite_outline, text: 'Favoritos'),
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
                                    _selectedIndex == 2
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
              selectedIndex: _selectedIndex,
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
