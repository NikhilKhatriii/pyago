import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => MockAuthRepository());

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({this.status = AuthStatus.unknown, this.user, this.errorMessage});

  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  AuthState copyWith({AuthStatus? status, AppUser? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// Owns the current session. GoRouter's redirect logic listens to this
/// via [authStatusProvider] so navigation always reflects auth state.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState()) {
    _restore();
  }

  final AuthRepository _repository;

  Future<void> _restore() async {
    final user = await _repository.restoreSession();
    state = AuthState(
      status: user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      user: user,
    );
  }

  Future<bool> login(String email, String password) async {
    try {
      final user = await _repository.login(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> register(String email, String password, String displayName) async {
    try {
      final user = await _repository.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String code) async {
    try {
      await _repository.verifyOtp(email: state.user?.email ?? '', code: code);
      state = state.copyWith(user: state.user?.copyWith(isEmailVerified: true));
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> completeProfile({required String bio, String? avatarUrl}) async {
    try {
      final user = await _repository.completeProfile(bio: bio, avatarUrl: avatarUrl);
      state = state.copyWith(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authControllerProvider.select((s) => s.status));
});

final onboardingCompleteProvider = StateProvider<bool>((ref) => false);
