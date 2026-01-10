import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'core/services/notification_service.dart';
import 'core/services/tts_service.dart';

import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/user_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/search_patients_usecase.dart';
import 'features/auth/infra/datasources/auth_remote_datasource.dart';
import 'features/auth/infra/datasources/user_remote_datasource.dart';
import 'features/auth/infra/repositories/auth_repository_impl.dart';
import 'features/auth/infra/repositories/user_repository_impl.dart';
import 'features/auth/ui/view_model/auth_view_model.dart';

import 'features/care_plan/domain/repositories/care_plan_repository.dart';
import 'features/care_plan/domain/usecases/create_care_plan_usecase.dart';
import 'features/care_plan/domain/usecases/get_plans_usecase.dart';
import 'features/care_plan/domain/usecases/update_care_plan_usecase.dart';
import 'features/care_plan/infra/datasources/care_plan_remote_datasource.dart';
import 'features/care_plan/infra/repositories/care_plan_repository_impl.dart';
import 'features/care_plan/ui/view_model/care_plan_view_model.dart';

import 'features/home/domain/usecases/get_doctor_stats_usecase.dart';
import 'features/home/ui/view_model/home_view_model.dart';
import 'features/home/ui/view_model/patient_detail_view_model.dart';

import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/logout_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/infra/datasources/profile_remote_datasource.dart';
import 'features/profile/infra/repositories/profile_repository_impl.dart';
import 'features/profile/ui/view_model/profile_view_model.dart';

import 'features/check_in/domain/repositories/check_in_repository.dart';
import 'features/check_in/domain/usecases/get_patient_check_ins_usecase.dart';
import 'features/check_in/domain/usecases/get_plan_history_usecase.dart';
import 'features/check_in/domain/usecases/has_check_in_today_usecase.dart';
import 'features/check_in/domain/usecases/perform_check_in_usecase.dart';
import 'features/check_in/infra/datasources/check_in_remote_datasource.dart';
import 'features/check_in/infra/repositories/check_in_repository_impl.dart';
import 'features/check_in/ui/view_model/check_in_view_model.dart';

import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/domain/usecases/get_messages_usecase.dart';
import 'features/chat/domain/usecases/send_message_usecase.dart';
import 'features/chat/infra/datasources/chat_remote_datasource.dart';
import 'features/chat/infra/repositories/chat_repository_impl.dart';
import 'features/chat/ui/view_model/chat_view_model.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  // Parse Server Initialization
  await dotenv.load(fileName: ".env");
  final keyApplicationId = dotenv.env['APP_ID'] ?? '';
  final keyClientKey = dotenv.env['CLIENT_KEY'] ?? '';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  if (keyApplicationId.isEmpty || keyClientKey.isEmpty) {
    throw Exception('CHAVES DO PARSE NÃO ENCONTRADAS NO .ENV');
  }

  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
  );

  //! Core
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<TtsService>(() => TtsService());

  //! Features - Auth
  // ViewModel
  sl.registerFactory(
    () => AuthViewModel(loginUseCase: sl(), registerUseCase: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => SearchPatientsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));

  // DataSource
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => ParseAuthDataSourceImpl(),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(),
  );

  //! Features - CarePlan
  // ViewModel
  sl.registerFactory(
    () => CarePlanViewModel(
      createCarePlanUseCase: sl(),
      getPlansUseCase: sl(),
      updateCarePlanUseCase: sl(),
      searchPatientsUseCase: sl(),
    ),
  );

  //! Features - Home
  sl.registerFactory(() => HomeViewModel(getDoctorStatsUseCase: sl()));

  sl.registerLazySingleton(
    () => GetDoctorStatsUseCase(
      carePlanRepository: sl(),
      checkInRepository: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => CreateCarePlanUseCase(sl()));
  sl.registerLazySingleton(() => GetPlansUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCarePlanUseCase(sl()));

  // Repository
  sl.registerLazySingleton<CarePlanRepository>(
    () => CarePlanRepositoryImpl(sl()),
  );

  // DataSource
  sl.registerLazySingleton<CarePlanRemoteDataSource>(
    () => ParseCarePlanDataSourceImpl(),
  );

  //! Features - Profile
  // ViewModel
  sl.registerFactory(
    () => ProfileViewModel(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  // DataSource
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ParseProfileDataSourceImpl(),
  );

  //! Features - Check-In
  // ViewModel
  sl.registerFactory(
    () => CheckInViewModel(
      performCheckInUseCase: sl(),
      getPlanHistoryUseCase: sl(),
      hasCheckInTodayUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => PatientDetailViewModel(getPatientCheckInsUseCase: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => PerformCheckInUseCase(sl()));
  sl.registerLazySingleton(() => GetPlanHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetPatientCheckInsUseCase(sl()));
  sl.registerLazySingleton(() => HasCheckInTodayUseCase(sl()));

  // Repository
  sl.registerLazySingleton<CheckInRepository>(
    () => CheckInRepositoryImpl(sl(), carePlanRepository: sl()),
  );

  // DataSource
  sl.registerLazySingleton<CheckInRemoteDataSource>(
    () => ParseCheckInDataSourceImpl(),
  );

  //! Features - Chat
  // ViewModel
  sl.registerFactory(
    () => ChatViewModel(sendMessageUseCase: sl(), getMessagesUseCase: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSource
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(),
  );
}
