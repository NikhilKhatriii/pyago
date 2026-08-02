import 'package:equatable/equatable.dart';

class Persona extends Equatable {
  const Persona({
    required this.id,
    required this.displayName,
    this.bio = '',
    this.avatarUrl,
    required this.createdAt,
  });

  final String id;
  final String displayName;
  final String bio;
  final String? avatarUrl;
  final DateTime createdAt;

  Persona copyWith({
    String? id,
    String? displayName,
    String? bio,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return Persona(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'bio': bio,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Persona.fromJson(Map<String, dynamic> json) => Persona(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        bio: json['bio'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  List<Object?> get props => [id, displayName, bio, avatarUrl, createdAt];
}
