import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_location_entity.dart';
import 'package:pet_adoption_app/src/presentation/config/themes/light_theme.dart';
import 'package:pet_adoption_app/src/presentation/utils/toast_notification.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';

class LocationPickerResult {
  final PetLocationEntity location;
  final double radiusKm;

  const LocationPickerResult({required this.location, required this.radiusKm});
}

class LocationPickerScreen extends StatefulWidget {
  final PetLocationEntity? initialLocation;
  final double initialRadius;
  final bool showRadiusControl;
  final String title;

  const LocationPickerScreen({
    super.key,
    this.initialLocation,
    this.initialRadius = 5.0,
    this.showRadiusControl = true,
    this.title = 'Seleccionar ubicación',
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController _mapController;
  LatLng _selectedLocation = const LatLng(
    20.5264,
    -100.8147,
  ); // Celaya por defecto
  double _currentRadius = 5.0;
  bool _isLoadingLocation = false;
  bool _isLoadingAddress = false;

  String _currentAddress = 'Ubicación seleccionada';
  String _currentCity = 'Ciudad';
  String _currentState = 'Estado';

  final Set<Circle> _circles = {};
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _currentRadius = widget.initialRadius;

    if (widget.initialLocation != null) {
      _selectedLocation = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _currentAddress = widget.initialLocation!.address;
      _currentCity = widget.initialLocation!.city;
      _currentState = widget.initialLocation!.state;
    } else {
      _getAddressFromCoordinates(_selectedLocation);
    }

    _updateCircle();
  }

  Future<void> _getAddressFromCoordinates(LatLng location) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        setState(() {
          // Construir dirección aproximada
          _currentAddress = _buildAddressString(place);
          _currentCity =
              place.locality ??
              place.subAdministrativeArea ??
              'Ciudad desconocida';
          _currentState = place.administrativeArea ?? 'Estado desconocido';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      print('Error en geocoding reverso: $e');
      setState(() {
        _currentAddress = 'Ubicación seleccionada';
        _currentCity = 'Ciudad';
        _currentState = 'Estado';
        _isLoadingAddress = false;
      });
    }
  }

  String _buildAddressString(Placemark place) {
    List<String> addressParts = [];

    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    } else if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
      addressParts.add(place.thoroughfare!);
    }

    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }

    return addressParts.isEmpty
        ? 'Ubicación seleccionada'
        : addressParts.join(', ');
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showLocationError();
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = newLocation;
        _updateCircle();
      });

      await _getAddressFromCoordinates(newLocation);

      _mapController.animateCamera(CameraUpdate.newLatLngZoom(newLocation, 13));
    } catch (e) {
      _showLocationError();
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _showLocationError() {
    _showToast(
      'Error',
      'No se pudo obtener la ubicación actual',
      ToastNotificationType.error,
    );
  }

  void _updateCircle() {
    _circles.clear();
    _markers.clear();

    // Agregar círculo de radio si está habilitado
    if (widget.showRadiusControl) {
      _circles.add(
        Circle(
          circleId: const CircleId('search_radius'),
          center: _selectedLocation,
          radius: _currentRadius * 1000,
          fillColor: LightTheme.secondaryColor.withAlpha(50),
          strokeColor: LightTheme.secondaryColor,
          strokeWidth: 2,
        ),
      );
    }

    // Agregar marcador
    _markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: _selectedLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    setState(() {});
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _updateCircle();
    });

    _getAddressFromCoordinates(position);
  }

  void _onRadiusChanged(double value) {
    setState(() {
      _currentRadius = value;
      _updateCircle();
    });
  }

  void _handleConfirm() {
    final location = PetLocationEntity(
      latitude: _selectedLocation.latitude,
      longitude: _selectedLocation.longitude,
      address: _currentAddress,
      city: _currentCity,
      state: _currentState,
    );

    context.pop(
      LocationPickerResult(location: location, radiusKm: _currentRadius),
    );
  }

  void _showToast(
    String title,
    String description,
    ToastNotificationType type,
  ) {
    ToastNotification.show(
      context,
      title: title,
      description: description,
      type: type,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(
          widget.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 13,
            ),
            circles: _circles,
            markers: _markers,
            onTap: _onMapTap,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildSelectedAddressCard(theme),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildActionsCard(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedAddressCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    _isLoadingAddress
                        ? Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Obteniendo ubicación...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_currentCity, $_currentState',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _currentAddress,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
              ),
              IconButton(
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                icon:
                    _isLoadingLocation
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Icon(
                          Icons.my_location,
                          color: theme.colorScheme.primary,
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (widget.showRadiusControl)
            _buildRadiusControl(theme)
          else
            _buildPrivacyInfo(theme),
          const SizedBox(height: 10),
          _buildActionButtoms(),
        ],
      ),
    );
  }

  Widget _buildRadiusControl(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ajustar radio de búsqueda',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 12,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_currentRadius.toStringAsFixed(0)} km',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Slider(
          value: _currentRadius,
          min: 5,
          max: 100,
          divisions: 19,
          label: '${_currentRadius.toStringAsFixed(0)} km',
          onChanged: _onRadiusChanged,
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildPrivacyInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu privacidad es importante',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Solo se mostrará información general de la zona, no tu dirección exacta.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtoms() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Cancelar',
            variant: ButtonVariant.outline,
            onPressed: () => context.pop(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomButton(
            text: 'Aplicar',
            onPressed: _handleConfirm,
            icon: const Icon(Icons.check, size: 20),
          ),
        ),
      ],
    );
  }
}
