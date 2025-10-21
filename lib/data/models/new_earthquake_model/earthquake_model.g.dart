// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earthquake_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EarthquakeModel _$EarthquakeModelFromJson(Map<String, dynamic> json) =>
    EarthquakeModel(
      rms: parseDoubleNullable(json['rms']),
      eventID: parseIntNullable(json['eventID']),
      location: parseStringSafe(json['location']),
      latitude: parseDoubleNullable(json['latitude']),
      longitude: parseDoubleNullable(json['longitude']),
      depth: parseDoubleNullable(json['depth']),
      type: parseStringSafe(json['type']),
      magnitude: parseDoubleNullable(json['magnitude']),
      country: parseStringSafe(json['country']),
      province: parseStringSafe(json['province']),
      district: parseStringSafe(json['district']),
      neighborhood: parseStringSafe(json['neighborhood']),
      date: json['date'] == null
          ? null
          : DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$EarthquakeModelToJson(EarthquakeModel instance) =>
    <String, dynamic>{
      'rms': instance.rms,
      'eventID': instance.eventID,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'depth': instance.depth,
      'type': instance.type,
      'magnitude': instance.magnitude,
      'country': instance.country,
      'province': instance.province,
      'district': instance.district,
      'neighborhood': instance.neighborhood,
      'date': instance.date?.toIso8601String(),
    };
