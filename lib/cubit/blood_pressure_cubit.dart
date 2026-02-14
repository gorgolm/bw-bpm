import 'dart:async';

import 'package:bw_pm/config/keys.dart';
import 'package:bw_pm/config/logger/flogger.dart';
import 'package:bw_pm/model/blood_pressure_reading.dart';
import 'package:bw_pm/services/ble_service.dart';
import 'package:bw_pm/services/local_storage_service.dart';
import 'package:bw_pm/services/sync_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'blood_pressure_state.dart';

class BloodPressureCubit extends Cubit<BloodPressureState> {
  BloodPressureCubit({
    required SyncService syncService,
    required BLEService bleService,
    required LocalStorageService localStorage,
  }) : _bleService = bleService,
       _syncService = syncService,
       _localStorage = localStorage,
       super(BloodPressureInitialState()) {
    _scanSubscription = FlutterBluePlus.scanResults.listen(_onScanResults);
  }

  // Standard GATT UUIDs for Blood Pressure
  // Service: 0x1810
  static const String _bpServiceUUID = '1810';
  // Characteristic: 0x2A35 (Blood Pressure Measurement)
  static const String _bpMeasurementCharacteristicUUID = '2A35';

  final SyncService _syncService;
  final BLEService _bleService;
  final LocalStorageService _localStorage;

  late final StreamSubscription<List<ScanResult>> _scanSubscription;
  StreamSubscription<List<int>>? _scanDataSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  String? _autoConnectRemoteId;
  bool _isConnecting = false;
  bool _hasConnected = false;

  @override
  Future<void> close() async {
    await _scanSubscription.cancel();
    await _scanDataSubscription?.cancel();
    await _connectionStateSubscription?.cancel();
    return super.close();
  }

  /// Starts scanning for Bluetooth devices advertising the Blood Pressure Service
  Future<void> startScanning() async {
    if (FlutterBluePlus.isScanningNow) return;

    _autoConnectRemoteId = await _getSavedDeviceId();
    emit(BloodPressureScanningState(results: const []));

    await FlutterBluePlus.startScan(
      withServices: [Guid(_bpServiceUUID)],
      withRemoteIds: [?_autoConnectRemoteId],
      removeIfGone: const Duration(seconds: 5),
      continuousUpdates: true,
    );
  }

  /// Stops scanning for Bluetooth devices
  Future<void> stopScanning() async {
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
  }

  Future<void> connectToDevice(ScanResult result) async {
    if (_isConnecting) return;

    _autoConnectRemoteId = result.device.remoteId.str;
    emit(BloodPressureConnectingState(device: result.device));
    await stopScanning();
    await _connectAndSubscribe(result.device);
  }

  void _onScanResults(List<ScanResult> results) {
    final sortedResults = results..sort((a, b) => b.rssi.compareTo(a.rssi));
    emit(BloodPressureScanningState(results: sortedResults));

    final autoId = _autoConnectRemoteId;
    if (autoId == null || _isConnecting) return;

    ScanResult? match;
    for (final result in sortedResults) {
      if (result.device.remoteId.str == autoId) {
        match = result;
        break;
      }
    }

    if (match != null) {
      connectToDevice(match);
    }
  }

  Future<void> _connectAndSubscribe(BluetoothDevice device) async {
    if (_isConnecting) return;
    _isConnecting = true;
    _hasConnected = false;

    try {
      // Skip if already connected
      if (device.isConnected) {
        _hasConnected = true;
        emit(BloodPressureConnectedState(readings: const []));
        return;
      }

      // Connect to the device
      Flogger.d('Connecting to ${device.platformName} (${device.remoteId})');
      await _connectToDevice(device);
    } on Exception catch (e) {
      Flogger.e('Connection error: $e');
      return emit(
        BloodPressureErrorState(message: 'Failed to connect: $e', onRetry: () => _connectAndSubscribe(device)),
      );
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = device.connectionState.listen((state) async {
      if (state == .connected) {
        Flogger.d('Connected! Discovering services...');
        _hasConnected = true;
        await _getDeviceServices(device);
        return;
      }

      if (state == .disconnected && _hasConnected) {
        Flogger.d('Device disconnected. Restarting scan...');
        await _scanDataSubscription?.cancel();
        _scanDataSubscription = null;
        emit(BloodPressureScanningState(results: const []));
        await startScanning();
      }
    });
    // Connect to device
    await device.connect(autoConnect: true, mtu: null, license: .free); // Free license 👀
  }

  Future<void> _getDeviceServices(BluetoothDevice device) async {
    final services = await device.discoverServices();

    // Find the Blood Pressure Service (UUID 0x1810)
    for (final service in services) {
      if (service.uuid.toString().toUpperCase() == _bpServiceUUID) {
        Flogger.d('Found Blood Pressure service!');

        // Find the Blood Pressure Measurement Characteristic (UUID 0x2A35)
        for (final characteristic in service.characteristics) {
          if (characteristic.uuid.toString().toUpperCase() == _bpMeasurementCharacteristicUUID) {
            Flogger.d('Found Blood Pressure Measurement Characteristic! - Subscribing...');
            await _subscribeToCharacteristic(characteristic, device.remoteId.str);
          }
        }
      }
    }
  }

  Future<void> _subscribeToCharacteristic(BluetoothCharacteristic characteristic, String deviceId) async {
    // Enable notifications
    await characteristic.setNotifyValue(true); //TODO: should check if successful

    // Listen to data
    await _scanDataSubscription?.cancel();
    _scanDataSubscription = characteristic.lastValueStream.listen((bpValue) async {
      if (bpValue.isNotEmpty) {
        final bp = _bleService.parseBloodPressureData(bpValue);
        if (bp != null) {
          final synced = await _syncService.enqueueReading(bp);
          if (state case final BloodPressureConnectedState currentState) {
            emit(
              BloodPressureConnectedState(
                readings: [
                  bp.copyWith(synced: synced),
                  ...currentState.readings,
                ],
              ),
            );
          }
        }
      }
    });

    await _saveDeviceId(deviceId);
    emit(BloodPressureConnectedState(readings: const []));
  }

  Future<String?> _getSavedDeviceId() async => _localStorage.get<String>(lastUsedBpDeviceIdKey);

  Future<void> _saveDeviceId(String deviceId) async => _localStorage.save<String>(lastUsedBpDeviceIdKey, deviceId);
}
