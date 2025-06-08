import 'package:equatable/equatable.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_location_entity.dart';

enum PetSize { small, medium, large }

enum PetGender { male, female }

enum PetStatus { available, pending, adopted }

class PetEntity extends Equatable {
  final String id;
  final String name;
  final int ageInMonths;
  final double weight;
  final PetSize size;
  final String breed;
  final String color;
  final PetGender gender;
  final String category;

  // Información médica
  final bool vaccinated;
  final bool sterilized;
  final List<String> medicalConditions;

  // Comportamiento
  final bool goodWithKids;
  final bool goodWithPets;
  final bool goodWithStrangers;

  // Información adicional
  final String description;
  final List<String> imageUrls;
  final PetLocationEntity location;

  // Información del dueño y estado
  final String ownerId;
  final PetStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adoptedBy;
  final DateTime? adoptionDate;

  // Información adicional para búsquedas
  final List<String> searchTags;

  const PetEntity({
    required this.id,
    required this.name,
    required this.ageInMonths,
    required this.weight,
    required this.size,
    required this.breed,
    required this.color,
    required this.gender,
    required this.category,
    required this.vaccinated,
    required this.sterilized,
    required this.medicalConditions,
    required this.goodWithKids,
    required this.goodWithPets,
    required this.goodWithStrangers,
    required this.description,
    required this.imageUrls,
    required this.location,
    required this.ownerId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.adoptedBy,
    this.adoptionDate,
    this.searchTags = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    ageInMonths,
    weight,
    size,
    breed,
    color,
    gender,
    category,
    vaccinated,
    sterilized,
    medicalConditions,
    goodWithKids,
    goodWithPets,
    goodWithStrangers,
    description,
    imageUrls,
    location,
    ownerId,
    status,
    createdAt,
    updatedAt,
    adoptedBy,
    adoptionDate,
    searchTags,
  ];

  String get ageString {
    if (ageInMonths < 12) {
      return '$ageInMonths ${ageInMonths == 1 ? 'mes' : 'meses'}';
    }
    final years = ageInMonths ~/ 12;
    final months = ageInMonths % 12;

    if (months == 0) {
      return '$years ${years == 1 ? 'año' : 'años'}';
    }
    return '$years ${years == 1 ? 'año' : 'años'} y $months ${months == 1 ? 'mes' : 'meses'}';
  }

  String get sizeString {
    switch (size) {
      case PetSize.small:
        return 'Pequeño';
      case PetSize.medium:
        return 'Mediano';
      case PetSize.large:
        return 'Grande';
    }
  }

  String get genderString {
    switch (gender) {
      case PetGender.male:
        return 'Macho';
      case PetGender.female:
        return 'Hembra';
    }
  }

  String get statusString {
    switch (status) {
      case PetStatus.available:
        return 'Disponible';
      case PetStatus.pending:
        return 'Pendiente';
      case PetStatus.adopted:
        return 'Adoptado';
    }
  }

  bool get isAvailable => status == PetStatus.available;

  // Método para crear una copia con cambios
  PetEntity copyWith({
    String? id,
    String? name,
    int? ageInMonths,
    double? weight,
    PetSize? size,
    String? breed,
    String? color,
    PetGender? gender,
    String? category,
    bool? vaccinated,
    bool? sterilized,
    List<String>? medicalConditions,
    bool? goodWithKids,
    bool? goodWithPets,
    bool? goodWithStrangers,
    String? description,
    List<String>? imageUrls,
    PetLocationEntity? location,
    String? ownerId,
    PetStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adoptedBy,
    DateTime? adoptionDate,
    List<String>? searchTags,
  }) {
    return PetEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      ageInMonths: ageInMonths ?? this.ageInMonths,
      weight: weight ?? this.weight,
      size: size ?? this.size,
      breed: breed ?? this.breed,
      color: color ?? this.color,
      gender: gender ?? this.gender,
      category: category ?? this.category,
      vaccinated: vaccinated ?? this.vaccinated,
      sterilized: sterilized ?? this.sterilized,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      goodWithKids: goodWithKids ?? this.goodWithKids,
      goodWithPets: goodWithPets ?? this.goodWithPets,
      goodWithStrangers: goodWithStrangers ?? this.goodWithStrangers,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adoptedBy: adoptedBy ?? this.adoptedBy,
      adoptionDate: adoptionDate ?? this.adoptionDate,
      searchTags: searchTags ?? this.searchTags,
    );
  }
}
