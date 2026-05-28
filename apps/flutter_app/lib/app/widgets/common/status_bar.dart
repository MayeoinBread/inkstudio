import 'package:flutter/material.dart';
import 'package:flutter_app/app/state/device_session_state.dart';

class StatusBar extends StatelessWidget {
  final DeviceSessionState state;

  const StatusBar({
    super.key,
    required this.state
  });

  @override
  Widget build(BuildContext context) {
    final connected = state.isConnected;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
          const SizedBox(width: 10),
          // Device name
          Text(state.deviceName, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          // Status text
          Expanded(
            child: Text(state.statusText, overflow: TextOverflow.ellipsis)
          ),
          // Battery
          Row(
            children: [
              const Icon(Icons.battery_full, size: 16),
              const SizedBox(width: 4),
              Text('${state.batteryPercent}%')
            ]
          ),
          const SizedBox(width: 16),
          // Transfer state
          Text(
            'Transfer State: ${state.transfer.name.toUpperCase()}',
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)
          ),
          const SizedBox(width: 16),
          // Progress (only meaningful during transfer)
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              value: state.transfer == TransferState.idle
                ? 0
                : state.progress
            )
          ),
          if (state.transfer == TransferState.uploading)
            Text('${(state.progress * 100).toStringAsFixed(0)}%')
        ]
      )
    );
  }
}