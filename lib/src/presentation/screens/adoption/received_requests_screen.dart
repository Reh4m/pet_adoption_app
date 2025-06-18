import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/domain/entities/adoption_request_entity.dart';
import 'package:pet_adoption_app/src/presentation/providers/adoption_request_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/src/presentation/screens/adoption/widgets/adoption_request_card.dart';
import 'package:pet_adoption_app/src/presentation/screens/adoption/widgets/request_detail_dialog.dart';
import 'package:pet_adoption_app/src/presentation/utils/toast_notification.dart';
import 'package:provider/provider.dart';

class ReceivedRequestsScreen extends StatefulWidget {
  const ReceivedRequestsScreen({super.key});

  @override
  State<ReceivedRequestsScreen> createState() => _ReceivedRequestsScreenState();
}

class _ReceivedRequestsScreenState extends State<ReceivedRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeRequests() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final adoptionProvider = context.read<AdoptionRequestProvider>();
      final currentUser = userProvider.currentUser;

      if (currentUser != null) {
        adoptionProvider.startReceivedRequestsListener(currentUser.id);
      }
    });
  }

  void _handleRequestAction(AdoptionRequestEntity request) {
    showDialog(
      context: context,
      builder:
          (context) => RequestDetailDialog(
            request: request,
            isOwner: true,
            onAccept: () => _acceptRequest(request),
            onReject: () => _rejectRequest(request),
          ),
    );
  }

  Future<void> _acceptRequest(AdoptionRequestEntity request) async {
    final adoptionProvider = context.read<AdoptionRequestProvider>();

    final success = await adoptionProvider.acceptRequest(
      request.id,
      notes: 'Solicitud aceptada. ¡Felicidades!',
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      _showToast(
        'Solicitud Aceptada',
        'Has aceptado la solicitud de adopción de ${request.requesterName}.',
        ToastNotificationType.success,
      );
    } else {
      _showToast(
        'Error',
        adoptionProvider.responseError ?? 'Error al aceptar la solicitud.',
        ToastNotificationType.error,
      );
    }
  }

  Future<void> _rejectRequest(AdoptionRequestEntity request) async {
    final reason = await _showRejectDialog();
    if (reason == null) return;

    // ignore: use_build_context_synchronously
    final adoptionProvider = context.read<AdoptionRequestProvider>();

    final success = await adoptionProvider.rejectRequest(
      request.id,
      rejectionReason: reason,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      _showToast(
        'Solicitud Rechazada',
        'Has rechazado la solicitud de adopción.',
        ToastNotificationType.info,
      );
    } else {
      _showToast(
        'Error',
        adoptionProvider.responseError ?? 'Error al rechazar la solicitud.',
        ToastNotificationType.error,
      );
    }
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Rechazar Solicitud'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('¿Por qué rechazas esta solicitud?'),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Motivo del rechazo (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final reason = controller.text.trim();
                  Navigator.pop(
                    context,
                    reason.isEmpty ? 'Sin motivo especificado' : reason,
                  );
                },
                child: const Text('Rechazar'),
              ),
            ],
          ),
    );
  }

  void _showToast(
    String title,
    String description,
    ToastNotificationType type,
  ) {
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
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(
          'Solicitudes Recibidas',
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
          isScrollable: true,
          dividerHeight: 0,
          tabs: const [
            Tab(text: 'Pendientes'),
            Tab(text: 'Aceptadas'),
            Tab(text: 'Rechazadas'),
            Tab(text: 'Todas'),
          ],
        ),
      ),
      body: Consumer<AdoptionRequestProvider>(
        builder: (context, provider, child) {
          if (provider.state == AdoptionRequestState.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando solicitudes...'),
                ],
              ),
            );
          }

          if (provider.state == AdoptionRequestState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Error al cargar solicitudes',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    provider.errorMessage ?? 'Error desconocido',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final receivedRequests = provider.receivedRequests;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRequestsList(
                receivedRequests.where((r) => r.isPending).toList(),
                'pendientes',
              ),
              _buildRequestsList(
                receivedRequests.where((r) => r.isAccepted).toList(),
                'aceptadas',
              ),
              _buildRequestsList(
                receivedRequests.where((r) => r.isRejected).toList(),
                'rechazadas',
              ),
              _buildRequestsList(receivedRequests, 'todas'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRequestsList(List<AdoptionRequestEntity> requests, String type) {
    if (requests.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AdoptionRequestCard(
              request: request,
              isOwnerView: true,
              onTap: () => _handleRequestAction(request),
              onViewProfile: () => context.push('/user/${request.requesterId}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    final theme = Theme.of(context);

    String title;
    String description;
    IconData icon;

    switch (type) {
      case 'pendientes':
        title = 'Sin solicitudes pendientes';
        description =
            'Cuando alguien esté interesado en tus mascotas, aparecerán aquí.';
        icon = Icons.schedule;
        break;
      case 'aceptadas':
        title = 'Sin solicitudes aceptadas';
        description = 'Las solicitudes que aceptes aparecerán aquí.';
        icon = Icons.check_circle_outline;
        break;
      case 'rechazadas':
        title = 'Sin solicitudes rechazadas';
        description = 'Las solicitudes que rechaces aparecerán aquí.';
        icon = Icons.cancel_outlined;
        break;
      default:
        title = 'Sin solicitudes';
        description = 'Aún no has recibido solicitudes de adopción.';
        icon = Icons.inbox_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
