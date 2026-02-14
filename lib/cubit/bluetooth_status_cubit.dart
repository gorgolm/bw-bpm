import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothStatusCubit extends Cubit<BluetoothAdapterState> {
  BluetoothStatusCubit() : super(.unknown) {
    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen(_onAdapterStateChanged);
  }

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  void _onAdapterStateChanged(BluetoothAdapterState state) => emit(state);

  @override
  Future<void> close() {
    _adapterStateStateSubscription.cancel();
    return super.close();
  }
}
