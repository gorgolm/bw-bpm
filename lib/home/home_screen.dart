import 'package:bw_pm/config/di/injection.dart';
import 'package:bw_pm/cubit/blood_pressure_cubit.dart';
import 'package:bw_pm/cubit/bluetooth_status_cubit.dart';
import 'package:bw_pm/home/connected_content.dart';
import 'package:bw_pm/home/scanning_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blood Pressure Monitor'), elevation: 2),
      body: BlocBuilder<BluetoothStatusCubit, BluetoothAdapterState>(
        builder: (context, bluetoothState) {
          if (bluetoothState == .on) {
            return const BPMonitorContent();
          }
          return _BluetoothNotEnabledContent(currentState: bluetoothState);
        },
      ),
    );
  }
}

class BPMonitorContent extends StatelessWidget {
  const BPMonitorContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BloodPressureCubit>(
      create: (_) => getIt<BloodPressureCubit>()..startScanning(),
      child: BlocBuilder<BloodPressureCubit, BloodPressureState>(
        builder: (context, state) => switch (state) {
          BloodPressureInitialState() => const Center(child: CircularProgressIndicator()),
          BloodPressureScanningState() => ScanningContent(results: state.results),
          BloodPressureConnectingState() => _ConnectingContent(device: state.device),
          BloodPressureConnectedState() => ReadingsOrWaitingContent(readings: state.readings),
          BloodPressureErrorState() => _ErrorContent(message: state.message, onRetry: state.onRetry),
        },
      ),
    );
  }
}

class _BluetoothNotEnabledContent extends StatelessWidget {
  const _BluetoothNotEnabledContent({required this.currentState});

  final BluetoothAdapterState currentState;

  @override
  Widget build(BuildContext context) {
    if (currentState == .off) {
      return Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Icon(Icons.bluetooth_disabled, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Bluetooth is Off',
              style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Please enable Bluetooth to receive measurements.', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking Bluetooth status...', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }
  }
}

class _ConnectingContent extends StatelessWidget {
  const _ConnectingContent({required this.device});

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            device.platformName.isNotEmpty ? 'Connecting to ${device.platformName}' : 'Connecting...',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.message, this.onRetry});

  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text('Connection failed', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => onRetry!(), child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
