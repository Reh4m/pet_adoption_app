import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_adoption_app/src/data/models/pet/pet_location_model.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';

class PetModel extends PetEntity {
  const PetModel({
    required super.id,
    required super.name,
    required super.ageInMonths,
    required super.weight,
    required super.size,
    required super.breed,
    required super.color,
    required super.gender,
    required super.category,
    required super.vaccinated,
    required super.sterilized,
    required super.medicalConditions,
    required super.goodWithKids,
    required super.goodWithPets,
    required super.goodWithStrangers,
    required super.description,
    required super.imageUrls,
    required super.location,
    required super.ownerId,
    required super.status,
    required super.createdAt,
    super.updatedAt,
    super.adoptedBy,
    super.adoptionDate,
    super.searchTags,
  });

  factory PetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PetModel(
      id: doc.id,
      name: data['name'] ?? '',
      ageInMonths: data['ageInMonths'] ?? 0,
      weight: (data['weight'] ?? 0.0).toDouble(),
      size: _parsePetSize(data['size']),
      breed: data['breed'] ?? '',
      color: data['color'] ?? '',
      gender: _parsePetGender(data['gender']),
      category: data['category'] ?? '',
      vaccinated: data['vaccinated'] ?? false,
      sterilized: data['sterilized'] ?? false,
      medicalConditions: List<String>.from(data['medicalConditions'] ?? []),
      goodWithKids: data['goodWithKids'] ?? false,
      goodWithPets: data['goodWithPets'] ?? false,
      goodWithStrangers: data['goodWithStrangers'] ?? false,
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      location: PetLocationModel.fromMap(data['location'] ?? {}),
      ownerId: data['ownerId'] ?? '',
      status: _parsePetStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      adoptedBy: data['adoptedBy'],
      adoptionDate: (data['adoptionDate'] as Timestamp?)?.toDate(),
      searchTags: List<String>.from(data['searchTags'] ?? []),
    );
  }

  factory PetModel.fromMap(Map<String, dynamic> map) {
    return PetModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      ageInMonths: map['ageInMonths'] ?? 0,
      weight: (map['weight'] ?? 0.0).toDouble(),
      size: _parsePetSize(map['size']),
      breed: map['breed'] ?? '',
      color: map['color'] ?? '',
      gender: _parsePetGender(map['gender']),
      category: map['category'] ?? '',
      vaccinated: map['vaccinated'] ?? false,
      sterilized: map['sterilized'] ?? false,
      medicalConditions: List<String>.from(map['medicalConditions'] ?? []),
      goodWithKids: map['goodWithKids'] ?? false,
      goodWithPets: map['goodWithPets'] ?? false,
      goodWithStrangers: map['goodWithStrangers'] ?? false,
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      location: PetLocationModel.fromMap(map['location'] ?? {}),
      ownerId: map['ownerId'] ?? '',
      status: _parsePetStatus(map['status']),
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt:
          map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['updatedAt'] ?? ''),
      adoptedBy: map['adoptedBy'],
      adoptionDate:
          map['adoptionDate'] is Timestamp
              ? (map['adoptionDate'] as Timestamp).toDate()
              : DateTime.tryParse(map['adoptionDate'] ?? ''),
      searchTags: List<String>.from(map['searchTags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'ageInMonths': ageInMonths,
      'weight': weight,
      'size': size.name,
      'breed': breed,
      'color': color,
      'gender': gender.name,
      'category': category,
      'vaccinated': vaccinated,
      'sterilized': sterilized,
      'medicalConditions': medicalConditions,
      'goodWithKids': goodWithKids,
      'goodWithPets': goodWithPets,
      'goodWithStrangers': goodWithStrangers,
      'description': description,
      'imageUrls': imageUrls,
      'location': (location as PetLocationModel).toMap(),
      'ownerId': ownerId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'adoptedBy': adoptedBy,
      'adoptionDate':
          adoptionDate != null ? Timestamp.fromDate(adoptionDate!) : null,
      'searchTags': _generateSearchTags(),
    };
  }

  factory PetModel.fromEntity(PetEntity entity) {
    return PetModel(
      id: entity.id,
      name: entity.name,
      ageInMonths: entity.ageInMonths,
      weight: entity.weight,
      size: entity.size,
      breed: entity.breed,
      color: entity.color,
      gender: entity.gender,
      category: entity.category,
      vaccinated: entity.vaccinated,
      sterilized: entity.sterilized,
      medicalConditions: entity.medicalConditions,
      goodWithKids: entity.goodWithKids,
      goodWithPets: entity.goodWithPets,
      goodWithStrangers: entity.goodWithStrangers,
      description: entity.description,
      imageUrls: entity.imageUrls,
      location: entity.location,
      ownerId: entity.ownerId,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      adoptedBy: entity.adoptedBy,
      adoptionDate: entity.adoptionDate,
      searchTags: entity.searchTags,
    );
  }

  // Métodos de parseo privados
  static PetSize _parsePetSize(String? size) {
    switch (size?.toLowerCase()) {
      case 'small':
        return PetSize.small;
      case 'medium':
        return PetSize.medium;
      case 'large':
        return PetSize.large;
      default:
        return PetSize.medium;
    }
  }

  static PetGender _parsePetGender(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
        return PetGender.male;
      case 'female':
        return PetGender.female;
      default:
        return PetGender.male;
    }
  }

  static PetStatus _parsePetStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return PetStatus.available;
      case 'pending':
        return PetStatus.pending;
      case 'adopted':
        return PetStatus.adopted;
      default:
        return PetStatus.available;
    }
  }

  // Generar tags de búsqueda automáticamente
  List<String> _generateSearchTags() {
    final tags = <String>{
      name.toLowerCase(),
      breed.toLowerCase(),
      color.toLowerCase(),
      category.toLowerCase(),
      size.name,
      gender.name,
      ...medicalConditions.map((e) => e.toLowerCase()),
      if (vaccinated) 'vacunado',
      if (sterilized) 'esterilizado',
      if (goodWithKids) 'bueno con niños',
      if (goodWithPets) 'bueno con mascotas',
      if (goodWithStrangers) 'sociable',
    };

    return tags.toList();
  }
}
