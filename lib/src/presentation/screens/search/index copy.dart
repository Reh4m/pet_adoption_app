// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:pet_adoption_app/src/core/data/pet_categories.dart';
// import 'package:pet_adoption_app/src/presentation/providers/search_provider.dart';
// import 'package:pet_adoption_app/src/presentation/screens/search/widgets/filter_section.dart';
// import 'package:pet_adoption_app/src/presentation/screens/search/widgets/search_results_grid.dart';
// import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
// import 'package:provider/provider.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   late final SearchProvider _searchProvider;

//   // Filtros locales antes de aplicar
//   List<String> _selectedCategories = [];
//   List<String> _selectedSizes = [];
//   List<String> _selectedGenders = [];
//   bool? _vaccinated;
//   bool? _sterilized;
//   bool? _goodWithKids;
//   bool? _goodWithPets;
//   int? _minAge;
//   int? _maxAge;

//   @override
//   void initState() {
//     super.initState();
//     _searchProvider = context.read<SearchProvider>();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _showLocationPicker() async {
//     final result = await context.push('/location-picker');

//     if (result != null && mounted) {
//       _searchProvider.searchWithFilters();
//     }
//   }

//   void _applyFilters() {
//     final filters = SearchFilters(
//       query:
//           _searchController.text.trim().isEmpty
//               ? null
//               : _searchController.text.trim(),
//       categories: _selectedCategories.isEmpty ? null : _selectedCategories,
//       sizes: _selectedSizes.isEmpty ? null : _selectedSizes,
//       genders: _selectedGenders.isEmpty ? null : _selectedGenders,
//       vaccinated: _vaccinated,
//       sterilized: _sterilized,
//       goodWithKids: _goodWithKids,
//       goodWithPets: _goodWithPets,
//       minAge: _minAge,
//       maxAge: _maxAge,
//       location: _searchProvider.currentLocation,
//       radiusInKm: _searchProvider.searchRadius,
//     );

//     _searchProvider.updateFilters(filters);
//     _searchProvider.searchWithFilters();
//   }

//   void _clearFilters() {
//     setState(() {
//       _searchController.clear();
//       _selectedCategories = [];
//       _selectedSizes = [];
//       _selectedGenders = [];
//       _vaccinated = null;
//       _sterilized = null;
//       _goodWithKids = null;
//       _goodWithPets = null;
//       _minAge = null;
//       _maxAge = null;
//     });

//     _searchProvider.clearFilters();
//   }

//   void _showFiltersBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => _buildFiltersSheet(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: theme.colorScheme.primary,
//         foregroundColor: theme.colorScheme.onPrimary,
//         title: Text(
//           'Buscar Mascotas',
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.w600,
//             color: theme.colorScheme.onPrimary,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           _buildSearchBar(theme),
//           _buildFiltersBar(theme),
//           Expanded(child: _buildContent()),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: theme.cardColor,
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Buscar por nombre, raza...',
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon:
//                     _searchController.text.isNotEmpty
//                         ? IconButton(
//                           icon: const Icon(Icons.clear),
//                           onPressed: () {
//                             _searchController.clear();
//                             setState(() {});
//                           },
//                         )
//                         : null,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//               ),
//               onChanged: (value) => setState(() {}),
//               onSubmitted: (value) => _applyFilters(),
//             ),
//           ),
//           const SizedBox(width: 10),
//           CustomButton(
//             text: 'Buscar',
//             onPressed: _applyFilters,
//             variant: ButtonVariant.primary,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFiltersBar(ThemeData theme) {
//     return Consumer<SearchProvider>(
//       builder: (context, provider, child) {
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           color: theme.cardColor,
//           child: Row(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: [
//                       _buildFilterChip(
//                         theme,
//                         icon: Icons.location_on,
//                         label:
//                             provider.currentLocation != null
//                                 ? '${provider.searchRadius.toInt()} km'
//                                 : 'Ubicación',
//                         onTap: _showLocationPicker,
//                         isActive: provider.currentLocation != null,
//                       ),
//                       const SizedBox(width: 8),
//                       _buildFilterChip(
//                         theme,
//                         icon: Icons.tune,
//                         label:
//                             'Filtros${provider.filters.activeFiltersCount > 0 ? ' (${provider.filters.activeFiltersCount})' : ''}',
//                         onTap: _showFiltersBottomSheet,
//                         isActive: provider.filters.hasActiveFilters,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (provider.filters.hasActiveFilters) ...[
//                 const SizedBox(width: 8),
//                 TextButton(
//                   onPressed: _clearFilters,
//                   child: Text(
//                     'Limpiar',
//                     style: TextStyle(color: theme.colorScheme.error),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFilterChip(
//     ThemeData theme, {
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     required bool isActive,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color:
//               isActive
//                   ? theme.colorScheme.primary
//                   : theme.colorScheme.primary.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: theme.colorScheme.primary,
//             width: isActive ? 0 : 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 16,
//               color:
//                   isActive
//                       ? theme.colorScheme.onPrimary
//                       : theme.colorScheme.primary,
//             ),
//             const SizedBox(width: 6),
//             Text(
//               label,
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color:
//                     isActive
//                         ? theme.colorScheme.onPrimary
//                         : theme.colorScheme.primary,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContent() {
//     return Consumer<SearchProvider>(
//       builder: (context, provider, child) {
//         if (provider.state == SearchState.initial) {
//           return _buildInitialState();
//         }

