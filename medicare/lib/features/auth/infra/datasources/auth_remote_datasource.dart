import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(
    String name,
    String email,
    String password,
    String type,
  );
  Future<UserModel?> getCurrentUser();
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
      // Define permissões de segurança APÓS o login/criação
      final currentUser = response.result as ParseUser;
      final acl = ParseACL(owner: currentUser);
      acl.setPublicReadAccess(
        allowed: true,
      ); // Todo mundo pode ler (Nome, Email)
      acl.setPublicWriteAccess(allowed: false); // Só o dono pode editar
      currentUser.setACL(acl);

      await currentUser.save();

      return UserModel.fromParse(currentUser);
    } else {
      throw ServerException(
        message: response.error?.message ?? 'Erro ao cadastrar',
      );
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = await ParseUser.currentUser() as ParseUser?;
      if (user != null && user.sessionToken != null) {
        final response = await user.getUpdatedUser();
        if (response.success && response.result != null) {
          return UserModel.fromParse(response.result as ParseUser);
        }
      }
      return null;
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar usuário atual: $e');
    }
  }
}
