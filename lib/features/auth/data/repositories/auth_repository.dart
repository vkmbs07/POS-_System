import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// Mock User class
class MockUser {
  final String email;
  MockUser(this.email);
}

// Mock Auth Service
class MockAuthService {
  final _authStateController = StreamController<MockUser?>.broadcast();
  Stream<MockUser?> get authStateChanges => _authStateController.stream;
  
  MockUser? _currentUser;
  MockUser? get currentUser => _currentUser;

  Future<void> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    if (password == 'error') throw Exception('Invalid credentials');
    _currentUser = MockUser(email);
    _authStateController.add(_currentUser);
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _authStateController.add(null);
  }
}

final authServiceProvider = Provider((ref) => MockAuthService());

final authStateProvider = StreamProvider<MockUser?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

class AuthRepository {
  final MockAuthService _authService;

  AuthRepository(this._authService);

  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email, password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(ref.read(authServiceProvider));
});
