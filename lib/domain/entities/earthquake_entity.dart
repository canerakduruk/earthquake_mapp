import 'package:flutter/material.dart';

class EarthquakeEntity {
  final String? eventId;
  final String? magnitude;
  final String? magnitudeType;
  final DateTime dateTime;
  final String? latitude;
  final String? longitude;
  final String? depth;
  final String? location;
  final String? province;
  final String? district;

  EarthquakeEntity({
    required this.eventId,
    required this.magnitude,
    required this.magnitudeType,
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    required this.depth,
    required this.location,
    this.province,
    this.district,
  });

  String get magnitudeDisplay => '$magnitude $magnitudeType';

  String get depthDisplay => '$depth km';

  String get coordinatesDisplay => '$latitude, $longitude';

  Color get magnitudeColor {
    final double? mag = double.tryParse(magnitude ?? '');
    if (mag == null) return Colors.grey;

    if (mag >= 7.0) return Colors.red.shade800;
    if (mag >= 5.0) return Colors.orange.shade700;
    if (mag >= 3.0) return Colors.yellow.shade700;
    return Colors.green.shade600;
  }
}
