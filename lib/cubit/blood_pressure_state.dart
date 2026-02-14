part of 'blood_pressure_cubit.dart';

@immutable
sealed class BloodPressureState {}

final class BloodPressureInitialState extends BloodPressureState {}

final class BloodPressureScanningState extends BloodPressureState {
  final List<ScanResult> results;

  BloodPressureScanningState({required this.results});
}

final class BloodPressureConnectingState extends BloodPressureState {
  final BluetoothDevice device;

  BloodPressureConnectingState({required this.device});
}

final class BloodPressureConnectedState extends BloodPressureState {
  final List<BloodPressureReading> readings;

  BloodPressureConnectedState({required this.readings});
}

final class BloodPressureErrorState extends BloodPressureState {
  final String message;
  final Future<void> Function()? onRetry;

  BloodPressureErrorState({this.message = 'An error occurred while connecting to the device.', this.onRetry});
}
