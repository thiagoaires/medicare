import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'package:medicare/features/core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(
    String name,
    String email,
    String password,
    String type,
  );
}

class ParseAuthDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login(String email, String password) async {
    final user = ParseUser(email, password, null);

    // O ParseSDK faz a mágica de rede aqui
    var response = await user.login();

    if (response.success) {
      return UserModel.fromParse(response.result as ParseUser);
    } else {
      // Tratamento de erro do Parse
      throw ServerException(
        message: response.error?.message ?? 'Erro desconhecido',
      );
    }
  }

  @override
  Future<UserModel> register(
    String name,
    String email,
    String password,
    String type,
  ) async {
    final user = ParseUser.createUser(email, password, email);

    user.set<String>('fullName', name);
    user.set<String>('userType', type);

    var response = await user.signUp();

    if (response.success) {
      return UserModel.fromParse(response.result as ParseUser);
    } else {
      throw ServerException(
        message: response.error?.message ?? 'Erro ao cadastrar',
      );
    }
  }
}
