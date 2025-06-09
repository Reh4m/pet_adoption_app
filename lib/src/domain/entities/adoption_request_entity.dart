import 'package:equatable/equatable.dart';

enum AdoptionRequestStatus { pending, accepted, rejected, cancelled, completed }

class AdoptionRequestEntity extends Equatable {
  final String id;
  final String petId;
  final String petName;
  final List<String> petImageUrls;
  final String requesterId;
  final String requesterName;
  final String? requesterPhotoUrl;
  final String ownerId;
  final String ownerName;
  final AdoptionRequestStatus status;
  final String message;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? responseDate;
  final String? rejectionReason;
  final String? notes;

  const AdoptionRequestEntity({
    required this.id,
    required this.petId,
    required this.petName,
    required this.petImageUrls,
    required this.requesterId,
    required this.requesterName,
    this.requesterPhotoUrl,
    required this.ownerId,
    required this.ownerName,
    required this.status,
    required this.message,
    required this.createdAt,
    this.updatedAt,
    this.responseDate,
    this.rejectionReason,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    petId,
    petName,
    petImageUrls,
    requesterId,
    requesterName,
    requesterPhotoUrl,
    ownerId,
    ownerName,
    status,
    message,
    createdAt,
    updatedAt,
    responseDate,
    rejectionReason,
    notes,
  ];

  String get statusString {
    switch (status) {
      case AdoptionRequestStatus.pending:
        return 'Pendiente';
      case AdoptionRequestStatus.accepted:
        return 'Aceptada';
      case AdoptionRequestStatus.rejected:
        return 'Rechazada';
      case AdoptionRequestStatus.cancelled:
        return 'Cancelada';
      case AdoptionRequestStatus.completed:
        return 'Completada';
    }
  }

  bool get isPending => status == AdoptionRequestStatus.pending;
  bool get isAccepted => status == AdoptionRequestStatus.accepted;
  bool get isRejected => status == AdoptionRequestStatus.rejected;
  bool get isCancelled => status == AdoptionRequestStatus.cancelled;
  bool get isCompleted => status == AdoptionRequestStatus.completed;
  bool get canBeCancelled => status == AdoptionRequestStatus.pending;
  bool get canBeResponded => status == AdoptionRequestStatus.pending;

  AdoptionRequestEntity copyWith({
    String? id,
    String? petId,
    String? petName,
    List<String>? petImageUrls,
    String? requesterId,
    String? requesterName,
    String? requesterPhotoUrl,
    String? ownerId,
    String? ownerName,
    AdoptionRequestStatus? status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? responseDate,
    String? rejectionReason,
    String? notes,
  }) {
    return AdoptionRequestEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      petImageUrls: petImageUrls ?? this.petImageUrls,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterPhotoUrl: requesterPhotoUrl ?? this.requesterPhotoUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      responseDate: responseDate ?? this.responseDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
    );
  }
}
