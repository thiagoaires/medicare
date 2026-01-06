import 'package:flutter/material.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final LogoutUseCase logoutUseCase;

  ProfileViewModel({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.logoutUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isEditing = false;
  bool get isEditing => _isEditing;

  ProfileEntity? _profile;
  ProfileEntity? get profile => _profile;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getProfileUseCase();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (profile) {
        _profile = profile;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void toggleEdit() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  Future<void> saveProfile(String name, String phone) async {
    if (_profile == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Create updated profile entity
    final updatedProfile = ProfileEntity(
      id: _profile!.id,
      name: name,
      email: _profile!.email,
      userType: _profile!.userType,
      crm: _profile!.crm,
      phone: phone,
    );

    final result = await updateProfileUseCase(updatedProfile);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (_) {
        // Success
        _profile = updatedProfile;
        _isEditing = false;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final result = await logoutUseCase();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (_) {
        _isLoading = false;
        notifyListeners();
        // Clear everything and go to login
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      },
    );
  }
}
