import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.userType,
    super.crm,
    super.phone,
  });

  factory ProfileModel.fromParse(ParseUser user) {
    return ProfileModel(
      id: user.objectId!,
      name:
          user.get<String>('fullName') ??
          user.get<String>('username') ??
          'Sem Nome',
      email: user.emailAddress ?? user.username ?? '',
      userType: user.get<String>('userType') ?? '',
      crm: user.get<String>('crm'),
      phone: user.get<String>('phone'),
    );
  }
}
