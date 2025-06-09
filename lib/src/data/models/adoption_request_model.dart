import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_adoption_app/src/domain/entities/adoption_request_entity.dart';

class AdoptionRequestModel extends AdoptionRequestEntity {
  const AdoptionRequestModel({
    required super.id,
    required super.petId,
    required super.petName,
    required super.petImageUrls,
    required super.requesterId,
    required super.requesterName,
    super.requesterPhotoUrl,
    required super.ownerId,
    required super.ownerName,
    required super.status,
    required super.message,
    required super.createdAt,
    super.updatedAt,
    super.responseDate,
    super.rejectionReason,
    super.notes,
  });

  factory AdoptionRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AdoptionRequestModel(
      id: doc.id,
      petId: data['petId'] ?? '',
      petName: data['petName'] ?? '',
      petImageUrls: List<String>.from(data['petImageUrls'] ?? []),
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? '',
      requesterPhotoUrl: data['requesterPhotoUrl'],
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      status: _parseStatus(data['status']),
      message: data['message'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      responseDate: (data['responseDate'] as Timestamp?)?.toDate(),
      rejectionReason: data['rejectionReason'],
      notes: data['notes'],
    );
  }

  factory AdoptionRequestModel.fromMap(Map<String, dynamic> map) {
    return AdoptionRequestModel(
      id: map['id'] ?? '',
      petId: map['petId'] ?? '',
      petName: map['petName'] ?? '',
      petImageUrls: List<String>.from(map['petImageUrls'] ?? []),
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      requesterPhotoUrl: map['requesterPhotoUrl'],
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      status: _parseStatus(map['status']),
      message: map['message'] ?? '',
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt:
          map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['updatedAt'] ?? ''),
      responseDate:
          map['responseDate'] is Timestamp
              ? (map['responseDate'] as Timestamp).toDate()
              : DateTime.tryParse(map['responseDate'] ?? ''),
      rejectionReason: map['rejectionReason'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'petName': petName,
      'petImageUrls': petImageUrls,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterPhotoUrl': requesterPhotoUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'status': status.name,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'responseDate':
          responseDate != null ? Timestamp.fromDate(responseDate!) : null,
      'rejectionReason': rejectionReason,
      'notes': notes,
    };
  }

  factory AdoptionRequestModel.fromEntity(AdoptionRequestEntity entity) {
    return AdoptionRequestModel(
      id: entity.id,
      petId: entity.petId,
      petName: entity.petName,
      petImageUrls: entity.petImageUrls,
      requesterId: entity.requesterId,
      requesterName: entity.requesterName,
      requesterPhotoUrl: entity.requesterPhotoUrl,
      ownerId: entity.ownerId,
      ownerName: entity.ownerName,
      status: entity.status,
      message: entity.message,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      responseDate: entity.responseDate,
      rejectionReason: entity.rejectionReason,
      notes: entity.notes,
    );
  }

  AdoptionRequestEntity toEntity() {
    return AdoptionRequestEntity(
      id: id,
      petId: petId,
      petName: petName,
      petImageUrls: petImageUrls,
      requesterId: requesterId,
      requesterName: requesterName,
      requesterPhotoUrl: requesterPhotoUrl,
      ownerId: ownerId,
      ownerName: ownerName,
      status: status,
      message: message,
      createdAt: createdAt,
      updatedAt: updatedAt,
      responseDate: responseDate,
      rejectionReason: rejectionReason,
      notes: notes,
    );
  }

  static AdoptionRequestStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return AdoptionRequestStatus.pending;
      case 'accepted':
        return AdoptionRequestStatus.accepted;
      case 'rejected':
        return AdoptionRequestStatus.rejected;
      case 'cancelled':
        return AdoptionRequestStatus.cancelled;
      case 'completed':
        return AdoptionRequestStatus.completed;
      default:
        return AdoptionRequestStatus.pending;
    }
  }
}
