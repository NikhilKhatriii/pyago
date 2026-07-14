import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.bio = '',
    this.avatarUrl,
    this.isEmailVerified = false,
  });

  final String id;
  final String email;
  final String displayName;
  final String bio;
  final String? avatarUrl;
  final bool isEmailVerified;

  AppUser copyWith({
    String? displayName,
    String? bio,
    String? avatarUrl,
    bool? isEmailVerified,
  }) {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, bio, avatarUrl, isEmailVerified];
}
