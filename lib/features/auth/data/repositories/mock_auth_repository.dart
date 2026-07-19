import 'dart:math';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../domain/models/app_user.dart';
import '../../domain/models/persona.dart';
import '../../domain/repositories/auth_repository.dart';

/// In-memory auth implementation used until a real backend is wired up.
/// It mimics network latency and validation so the UI and providers
/// built against it behave exactly as they will against a live API.
class MockAuthRepository implements AuthRepository {
  AppUser? _currentUser;
  final _random = Random();

  Future<void> _simulateLatency() =>
      Future.delayed(Duration(milliseconds: 400 + _random.nextInt(400)));

  @override
  Future<AppUser> login({required String email, required String password}) async {
    await _simulateLatency();
    if (!email.isValidEmail) {
      throw const ValidationException('Enter a valid email address.');
    }
    if (password.length < 8) {
      throw const AuthException('Incorrect email or password.');
    }
    final defaultPersona = Persona(
      id: 'p_default',
      displayName: email.split('@').first.capitalized,
      createdAt: DateTime.now(),
    );
    _currentUser = AppUser(
      id: 'user_${email.hashCode}',
      email: email,
      isEmailVerified: true,
      personas: [defaultPersona],
      activePersonaId: 'p_default',
    );
    return _currentUser!;
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await _simulateLatency();
    if (!email.isValidEmail) {
      throw const ValidationException('Enter a valid email address.');
    }
    if (!password.isValidPassword) {
      throw const ValidationException(
          'Password must be at least 8 characters and include a letter and a number.');
    }
    if (displayName.trim().isEmpty) {
      throw const ValidationException('Enter a display name.');
    }
    final defaultPersona = Persona(
      id: 'p_default',
      displayName: displayName.trim(),
      createdAt: DateTime.now(),
    );
    _currentUser = AppUser(
      id: 'user_${email.hashCode}',
      email: email,
      personas: [defaultPersona],
      activePersonaId: 'p_default',
    );
    return _currentUser!;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _simulateLatency();
    if (!email.isValidEmail) {
      throw const ValidationException('Enter a valid email address.');
    }
  }

  @override
  Future<void> verifyOtp({required String email, required String code}) async {
    await _simulateLatency();
    if (code.length != 6) {
      throw const ValidationException('Enter the 6-digit code.');
    }
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isEmailVerified: true);
    }
  }

  @override
  Future<AppUser> completeProfile({required String bio, String? avatarUrl}) async {
    await _simulateLatency();
    if (_currentUser == null) {
      throw const AuthException('No active session.');
    }
    _currentUser = _currentUser!.copyWith(bio: bio, avatarUrl: avatarUrl);
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await _simulateLatency();
    _currentUser = null;
  }

  @override
  Future<AppUser?> restoreSession() async {
    await _simulateLatency();
    return _currentUser;
  }

  @override
  Future<void> updateUser(AppUser user) async {
    _currentUser = user;
  }
}
