import 'package:flutter/foundation.dart';
import 'package:inkstudio/app/data/models/device_settings.dart';
import 'package:inkstudio/transport/device_info.dart';

enum ConnectionState {
  disconnected,
  scanning,
  connecting,
  connected
}

enum TransferState {
  idle,
  uploading,
  downloading,
  importing
}

@immutable
class DeviceSessionState {
  final ConnectionState connection;
  final TransferState transfer;

  final double progress;  //0-1

  final int? activeSlot;
  final int? transferSlot;
  final List<int> availableSlots;

  final String deviceName;
  
  final DeviceInfo deviceInfo;

  final DeviceSettings settings;

  const DeviceSessionState({
    required this.connection,
    required this.transfer,
    required this.progress,
    required this.deviceName,
    required this.deviceInfo,
    required this.availableSlots,
    required this.settings,
    this.activeSlot,
    this.transferSlot
  });

  bool get isConnected => connection == ConnectionState.connected;
  bool get isIdle => transfer == TransferState.idle;
  bool get isBusy => transfer != TransferState.idle;
  bool get canConnect => connection == ConnectionState.disconnected;
  bool get canDisconnect => isConnected && isIdle;
  bool get canTransfer => isConnected && isIdle;
  bool get hasSelectedSlot => activeSlot != null;
  bool get canDownload => hasSelectedSlot && canTransfer && hasImageInSlot(activeSlot!);

  String get statusText {
    // Shouldn't really get to a point where we are transferring with a null slot...
    int? slot = transferSlot ?? activeSlot;
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
            return (slot == null)
              ? 'Uploading slot...'
              : 'Uploading slot $slot';
          case TransferState.downloading:
            return (slot == null)
              ? 'Downloading slot...'
              : 'Downloading slot $slot';
          case TransferState.importing:
            return 'Importing images...';
        }
    }
  }

  bool hasImageInSlot(int slot) {
    return availableSlots.contains(slot);
  }

  DeviceSessionState copyWith({
    ConnectionState? connection,
    TransferState? transfer,
    double? progress,
    int? activeSlot,
    int? transferSlot,
    List<int>? availableSlots,
    String? deviceName,
    DeviceInfo? deviceInfo,
    int? batteryPercent,
    String? firmware,
    DeviceSettings? settings
  }) {
    return DeviceSessionState(
      connection: connection ?? this.connection,
      transfer: transfer ?? this.transfer,
      progress: progress ?? this.progress,
      activeSlot: activeSlot ?? this.activeSlot,
      transferSlot: transferSlot ?? this.transferSlot,
      availableSlots: availableSlots ?? this.availableSlots,
      deviceName: deviceName ?? this.deviceName,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      settings: settings ?? this.settings
    );
  }
}