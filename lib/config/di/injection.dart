import 'package:bw_pm/cubit/bluetooth_status_cubit.dart';
import 'package:bw_pm/cubit/internet_connection_status_cubit.dart';
import 'package:bw_pm/services/ble_service.dart';
import 'package:bw_pm/services/local_storage_service.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Services
  getIt
    ..registerLazySingleton<LocalStorageService>(() => LocalStorageService(preferences: SharedPreferencesAsync()))
    ..registerLazySingleton<BLEService>(() => BLEService(const Uuid()))
    // Cubits
    ..registerFactory<BluetoothStatusCubit>(BluetoothStatusCubit.new)
    ..registerFactory<InternetConnectionStatusCubit>(
      () => InternetConnectionStatusCubit(internetConnection: InternetConnection()),
    );
}
