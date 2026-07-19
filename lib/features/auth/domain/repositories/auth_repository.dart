import '../models/app_user.dart';

/// Contract for authentication. [MockAuthRepository] is the only
/// implementation for now; swapping in a real backend later means
/// implementing this interface and updating a single provider override.
abstract interface class AuthRepository {
  Future<AppUser> login({required String email, required String password});
  Future<AppUser> register({
    required String email,
    required String password,
    required String displayName,
  });
  Future<void> sendPasswordReset(String email);
  Future<void> verifyOtp({required String email, required String code});
  Future<AppUser> completeProfile({required String bio, String? avatarUrl});
  Future<void> logout();
  Future<AppUser?> restoreSession();
  Future<void> updateUser(AppUser user);
}
