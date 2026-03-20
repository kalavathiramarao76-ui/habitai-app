import 'dart:convert';

import 'package:uuid/uuid.dart';

enum CoachMessageType { insight, alert, tip, milestone, correlation }

class CoachMessage {
  final String id;
  final CoachMessageType type;
  final String title;
  final String message;
  final String? habitId;
  final DateTime createdAt;
  final bool isRead;

  CoachMessage({
    String? id,
    required this.type,
    required this.title,
    required this.message,
    this.habitId,
    DateTime? createdAt,
    this.isRead = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'message': message,
        'habitId': habitId,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
      };

  factory CoachMessage.fromJson(Map<String, dynamic> json) {
    return CoachMessage(
      id: json['id'] as String,
      type: CoachMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CoachMessageType.tip,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      habitId: json['habitId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  CoachMessage copyWith({
    String? id,
    CoachMessageType? type,
    String? title,
    String? message,
    String? habitId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return CoachMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      habitId: habitId ?? this.habitId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory CoachMessage.fromJsonString(String source) =>
      CoachMessage.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
