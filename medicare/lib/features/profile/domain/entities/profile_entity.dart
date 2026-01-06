import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String userType;
  final String? crm;
  final String? phone;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.crm,
    this.phone,
  });

  @override
  List<Object?> get props => [id, name, email, userType, crm, phone];
}
