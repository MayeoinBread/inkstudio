import 'package:flutter/material.dart';
import 'package:picpak_open/app/state/device_session_state.dart';

class StatusBar extends StatelessWidget {
  final DeviceSessionState state;

  const StatusBar({
    super.key,
    required this.state
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final connected = state.isConnected;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor
          )
        )
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color: connected ? Colors.green : Colors.red
          ),
          const SizedBox(width: 12),
          // Device name
          Text(state.deviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          // Status text
          Expanded(
            child: Text(state.statusText, overflow: TextOverflow.ellipsis)
          ),
          // Battery
          Row(
            children: [
              const Icon(Icons.battery_full, size: 12),
              const SizedBox(width: 4),
              Text('${state.batteryPercent}%')
            ]
          ),
          const SizedBox(width: 12),
          // Transfer state
          Text(
            'State: ${state.transfer.name.toUpperCase()}',
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: isMobile ? 35 : 120,
            child: isMobile
              ? CircularProgressIndicator(
                value: state.transfer == TransferState.idle
                ? 0.0 : state.progress,
                backgroundColor: Colors.black26,
                constraints: BoxConstraints.tight(Size(35, 35)),
              )
              : LinearProgressIndicator(
                value: state.transfer == TransferState.idle
                ? 0.0
                : state.progress
              )
          ),
          if (state.transfer != TransferState.idle)
            Text('${(state.progress * 100).toStringAsFixed(0)}%')
        ]
      )
    );
  }
}