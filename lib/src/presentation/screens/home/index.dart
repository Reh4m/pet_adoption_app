import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_adoption_app/src/core/data/pet_categories.dart';
import 'package:pet_adoption_app/src/core/data/pets.dart';
import 'package:pet_adoption_app/src/presentation/screens/home/widgets/pet_card.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';

final categories = petCategories;
final pets = petsByCategory;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategoryIndex = 0;
  CarouselSliderController carouselController = CarouselSliderController();
  int currentPetIndex = 0;

  List<Pet> get currentPets => pets[categories[selectedCategoryIndex].id] ?? [];

  @override
  void dispose() {
    super.dispose();
  }

  void _onCategorySelected(int index) {
    setState(() {
      selectedCategoryIndex = index;
      currentPetIndex = 0;
    });

    carouselController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeader(theme),
              const SizedBox(height: 20),
              _buildSearchButton(),
              const SizedBox(height: 20),
              _buildCategories(theme),
              const SizedBox(height: 20),
              Expanded(child: _buildPetCarousel()),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ubicación', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 5),
            Text(
              'Celaya, Guanajuato',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, size: 25),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
    return GestureDetector(
      onTap: () {
        // Navegación a pantalla de búsqueda
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navegando a búsqueda...')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[500], size: 20),
            const SizedBox(width: 12),
            Text(
              'Buscar mascotas...',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categorías',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            CustomButton(
              onPressed: () {},
              text: 'Ver Todas',
              variant: ButtonVariant.text,
              icon: Icon(
                Icons.arrow_forward,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              iconPosition: ButtonIconPosition.right,
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategoryIndex == index;

              return Column(
                children: [
                  InkWell(
                    onTap: () => _onCategorySelected(index),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? category.color
                                : category.color.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        category.icon,
                        size: 30,
                        color:
                            isSelected
                                ? theme.colorScheme.onPrimary
                                : category.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    category.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPetCarousel() {
    if (currentPets.isEmpty) {
      return const Center(
        child: Text(
          'No hay mascotas disponibles',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return CarouselSlider(
      carouselController: carouselController,
      items: currentPets.map((pet) => PetCard(pet: pet)).toList(),
      options: CarouselOptions(
        height: double.infinity,
        enlargeCenterPage: true,
        onPageChanged: (index, reason) {
          setState(() {
            HapticFeedback.selectionClick();
            currentPetIndex = index % currentPets.length;
          });
        },
      ),
    );
  }
}
