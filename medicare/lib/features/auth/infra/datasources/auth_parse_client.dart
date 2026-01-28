import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

// Interface para o cliente do Parse
abstract class AuthParseClient {
  Future<ParseResponse> login(String username, String password);
  Future<ParseResponse> signUp(ParseUser user);
  Future<ParseUser?> currentUser();
  Future<ParseResponse> getUpdatedUser(ParseUser user);
  Future<ParseResponse> save(ParseObject object);
  ParseUser createUser(String username, String password, String? emailAddress);
}

// Implementação real do cliente
class AuthParseClientImpl implements AuthParseClient {
  @override
  Future<ParseResponse> login(String username, String password) async {
    final user = ParseUser(username, password, null);
    return await user.login();
  }

  @override
  Future<ParseResponse> signUp(ParseUser user) async {
    return await user.signUp();
  }

  @override
  Future<ParseUser?> currentUser() async {
    return await ParseUser.currentUser() as ParseUser?;
  }

  @override
  Future<ParseResponse> getUpdatedUser(ParseUser user) async {
    return await user.getUpdatedUser();
  }

  @override
  Future<ParseResponse> save(ParseObject object) async {
    return await object.save();
  }

  @override
  ParseUser createUser(String username, String password, String? emailAddress) {
    return ParseUser.createUser(username, password, emailAddress);
  }
}
