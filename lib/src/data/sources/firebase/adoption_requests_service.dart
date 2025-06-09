import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_adoption_app/src/core/errors/exceptions.dart';
import 'package:pet_adoption_app/src/data/models/adoption_request_model.dart';
import 'package:pet_adoption_app/src/domain/entities/adoption_request_entity.dart';

class FirebaseAdoptionRequestsService {
  final FirebaseFirestore firestore;

  FirebaseAdoptionRequestsService({required this.firestore});

  static const String _requestsCollection = 'adoption_requests';

  Future<String> createAdoptionRequest(AdoptionRequestModel request) async {
    try {
      final docRef = firestore.collection(_requestsCollection).doc();
      final requestId = docRef.id;

      final requestWithId = AdoptionRequestModel.fromEntity(
        request.copyWith(id: requestId, createdAt: DateTime.now()),
      );

      await docRef.set(requestWithId.toFirestore());
      return requestId;
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<List<AdoptionRequestModel>> getReceivedRequests(String ownerId) {
    try {
      return firestore
          .collection(_requestsCollection)
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => AdoptionRequestModel.fromFirestore(doc))
                    .toList(),
          );
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<List<AdoptionRequestModel>> getSentRequests(String requesterId) {
    try {
      return firestore
          .collection(_requestsCollection)
          .where('requesterId', isEqualTo: requesterId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => AdoptionRequestModel.fromFirestore(doc))
                    .toList(),
          );
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<List<AdoptionRequestModel>> getRequestsForPet(String petId) {
    try {
      return firestore
          .collection(_requestsCollection)
          .where('petId', isEqualTo: petId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => AdoptionRequestModel.fromFirestore(doc))
                    .toList(),
          );
    } catch (e) {
      throw ServerException();
    }
  }

  Future<AdoptionRequestModel> getRequestById(String requestId) async {
    try {
      final doc =
          await firestore.collection(_requestsCollection).doc(requestId).get();

      if (!doc.exists) {
        throw AdoptionRequestNotFoundException();
      }

      return AdoptionRequestModel.fromFirestore(doc);
    } catch (e) {
      if (e is AdoptionRequestNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Future<bool> hasExistingRequest(String petId, String requesterId) async {
    try {
      final query =
          await firestore
              .collection(_requestsCollection)
              .where('petId', isEqualTo: petId)
              .where('requesterId', isEqualTo: requesterId)
              .where('status', isEqualTo: 'pending')
              .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> acceptRequest(String requestId, {String? notes}) async {
    try {
      await firestore.collection(_requestsCollection).doc(requestId).update({
        'status': AdoptionRequestStatus.accepted.name,
        'responseDate': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        if (notes != null) 'notes': notes,
      });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> rejectRequest(
    String requestId, {
    required String rejectionReason,
  }) async {
    try {
      await firestore.collection(_requestsCollection).doc(requestId).update({
        'status': AdoptionRequestStatus.rejected.name,
        'responseDate': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'rejectionReason': rejectionReason,
      });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      await firestore.collection(_requestsCollection).doc(requestId).update({
        'status': AdoptionRequestStatus.cancelled.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> completeRequest(String requestId, {String? notes}) async {
    try {
      await firestore.collection(_requestsCollection).doc(requestId).update({
        'status': AdoptionRequestStatus.completed.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        if (notes != null) 'notes': notes,
      });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<Map<String, int>> getRequestStatistics(String userId) async {
    try {
      // Solicitudes enviadas
      final sentQuery =
          await firestore
              .collection(_requestsCollection)
              .where('requesterId', isEqualTo: userId)
              .get();

      // Solicitudes recibidas
      final receivedQuery =
          await firestore
              .collection(_requestsCollection)
              .where('ownerId', isEqualTo: userId)
              .get();

      int sentPending = 0;
      int sentAccepted = 0;
      int sentRejected = 0;

      for (final doc in sentQuery.docs) {
        final status = doc.data()['status'] as String?;
        switch (status) {
          case 'pending':
            sentPending++;
            break;
          case 'accepted':
            sentAccepted++;
            break;
          case 'rejected':
            sentRejected++;
            break;
        }
      }

      int receivedPending = 0;
      int receivedAccepted = 0;
      int receivedRejected = 0;

      for (final doc in receivedQuery.docs) {
        final status = doc.data()['status'] as String?;
        switch (status) {
          case 'pending':
            receivedPending++;
            break;
          case 'accepted':
            receivedAccepted++;
            break;
          case 'rejected':
            receivedRejected++;
            break;
        }
      }

      return {
        'sentTotal': sentQuery.docs.length,
        'sentPending': sentPending,
        'sentAccepted': sentAccepted,
        'sentRejected': sentRejected,
        'receivedTotal': receivedQuery.docs.length,
        'receivedPending': receivedPending,
        'receivedAccepted': receivedAccepted,
        'receivedRejected': receivedRejected,
      };
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> rejectPendingRequestsForPet(
    String petId,
    String acceptedRequestId,
  ) async {
    try {
      final pendingRequests =
          await firestore
              .collection(_requestsCollection)
              .where('petId', isEqualTo: petId)
              .where('status', isEqualTo: 'pending')
              .get();

      final batch = firestore.batch();

      for (final doc in pendingRequests.docs) {
        if (doc.id != acceptedRequestId) {
          batch.update(doc.reference, {
            'status': AdoptionRequestStatus.rejected.name,
            'responseDate': Timestamp.fromDate(DateTime.now()),
            'updatedAt': Timestamp.fromDate(DateTime.now()),
            'rejectionReason':
                'La mascota ya fue adoptada por otro solicitante.',
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw ServerException();
    }
  }
}
