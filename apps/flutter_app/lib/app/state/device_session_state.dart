import 'package:flutter/foundation.dart';

enum ConnectionState {
  disconnected,
  scanning,
  connecting,
  connected
}

enum TransferState {
  idle,
  uploading,
  downloading
}

@immutable
class DeviceSessionState {
  final ConnectionState connection;
  final TransferState transfer;

  final double progress;  //0-1
  final int? activeSlot;

  final String deviceName;
  final int batteryPercent;
  final String firmware;

  const DeviceSessionState({
    required this.connection,
    required this.transfer,
    required this.progress,
    required this.deviceName,
    required this.batteryPercent,
    required this.firmware,
    this.activeSlot
  });

  bool get isConnected => connection == ConnectionState.connected;

  String get statusText {
    switch (connection) {
      case ConnectionState.disconnected:
        return 'Disconnected';
      case ConnectionState.scanning:
        return 'Scanning';
      case ConnectionState.connecting:
        return 'Connecting';
      case ConnectionState.connected:
        switch (transfer) {
          case TransferState.idle:
            return 'Connected';
          case TransferState.uploading:
            return 'Uploading slot $activeSlot';
          case TransferState.downloading:
            return 'Downloading slot $activeSlot';
        }
    }
  }

  DeviceSessionState copyWith({
    ConnectionState? connection,
    TransferState? transfer,
    double? progress,
    int? activeSlot,
    String? deviceName,
    int? batteryPercent,
    String? firmware
  }) {
    return DeviceSessionState(
      connection: connection ?? this.connection,
      transfer: transfer ?? this.transfer,
      progress: progress ?? this.progress,
      activeSlot: activeSlot ?? this.activeSlot,
      deviceName: deviceName ?? this.deviceName,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      firmware: firmware ?? this.firmware
    );
  }
}