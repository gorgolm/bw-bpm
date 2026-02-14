import 'dart:async';

import 'package:bw_pm/config/di/injection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  FlutterBluePlus.setLogLevel(.warning);
  FlutterBluePlus.setOptions(restoreState: true); // Note: For iOS background BLE usage

  // Title: Request permissions at app startup
  // TODO: Should ask after some user interaction, like tapping on "connect device" etc.
  unawaited(_requestPermissions());
  runApp(await builder());
}

Future<void> _requestPermissions() async =>
    await [Permission.bluetooth, Permission.bluetoothScan, Permission.bluetoothConnect, Permission.location].request();
