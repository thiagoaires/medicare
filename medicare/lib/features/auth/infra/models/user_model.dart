import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.userType,
  });

  // Factory que converte o objeto sujo do ParseSDK para nosso Model limpo
  factory UserModel.fromParse(ParseUser parseUser) {
    return UserModel(
      id: parseUser.objectId!,
      username: parseUser.get<String>('fullName') ?? 'Sem Nome',
      email: parseUser.emailAddress ?? '',
      userType: parseUser.get<String>('userType') ?? 'paciente',
    );
  }
}
