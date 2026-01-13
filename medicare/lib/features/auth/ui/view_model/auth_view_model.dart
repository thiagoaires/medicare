import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

enum AuthStatus { initial, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AuthRepository authRepository;

  AuthViewModel({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.authRepository,
  });

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  UserEntity? _user;
  UserEntity? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await loginUseCase(email, password);

    result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (user) {
        _status = AuthStatus.success;
        _user = user;
        notifyListeners();
      },
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String type,
  }) async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await registerUseCase(
      name: name,
      email: email,
      password: password,
      type: type,
    );

    result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (user) {
        _status = AuthStatus.success;
        _user = user;
        notifyListeners();
      },
    );
  }

  void resetState() {
    _status = AuthStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await authRepository.getCurrentUser();

    return result.fold(
      (failure) {
        _status = AuthStatus.initial;
        _user = null;
        notifyListeners();
        return false;
      },
      (user) {
        if (user != null) {
          _user = user;
          _status = AuthStatus.success;
          notifyListeners();
          return true;
        } else {
          _status = AuthStatus.initial;
          _user = null;
          notifyListeners();
          return false;
        }
      },
    );
  }
}
