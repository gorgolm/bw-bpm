import 'package:bw_pm/config/logger/flogger.dart';
import 'package:bw_pm/cubit/bluetooth_status_cubit.dart';
import 'package:bw_pm/cubit/internet_connection_status_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blood Pressure Monitor'), elevation: 2),
      body: BlocListener<InternetConnectionStatusCubit, bool>(
        listener: (context, state) {
          Flogger.d('Internet connection status changed: ${state ? 'Connected' : 'Disconnected'}');
        },
        child: BlocBuilder<BluetoothStatusCubit, BluetoothAdapterState>(
          builder: (context, state) {
            return Column(children: [Text(state.toString())]);
          },
        ),
      ),
    );
  }
}
