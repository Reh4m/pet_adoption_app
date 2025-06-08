import 'dart:math' as math;

import 'package:equatable/equatable.dart';

class PetLocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;

  const PetLocationEntity({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
  });

  @override
  List<Object?> get props => [latitude, longitude, address, city, state];

  // Método para calcular distancia (útil para búsquedas por proximidad)
  double distanceTo(PetLocationEntity other) {
    // Implementación simplificada usando fórmula de Haversine
    const double earthRadius = 6371; // Radio de la Tierra en km

    final double dLat = _toRadians(other.latitude - latitude);
    final double dLon = _toRadians(other.longitude - longitude);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitude)) *
            math.cos(_toRadians(other.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  PetLocationEntity copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
  }) {
    return PetLocationEntity(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
    );
  }
}
