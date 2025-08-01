import 'package:earthquake_mapp/core/enums/earthquake_enums.dart';
import 'package:earthquake_mapp/core/utils/date_helper.dart';
import 'package:earthquake_mapp/data/services/earthquake_service.dart';
import 'package:earthquake_mapp/presentation/providers/earthquake_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map_marker_cluster_plus/flutter_map_marker_cluster_plus.dart';

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

  int? _minMagnitudeFilter; // Burada seçilen minimum büyüklük tutulacak

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(earthquakeMapProvider.notifier).loadEarthquakes();
    });
  }

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

      final startDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        0,
        0,
        0,
      );

      final endDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
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
      // Burada liste API'den tekrar çekiliyor, bu tarih değişiminde olur
    }

    setState(() {
      _isDatePickerOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final earthquakeState = ref.watch(earthquakeMapProvider);

    // Butonlar ve diğer UI her zaman gösterilecek,
    // ama harita kısmı ya da markerlar veri gelene kadar boş ya da loading gösterilecek.

    return Scaffold(
      body: Stack(
        children: [
          // Harita ve markerlar: loading ise spinner, değilse harita
          Positioned.fill(
            child: earthquakeState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
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
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.earthquake_mapp',
                      ),
                      MarkerClusterLayerWidget(
                        options: MarkerClusterLayerOptions(
                          maxClusterRadius: 45,
                          size: const Size(40, 40),
                          markers:
                              (_minMagnitudeFilter == null
                                      ? earthquakeState.earthquakes
                                      : earthquakeState.earthquakes.where((eq) {
                                          if (eq.magnitude == null) {
                                            return false;
                                          }
                                          final mag = double.tryParse(
                                            eq.magnitude!,
                                          );
                                          if (mag == null) return false;
                                          return mag >= _minMagnitudeFilter!;
                                        }).toList())
                                  .map((earthquake) {
                                    final latString = earthquake.latitude;
                                    final lonString = earthquake.longitude;
                                    if (latString == null ||
                                        lonString == null) {
                                      return null;
                                    }
                                    final lat = double.tryParse(latString);
                                    final lon = double.tryParse(lonString);
                                    if (lat == null || lon == null) return null;
                                    return Marker(
                                      point: LatLng(lat, lon),
                                      width: 50,
                                      height: 50,
                                      child: GestureDetector(
                                        onTap: () {
                                          _showEarthquakeDetail(
                                            earthquake,
                                          ); // 👈 Modalı aç
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: earthquake.magnitudeColor,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            earthquake.magnitude ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                                  .whereType<Marker>()
                                  .toList(),
                          builder: (context, markers) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(150),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                markers.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),

          // Hata varsa haritanın üstünde gösterelim
          if (earthquakeState.error != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.withAlpha(120),
                child: Text(
                  'Hata oluştu: ${earthquakeState.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

          // Tarih seçici SafeArea içinde üstte
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () => _selectDate(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(200),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: const [
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

          // Sağ üst yenile butonu
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

          // Alt sağ zoom ve konum butonları
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

          // Alt sol büyüklük filtre butonu
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 10),
                child: PopupMenuButton<int>(
                  tooltip: 'Büyüklük Seçenekleri',
                  onSelected: (value) {
                    setState(() {
                      _minMagnitudeFilter = value;
                    });
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 8, child: Text('8 üstü')),
                    PopupMenuItem(value: 5, child: Text('5 üstü')),
                    PopupMenuItem(value: 3, child: Text('3 üstü')),
                    PopupMenuItem(value: 0, child: Text('Hepsi')),
                  ],
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                        0.8,
                      ), // Buraya istediğin arka plan rengini ver
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const FaIcon(
                      FontAwesomeIcons.plusMinus,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEarthquakeDetail(earthquake) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Deprem Detayları',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildDetailTile(
                  Icons.speed,
                  'Büyüklük',
                  earthquake.magnitudeDisplay,
                ),
                _buildDetailTile(
                  Icons.access_time,
                  'Tarih',
                  DateHelper.formatDateTimeForDisplay(earthquake.dateTime),
                ),
                _buildDetailTile(
                  Icons.location_on,
                  'Konum',
                  earthquake.location ?? '',
                ),
                _buildDetailTile(
                  Icons.map,
                  'Koordinat',
                  earthquake.coordinatesDisplay,
                ),
                _buildDetailTile(
                  Icons.vertical_align_bottom,
                  'Derinlik',
                  earthquake.depthDisplay,
                ),
                if (earthquake.province != null)
                  _buildDetailTile(
                    Icons.location_city,
                    'İl',
                    earthquake.province!,
                  ),
                if (earthquake.district != null)
                  _buildDetailTile(
                    Icons.apartment,
                    'İlçe',
                    earthquake.district!,
                  ),

                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Kapat'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: Colors.grey[700]),
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(value),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
