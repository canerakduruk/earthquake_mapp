import 'package:earthquake_mapp/core/enums/earthquake_enums.dart';
import 'package:earthquake_mapp/data/models/new_earthquake_model/earthquake_model.dart';
import 'package:earthquake_mapp/data/params/earthquake_params.dart';
import 'package:earthquake_mapp/features/providers/earthquake_provider.dart';
import 'package:earthquake_mapp/shared/widgets/modal/earthquake_detail_modal.dart';
import 'package:earthquake_mapp/shared/widgets/view/earthquake_map/earthquake_map.dart';
import 'package:earthquake_mapp/shared/widgets/view/earthquake_map/filter_date_selector.dart';
import 'package:earthquake_mapp/shared/widgets/view/earthquake_map/magnitude_filter_button.dart';
import 'package:earthquake_mapp/shared/widgets/view/earthquake_map/zoom_and_location_buttons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class EarthquakeMapScreen extends ConsumerStatefulWidget {
  const EarthquakeMapScreen({super.key});

  @override
  ConsumerState<EarthquakeMapScreen> createState() =>
      _EarthquakeMapScreenState();
}

class _EarthquakeMapScreenState extends ConsumerState<EarthquakeMapScreen> {
  final MapController _mapController = MapController();
  final double _initialZoom = 5.5;
  LatLng? _initialPosition;

  DateTime _selectedDate = DateTime.now();
  int? _minMagnitudeFilter;
  bool _isDatePickerOpen = false;

  // 1. 'mapParams' artık 'build' içinde değil, bir state değişkeni.
  late EarthquakeParams _mapParams;

  @override
  void initState() {
    super.initState();
    // 2. Parametreyi 'initState' içinde ilk kez oluştur.
    _updateMapParams();
  }

  // 3. Parametreleri güncelleyen bir yardımcı metot.
  void _updateMapParams() {
    final startDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      0, 0, 0,
    );
    final endDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      23, 59, 59,
    );

    // 'const' constructor kullandığımızdan (Equatable sayesinde)
    // _selectedDate değişmediği sürece bu nesne aynı kalır.
    _mapParams = EarthquakeParams(
      startDate: startDate,
      endDate: endDate,
      minMagnitude: 0.0,
      orderBy: OrderBy.timeDesc,
    );
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
      _mapController.move(_initialPosition!, _initialZoom);
    }
  }

  void _resetMap() {

    ref.invalidate(earthquakeProvider(_mapParams));
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _minMagnitudeFilter = null;
        _updateMapParams();
      });
    }

    setState(() {
      _isDatePickerOpen = false;
    });
  }

  void _showEarthquakeDetail(EarthquakeModel earthquake) {
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
    // 6. 'build' içinde yeni nesne oluşturmak yerine, state'deki
    // mevcut '_mapParams' nesnesini 'watch' et.
    final asyncEarthquakes = ref.watch(earthquakeProvider(_mapParams));

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: asyncEarthquakes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.red.withAlpha(120),
                  child: Text(
                    tr('error_occurred', args: [error.toString()]),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              data: (earthquakes) {
                final filteredList = (_minMagnitudeFilter == null
                    ? earthquakes
                    : earthquakes.where((eq) {
                  final mag = eq.magnitude;
                  return mag != null && mag >= _minMagnitudeFilter!;
                }).toList());

                return EarthquakeMap(
                  mapController: _mapController,
                  initialZoom: _initialZoom,
                  initialPosition:
                  _initialPosition ?? const LatLng(39.9208, 32.8541),
                  earthquakes: filteredList,
                  onMarkerTap: (eq) => _showEarthquakeDetail(eq),
                  onMapReady: (pos) {
                    _initialPosition = pos;
                  },
                );
              },
            ),
          ),
          if (asyncEarthquakes.isRefreshing)
            const Center(child: CircularProgressIndicator()),
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
                  onPressed: _resetMap, // Artık 'invalidate' içeriyor
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