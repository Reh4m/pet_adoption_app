import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/core/di/index.dart';
import 'package:pet_adoption_app/src/core/errors/failures.dart';
import 'package:pet_adoption_app/src/domain/entities/adoption_request_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/chat/chat_entity.dart';
import 'package:pet_adoption_app/src/domain/usecases/adoption_integration_usecases.dart';
import 'package:pet_adoption_app/src/domain/usecases/adoption_requests_usecases.dart';
import 'package:pet_adoption_app/src/presentation/providers/chat_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';

enum AdoptionRequestState { initial, loading, success, error }

class AdoptionRequestProvider extends ChangeNotifier {
  final CreateAdoptionRequestUseCase _createRequestUseCase =
      sl<CreateAdoptionRequestUseCase>();
  final GetReceivedRequestsUseCase _getReceivedRequestsUseCase =
      sl<GetReceivedRequestsUseCase>();
  final GetSentRequestsUseCase _getSentRequestsUseCase =
      sl<GetSentRequestsUseCase>();
  final GetRequestsForPetUseCase _getRequestsForPetUseCase =
      sl<GetRequestsForPetUseCase>();
  final HasExistingRequestUseCase _hasExistingRequestUseCase =
      sl<HasExistingRequestUseCase>();
  final AcceptRequestUseCase _acceptRequestUseCase = sl<AcceptRequestUseCase>();
  final RejectRequestUseCase _rejectRequestUseCase = sl<RejectRequestUseCase>();
  final CancelRequestUseCase _cancelRequestUseCase = sl<CancelRequestUseCase>();
  final CompleteRequestUseCase _completeRequestUseCase =
      sl<CompleteRequestUseCase>();
  final GetRequestStatisticsUseCase _getRequestStatisticsUseCase =
      sl<GetRequestStatisticsUseCase>();
  final InitiateChatFromAdoptionRequestUseCase _initiateChatUseCase =
      sl<InitiateChatFromAdoptionRequestUseCase>();
  final SendAdoptionStatusUpdateUseCase _sendStatusUpdateUseCase =
      sl<SendAdoptionStatusUpdateUseCase>();

  AdoptionRequestState _state = AdoptionRequestState.initial;
  String? _errorMessage;

  AdoptionRequestState _createState = AdoptionRequestState.initial;
  AdoptionRequestState _responseState = AdoptionRequestState.initial;
  String? _createError;
  String? _responseError;

  List<AdoptionRequestEntity> _receivedRequests = [];
  List<AdoptionRequestEntity> _sentRequests = [];
  Map<String, List<AdoptionRequestEntity>> _petRequests = {};
  Map<String, int> _requestStatistics = {};

  StreamSubscription? _receivedRequestsSubscription;
  StreamSubscription? _sentRequestsSubscription;
  final Map<String, StreamSubscription> _petRequestsSubscriptions = {};

  AdoptionRequestState get state => _state;
  String? get errorMessage => _errorMessage;

  AdoptionRequestState get createState => _createState;
  String? get createError => _createError;

  AdoptionRequestState get responseState => _responseState;
  String? get responseError => _responseError;

  List<AdoptionRequestEntity> get receivedRequests =>
      List.from(_receivedRequests);
  List<AdoptionRequestEntity> get sentRequests => List.from(_sentRequests);
  Map<String, int> get requestStatistics => Map.from(_requestStatistics);

  List<AdoptionRequestEntity> getRequestsForPet(String petId) {
    return List.from(_petRequests[petId] ?? []);
  }

  int get pendingReceivedCount =>
      _receivedRequests.where((r) => r.isPending).length;

  int get pendingSentCount => _sentRequests.where((r) => r.isPending).length;

  Future<String?> createAdoptionRequest(AdoptionRequestEntity request) async {
    _setCreateState(AdoptionRequestState.loading);

    final result = await _createRequestUseCase(request);

    return result.fold(
      (failure) {
        _setCreateError(_mapFailureToMessage(failure));
        return null;
      },
      (requestId) {
        _setCreateState(AdoptionRequestState.success);
        return requestId;
      },
    );
  }

