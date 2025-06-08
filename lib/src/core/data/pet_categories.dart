import 'package:flutter/material.dart';

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
