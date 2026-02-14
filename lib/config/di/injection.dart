import 'package:bw_pm/services/ble_service.dart';
import 'package:bw_pm/services/local_storage_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<LocalStorageService>(() => LocalStorageService(preferences: SharedPreferencesAsync()));
  getIt.registerLazySingleton<BLEService>(() => BLEService(const Uuid()));
}
