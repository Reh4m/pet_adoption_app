import 'package:equatable/equatable.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_location_entity.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? phoneNumber;
  final PetLocationEntity? location;
  final String? bio;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Estadísticas del usuario
  final int petsPosted;
  final int petsAdopted;
  final double rating;
  final int totalReviews;

  // Configuraciones
  final bool notificationsEnabled;
  final bool emailNotificationsEnabled;
  final double searchRadius;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.phoneNumber,
    this.location,
    this.bio,
    required this.createdAt,
    this.updatedAt,
    this.petsPosted = 0,
    this.petsAdopted = 0,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.notificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.searchRadius = 50.0,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    photoUrl,
    phoneNumber,
    location,
    bio,
    createdAt,
    updatedAt,
    petsPosted,
    petsAdopted,
    rating,
    totalReviews,
    notificationsEnabled,
    emailNotificationsEnabled,
    searchRadius,
  ];

  bool get hasLocation => location != null;
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
  bool get hasPhone => phoneNumber != null && phoneNumber!.isNotEmpty;
  bool get hasBio => bio != null && bio!.isNotEmpty;

  String get ratingString => rating.toStringAsFixed(1);

  bool get isExperienced => petsPosted > 0 || petsAdopted > 0;

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? phoneNumber,
    PetLocationEntity? location,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? petsPosted,
    int? petsAdopted,
    double? rating,
    int? totalReviews,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    double? searchRadius,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      petsPosted: petsPosted ?? this.petsPosted,
      petsAdopted: petsAdopted ?? this.petsAdopted,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      searchRadius: searchRadius ?? this.searchRadius,
    );
  }
}
