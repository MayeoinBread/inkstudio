# Changelog

## v0.3.0

Add support for stickers
- Different shapes can be added (square, circle, triangle, diamond, heart, rounded rectangle)
- Device-native colours only (black, white, yellow, red), helps them "pop"
- Filled or outline with stroke thickness
- Processed after dithering, so shows as a block colour on-device
- Scale, rotate, position can be adjusted, multiple stickers added per image
- Stickers persist in database and can be removed/edited from the UI easily

Fix issue with images re-saving as new with new ID, instead of updating existing database entry

## v0.2.2

More bug fixes for v0.2.0. Fixed issues with images deleting instead of uploading, and issues with cropping.

## v0.2.1

Bug fixes for v0.2.0

## v0.2.0

Album support, filters

### Added

- Albums to store groups of photos
- Sync different albums without re-importing images
  - NOTE: After updating, ensure you press the "Sync" button on the library page to ensure the App knows what images are on the device
- Sepia, Inverted, Adaptive Threshold filters

## v0.1.0

Initial public release.

### Added

- Windows desktop application
- Android application
- Offline library
- Album management
- Image editor
- QR editor
- Note editor
- BLE synchronisation
- Image processing pipeline
