import 'package:earthquake_mapp/presentation/providers/earthquake_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class EarthquakeMapScreen extends ConsumerStatefulWidget {
  const EarthquakeMapScreen({super.key});

  @override
  ConsumerState<EarthquakeMapScreen> createState() =>
      _EarthquakeMapScreenState();
}

class _EarthquakeMapScreenState extends ConsumerState<EarthquakeMapScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(earthquakeMapProvider.notifier).loadEarthquakes();
    });
  }

  final MapController _mapController = MapController();
  final double _zoom = 5.5;

  LatLng? _initialPosition;

  final List<LatLng> earthquakeLocations = [
    LatLng(39.9208, 32.8541), // Ankara
    LatLng(41.0082, 28.9784), // İstanbul
    LatLng(37.0000, 35.3213), // Adana
  ];

  DateTime _selectedDate = DateTime.now();
  bool _isDatePickerOpen = false;

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    final newZoom = currentZoom + 0.5;
    _mapController.move(_mapController.camera.center, newZoom);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    final newZoom = currentZoom - 0.5;
    _mapController.move(_mapController.camera.center, newZoom);
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
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }

    setState(() {
      _isDatePickerOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final earthquakeState = ref.watch(earthquakeMapProvider);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(39.9208, 32.8541),
              initialZoom: _zoom,
              minZoom: 3,
              maxZoom: 18,
              onMapReady: () {
                _initialPosition = const LatLng(39.9208, 32.8541);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.earthquake_mapp',
              ),
              MarkerLayer(
                markers: earthquakeState.earthquakes
                    .map((earthquake) {
                      final latString = earthquake.latitude;
                      final lonString = earthquake.longitude;

                      if (latString == null || lonString == null) {
                        return null; // Koordinat yoksa marker oluşturma
                      }

                      final lat = double.tryParse(latString);
                      final lon = double.tryParse(lonString);

                      if (lat == null || lon == null) {
                        return null; // Parse edilemediyse marker oluşturma
                      }

                      return Marker(
                        point: LatLng(lat, lon),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 32,
                        ),
                      );
                    })
                    .whereType<Marker>()
                    .toList(), // null olanları filtrele
              ),
            ],
          ),

          // Tarih seçici SafeArea içinde üstte
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(200),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 140,
                    maxWidth: 180,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          DateFormat.yMMMMd().format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _isDatePickerOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
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
                  heroTag: 'Haritayı Yenile',
                  onPressed: _resetMap,
                  child: const Icon(Icons.refresh),
                ),
              ),
            ),
          ),

          // Butonlar da SafeArea içinde altta sağda
          SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, right: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      mini: true,
                      heroTag: "centerMap",
                      onPressed: _centerMap,
                      child: const Icon(Icons.my_location),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      mini: true,
                      onPressed: _zoomIn,
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      mini: true,
                      onPressed: _zoomOut,
                      child: const Icon(Icons.remove),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 10),
                child: PopupMenuButton<int>(
                  icon: FaIcon(FontAwesomeIcons.anchor),
                  tooltip: 'Büyüklük Seçenekleri',
                  onSelected: (value) {
                    // Burada seçilen büyüklüğe göre filtreleme veya işlem yapabilirsiniz
                    // Örneğin: print('Seçilen büyüklük: $value');
                    // İsterseniz setState ile seçim bilgisini kaydedip UI güncelleyebilirsiniz
                    print('Seçilen büyüklük: $value üstü');
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 3, child: Text('3 üstü')),
                    const PopupMenuItem(value: 5, child: Text('5 üstü')),
                    const PopupMenuItem(value: 8, child: Text('8 üstü')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
