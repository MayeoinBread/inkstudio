class DeviceInfo {
  final int battery;
  final String? hardware;
  final String? firmware;
  final String? serial;
  final int imageCount;

  DeviceInfo({
    required this.battery,
    required this.hardware,
    required this.firmware,
    required this.serial,
    required this.imageCount
  });
}