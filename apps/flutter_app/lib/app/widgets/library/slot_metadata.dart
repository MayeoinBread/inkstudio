import 'package:flutter/material.dart';
import 'package:inkstudio_image/inkstudio_image.dart';

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
  clear,
  delete,
  upload,
  verifyHash
}

class SlotStatusIndicator {
  final IconData? icon;
  final Color? colour;
  final double? size;

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
    case SlotPendingAction.clear:
      return const SlotStatusIndicator(icon: Icons.image_not_supported_outlined, colour: Colors.red, size: 36);
    case SlotPendingAction.none:
      return null;
    case SlotPendingAction.verifyHash:
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

  final QrType? qrType;

  final String? text;

  final String? wifiSsid;
  final String? wifiPassword;
  final String? wifiSecurity;

  final ImageAdjustments adjustments;

  final DitherMode dither;
  final ImageFilter filter;

  final String? imageId;

  final Rect? cropRect;

  final PaletteBias paletteBias;

  final int rotation;

  const SlotMetadata({
    required this.type,
    this.syncState = SlotSyncState.clean,
    this.pendingAction = SlotPendingAction.none,
    this.qrType,
    this.text,
    this.wifiSsid,
    this.wifiPassword,
    this.wifiSecurity,

    this.adjustments = const ImageAdjustments(),
    this.dither = DitherMode.none,
    this.filter = ImageFilter.normal,

    this.paletteBias = const PaletteBias(),

    this.imageId,

    this.cropRect,
    this.rotation = 0
  });

  SlotMetadata copyWith({
    SlotContentType? type,
    SlotSyncState? syncState,
    SlotPendingAction? pendingAction,
    QrType? qrType,
    String? text,
    String? wifiSsid,
    String? wifiPassword,
    String? wifiSecurity,
    ImageAdjustments? adjustments,
    PaletteBias? paletteBias,
    DitherMode? dither,
    ImageFilter? filter,
    String? imageId,
    Rect? cropRect,
    int? rotation
  }) {
    return SlotMetadata(
      type: type ?? this.type,
      syncState: syncState ?? this.syncState,
      pendingAction: pendingAction ?? this.pendingAction,
      qrType: qrType ?? this.qrType,
      text: text ?? this.text,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      wifiSecurity: wifiSecurity ?? this.wifiSecurity,
      adjustments: adjustments ?? this.adjustments,
      paletteBias: paletteBias ?? this.paletteBias,
      dither: dither ?? this.dither,
      filter: filter ?? this.filter,
      imageId: imageId ?? this.imageId,
      cropRect: cropRect ?? this.cropRect,
      rotation: rotation ?? this.rotation
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      
      'text': text,
      
      'wifiSsid': wifiSsid,
      'wifiPassword': wifiPassword,
      'wifiSecurity': wifiSecurity,
      
      'imageId': imageId,
      
      'brightness': adjustments.brightness,
      'contrast': adjustments.contrast,
      'saturation': adjustments.saturation,
      'sharpen': adjustments.sharpen,
      'comicStrength': adjustments.comicStrength,
      'inkThickness': adjustments.inkThickness,
      'toneLevels': adjustments.toneLevels,
      'halftoneScale': adjustments.halftoneScale,
      'hatchDensity': adjustments.hatchDensity,
      'sketchStrength': adjustments.sketchStrength,
      'thresholdRadius': adjustments.thresholdRadius,

      'blackBias': paletteBias.black,
      'whiteBias': paletteBias.white,
      'redBias': paletteBias.red,
      'yellowBias': paletteBias.yellow,
      
      'dither': dither.name,
      
      'filter': filter.name,
      
      'cropX': cropRect?.left,
      'cropY': cropRect?.top,
      'cropW': cropRect?.width,
      'cropH': cropRect?.height,

      'rotation': rotation
    };
  }

  factory SlotMetadata.fromJson(
    Map<String, dynamic> json,
  ) {
    return SlotMetadata(
      type: SlotContentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SlotContentType.empty,
      ),
      syncState: SlotSyncState.clean,
      pendingAction: SlotPendingAction.none,
      text: json['text'],
      wifiSsid: json['wifiSsid'],
      wifiPassword: json['wifiPassword'],
      wifiSecurity: json['wifiSecurity'],
      imageId: json['imageId'],

      adjustments: ImageAdjustments(
        brightness: (json['brightness'] as num?)?.toDouble() ?? 0.0,
        contrast: (json['contrast'] as num?)?.toDouble() ?? 1.0,
        saturation: (json['saturation'] as num?)?.toDouble() ?? 1.0,
        sharpen: (json['sharpen'] as num?)?.toDouble() ?? 0.0,
        comicStrength: (json['comicStrength'] as num?)?.toDouble() ?? 1.0,
        inkThickness: (json['inkThickness'] as num?)?.toDouble() ?? 0.0,
        toneLevels: (json['toneLevels'] as num?)?.toDouble() ?? 2.0,
        halftoneScale: (json['halftoneScale'] as num?)?.toDouble() ?? 6.0,
        hatchDensity: (json['hatchDensity'] as num?)?.toDouble() ?? 8.0,
        sketchStrength: (json['sketchStrength'] as num?)?.toDouble() ?? 1.0,
        thresholdRadius: (json['thresholdRadius'] as num?)?.toInt() ?? 1
      ),

      paletteBias: PaletteBias(
        black: (json['blackBias'] as num?)?.toDouble() ?? 1.0,
        white: (json['whiteBias'] as num?)?.toDouble() ?? 1.0,
        red: (json['redBias'] as num?)?.toDouble() ?? 1.0,
        yellow: (json['yellowBias'] as num?)?.toDouble() ?? 1.0
      ),

      dither: DitherMode.values.firstWhere(
        (e) => e.name == json['dither'],
        orElse: () => DitherMode.none,
      ),

      filter: ImageFilter.values.firstWhere(
        (e) => e.name == json['filter'],
        orElse: () => ImageFilter.normal,
      ),

      cropRect: (json['cropX'] != null &&
                json['cropY'] != null &&
                json['cropW'] != null &&
                json['cropH'] != null)
          ? Rect.fromLTWH(
              (json['cropX'] as num).toDouble(),
              (json['cropY'] as num).toDouble(),
              (json['cropW'] as num).toDouble(),
              (json['cropH'] as num).toDouble(),
            )
          : null,
      rotation: (json['rotation'] as num?)?.toInt() ?? 0,
    );
  }
}

class SlotMetadataDefaults {
  static SlotMetadata empty(int slot) {
    return SlotMetadata(
      type: SlotContentType.empty,
      syncState: SlotSyncState.clean,
      pendingAction: SlotPendingAction.none,
      adjustments: ImageAdjustments(),
      dither: DitherMode.atkinson,
      filter: ImageFilter.normal
    );
  }
}