import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/domain/entities/adoption_request_entity.dart';
import 'package:pet_adoption_app/src/presentation/providers/adoption_request_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/src/presentation/screens/adoption/widgets/adoption_request_card.dart';
import 'package:pet_adoption_app/src/presentation/screens/adoption/widgets/request_detail_dialog.dart';
import 'package:pet_adoption_app/src/presentation/utils/toast_notification.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_alert_dialog.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:provider/provider.dart';

class SentRequestsScreen extends StatefulWidget {
  const SentRequestsScreen({super.key});

  @override
  State<SentRequestsScreen> createState() => _SentRequestsScreenState();
}

class _SentRequestsScreenState extends State<SentRequestsScreen>
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
        adoptionProvider.startSentRequestsListener(currentUser.id);
      }
    });
  }

  void _handleRequestAction(AdoptionRequestEntity request) {
    showDialog(
      context: context,
      builder:
          (context) => RequestDetailDialog(
            request: request,
            isOwner: false,
            onCancel:
                request.canBeCancelled ? () => _cancelRequest(request) : null,
          ),
    );
  }

  Future<void> _cancelRequest(AdoptionRequestEntity request) async {
    final confirmed = await _showCancelConfirmation();
    if (!confirmed) return;

    // ignore: use_build_context_synchronously
    final adoptionProvider = context.read<AdoptionRequestProvider>();

    final success = await adoptionProvider.cancelRequest(request.id);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      _showToast(
        'Solicitud Cancelada',
        'Has cancelado tu solicitud de adopción para ${request.petName}.',
        ToastNotificationType.info,
      );
    } else {
      _showToast(
        'Error',
        adoptionProvider.responseError ?? 'Error al cancelar la solicitud.',
        ToastNotificationType.error,
      );
    }
  }

  Future<bool> _showCancelConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => CustomAlertDialog(
            status: AlertDialogStatus.warning,
            title: 'Cancelar Solicitud',
            description:
                '¿Estás seguro de que quieres cancelar esta solicitud de adopción?',
            primaryButtonText: 'Cancelar Solicitud',
            primaryButtonVariant: ButtonVariant.primary,
            onPrimaryPressed: () => Navigator.pop(context, true),
            isSecondaryButtonEnabled: true,
            secondaryButtonVariant: ButtonVariant.outline,
            onSecondaryPressed: () => Navigator.pop(context, false),
          ),
    );

    return result ?? false;
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
          'Mis Solicitudes',
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
                  Text('Cargando tus solicitudes...'),
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

          final sentRequests = provider.sentRequests;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRequestsList(
                sentRequests.where((r) => r.isPending).toList(),
                'pendientes',
              ),
              _buildRequestsList(
                sentRequests.where((r) => r.isAccepted).toList(),
                'aceptadas',
              ),
              _buildRequestsList(
                sentRequests
                    .where((r) => r.isRejected || r.isCancelled)
                    .toList(),
                'rechazadas',
              ),
              _buildRequestsList(sentRequests, 'todas'),
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
              isOwnerView: false,
              onTap: () => _handleRequestAction(request),
              onViewPet: () => context.push('/pets/${request.petId}'),
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
        description = 'Tus solicitudes pendientes de adopción aparecerán aquí.';
        icon = Icons.schedule;
        break;
      case 'aceptadas':
        title = 'Sin solicitudes aceptadas';
        description = '¡Cuando acepten tus solicitudes aparecerán aquí!';
        icon = Icons.check_circle_outline;
        break;
      case 'rechazadas':
        title = 'Sin solicitudes rechazadas';
        description =
            'Las solicitudes rechazadas o canceladas aparecerán aquí.';
        icon = Icons.cancel_outlined;
        break;
      default:
        title = 'Sin solicitudes enviadas';
        description = 'Cuando envíes solicitudes de adopción aparecerán aquí.';
        icon = Icons.send_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
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
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
              textAlign: TextAlign.center,
            ),
            if (type == 'todas') ...[
              const SizedBox(height: 20),
              CustomButton(
                text: 'Explorar Mascotas',
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.pets, size: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
