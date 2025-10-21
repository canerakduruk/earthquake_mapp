import 'package:flutter/material.dart'; // <-- 1. EKLENEN IMPORT
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'earthquake_model.g.dart'; // Bu dosyayı build_runner oluşturacak

// YARDIMCI FONKSİYON 1: Gelen 'null' dahil, double'a çevirir
double? parseDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    // String'i double'a çevirmeyi dener
    return double.tryParse(value); // Başarısız olursa 'null' döner
  }
  return null;
}

// YARDIMCI FONKSİYON 2: Gelen 'null' dahil, int'e çevirir
int? parseIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value); // Başarısız olursa 'null' döner
  }
  if (value is double) {
    return value.toInt();
  }
  return null;
}

// YARDIMCI FONKSİYON 3: String null ise "-" döner
String parseStringSafe(dynamic value) {
  if (value == null) return "-";
  if (value is String) {
    // Boş string gelirse de "-" ata
    return value.isEmpty ? "-" : value;
  }
  // Gelen değer (örn: sayı) string değilse, string'e çevir
  return value.toString();
}

@JsonSerializable()
class EarthquakeModel extends Equatable {
  // ... (Tüm alanlarınız burada, değişiklik yok) ...
  @JsonKey(fromJson: parseDoubleNullable)
  final double? rms;

  @JsonKey(fromJson: parseIntNullable)
  final int? eventID;

  @JsonKey(fromJson: parseStringSafe)
  final String location;

  @JsonKey(fromJson: parseDoubleNullable)
  final double? latitude;

  @JsonKey(fromJson: parseDoubleNullable)
  final double? longitude;

  @JsonKey(fromJson: parseDoubleNullable)
  final double? depth;

  @JsonKey(fromJson: parseStringSafe)
  final String type;

  @JsonKey(fromJson: parseDoubleNullable)
  final double? magnitude;

  @JsonKey(fromJson: parseStringSafe)
  final String country;

  @JsonKey(fromJson: parseStringSafe)
  final String province;

  @JsonKey(fromJson: parseStringSafe)
  final String district;

  @JsonKey(fromJson: parseStringSafe)
  final String neighborhood;

  final DateTime? date;

  // ... (Constructor burada, değişiklik yok) ...
  const EarthquakeModel({
    this.rms,
    this.eventID,
    required this.location,
    this.latitude,
    this.longitude,
    this.depth,
    required this.type,
    this.magnitude,
    required this.country,
    required this.province,
    required this.district,
    required this.neighborhood,
    this.date,
  });

  factory EarthquakeModel.fromJson(Map<String, dynamic> json) =>
      _$EarthquakeModelFromJson(json);

  Map<String, dynamic> toJson() => _$EarthquakeModelToJson(this);

  @override
  List<Object?> get props => [eventID];

  // --- 2. EKLENEN KOD BLOĞU ---
  /// Deprem büyüklüğüne göre bir renk döndürür.
  Color get magnitudeColor {
    // Büyüklük verisi 'null' ise gri döndür
    if (magnitude == null) {
      return Colors.grey.shade400;
    }

    // Büyüklük aralıklarına göre renk ata
    if (magnitude! < 3.0) {
      return Colors.green; // Hafif
    }
    if (magnitude! < 4.0) {
      return Colors.yellow.shade700; // Hafif-Orta
    }
    if (magnitude! < 5.0) {
      return Colors.orange; // Orta
    }
    if (magnitude! < 6.0) {
      return Colors.deepOrange.shade700; // Şiddetli
    }
    // 6.0 ve üzeri
    return Colors.red.shade900; // Çok Şiddetli
  }
// --- EKLENEN KOD BLOĞU SONU ---
}