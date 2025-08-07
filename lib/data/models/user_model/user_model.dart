import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;

  final String email;
  final String firstName;
  final String lastName;

  @JsonKey(fromJson: _fromJsonDate, toJson: _toJsonDate)
  final DateTime birthDate;

  @JsonKey(fromJson: _fromTimestamp, toJson: _toTimestamp)
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.createdAt,
  });

  // Factory & toJson otomatik generate edilecek
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // DateTime dönüşümleri
  static DateTime _fromJsonDate(String date) => DateTime.parse(date);
  static String _toJsonDate(DateTime date) => date.toIso8601String();

  // Firestore Timestamp dönüşümü
  static DateTime _fromTimestamp(dynamic timestamp) {
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else if (timestamp is Map && timestamp['_seconds'] != null) {
      // Eğer Firestore timestamp Map şeklindeyse (json'dan gelirken)
      final seconds = timestamp['_seconds'] as int;
      final nanoseconds = timestamp['_nanoseconds'] as int;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + nanoseconds ~/ 1000000,
      );
    } else if (timestamp.runtimeType.toString() == 'Timestamp') {
      // Firestore Timestamp objesi ise
      return (timestamp as dynamic).toDate();
    }
    throw Exception('Unknown timestamp format');
  }

  static dynamic _toTimestamp(DateTime date) {
    // Burada Firestore Timestamp objesi değil, JSON için string döndürür
    return date.toIso8601String();
  }
}
