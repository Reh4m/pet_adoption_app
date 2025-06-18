import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/presentation/providers/adoption_request_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AdoptionRequestsMainScreen extends StatefulWidget {
  const AdoptionRequestsMainScreen({super.key});

  @override
  State<AdoptionRequestsMainScreen> createState() =>
      _AdoptionRequestsMainScreenState();
}

class _AdoptionRequestsMainScreenState extends State<AdoptionRequestsMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeProvider();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final adoptionProvider = context.read<AdoptionRequestProvider>();
      final currentUser = userProvider.currentUser;

      if (currentUser != null) {
        // Inicializa los listeners para ambos tipos de solicitudes
        adoptionProvider.startReceivedRequestsListener(currentUser.id);
        adoptionProvider.startSentRequestsListener(currentUser.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(
          'Solicitudes de Adopción',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withAlpha(150),
          indicatorColor: theme.colorScheme.onPrimary,
          dividerHeight: 0,
          tabs: [
            Tab(
              child: Consumer<AdoptionRequestProvider>(
                builder: (context, provider, child) {
                  final pendingCount = provider.pendingReceivedCount;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox, size: 16),
                      const SizedBox(width: 10),
                      const Text('Recibidas'),
                      if (pendingCount > 0) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$pendingCount',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            Tab(
              child: Consumer<AdoptionRequestProvider>(
                builder: (context, provider, child) {
                  final pendingCount = provider.pendingSentCount;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send, size: 16),
                      const SizedBox(width: 10),
                      const Text('Enviadas'),
                      if (pendingCount > 0) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$pendingCount',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildReceivedRequestsTab(), _buildSentRequestsTab()],
      ),
    );
  }

  Widget _buildReceivedRequestsTab() {
    return Consumer<AdoptionRequestProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildReceivedSummary(provider),
              const SizedBox(height: 20),
              Expanded(child: _buildQuickActions('received')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSentRequestsTab() {
    return Consumer<AdoptionRequestProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildSentSummary(provider),
              const SizedBox(height: 20),
              Expanded(child: _buildQuickActions('sent')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceivedSummary(AdoptionRequestProvider provider) {
    final theme = Theme.of(context);
    final pendingCount = provider.pendingReceivedCount;
    final totalCount = provider.receivedRequests.length;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.inbox, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solicitudes Recibidas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$totalCount total, $pendingCount pendientes',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (pendingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$pendingCount',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentSummary(AdoptionRequestProvider provider) {
    final theme = Theme.of(context);
    final pendingCount = provider.pendingSentCount;
    final totalCount = provider.sentRequests.length;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.send, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solicitudes Enviadas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$totalCount total, $pendingCount ${pendingCount > 1 ? 'pendientes' : 'pendiente'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (pendingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$pendingCount',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(String type) {
    final theme = Theme.of(context);
    final isReceived = type == 'received';

    return Column(
      children: [
        ListTile(
          onTap:
              () => context.push(
                isReceived ? '/adoption/received' : '/adoption/sent',
              ),
          tileColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(
            isReceived ? Icons.visibility : Icons.send,
            color: theme.colorScheme.primary,
          ),
          title: Text(
            isReceived ? 'Ver Todas las Recibidas' : 'Ver Todas las Enviadas',
          ),
          subtitle: Text(
            isReceived
                ? 'Gestiona las solicitudes de adopción'
                : 'Revisa el estado de tus solicitudes',
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        const SizedBox(height: 16),
        if (!isReceived) ...[
          ListTile(
            onTap: () => context.go('/home'),
            tileColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: Icon(Icons.pets, color: theme.colorScheme.secondary),
            title: const Text('Explorar Mascotas'),
            subtitle: const Text('Encuentra tu próxima compañía'),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ],
    );
  }
}
