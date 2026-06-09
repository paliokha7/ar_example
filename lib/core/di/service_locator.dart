import 'package:get_it/get_it.dart';
import '../services/ar_platform_service.dart';
import '../../features/ar/data/repositories/ar_repository_impl.dart';
import '../../features/ar/domain/repositories/ar_repository.dart';
import '../../features/ar/presentation/cubit/plane_detection_cubit.dart';

final sl = GetIt.instance;

void init() {
  // Services
  sl.registerLazySingleton<UnifiedARPlatformService>(
    () => UnifiedARPlatformService(),
  );

  // Repositories
  sl.registerLazySingleton<ARRepository>(
    () => ARRepositoryImpl(sl<UnifiedARPlatformService>()),
  );

  // Cubits
  sl.registerFactory(
    () => PlaneDetectionCubit(sl<ARRepository>()),
  );
} 