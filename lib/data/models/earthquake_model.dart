import 'package:json_annotation/json_annotation.dart';

part 'earthquake_model.g.dart';

@JsonSerializable()
class EarthquakeModel {
  @JsonKey(name: 'eventID')
  final String? eventId;

  @JsonKey(name: 'magnitude')
  final String? magnitude;

  @JsonKey(name: 'type')
  final String? magnitudeType;

  @JsonKey(name: 'date')
  final String? date;

  @JsonKey(name: 'latitude')
  final String? latitude;

  @JsonKey(name: 'longitude')
  final String? longitude;

  @JsonKey(name: 'depth')
  final String? depth;

  @JsonKey(name: 'location')
  final String? location;

  @JsonKey(name: 'province')
  final String? province;

  @JsonKey(name: 'district')
  final String? district;

  EarthquakeModel({
    required this.eventId,
    required this.magnitude,
    required this.magnitudeType,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.depth,
    required this.location,
    this.province,
    this.district,
  });

  factory EarthquakeModel.fromJson(Map<String, dynamic> json) =>
      _$EarthquakeModelFromJson(json);

  Map<String, dynamic> toJson() => _$EarthquakeModelToJson(this);

  DateTime get dateTime {
    try {
      return DateTime.parse(date ?? '');
    } catch (e) {
      return DateTime.now();
    }
  }
}

@JsonSerializable()
class EarthquakeResponse {
  @JsonKey(name: 'result')
  final List<EarthquakeModel> earthquakes;

  @JsonKey(name: 'status')
  final bool status;

  @JsonKey(name: 'httpStatus')
  final int httpStatus;

  EarthquakeResponse({
    required this.earthquakes,
    required this.status,
    required this.httpStatus,
  });

  factory EarthquakeResponse.fromJson(Map<String, dynamic> json) =>
      _$EarthquakeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EarthquakeResponseToJson(this);
}
