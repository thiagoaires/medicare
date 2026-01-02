import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/infra/datasources/auth_remote_datasource.dart';
import 'features/auth/infra/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/provider/auth_provider.dart';

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

  //! Features - Auth
  // Provider
  sl.registerFactory(
    () => AuthProvider(loginUseCase: sl(), registerUseCase: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // DataSource
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => ParseAuthDataSourceImpl(),
  );
}
