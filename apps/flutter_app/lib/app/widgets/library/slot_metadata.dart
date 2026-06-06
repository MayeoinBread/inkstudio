import 'package:flutter/material.dart';
import 'package:picpak_image/picpak_image.dart';

enum SlotContentType {
  empty,
  image,
  qr,
  note,
  generated
}

enum SlotSyncState {
  clean,
  uploading,
  failed
}

enum SlotPendingAction {
  none,
  delete,
  upload
}

class SlotStatusIndicator {
  final IconData icon;
  final Color colour;
  final double size;

  const SlotStatusIndicator({
    required this.icon,
    required this.colour,
    required this.size
  });
}

SlotStatusIndicator? getStatusIndicator(SlotMetadata metadata) {
  switch (metadata.pendingAction) {
    case SlotPendingAction.delete:
      return const SlotStatusIndicator(icon: Icons.delete_outline, colour: Colors.red, size: 36);
    case SlotPendingAction.upload:
      return const SlotStatusIndicator(icon: Icons.cloud_upload_outlined, colour: Colors.orange, size: 36);
    case SlotPendingAction.none:
      break;
  }

  switch (metadata.syncState) {
    case SlotSyncState.uploading:
      return const SlotStatusIndicator(icon: Icons.sync, colour: Colors.blue, size: 36);
    case SlotSyncState.failed:
      return const SlotStatusIndicator(icon: Icons.error_outline, colour: Colors.red, size: 36);
    case SlotSyncState.clean:
      return null;
  }
}

class SlotMetadata {
  final SlotContentType type;
  final SlotSyncState syncState;
  final SlotPendingAction pendingAction;

  final String? text;

  final String? wifiSsid;
  final String? wifiPassword;
  final String? wifiSecurity;

  final ImageAdjustments adjustments;

  final DitherMode dither;
  final FitStrategy fit;
  final ImageFilter filter;

  const SlotMetadata({
    required this.type,
    this.syncState = SlotSyncState.clean,
    this.pendingAction = SlotPendingAction.none,
    this.text,
    this.wifiSsid,
    this.wifiPassword,
    this.wifiSecurity,

    this.adjustments = const ImageAdjustments(brightness: 1.0, contrast: 1.0),
    this.dither = DitherMode.none,
    this.fit = FitStrategy.contain,
    this.filter = ImageFilter.normal
  });

  SlotMetadata copyWith({
    SlotContentType? type,
    SlotSyncState? syncState,
    SlotPendingAction? pendingAction,
    String? text,
    String? wifiSsid,
    String? wifiPassword,
    String? wifiSecurity,
    ImageAdjustments? adjustments,
    DitherMode? dither,
    FitStrategy? fit,
    ImageFilter? filter,
  }) {
    return SlotMetadata(
      type: type ?? this.type,
      syncState: syncState ?? this.syncState,
      pendingAction: pendingAction ?? this.pendingAction,
      text: text ?? this.text,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      wifiSecurity: wifiSecurity ?? this.wifiSecurity,
      adjustments: adjustments ?? this.adjustments,
      dither: dither ?? this.dither,
      fit: fit ?? this.fit,
      filter: filter ?? this.filter
    );
  }
}