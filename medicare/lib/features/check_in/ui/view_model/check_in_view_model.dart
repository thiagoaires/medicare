import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/check_in_entity.dart';
import '../../domain/usecases/get_plan_history_usecase.dart';
import '../../domain/usecases/perform_check_in_usecase.dart';
import '../../domain/usecases/has_check_in_today_usecase.dart';

class CheckInViewModel extends ChangeNotifier {
  final PerformCheckInUseCase performCheckInUseCase;
  final GetPlanHistoryUseCase getPlanHistoryUseCase;
  final HasCheckInTodayUseCase hasCheckInTodayUseCase; // New dependency

  CheckInViewModel({
    required this.performCheckInUseCase,
    required this.getPlanHistoryUseCase,
    required this.hasCheckInTodayUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCheckingStatus = false;
  bool get isCheckingStatus => _isCheckingStatus;

  bool _isCheckedInToday = false;
  bool get isCheckedInToday => _isCheckedInToday;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CheckInEntity> _history = [];
  List<CheckInEntity> get history => _history;

  Future<void> checkStatus(String planId) async {
    _isCheckingStatus = true;
    _errorMessage = null;
    notifyListeners();

    // Use efficient hasCheckInToday query first
    final hasCheckInResult = await hasCheckInTodayUseCase(planId);

    hasCheckInResult.fold(
      (failure) {
        // Silently fail or log, but don't block UI too much?
        // Or treat as not checked in?
        _isCheckedInToday = false;
      },
      (hasCheckIn) {
        _isCheckedInToday = hasCheckIn;
      },
    );

    // Also fetch history if needed for other screens, or separate?
    // For now keeping history fetch but it's secondary to the status check for FAB.
    // Actually, let's keep getPlanHistoryUseCase if used by other parts,
    // but relies on hasCheckInToday for the FAB state to be fast.

    _isCheckingStatus = false;
    notifyListeners();
  }

  Future<File?> pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (status.isPermanentlyDenied) {
        _errorMessage =
            'Permissão de câmera negada permanentemente. Ative nas configurações.';
        notifyListeners();
        return null;
      }
      if (!status.isGranted) return null;
    } else if (source == ImageSource.gallery) {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        PermissionStatus status;
        if (androidInfo.version.sdkInt <= 32) {
          status = await Permission.storage.request();
        } else {
          status = await Permission.photos.request();
        }

        if (status.isPermanentlyDenied) {
          _errorMessage =
              'Permissão de galeria negada permanentemente. Ative nas configurações.';
          notifyListeners();
          return null;
        }
        if (!status.isGranted) return null;
      }
      // iOS gallery permission is handled by plist mostly, but can add Permission.photos check if needed.
    }

    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70, // Optimize size
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      _errorMessage = 'Erro ao selecionar imagem: $e';
      notifyListeners();
    }
    return null;
  }

  Future<bool> doCheckIn(
    String planId, {
    String? notes,
    int? feeling,
    File? photo,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await performCheckInUseCase(
      planId,
      notes,
      feeling: feeling,
      photo: photo,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        // Sucesso
        _isCheckedInToday = true;
        _isLoading = false;
        notifyListeners();
        // Refresh history to include the new one
        checkStatus(planId);
        return true;
      },
    );
  }
}