  Future<bool> hasExistingRequest(String petId, String requesterId) async {
    final result = await _hasExistingRequestUseCase(petId, requesterId);

    return result.fold((failure) => false, (exists) => exists);
  }

  void startReceivedRequestsListener(String ownerId) {
    _setState(AdoptionRequestState.loading);

    _receivedRequestsSubscription = _getReceivedRequestsUseCase(ownerId).listen(
      (either) {
        either.fold((failure) => _setError(_mapFailureToMessage(failure)), (
          requests,
        ) {
          _receivedRequests = requests;
          _setState(AdoptionRequestState.success);
        });
      },
      onError: (error) => _setError('Error de conexión: $error'),
    );
  }

  void startSentRequestsListener(String requesterId) {
    _setState(AdoptionRequestState.loading);

    _sentRequestsSubscription = _getSentRequestsUseCase(requesterId).listen((
      either,
    ) {
      either.fold((failure) => _setError(_mapFailureToMessage(failure)), (
        requests,
      ) {
        _sentRequests = requests;
        _setState(AdoptionRequestState.success);
      });
    }, onError: (error) => _setError('Error de conexión: $error'));
  }

  void startPetRequestsListener(String petId) {
    // Evitar múltiples listeners para la misma mascota
    if (_petRequestsSubscriptions.containsKey(petId)) return;

    _petRequestsSubscriptions[petId] = _getRequestsForPetUseCase(petId).listen((
      either,
    ) {
      either.fold((failure) => _setError(_mapFailureToMessage(failure)), (
        requests,
      ) {
        _petRequests[petId] = requests;
        notifyListeners();
      });
    }, onError: (error) => _setError('Error de conexión: $error'));
  }

  Future<bool> acceptRequest(String requestId, {String? notes}) async {
    _setResponseState(AdoptionRequestState.loading);

    final result = await _acceptRequestUseCase(requestId, notes: notes);

    return result.fold(
      (failure) {
        _setResponseError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setResponseState(AdoptionRequestState.success);
        return true;
      },
    );
  }

  Future<bool> rejectRequest(
    String requestId, {
    required String rejectionReason,
  }) async {
    _setResponseState(AdoptionRequestState.loading);

    final result = await _rejectRequestUseCase(
      requestId,
      rejectionReason: rejectionReason,
    );

    return result.fold(
      (failure) {
        _setResponseError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setResponseState(AdoptionRequestState.success);
        return true;
      },
    );
  }

  Future<bool> cancelRequest(String requestId) async {
    _setResponseState(AdoptionRequestState.loading);

    final result = await _cancelRequestUseCase(requestId);

    return result.fold(
      (failure) {
        _setResponseError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setResponseState(AdoptionRequestState.success);
        return true;
      },
    );
  }

  Future<bool> completeRequest(String requestId, {String? notes}) async {
    _setResponseState(AdoptionRequestState.loading);

    final result = await _completeRequestUseCase(requestId, notes: notes);

    return result.fold(
      (failure) {
        _setResponseError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setResponseState(AdoptionRequestState.success);
        return true;
      },
    );
  }

  Future<void> loadRequestStatistics(String userId) async {
    final result = await _getRequestStatisticsUseCase(userId);

    result.fold((failure) => _setError(_mapFailureToMessage(failure)), (
      statistics,
    ) {
      _requestStatistics = statistics;
      notifyListeners();
    });
  }

  Future<ChatEntity?> initiateChatFromRequest(String adoptionRequestId) async {
    final result = await _initiateChatUseCase(adoptionRequestId);

    return result.fold((failure) {
      _setError(_mapFailureToMessage(failure));
      return null;
    }, (chat) => chat);
  }

