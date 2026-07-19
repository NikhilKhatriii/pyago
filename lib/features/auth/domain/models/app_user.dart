import 'package:equatable/equatable.dart';
import 'persona.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    this.isEmailVerified = false,
    required this.personas,
    required this.activePersonaId,
  });

  final String id;
  final String email;
  final bool isEmailVerified;
  final List<Persona> personas;
  final String activePersonaId;

  Persona get activePersona =>
      personas.firstWhere((p) => p.id == activePersonaId, orElse: () => personas.first);

  String get displayName => activePersona.displayName;
  String get bio => activePersona.bio;
  String? get avatarUrl => activePersona.avatarUrl;

  AppUser copyWith({
    String? displayName,
    String? bio,
    String? avatarUrl,
    bool? isEmailVerified,
    List<Persona>? personas,
    String? activePersonaId,
  }) {
    final activeId = activePersonaId ?? this.activePersonaId;
    List<Persona> updatedPersonas = personas ?? List.from(this.personas);
    if (displayName != null || bio != null || avatarUrl != null) {
      final idx = updatedPersonas.indexWhere((p) => p.id == activeId);
      if (idx != -1) {
        updatedPersonas[idx] = updatedPersonas[idx].copyWith(
          displayName: displayName,
          bio: bio,
          avatarUrl: avatarUrl,
        );
      }
    }
    return AppUser(
      id: id,
      email: email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      personas: updatedPersonas,
      activePersonaId: activeId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'isEmailVerified': isEmailVerified,
        'personas': personas.map((p) => p.toJson()).toList(),
        'activePersonaId': activePersonaId,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final list = (json['personas'] as List? ?? [])
        .map((p) => Persona.fromJson(p as Map<String, dynamic>))
        .toList();
    final display = json['displayName'] as String? ?? 'You';
    final bioVal = json['bio'] as String? ?? '';
    final avatar = json['avatarUrl'] as String?;
    final defaultPersonaId = json['activePersonaId'] as String? ?? 'default';

    final finalPersonas = list.isNotEmpty
        ? list
        : [
            Persona(
              id: defaultPersonaId,
              displayName: display,
              bio: bioVal,
              avatarUrl: avatar,
              createdAt: DateTime.now(),
            )
          ];

    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      personas: finalPersonas,
      activePersonaId: defaultPersonaId,
    );
  }

  @override
  List<Object?> get props => [id, email, isEmailVerified, personas, activePersonaId];
}
