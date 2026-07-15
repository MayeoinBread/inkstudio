import 'package:flutter/material.dart' hide ConnectionState;
import 'package:inkstudio/app/data/models/device_settings.dart';
import 'package:inkstudio/app/state/device_session_state.dart';
import 'package:inkstudio/transport/device_info.dart';

class DeviceSessionService extends ValueNotifier<DeviceSessionState> {

  DeviceSessionService._() : super(_initial);

  static final instance = DeviceSessionService._();

  static final DeviceSessionState _initial = DeviceSessionState(
    connection: ConnectionState.disconnected,
    transfer: TransferState.idle,
    progress: 0.0,
    deviceName: 'Not Connected',
    deviceInfo: DeviceInfo(battery: 0, hardware: '-', firmware: '-', serial: '-', flag: 0),
    availableSlots: const[],
    settings: DeviceSettings(seconds: 3600, accelerometer: false)
  );

  DeviceSessionState get state => value;
  set state(DeviceSessionState newState) => value = newState;

  void update(DeviceSessionState Function(DeviceSessionState s) fn) {
    value = fn(value);
  }
}