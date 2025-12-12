import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/presentation/providers/search_provider.dart';
import 'package:pet_adoption_app/src/presentation/screens/search/widgets/search_results_grid.dart';
import 'package:provider/provider.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final SearchProvider _searchProvider;

  @override
  void initState() {
    super.initState();
    _searchProvider = context.read<SearchProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchProvider.searchWithFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(
          'Resultados de búsqueda',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<SearchProvider>(
        builder: (context, provider, child) {
          if (provider.state == SearchState.loading) {
            return _buildLoadingState();
          }

          if (provider.state == SearchState.error) {
            return _buildErrorState(theme, provider.errorMessage);
          }

          if (provider.state == SearchState.locationDenied) {
            return _buildLocationDeniedState(theme);
          }

          if (!provider.hasResults) {
            return _buildEmptyState(theme);
          }

          return SearchResultsGrid(pets: provider.searchResults);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Buscando mascotas...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error en la búsqueda',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Error desconocido',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDeniedState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Ubicación denegada', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Necesitamos acceso a tu ubicación para buscar mascotas cerca de ti',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 80, color: theme.colorScheme.error),
            const SizedBox(height: 24),
            Text(
              'No se encontraron mascotas',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Intenta ajustar tus filtros de búsqueda',
              style: theme.textTheme.bodyMedium?.copyWith(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
