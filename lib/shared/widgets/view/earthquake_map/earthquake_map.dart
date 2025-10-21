import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster_plus/flutter_map_marker_cluster_plus.dart';
import 'package:latlong2/latlong.dart';

class EarthquakeMap extends StatelessWidget {
  final MapController mapController;
  final double initialZoom;
  final LatLng initialPosition;
  final List earthquakes;
  final void Function(dynamic earthquake) onMarkerTap;
  final void Function(LatLng) onMapReady;

  const EarthquakeMap({
    super.key,
    required this.mapController,
    required this.initialZoom,
    required this.initialPosition,
    required this.earthquakes,
    required this.onMarkerTap,
    required this.onMapReady,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialPosition,
        initialZoom: initialZoom,
        minZoom: 3,
        maxZoom: 18,
        onMapReady: () => onMapReady(initialPosition),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.earthquake_mapp',
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 45,
            size: const Size(40, 40),
            markers: earthquakes
                .map((earthquake) {
                  final latitude = earthquake.latitude;
                  final longitude = earthquake.longitude;
                  if (latitude == null || longitude == null) return null;


                  return Marker(
                    point: LatLng(latitude, longitude),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () => onMarkerTap(earthquake),
                      child: Container(
                        decoration: BoxDecoration(
                          color: earthquake.magnitudeColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          earthquake.magnitude.toString(),
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
            builder: (context, markers) => Container(
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
            ),
          ),
        ),
      ],
    );
  }
}
