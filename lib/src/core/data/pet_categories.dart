import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/core/constants/theme_constants.dart';
import 'package:pet_adoption_app/src/presentation/config/themes/light_theme.dart';

class PetCategory {
  final int id;
  final String name;
  final IconData icon;
  final Color color;

  PetCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

final List<PetCategory> petCategories = [
  PetCategory(id: 1, name: 'Perros', icon: Icons.pets, color: Colors.orange),
  PetCategory(id: 2, name: 'Gatos', icon: Icons.pets, color: Colors.purple),
  PetCategory(
    id: 3,
    name: 'Conejos',
    icon: Icons.cruelty_free,
    color: Colors.pink,
  ),
  PetCategory(
    id: 4,
    name: 'Aves',
    icon: Icons.flutter_dash,
    color: Colors.blue,
  ),
  PetCategory(id: 5, name: 'Peces', icon: Icons.water_drop, color: Colors.cyan),
];

final petGenders = [
  PetCategory(
    id: 1,
    name: 'Macho',
    icon: Icons.male,
    color: ThemeConstants.maleColor,
  ),
  PetCategory(
    id: 2,
    name: 'Hembra',
    icon: Icons.female,
    color: ThemeConstants.femaleColor,
  ),
];

final petSizes = [
  PetCategory(
    id: 1,
    name: 'Pequeño',
    icon: Icons.filter_1,
    color: LightTheme.primaryColor,
  ),
  PetCategory(
    id: 2,
    name: 'Mediano',
    icon: Icons.filter_2,
    color: LightTheme.primaryColor,
  ),
  PetCategory(
    id: 3,
    name: 'Grande',
    icon: Icons.filter_3,
    color: LightTheme.primaryColor,
  ),
];

final petAges = [
  PetCategory(
    id: 1,
    name: 'Bebé',
    icon: Icons.child_care,
    color: LightTheme.primaryColor,
  ),
  PetCategory(
    id: 2,
    name: 'Joven',
    icon: Icons.accessibility_rounded,
    color: LightTheme.primaryColor,
  ),
  PetCategory(
    id: 3,
    name: 'Adulto',
    icon: Icons.person,
    color: LightTheme.primaryColor,
  ),
  PetCategory(
    id: 4,
    name: 'Senior',
    icon: Icons.elderly,
    color: LightTheme.primaryColor,
  ),
];
