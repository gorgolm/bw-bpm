import 'dart:math';

import 'package:bw_pm/config/logger/flogger.dart';
import 'package:bw_pm/model/blood_pressure_reading.dart';
import 'package:uuid/uuid.dart';

class BLEService {
  BLEService(this._uuid);

  final Uuid _uuid;

  BloodPressureReading? parseBloodPressureData(List<int> data) {
    // Not enough data
    if (data.length < 7) {
      Flogger.i("Received data is too short to be a valid blood pressure reading.");
      return null;
    }

    Flogger.d("Received Data: $data");
    try {
      // IEEE 11073-20601 Regulatory Certification Data Exchange
      // Byte 0: Flags
      int flags = data[0];
      bool isKPa = (flags & 0x01) != 0;
      bool hasTimestamp = (flags & 0x02) != 0;
      bool hasPulse = (flags & 0x04) != 0;

      int index = 1;

      // Helper for SFLOAT (16-bit)
      double readSFloat() {
        int raw = data[index] + (data[index + 1] << 8);
        index += 2;

        int mantissa = raw & 0x0FFF;
        int exponent = raw >> 12;

        if (exponent >= 0x08) exponent = -((0x0F + 1) - exponent); // signed 4-bit check
        if (mantissa >= 0x0800) mantissa = -((0xFFF + 1) - mantissa); // signed 12-bit check

        return (mantissa * pow(10, exponent)).toDouble();
      }

      // Reading values
      double systolic = readSFloat();
      double diastolic = readSFloat();
      readSFloat(); // Mean Arterial Pressure (MAP) - unused but read to advance index

      // Convert units if needed (kPa -> mmHg)
      if (isKPa) {
        systolic *= 7.50062;
        diastolic *= 7.50062;
      }

      DateTime timestamp = DateTime.now();
      if (hasTimestamp) {
        // Year (2 bytes), Month, Day, Hour, Minute, Second
        int year = data[index] + (data[index + 1] << 8);
        int month = data[index + 2];
        int day = data[index + 3];
        int hour = data[index + 4];
        int minute = data[index + 5];
        int second = data[index + 6];
        timestamp = DateTime(year, month, day, hour, minute, second);
        index += 7;
      }

      double pulse = 0;
      if (hasPulse) {
        pulse = readSFloat();
      }

      final reading = BloodPressureReading(
        id: _uuid.v6(),
        systolic: systolic.round(),
        diastolic: diastolic.round(),
        pulse: pulse.round(),
        timestamp: timestamp,
        synced: false,
      );

      Flogger.d("Received reading: ${reading.systolic}/${reading.diastolic} pulse: ${reading.pulse}");
      return reading;
    } catch (e) {
      Flogger.e("Error parsing blood pressure data: $e");
      return null;
    }
  }
}
