import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../../../core/errors/exceptions.dart';
import '../models/profile_model.dart';
import '../../domain/entities/profile_entity.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<void> updateProfile(ProfileEntity profile);
  Future<void> logout();
}

class ParseProfileDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<ProfileModel> getProfile() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user == null) {
      throw const ServerException(message: 'User not logged in');
    }

    final response = await user.getUpdatedUser();
    if (response.success && response.result != null) {
      return ProfileModel.fromParse(response.result as ParseUser);
    } else {
      throw ServerException(
        message: response.error?.message ?? 'Failed to fetch user',
      );
    }
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user == null) {
      throw const ServerException(message: 'User not logged in');
    }

    user.set('name', profile.name);
    if (profile.phone != null) {
      user.set('phone', profile.phone);
    }

    final response = await user.save();
    if (!response.success) {
      throw ServerException(
        message: response.error?.message ?? 'Failed to update profile',
      );
    }
  }

  @override
  Future<void> logout() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      final response = await user.logout();
      if (!response.success) {
        throw ServerException(
          message: response.error?.message ?? 'Failed to logout',
        );
      }
    }
  }
}
