import 'package:bw_pm/config/di/injection.dart';
import 'package:bw_pm/cubit/bluetooth_status_cubit.dart';
import 'package:bw_pm/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BluetoothStatusCubit>(create: (_) => getIt<BluetoothStatusCubit>()),
      ],
      child: MaterialApp(
        title: 'Blood Pressure Monitor',
        theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
