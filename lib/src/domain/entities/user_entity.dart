import 'package:equatable/equatable.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_location_entity.dart';

enum UserAuthProvider { email, google }

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
  final UserAuthProvider authProvider;

  // Estadísticas del usuario
  final int petsPosted;
  final int petsAdopted;

  // Configuraciones
  final bool notificationsEnabled;
  final bool emailNotificationsEnabled;
  final double searchRadius;

  // Estado del usuario
  final bool isActive;
  final bool isVerified;

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
    required this.authProvider,
    this.petsPosted = 0,
    this.petsAdopted = 0,
    this.notificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.searchRadius = 50.0,
    this.isActive = true,
    this.isVerified = false,
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
    authProvider,
    petsPosted,
    petsAdopted,
    notificationsEnabled,
    emailNotificationsEnabled,
    searchRadius,
    isActive,
    isVerified,
  ];

  bool get hasLocation => location != null;
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
  bool get hasPhone => phoneNumber != null && phoneNumber!.isNotEmpty;
  bool get hasBio => bio != null && bio!.isNotEmpty;
  bool get isExperienced => petsPosted > 0 || petsAdopted > 0;
  bool get isEmailProvider => authProvider == UserAuthProvider.email;
  bool get isGoogleProvider => authProvider == UserAuthProvider.google;

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
    UserAuthProvider? authProvider,
    int? petsPosted,
    int? petsAdopted,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    double? searchRadius,
    bool? isActive,
    bool? isVerified,
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
      authProvider: authProvider ?? this.authProvider,
      petsPosted: petsPosted ?? this.petsPosted,
      petsAdopted: petsAdopted ?? this.petsAdopted,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      searchRadius: searchRadius ?? this.searchRadius,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  String get displayName {
    if (name.isNotEmpty) return name;
    return email.split('@').first;
  }

  bool get canEditPhoto => isEmailProvider;

  String get initials {
    final nameParts = displayName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }
}
