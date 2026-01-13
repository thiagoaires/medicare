import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String userType;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.userType,
  });

  @override
  List<Object?> get props => [id, username, email, userType];
}
