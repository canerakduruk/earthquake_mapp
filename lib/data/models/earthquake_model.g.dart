// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earthquake_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EarthquakeModel _$EarthquakeModelFromJson(Map<String, dynamic> json) =>
    EarthquakeModel(
      eventId: json['eventID'] as String?,
      magnitude: json['magnitude'] as String?,
      magnitudeType: json['type'] as String?,
      date: json['date'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      depth: json['depth'] as String?,
      location: json['location'] as String?,
      province: json['province'] as String?,
      district: json['district'] as String?,
    );

Map<String, dynamic> _$EarthquakeModelToJson(EarthquakeModel instance) =>
    <String, dynamic>{
      'eventID': instance.eventId,
      'magnitude': instance.magnitude,
      'type': instance.magnitudeType,
      'date': instance.date,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'depth': instance.depth,
      'location': instance.location,
      'province': instance.province,
      'district': instance.district,
    };

EarthquakeResponse _$EarthquakeResponseFromJson(Map<String, dynamic> json) =>
    EarthquakeResponse(
      earthquakes: (json['result'] as List<dynamic>)
          .map((e) => EarthquakeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as bool,
      httpStatus: (json['httpStatus'] as num).toInt(),
    );

Map<String, dynamic> _$EarthquakeResponseToJson(EarthquakeResponse instance) =>
    <String, dynamic>{
      'result': instance.earthquakes,
      'status': instance.status,
      'httpStatus': instance.httpStatus,
    };
