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

  String get magnitudeColor {
    final double? mag = double.tryParse(magnitude ?? "");
    if (mag == null) return 'unknown';

    if (mag >= 7.0) return 'critical';
    if (mag >= 5.0) return 'high';
    if (mag >= 3.0) return 'medium';
    return 'low';
  }
}
