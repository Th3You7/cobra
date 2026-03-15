import 'package:flutter/material.dart';
import '../../../../core/models/device_info.dart';

/// Shows device key and MAC address when device is not authorized.
/// User can share this info with admin to get authorization.
class DeviceInfoPage extends StatelessWidget {
  final DeviceInfo? deviceInfo;

  const DeviceInfoPage({super.key, this.deviceInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device is Not Authorized')),
      body: deviceInfo == null
          ? _buildNoInfoView(context)
          : _buildDeviceInfoView(context),
    );
  }

  Widget _buildNoInfoView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'No device information available.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDeviceInfoView(BuildContext context) {
    final info = deviceInfo!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.device_unknown,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Share this information with admin to get authorized',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildInfoCard(context, label: 'Device Key', value: info.deviceKey),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              label: 'MAC Address',
              value: info.macAddress ?? 'Not available',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
