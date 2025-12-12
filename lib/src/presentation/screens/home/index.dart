import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/core/data/pet_categories.dart';
import 'package:pet_adoption_app/src/presentation/providers/pet_provider.dart';
import 'package:pet_adoption_app/src/presentation/screens/home/widgets/pet_card.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:provider/provider.dart';

final categories = petCategories;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategoryIndex = 0;
  CarouselSliderController carouselController = CarouselSliderController();
  int currentPetIndex = 0;

  late final PetProvider _petProvider;

  String get selectedCategoryName =>
      categories[selectedCategoryIndex].name.toLowerCase();

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    _petProvider = context.read<PetProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _petProvider.startCategoryListener(selectedCategoryName);
      }
    });
  }

  void _onCategorySelected(int index) {
    // Detener listener de categoría anterior
    _petProvider.stopCategoryListener(selectedCategoryName);

    setState(() {
      selectedCategoryIndex = index;
      currentPetIndex = 0;
    });

    // Iniciar listener para nueva categoría
    _petProvider.startCategoryListener(selectedCategoryName);

    carouselController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleRefresh() async {
    await _petProvider.refreshPets();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(theme),
                const SizedBox(height: 20),
                _buildSearchButton(theme),
                const SizedBox(height: 20),
                _buildCategories(theme),
                const SizedBox(height: 20),
                SizedBox(height: size.height * 0.5, child: _buildPetContent()),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/pet-registration');
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
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
    );
  }

  Widget _buildSearchButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () => context.push('/search-filters'),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: theme.colorScheme.onSurface.withAlpha(100),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Buscar mascotas...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
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
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 20),
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

  Widget _buildPetContent() {
    return Consumer<PetProvider>(
      builder: (context, provider, child) {
        final pets = provider.getPetsByCategory(selectedCategoryName);
        final isLoading = provider.state == PetState.loading && pets.isEmpty;
        final hasError = provider.state == PetState.error;

        if (isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando mascotas...'),
              ],
            ),
          );
        }

        if (hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar mascotas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage ?? 'Error desconocido',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _handleRefresh,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (pets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No hay ${categories[selectedCategoryIndex].name.toLowerCase()} disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sé el primero en publicar un ${categories[selectedCategoryIndex].name.toLowerCase().substring(0, categories[selectedCategoryIndex].name.length - 1)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/pet-registration');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Publicar Mascota'),
                ),
              ],
            ),
          );
        }

        return CarouselSlider(
          carouselController: carouselController,
          items: pets.map((pet) => PetCard(pet: pet)).toList(),
          options: CarouselOptions(
            height: double.infinity,
            enlargeCenterPage: true,
            enableInfiniteScroll: pets.length > 1,
            onPageChanged: (index, reason) {
              setState(() {
                HapticFeedback.selectionClick();
                currentPetIndex = index % pets.length;
              });
            },
          ),
        );
      },
    );
  }
}
