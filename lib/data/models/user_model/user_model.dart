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

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  static DateTime _fromJsonDate(String date) => DateTime.parse(date);
  static String _toJsonDate(DateTime date) => date.toIso8601String();

  static DateTime _fromTimestamp(dynamic timestamp) {
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else if (timestamp is Map && timestamp['_seconds'] != null) {
      final seconds = timestamp['_seconds'] as int;
      final nanoseconds = timestamp['_nanoseconds'] as int;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + nanoseconds ~/ 1000000,
      );
    } else if (timestamp.runtimeType.toString() == 'Timestamp') {
      return (timestamp as dynamic).toDate();
    }
    throw Exception('Unknown timestamp format');
  }

  static dynamic _toTimestamp(DateTime date) {
    return date.toIso8601String();
  }
}
