import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

enum AuthStatus { initial, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthViewModel({required this.loginUseCase, required this.registerUseCase});

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

  Future<bool> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final user = await ParseUser.currentUser() as ParseUser?;

      if (user != null && user.sessionToken != null) {
        final response = await user.getUpdatedUser();
        if (response.success && response.result != null) {
          final updatedUser = response.result as ParseUser;
          _user = UserEntity(
            id: updatedUser.objectId!,
            name: updatedUser.get<String>('name') ?? '',
            email: updatedUser.emailAddress ?? '',
            type: updatedUser.get<String>('userType') ?? 'paciente',
          );
          _status = AuthStatus.success;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      // Error checking auth
    }

    _status = AuthStatus.initial;
    _user = null;
    notifyListeners();
    return false;
  }
}
