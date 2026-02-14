import 'dart:async';
import 'dart:convert';

import 'package:bw_pm/config/keys.dart';
import 'package:bw_pm/config/logger/flogger.dart';
import 'package:bw_pm/model/blood_pressure_reading.dart';
import 'package:bw_pm/services/local_storage_service.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class SyncService {
  SyncService({
    required LocalStorageService localStorage,
    required InternetConnection internetConnection,
  }) : _localStorage = localStorage,
       _internetConnection = internetConnection {
    _connectivitySubscription = _internetConnection.onStatusChange.listen(_onConnectivityChanged);
    _initializeStatus();
  }

  final LocalStorageService _localStorage;
  final InternetConnection _internetConnection;
  late final StreamSubscription<InternetStatus> _connectivitySubscription;

  bool _isConnected = false;
  bool _isSyncing = false;

  Future<bool> enqueueReading(BloodPressureReading reading) async {
    if (_isConnected) {
      _logSync(reading.copyWith(synced: true));
      return true;
    }

    await _storeReading(reading);
    return false;
  }

  Future<void> dispose() async {
    await _connectivitySubscription.cancel();
  }

  Future<void> _initializeStatus() async {
    final status = await _internetConnection.internetStatus;
    _onConnectivityChanged(status);
  }

  void _onConnectivityChanged(InternetStatus status) {
    Flogger.d('Connectivity changed: $status');
    _isConnected = status == .connected;
    if (_isConnected) {
      unawaited(_flushQueue());
    }
  }

  Future<void> _flushQueue() async {
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      final queue = await _loadQueue();
      if (queue.isEmpty) return;

      for (final reading in queue) {
        _logSync(reading.copyWith(synced: true));
      }

      await _localStorage.delete(bpReadingsKey);
    } finally {
      _isSyncing = false;
    }
  }

  // TODO: should have some mutex over the storage access - or just a different storage solution altogether
  Future<void> _storeReading(BloodPressureReading reading) async {
    final queue = await _loadQueue();
    queue.add(reading);
    await _saveQueue(queue);
  }

  // TODO: this is very inefficient but just for PoC its ok
  Future<List<BloodPressureReading>> _loadQueue() async {
    final raw = await _localStorage.get<String>(bpReadingsKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = (jsonDecode(raw)) as List<dynamic>;
      return list.map((item) => BloodPressureReading.fromJson((item as Map).cast<String, dynamic>())).toList();
    } on Exception catch (error) {
      Flogger.e('Failed to decode queued readings: $error');
      return [];
    }
  }

  Future<void> _saveQueue(List<BloodPressureReading> queue) async {
    final jsonString = jsonEncode(queue.map((reading) => reading.toJson()).toList());
    await _localStorage.save<String>(bpReadingsKey, jsonString);
  }

  // Mocked API call
  void _logSync(BloodPressureReading reading) {
    Flogger.d(
      '''
Uploading reading ${reading.id}:
BP: ${reading.systolic}/${reading.diastolic}
Pulse: ${reading.pulse}
Date: ${reading.timestamp.toIso8601String()}
''',
    );
  }
}
