import 'package:flutter/material.dart';
import 'package:picpak_open/app/services/ble_service.dart';
import 'package:picpak_open/app/services/dashboard_actions.dart';
import 'package:picpak_open/app/services/device_session_service.dart';
import 'package:picpak_open/app/state/device_session_state.dart';
import 'package:picpak_open/app/widgets/device/device_settings_panel.dart';
import 'package:picpak_open/app/widgets/device/device_info_card.dart';
import 'package:picpak_open/app/widgets/device/device_slot_panel.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const DashboardPage({
    super.key,
    required this.onToggleTheme
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  final session = DeviceSessionService.instance;

  final ble = BleService.instance.manager;

  void updateSession(DeviceSessionState Function(DeviceSessionState current) updater) {
    setState(() { session.state = updater(session.state);});
  }

  @override
  void initState() {
    super.initState();

    ble.onDeviceInfo = (info) {
      if (mounted) {
        debugPrint("DASH PAGE: onDeviceInfo, mounted");
        setState(() {
        session.state = session.state.copyWith(
          batteryPercent: info.battery,
          firmware: info.firmware
        );
      });
      }
    };

    ble.onDeviceSettings = (settings) {
      if (mounted) {
        debugPrint("DASH PAGE: onDeviceSettings, mounted");
        setState(() {
          session.state = session.state.copyWith(
            settings: settings
          );
        });
      }
    };

    ble.onSlotList = (slots) {
      final safeActive = session.state.activeSlot;

      setState(() {
        session.state = session.state.copyWith(
          availableSlots: slots,
          activeSlot: slots.contains(safeActive) ? safeActive : (slots.isNotEmpty ? slots.first : null)
        );
      });
    };
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> _buildDesktopLayout(BuildContext context) {
    return [
      SingleChildScrollView(child: SizedBox(width: 340, child: _leftPanel(context))),
      SingleChildScrollView(child: SizedBox(width: 340, child: _centerPanel(context)))
    ];
  }
  
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _leftPanel(context),
          _centerPanel(context)
        ],
      )
    );
  }

  Widget _leftPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DeviceInfoCard(
            state: session.state,
            onConnect: session.state.canConnect
              ? () => DashboardActions.connect(ble: ble, updateSession: updateSession)
              : null,
            onDisconnect: session.state.canDisconnect
              ? () => DashboardActions.disconnect(ble: ble, updateSession: updateSession)
              : null,
          )
        ],
      ),
    );
  }

  Widget _centerPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DeviceSettingsPanel(
            settings: session.state.settings,
            onSettingsChanged: (settings) async {
              await ble.setDeviceSettings(settings);
            },
          )
        ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PicPak Open'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          )
        ]
      ),
      body:  isMobile
              ? _buildMobileLayout(context)
              : Row(children: _buildDesktopLayout(context))
    );
  }
}