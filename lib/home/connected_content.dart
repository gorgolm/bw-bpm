import 'package:bw_pm/model/blood_pressure_reading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReadingsOrWaitingContent extends StatelessWidget {
  const ReadingsOrWaitingContent({required this.readings, super.key});

  final List<BloodPressureReading> readings;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Icon(Icons.monitor_heart, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Waiting for measurement...', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              'Ensure your Device is On and Bluetooth is enabled.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: readings.length,
      itemBuilder: (context, index) {
        final r = readings[index];
        final pulseText = r.pulse > 0 ? 'Pulse: ${r.pulse} bpm\n' : '';
        final subtitleText = '$pulseText${DateFormat('EEE, MMM d • HH:mm:ss').format(r.timestamp)}';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: r.systolic > 140 ? Colors.red.shade100 : Colors.green.shade100,
              child: Icon(Icons.favorite, color: r.systolic > 140 ? Colors.red : Colors.green),
            ),
            title: Text(
              '${r.systolic}/${r.diastolic} mmHg',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(subtitleText),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: .center,
              children: [
                Icon(
                  r.synced ? Icons.cloud_done : Icons.cloud_upload_outlined,
                  color: r.synced ? Colors.teal : Colors.orange,
                  size: 28,
                ),
                if (!r.synced) const Text('Pending', style: TextStyle(fontSize: 10, color: Colors.orange)),
              ],
            ),
          ),
        );
      },
    );
  }
}
