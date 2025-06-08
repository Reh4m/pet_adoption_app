import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_location_entity.dart';

class PetLocationModel extends PetLocationEntity {
  const PetLocationModel({
    required super.latitude,
    required super.longitude,
    required super.address,
    required super.city,
    required super.state,
  });

  factory PetLocationModel.fromMap(Map<String, dynamic> map) {
    return PetLocationModel(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
    );
  }

  factory PetLocationModel.fromGeoPoint(
    GeoPoint geoPoint,
    Map<String, dynamic> addressData,
  ) {
    return PetLocationModel(
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
      address: addressData['address'] ?? '',
      city: addressData['city'] ?? '',
      state: addressData['state'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
    };
  }

  // Convertir a GeoPoint para consultas geográficas en Firestore
  GeoPoint toGeoPoint() {
    return GeoPoint(latitude, longitude);
  }

  factory PetLocationModel.fromEntity(PetLocationEntity entity) {
    return PetLocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
      city: entity.city,
      state: entity.state,
    );
  }

  PetLocationEntity toEntity() {
    return PetLocationEntity(
      latitude: latitude,
      longitude: longitude,
      address: address,
      city: city,
      state: state,
    );
  }
}
