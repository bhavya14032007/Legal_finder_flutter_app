import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository();
});

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final String? userEmail;
  final String? userName;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.userEmail,
    this.userName,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    String? userEmail,
    String? userName,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthController(this._repo)
      : super(
          AuthState(
            isAuthenticated: _repo.isAuthenticated || true, // default active guest session for mobile ease
            userEmail: _repo.currentUser?.email ?? 'advocate.user@example.com',
            userName: _repo.currentUser?.userMetadata?['full_name'] as String? ?? 'Adv. Rajesh Sharma',
          ),
        );

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repo.signInWithEmailPassword(email: email, password: password);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userEmail: email,
        userName: 'User ${email.split('@').first}',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repo.signUpWithEmailPassword(
        email: email,
        password: password,
        fullName: fullName,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userEmail: email,
        userName: fullName,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repo.resetPassword(email: email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.signOut();
    state = const AuthState(
      isAuthenticated: false,
      userEmail: null,
      userName: null,
    );
  }
}

