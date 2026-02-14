import 'package:bw_pm/cubit/blood_pressure_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanningContent extends StatelessWidget {
  const ScanningContent({required this.results, super.key});

  final List<ScanResult> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const _SearchingForDevicesWidget();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final name = _deviceName(result);
        final remoteId = result.device.remoteId.str;

        return Card(
          margin: const .symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.bluetooth, color: Colors.blueGrey),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(remoteId, style: Theme.of(context).textTheme.bodySmall),
            trailing: ElevatedButton(
              onPressed: () => context.read<BloodPressureCubit>().connectToDevice(result),
              child: const Text('Connect'),
            ),
          ),
        );
      },
    );
  }

  String _deviceName(ScanResult result) {
    final name = result.device.platformName;
    if (name.isNotEmpty) return name;

    final advName = result.advertisementData.advName;
    if (advName.isNotEmpty) return advName;

    return 'Unknown device';
  }
}

class _SearchingForDevicesWidget extends StatelessWidget {
  const _SearchingForDevicesWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const .symmetric(horizontal: 16, vertical: 16),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            const Text(
              'Searching for blood pressure devices...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              'Make sure your device is advertising the BP service.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }
}
