import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import 'core/ai_providers/ai_provider_manager.dart';
import 'core/network/network_info.dart';
import 'features/virtual_tryon/data/datasources/local_image_datasource.dart';
import 'features/virtual_tryon/data/datasources/replicate_remote_datasource.dart';
import 'features/virtual_tryon/data/repositories/tryon_repository_impl.dart';
import 'features/virtual_tryon/domain/repositories/tryon_repository.dart';
import 'features/virtual_tryon/domain/usecases/apply_virtual_tryon.dart';
import 'features/virtual_tryon/domain/usecases/generate_garment_from_text.dart';
import 'features/virtual_tryon/domain/usecases/select_user_image.dart';
import 'features/virtual_tryon/presentation/bloc/tryon_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // API Keys - In production, load from secure storage or environment
  const String fitroomApiKey = '031e299385954981ae793998ecdc59621e5cf863c36f6abbd7f11698c36fb0aa';

  // Core dependencies
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => ImagePicker());
  sl.registerLazySingleton(() => Connectivity());

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  // AI Provider Manager (FitRoom)
  final aiProviderManager = AIProviderManager();
  await aiProviderManager.initialize(fitroomApiKey: fitroomApiKey);
  sl.registerLazySingleton(() => aiProviderManager);

  // Data sources (legacy - not used with FitRoom)
  sl.registerLazySingleton<ReplicateRemoteDataSource>(
    () => ReplicateRemoteDataSourceImpl(
      dio: sl(),
      apiToken: '', // Not used - FitRoom handles API directly
    ),
  );

  sl.registerLazySingleton<LocalImageDataSource>(
    () => LocalImageDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<TryonRepository>(
    () => TryonRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SelectUserImage(sl()));
  sl.registerLazySingleton(() => GenerateGarmentFromText(sl()));
  sl.registerLazySingleton(() => ApplyVirtualTryon(sl()));

  // BLoC
  sl.registerFactory(
    () => TryonBloc(
      selectUserImage: sl(),
      providerManager: sl(),
      imagePicker: sl(),
    ),
  );
}
