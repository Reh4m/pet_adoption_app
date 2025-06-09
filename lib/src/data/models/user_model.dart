import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_adoption_app/src/data/models/pet/pet_location_model.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_location_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.photoUrl,
    super.phoneNumber,
    super.location,
    super.bio,
    required super.createdAt,
    super.updatedAt,
    required super.authProvider,
    super.petsPosted,
    super.petsAdopted,
    super.notificationsEnabled,
    super.emailNotificationsEnabled,
    super.searchRadius,
    super.isActive,
    super.isVerified,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      location:
          data['location'] != null
              ? PetLocationModel.fromMap(data['location'])
              : null,
      bio: data['bio'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      authProvider: _parseAuthProvider(data['authProvider']),
      petsPosted: data['petsPosted'] ?? 0,
      petsAdopted: data['petsAdopted'] ?? 0,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      emailNotificationsEnabled: data['emailNotificationsEnabled'] ?? true,
      searchRadius: (data['searchRadius'] ?? 50.0).toDouble(),
      isActive: data['isActive'] ?? true,
      isVerified: data['isVerified'] ?? false,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      location:
          map['location'] != null
              ? PetLocationModel.fromMap(map['location'])
              : null,
      bio: map['bio'],
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt:
          map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['updatedAt'] ?? ''),
      authProvider: _parseAuthProvider(map['authProvider']),
      petsPosted: map['petsPosted'] ?? 0,
      petsAdopted: map['petsAdopted'] ?? 0,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      emailNotificationsEnabled: map['emailNotificationsEnabled'] ?? true,
      searchRadius: (map['searchRadius'] ?? 50.0).toDouble(),
      isActive: map['isActive'] ?? true,
      isVerified: map['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'location': location != null ? _locationToMap(location!) : null,
      'bio': bio,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'authProvider': authProvider.name,
      'petsPosted': petsPosted,
      'petsAdopted': petsAdopted,
      'notificationsEnabled': notificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'searchRadius': searchRadius,
      'isActive': isActive,
      'isVerified': isVerified,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'location': location != null ? _locationToMap(location!) : null,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'authProvider': authProvider.name,
      'petsPosted': petsPosted,
      'petsAdopted': petsAdopted,
      'notificationsEnabled': notificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'searchRadius': searchRadius,
      'isActive': isActive,
      'isVerified': isVerified,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      photoUrl: entity.photoUrl,
      phoneNumber: entity.phoneNumber,
      location: entity.location,
      bio: entity.bio,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      authProvider: entity.authProvider,
      petsPosted: entity.petsPosted,
      petsAdopted: entity.petsAdopted,
      notificationsEnabled: entity.notificationsEnabled,
      emailNotificationsEnabled: entity.emailNotificationsEnabled,
      searchRadius: entity.searchRadius,
      isActive: entity.isActive,
      isVerified: entity.isVerified,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      location: location,
      bio: bio,
      createdAt: createdAt,
      updatedAt: updatedAt,
      authProvider: authProvider,
      petsPosted: petsPosted,
      petsAdopted: petsAdopted,
      notificationsEnabled: notificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled,
      searchRadius: searchRadius,
      isActive: isActive,
      isVerified: isVerified,
    );
  }

  Map<String, dynamic> _locationToMap(PetLocationEntity location) {
    return {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'address': location.address,
      'city': location.city,
      'state': location.state,
    };
  }

  static UserAuthProvider _parseAuthProvider(String? provider) {
    switch (provider?.toLowerCase()) {
      case 'email':
        return UserAuthProvider.email;
      case 'google':
        return UserAuthProvider.google;
      default:
        return UserAuthProvider.email;
    }
  }

  // Crear UserModel con campos actualizados
  @override
  UserModel copyWith({
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
    return UserModel(
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
}
