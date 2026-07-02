import 'package:flutter/material.dart' hide ConnectionState;
import 'package:inkstudio/app/data/models/device_settings.dart';
import 'package:inkstudio/app/state/device_session_state.dart';

class DeviceSessionService extends ValueNotifier<DeviceSessionState> {

  DeviceSessionService._() : super(_initial);

  static final instance = DeviceSessionService._();

  static final DeviceSessionState _initial = DeviceSessionState(
    connection: ConnectionState.disconnected,
    transfer: TransferState.idle,
    progress: 0.0,
    deviceName: 'Not Connected',
    batteryPercent: 0,
    firmware: '-',
    availableSlots: const[],
    settings: DeviceSettings(seconds: 3600, accelerometer: false)
  );

  DeviceSessionState get state => value;
  set state(DeviceSessionState newState) => value = newState;

  void update(DeviceSessionState Function(DeviceSessionState s) fn) {
    value = fn(value);
  }
}