import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/data/models/onboarding_model.dart';

class OnboardingData {
  static const List<OnboardingModel> pages = [
    OnboardingModel(
      title: 'Encuentra un amigo, da un hogar',
      description:
          'Adopta una mascota y dale una segunda oportunidad a un ser querido.',
      iconData: 'pets',
    ),
    OnboardingModel(
      title: 'Adopta con amor',
      description: 'Cada mascota merece un hogar lleno de amor y cuidado.',
      iconData: 'favorite',
    ),
    OnboardingModel(
      title: 'Únete a nuestra comunidad',
      description:
          'Conéctate con otros amantes de las mascotas y comparte tu experiencia.',
      iconData: 'community',
    ),
    OnboardingModel(
      title: 'Haz la diferencia',
      description:
          'Tu decisión de adoptar puede cambiar la vida de una mascota para siempre.',
      iconData: 'difference',
    ),
  ];

  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'pets':
        return Icons.pets;
      case 'favorite':
        return Icons.favorite;
      case 'home':
        return Icons.home;
      case 'community':
        return Icons.group;
      case 'difference':
        return Icons.change_circle;
      default:
        return Icons.info;
    }
  }
}
