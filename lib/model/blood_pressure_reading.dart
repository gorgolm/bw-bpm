import 'package:flutter/material.dart';

@immutable
class BloodPressureReading {
  final String id;
  final int systolic;
  final int diastolic;
  final int pulse;
  final DateTime timestamp;
  final bool synced;

  const BloodPressureReading({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.timestamp,
    this.synced = false,
  });

  BloodPressureReading copyWith({
    String? id,
    int? systolic,
    int? diastolic,
    int? pulse,
    DateTime? timestamp,
    bool? synced,
  }) {
    return BloodPressureReading(
      id: id ?? this.id,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'systolic': systolic,
    'diastolic': diastolic,
    'pulse': pulse,
    'timestamp': timestamp.toIso8601String(),
    'synced': synced,
  };

  factory BloodPressureReading.fromJson(Map<String, dynamic> json) => BloodPressureReading(
    id: json['id'] as String,
    systolic: json['systolic'] as int,
    diastolic: json['diastolic'] as int,
    pulse: json['pulse'] as int,
    timestamp: DateTime.parse(json['timestamp'] as String),
    synced: json['synced'] as bool? ?? false,
  );
}
