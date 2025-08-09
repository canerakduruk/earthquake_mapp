import 'package:earthquake_mapp/data/services/earthquake_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'filter_date_selector.dart';
import 'zoom_and_location_buttons.dart';
import 'magnitude_filter_button.dart';
import 'earthquake_map.dart';
import 'earthquake_detail_modal.dart';
import 'package:earthquake_mapp/core/enums/earthquake_enums.dart';
import 'package:earthquake_mapp/presentation/providers/earthquake_provider.dart';

class EarthquakeMapScreen extends ConsumerStatefulWidget {
  const EarthquakeMapScreen({super.key});

  @override
  ConsumerState<EarthquakeMapScreen> createState() =>
      _EarthquakeMapScreenState();
}

class _EarthquakeMapScreenState extends ConsumerState<EarthquakeMapScreen> {
  final MapController _mapController = MapController();
  final double _zoom = 5.5;
  LatLng? _initialPosition;

  DateTime _selectedDate = DateTime.now();
  bool _isDatePickerOpen = false;

  int? _minMagnitudeFilter;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(earthquakeMapProvider.notifier).loadEarthquakes();
    });
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 0.5);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 0.5);
  }

  void _centerMap() {
    if (_initialPosition != null) {
      _mapController.move(_initialPosition!, _mapController.camera.zoom);
    }
  }

  void _resetMap() {
    if (_initialPosition != null) {
      _mapController.move(_initialPosition!, _zoom);
    }
  }

  Future<void> _selectDate() async {
    setState(() {
      _isDatePickerOpen = true;
    });

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1999),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });

      final startDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        0,
        0,
        0,
      );
      final endDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        23,
        59,
        59,
      );

      final params = EarthquakeFilterParams(
        startDate: startDate,
        endDate: endDate,
        minMagnitude: null,
        maxMagnitude: null,
        magnitudeType: null,
        minDepth: null,
        maxDepth: null,
        limit: null,
        orderBy: OrderBy.timeDesc,
      );
      _minMagnitudeFilter = null;
      ref.read(earthquakeMapProvider.notifier).applyFilter(params);
    }

    setState(() {
      _isDatePickerOpen = false;
    });
  }

  void _showEarthquakeDetail(earthquake) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EarthquakeDetailModal(earthquake: earthquake),
    );
  }

  @override
  Widget build(BuildContext context) {
    final earthquakeState = ref.watch(earthquakeMapProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: earthquakeState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : EarthquakeMap(
                    mapController: _mapController,
                    initialZoom: _zoom,
                    initialPosition:
                        _initialPosition ?? const LatLng(39.9208, 32.8541),
                    earthquakes: (_minMagnitudeFilter == null
                        ? earthquakeState.earthquakes
                        : earthquakeState.earthquakes.where((eq) {
                            final mag = double.tryParse(eq.magnitude ?? '');
                            return mag != null && mag >= _minMagnitudeFilter!;
                          }).toList()),
                    onMarkerTap: _showEarthquakeDetail,
                    onMapReady: (pos) {
                      _initialPosition = pos;
                    },
                  ),
          ),
          if (earthquakeState.error != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.withAlpha(120),
                child: Text(
                  tr('error_occurred', args: [earthquakeState.error ?? '']),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: FilterDateSelector(
                selectedDate: _selectedDate,
                isOpen: _isDatePickerOpen,
                onTap: _selectDate,
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, right: 10),
                child: FloatingActionButton(
                  mini: true,
                  heroTag: 'resetMap',
                  onPressed: _resetMap,
                  child: const Icon(Icons.refresh),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, right: 10),
                child: ZoomAndLocationButtons(
                  onCenter: _centerMap,
                  onZoomIn: _zoomIn,
                  onZoomOut: _zoomOut,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 10),
                child: MagnitudeFilterButton(
                  onSelected: (value) {
                    setState(() {
                      _minMagnitudeFilter = value;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
