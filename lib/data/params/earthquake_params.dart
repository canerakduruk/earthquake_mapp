import 'package:earthquake_mapp/core/enums/earthquake_enums.dart';
import 'package:equatable/equatable.dart';

class EarthquakeParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final double? minLat;
  final double? maxLat;
  final double? minLon;
  final double? maxLon;
  final double? centerLat;
  final double? centerLon;
  final double? maxRadius;
  final double? minRadius;
  final double? minMagnitude;
  final double? maxMagnitude;
  final MagnitudeType? magnitudeType;
  final int? minDepth;
  final int? maxDepth;
  final int? limit;
  final int? offset;
  final OrderBy orderBy;
  final int? eventId;

  const EarthquakeParams({
    required this.startDate,
    required this.endDate,
    this.minLat,
    this.maxLat,
    this.minLon,
    this.maxLon,
    this.centerLat,
    this.centerLon,
    this.maxRadius,
    this.minRadius,
    this.minMagnitude,
    this.maxMagnitude,
    this.magnitudeType,
    this.minDepth,
    this.maxDepth,
    this.limit,
    this.offset,
    required this.orderBy,
    this.eventId,
  });


  @override
  List<Object?> get props => [
    startDate,
    endDate,
    minLat,
    maxLat,
    minLon,
    maxLon,
    centerLat,
    centerLon,
    maxRadius,
    minRadius,
    minMagnitude,
    maxMagnitude,
    magnitudeType,
    minDepth,
    maxDepth,
    limit,
    offset,
    orderBy,
    eventId,
  ];
}