//         if (provider.state == SearchState.loading) {
//           return _buildLoadingState();
//         }

//         if (provider.state == SearchState.error) {
//           return _buildErrorState(provider.errorMessage);
//         }

//         if (provider.state == SearchState.locationDenied) {
//           return _buildLocationDeniedState();
//         }

//         if (!provider.hasResults) {
//           return _buildEmptyState();
//         }

//         return SearchResultsGrid(
//           pets: provider.searchResults,
//           onPetTap: (pet) => context.push('/pets/${pet.id}'),
//         );
//       },
//     );
//   }

//   Widget _buildInitialState() {
//     final theme = Theme.of(context);

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(40),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.search,
//               size: 80,
//               color: theme.colorScheme.primary.withOpacity(0.5),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               '¿Buscas una mascota?',
//               style: theme.textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Usa los filtros para encontrar a tu compañero ideal',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: theme.colorScheme.onSurface.withOpacity(0.7),
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(),
//           SizedBox(height: 16),
//           Text('Buscando mascotas...'),
//         ],
//       ),
//     );
//   }

//   Widget _buildErrorState(String? error) {
//     final theme = Theme.of(context);

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(40),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
//             const SizedBox(height: 16),
//             Text(
//               'Error en la búsqueda',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 color: theme.colorScheme.error,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               error ?? 'Error desconocido',
//               style: theme.textTheme.bodyMedium,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             CustomButton(text: 'Reintentar', onPressed: _applyFilters),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLocationDeniedState() {
//     final theme = Theme.of(context);

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(40),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.location_off, size: 64, color: theme.colorScheme.error),
//             const SizedBox(height: 16),
//             Text('Ubicación denegada', style: theme.textTheme.titleLarge),
//             const SizedBox(height: 8),
//             Text(
//               'Necesitamos acceso a tu ubicación para buscar mascotas cerca de ti',
//               style: theme.textTheme.bodyMedium,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             CustomButton(
//               text: 'Configurar permisos',
//               onPressed: () {
//                 // Abrir configuración de la app
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     final theme = Theme.of(context);

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(40),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.pets,
//               size: 80,
//               color: theme.colorScheme.onSurface.withOpacity(0.3),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'No se encontraron mascotas',
//               style: theme.textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Intenta ajustar tus filtros de búsqueda',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: theme.colorScheme.onSurface.withOpacity(0.7),
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             CustomButton(
//               text: 'Limpiar filtros',
//               variant: ButtonVariant.outline,
//               onPressed: _clearFilters,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFiltersSheet() {
//     final theme = Theme.of(context);

//     return DraggableScrollableSheet(
//       initialChildSize: 0.9,
//       minChildSize: 0.5,
//       maxChildSize: 0.95,
//       expand: false,
//       builder: (context, scrollController) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Filtros de búsqueda',
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       setState(() {
//                         _selectedCategories = [];
//                         _selectedSizes = [];
//                         _selectedGenders = [];
//                         _vaccinated = null;
//                         _sterilized = null;
//                         _goodWithKids = null;
//                         _goodWithPets = null;
//                         _minAge = null;
//                         _maxAge = null;
//                       });
//                     },
//                     child: const Text('Limpiar todo'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               Expanded(
//                 child: ListView(
//                   controller: scrollController,
//                   children: [
//                     FilterSection(
//                       title: 'Categorías',
//                       icon: Icons.category,
//                       children:
//                           petCategories.map((category) {
//                             final isSelected = _selectedCategories.contains(
//                               category.name.toLowerCase(),
//                             );
//                             return FilterChip(
//                               label: Text(category.name),
//                               selected: isSelected,
//                               onSelected: (selected) {
//                                 setState(() {
//                                   if (selected) {
//                                     _selectedCategories.add(
//                                       category.name.toLowerCase(),
//                                     );
//                                   } else {
//                                     _selectedCategories.remove(
//                                       category.name.toLowerCase(),
//                                     );
//                                   }
//                                 });
//                               },
//                             );
//                           }).toList(),
//                     ),
//                     const SizedBox(height: 20),
//                     FilterSection(
//                       title: 'Tamaño',
//                       icon: Icons.straighten,
//                       children: [
//                         FilterChip(
//                           label: const Text('Pequeño'),
//                           selected: _selectedSizes.contains('small'),
//                           onSelected: (selected) {
//                             setState(() {
//                               if (selected) {
//                                 _selectedSizes.add('small');
//                               } else {
//                                 _selectedSizes.remove('small');
//                               }
//                             });
//                           },
//                         ),
//                         FilterChip(
//                           label: const Text('Mediano'),
//                           selected: _selectedSizes.contains('medium'),
//                           onSelected: (selected) {
//                             setState(() {
//                               if (selected) {
//                                 _selectedSizes.add('medium');
//                               } else {
//                                 _selectedSizes.remove('medium');
//                               }
//                             });
//                           },
//                         ),
//                         FilterChip(
//                           label: const Text('Grande'),
//                           selected: _selectedSizes.contains('large'),
//                           onSelected: (selected) {
//                             setState(() {
//                               if (selected) {
//                                 _selectedSizes.add('large');
//                               } else {
//                                 _selectedSizes.remove('large');
//                               }
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     FilterSection(
//                       title: 'Género',
//                       icon: Icons.wc,
//                       children: [
//                         FilterChip(
//                           label: const Text('Macho'),
//                           selected: _selectedGenders.contains('male'),
//                           onSelected: (selected) {
//                             setState(() {
//                               if (selected) {
//                                 _selectedGenders.add('male');
//                               } else {
//                                 _selectedGenders.remove('male');
//                               }
//                             });
//                           },
//                         ),
//                         FilterChip(
//                           label: const Text('Hembra'),
//                           selected: _selectedGenders.contains('female'),
//                           onSelected: (selected) {
//                             setState(() {
//                               if (selected) {
//                                 _selectedGenders.add('female');
//                               } else {
//                                 _selectedGenders.remove('female');
//                               }
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     FilterSection(
//                       title: 'Salud',
//                       icon: Icons.medical_services,
//                       children: [
//                         SwitchListTile(
//                           title: const Text('Vacunado'),
//                           value: _vaccinated ?? false,
//                           onChanged: (value) {
//                             setState(() {
//                               _vaccinated = value;
//                             });
//                           },
//                         ),
//                         SwitchListTile(
//                           title: const Text('Esterilizado'),
//                           value: _sterilized ?? false,
//                           onChanged: (value) {
//                             setState(() {
//                               _sterilized = value;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     FilterSection(
//                       title: 'Comportamiento',
//                       icon: Icons.psychology,
//                       children: [
//                         SwitchListTile(
//                           title: const Text('Bueno con niños'),
//                           value: _goodWithKids ?? false,
//                           onChanged: (value) {
//                             setState(() {
//                               _goodWithKids = value;
//                             });
//                           },
//                         ),
//                         SwitchListTile(
//                           title: const Text('Bueno con mascotas'),
//                           value: _goodWithPets ?? false,
//                           onChanged: (value) {
//                             setState(() {
//                               _goodWithPets = value;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   Expanded(
//                     child: CustomButton(
//                       text: 'Cancelar',
//                       variant: ButtonVariant.outline,
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: CustomButton(
//                       text: 'Aplicar filtros',
//                       onPressed: () {
//                         Navigator.pop(context);
//                         _applyFilters();
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
