import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetConnectionStatusCubit extends Cubit<bool> {
  InternetConnectionStatusCubit({required InternetConnection internetConnection})
    : _internetConnection = internetConnection,
      super(false) {
    _internetConnection.onStatusChange.listen(_onConnectivityChanged);
    _initializeStatus();
  }

  final InternetConnection _internetConnection;
  late final StreamSubscription<InternetStatus> _connectivitySubscription;

  Future<void> _initializeStatus() async => _emitStatus(await _internetConnection.internetStatus);

  void _onConnectivityChanged(InternetStatus result) => _emitStatus(result);

  void _emitStatus(InternetStatus result) => emit(result == .connected);

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
