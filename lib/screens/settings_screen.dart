import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../storage/app_store.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Cooperative settings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        const Text('Workspace preferences, permissions and data portability.'),
        const SizedBox(height: 18),
        GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Workspace role', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          SegmentedButton<UserRole>(
            segments: const [
              ButtonSegment(value: UserRole.manager, label: Text('Manager'), icon: Icon(Icons.admin_panel_settings)),
              ButtonSegment(value: UserRole.clerk, label: Text('Route clerk'), icon: Icon(Icons.badge_outlined)),
            ],
            selected: {store.role},
            onSelectionChanged: (value) => store.setRole(value.first),
          ),
          const SizedBox(height: 8),
          Text(
            store.isManager
                ? 'Full access: tariff settings and payout approval are enabled.'
                : 'Restricted access: record intake and advances. Tariff, payout approval and historical deletion are disabled.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ])),
        const SizedBox(height: 14),
        GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Appearance', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...[
            (VaultTheme.pasture, 'Pasture Obsidian', 'Forest slate • emerald accents'),
            (VaultTheme.daylight, 'Daylight Dairy', 'Bright milk-glass surfaces'),
            (VaultTheme.cooler, 'High-Contrast Cooler', 'Dark surfaces • amber figures'),
          ].map((theme) => RadioListTile<VaultTheme>(
                contentPadding: EdgeInsets.zero,
                value: theme.$1,
                groupValue: store.theme,
                onChanged: (value) => store.setTheme(value!),
                title: Text(theme.$2),
                subtitle: Text(theme.$3),
              )),
        ])),
        const SizedBox(height: 14),
        if (store.isManager)
          GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Cooperative operations', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _SettingValue(label: 'Milk tariff (KSh / L)', value: store.ratePerLiter, onSave: store.setRate),
            _SettingValue(label: 'Chilling tank capacity (L)', value: store.tankCapacity, onSave: store.setTankCapacity),
          ])),
        const SizedBox(height: 14),
        GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Local data & exports', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.offline_pin),
            title: Text('Offline storage active'),
            subtitle: Text('Records are saved on this device. Sync between devices is not configured.'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.data_object),
            title: const Text('Copy cooperative data (JSON)'),
            subtitle: const Text('Create a backup or transfer it securely.'),
            onTap: () async {
              final data = jsonEncode({
                'farmers': store.farmers.map((e) => e.toJson()).toList(),
                'deliveries': store.deliveries.map((e) => e.toJson()).toList(),
                'advances': store.advances.map((e) => e.toJson()).toList(),
                'payouts': store.payouts.map((e) => e.toJson()).toList(),
              });
              await Clipboard.setData(ClipboardData(text: data));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('JSON backup copied to clipboard')),
                );
              }
            },
          ),
        ])),
        const SizedBox(height: 14),
        GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Android application', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Install the latest Android release build on a compatible device.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              final uri = Uri.parse('https://github.com/kennedy-blip/maziwa-vault/releases/latest/download/app-release.apk');
              final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (!opened && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open the APK release. Check your connection and try again.')),
                );
              }
            },
            icon: const Icon(Icons.android),
            label: const Text('Download Android APK'),
          ),
        ])),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'MAZIWAVAULT • VERSION 1.0.0',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.5),
          ),
        ),
      ],
    );
  }
}

class _SettingValue extends StatelessWidget {
  const _SettingValue({required this.label, required this.value, required this.onSave});

  final String label;
  final double value;
  final Future<void> Function(double) onSave;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value.toStringAsFixed(2)),
      trailing: IconButton(
        icon: const Icon(Icons.edit_outlined),
        onPressed: () {
          final controller = TextEditingController(text: value.toStringAsFixed(2));
          showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(label),
              content: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    final parsed = double.tryParse(controller.text);
                    if (parsed != null && parsed > 0) onSave(parsed);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