  Future<bool> acceptRequestWithChat(String requestId, {String? notes}) async {
    _setResponseState(AdoptionRequestState.loading);

    // Primero aceptar la solicitud
    final acceptResult = await _acceptRequestUseCase(requestId, notes: notes);

    return await acceptResult.fold(
      (failure) async {
        _setResponseError(_mapFailureToMessage(failure));
        return false;
      },
      (_) async {
        // Obtener la solicitud para tener los datos completos
        final request = _receivedRequests.firstWhere((r) => r.id == requestId);

        // Crear chat automáticamente
        final chatProvider = sl<ChatProvider>();
        final userProvider = sl<UserProvider>();

        final currentUser = userProvider.currentUser;

        if (currentUser != null) {
          await chatProvider.createOrGetChat(
            adoptionRequestId: requestId,
            petId: request.petId,
            petName: request.petName,
            petImageUrls: request.petImageUrls,
            requesterId: request.requesterId,
            requesterName: request.requesterName,
            requesterPhotoUrl: request.requesterPhotoUrl,
            ownerId: currentUser.id,
            ownerName: currentUser.displayName,
            ownerPhotoUrl: currentUser.photoUrl,
          );
        }

        // Enviar mensaje del sistema al chat
        await _sendStatusUpdateUseCase(
          adoptionRequestId: requestId,
          newStatus: AdoptionRequestStatus.accepted,
          additionalMessage: notes,
        );

        _setResponseState(AdoptionRequestState.success);
        return true;
      },
    );
  }

  Future<bool> rejectRequestWithChat(
    String requestId, {
    required String rejectionReason,
  }) async {
    _setResponseState(AdoptionRequestState.loading);

    // Primero rechazar la solicitud
    final rejectResult = await _rejectRequestUseCase(
      requestId,
      rejectionReason: rejectionReason,
    );

    return await rejectResult.fold(
      (failure) async {
        _setResponseError(_mapFailureToMessage(failure));
        return false;
      },
      (_) async {
        // Luego enviar mensaje del sistema al chat
        await _sendStatusUpdateUseCase(
          adoptionRequestId: requestId,
          newStatus: AdoptionRequestStatus.rejected,
          additionalMessage: rejectionReason,
        );

        _setResponseState(AdoptionRequestState.success);
        return true;
      },
    );
  }

  void stopAllListeners() {
    _receivedRequestsSubscription?.cancel();
    _sentRequestsSubscription?.cancel();

    for (final subscription in _petRequestsSubscriptions.values) {
      subscription.cancel();
    }
    _petRequestsSubscriptions.clear();
  }

  void stopPetRequestsListener(String petId) {
    _petRequestsSubscriptions[petId]?.cancel();
    _petRequestsSubscriptions.remove(petId);
  }

  void _setState(AdoptionRequestState newState) {
    _state = newState;
    if (newState != AdoptionRequestState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(AdoptionRequestState.error);
  }

  void _setCreateState(AdoptionRequestState newState) {
    _createState = newState;
    if (newState != AdoptionRequestState.error) {
      _createError = null;
    }
    notifyListeners();
  }

  void _setCreateError(String message) {
    _createError = message;
    _setCreateState(AdoptionRequestState.error);
  }

  void _setResponseState(AdoptionRequestState newState) {
    _responseState = newState;
    if (newState != AdoptionRequestState.error) {
      _responseError = null;
    }
    notifyListeners();
  }

  void _setResponseError(String message) {
    _responseError = message;
    _setResponseState(AdoptionRequestState.error);
  }

  void clearCreateState() {
    _createState = AdoptionRequestState.initial;
    _createError = null;
    notifyListeners();
  }

  void clearResponseState() {
    _responseState = AdoptionRequestState.initial;
    _responseError = null;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return 'Sin conexión a internet';
      case const (ServerFailure):
        return 'Error del servidor';
      case const (AdoptionRequestNotFoundFailure):
        return 'Solicitud no encontrada';
      case const (DuplicateAdoptionRequestFailure):
        return 'Ya tienes una solicitud pendiente para esta mascota';
      case const (InvalidAdoptionRequestStatusFailure):
        return 'Estado de solicitud inválido';
      case const (AdoptionRequestAccessDeniedFailure):
        return 'No tienes permisos para esta acción';
      default:
        return 'Error inesperado';
    }
  }

  @override
  void dispose() {
    stopAllListeners();
    super.dispose();
  }
}
