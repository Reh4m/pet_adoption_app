import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/core/data/pet_categories.dart';
import 'package:pet_adoption_app/src/presentation/providers/search_provider.dart';
import 'package:pet_adoption_app/src/presentation/screens/location/location_picker_screen.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:provider/provider.dart';

class SearchFiltersScreen extends StatefulWidget {
  const SearchFiltersScreen({super.key});

  @override
  State<SearchFiltersScreen> createState() => _SearchFiltersScreenState();
}

class _SearchFiltersScreenState extends State<SearchFiltersScreen> {
  late final SearchProvider _searchProvider;

  // Filtros locales antes de aplicar
  List<String> _selectedCategories = [];
  List<String> _selectedSizes = [];
  List<String> _selectedGenders = [];
  List<String> _selectedAges = [];

  @override
  void initState() {
    super.initState();
    _searchProvider = context.read<SearchProvider>();
  }

  Future<void> _pickLocation() async {
    final result = await context.push<LocationPickerResult>('/location-picker');

    if (!mounted || result == null) return;

    _searchProvider.updateSearchRadius(result.radiusKm);
    _searchProvider.setSearchLocation(result.location);

    setState(() {});
  }

  void _applyFilters() async {
    final filters = SearchFilters(
      // query:
      categories: _selectedCategories.isEmpty ? null : _selectedCategories,
      sizes: _selectedSizes.isEmpty ? null : _selectedSizes,
      genders: _selectedGenders.isEmpty ? null : _selectedGenders,
      location: _searchProvider.currentLocation,
      radiusInKm: _searchProvider.searchRadius,
    );

    _searchProvider.updateFilters(filters);

    context.push('/search-results');
  }

  void _clearFilters() {
    setState(() {
      _selectedCategories = [];
      _selectedSizes = [];
      _selectedGenders = [];
      _selectedAges = [];
    });

    _searchProvider.clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(
          'Buscar Mascotas',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _clearFilters,
            tooltip: 'Limpiar filtros',
            icon: Icon(Icons.clear, color: theme.colorScheme.onPrimary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSearchBar(theme),
            const SizedBox(height: 20),
            _buildCategorySelector(theme),
            const SizedBox(height: 20),
            _buildGenderSelector(theme),
            const SizedBox(height: 20),
            _buildSizeSelector(theme),
            const SizedBox(height: 20),
            _buildAgeSelector(theme),
          ],
        ),
      ),
      bottomSheet: _buildContinueButton(theme),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicación',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _pickLocation,
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
                  Icons.location_on_outlined,
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _searchProvider.currentLocation != null
                        ? '${_searchProvider.currentLocation!.address} · ${_searchProvider.searchRadius} km'
                        : 'Selecciona una ubicación',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de mascota',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              petCategories.map((category) {
                final isSelected = _selectedCategories.contains(
                  category.name.toLowerCase(),
                );

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedCategories.remove(category.name.toLowerCase());
                      } else {
                        _selectedCategories.add(category.name.toLowerCase());
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? category.color.withAlpha(20)
                              : theme.cardColor,
                      border:
                          isSelected
                              ? Border.all(color: category.color, width: 2)
                              : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category.icon,
                          color:
                              isSelected
                                  ? category.color
                                  : theme.colorScheme.onSurface.withAlpha(150),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          category.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                isSelected
                                    ? category.color
                                    : theme.colorScheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Género ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: '(opcional)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withAlpha(100),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              petGenders.map((gender) {
                final isSelected = _selectedGenders.contains(
                  gender.name.toLowerCase(),
                );

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedGenders.remove(gender.name.toLowerCase());
                      } else {
                        _selectedGenders.add(gender.name.toLowerCase());
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? gender.color.withAlpha(20)
                              : theme.cardColor,
                      border:
                          isSelected
                              ? Border.all(color: gender.color, width: 2)
                              : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          gender.icon,
                          color:
                              isSelected
                                  ? gender.color
                                  : theme.colorScheme.onSurface.withAlpha(150),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          gender.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                isSelected
                                    ? gender.color
                                    : theme.colorScheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Tamaño ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: '(opcional)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withAlpha(100),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              petSizes.map((size) {
                final isSelected = _selectedSizes.contains(
                  size.name.toLowerCase(),
                );

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedSizes.remove(size.name.toLowerCase());
                      } else {
                        _selectedSizes.add(size.name.toLowerCase());
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? size.color.withAlpha(20)
                              : theme.cardColor,
                      border:
                          isSelected
                              ? Border.all(color: size.color, width: 2)
                              : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      size.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            isSelected
                                ? size.color
                                : theme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildAgeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Edad ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: '(opcional)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withAlpha(100),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              petAges.map((age) {
                final isSelected = _selectedAges.contains(
                  age.name.toLowerCase(),
                );

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedAges.remove(age.name.toLowerCase());
                      } else {
                        _selectedAges.add(age.name.toLowerCase());
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? age.color.withAlpha(20)
                              : theme.cardColor,
                      border:
                          isSelected
                              ? Border.all(color: age.color, width: 2)
                              : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      age.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            isSelected
                                ? age.color
                                : theme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildContinueButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: CustomButton(
        text: 'Buscar Mascotas',
        onPressed: _applyFilters,
        width: double.infinity,
        height: 56,
      ),
    );
  }
}
