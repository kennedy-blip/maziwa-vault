import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';\nimport 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../storage/app_store.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppStore>();
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text('Cooperative settings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 5), const Text('Workspace preferences, permissions and data portability.'),
      const SizedBox(height: 18),
      GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Workspace role', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        SegmentedButton<UserRole>(segments: const [ButtonSegment(value: UserRole.manager, label: Text('Manager'), icon: Icon(Icons.admin_panel_settings)), ButtonSegment(value: UserRole.clerk, label: Text('Route clerk'), icon: Icon(Icons.badge_outlined))], selected: {s.role}, onSelectionChanged: (v) => s.setRole(v.first)),
        const SizedBox(height: 8),
        Text(s.isManager ? 'Full access: tariff settings and payout approval are enabled.' : 'Restricted access: record intake and advances. Tariff, payout approval and historical deletion are disabled.', style: Theme.of(context).textTheme.bodySmall),
      ])),
      const SizedBox(height: 14),
      GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Appearance', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ...[
          (VaultTheme.pasture, 'Pasture Obsidian', 'Forest slate • emerald accents'),
          (VaultTheme.daylight, 'Daylight Dairy', 'Bright milk-glass surfaces'),
          (VaultTheme.cooler, 'High-Contrast Cooler', 'Dark surfaces • amber figures'),
        ].map((t) => RadioListTile<VaultTheme>(contentPadding: EdgeInsets.zero, value: t.$1, groupValue: s.theme, onChanged: (v) => s.setTheme(v!), title: Text(t.$2), subtitle: Text(t.$3))),
      ])),
      const SizedBox(height: 14),
      if (s.isManager) GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Cooperative operations', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        _SettingValue(label: 'Milk tariff (KSh / L)', value: s.ratePerLiter, onSave: s.setRate),
        _SettingValue(label: 'Chilling tank capacity (L)', value: s.tankCapacity, onSave: s.setTankCapacity),
      ])),
      const SizedBox(height: 14),
      GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Local data & exports', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.offline_pin), title: Text('Offline storage active'), subtitle: Text('Records are saved on this device. Sync between devices is not configured.')),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.data_object), title: const Text('Copy cooperative data (JSON)'), subtitle: const Text('Create a backup or transfer it securely.'), onTap: () async {
          final data = jsonEncode({'farmers': s.farmers.map((e) => e.toJson()).toList(), 'deliveries': s.deliveries.map((e) => e.toJson()).toList(), 'advances': s.advances.map((e) => e.toJson()).toList(), 'payouts': s.payouts.map((e) => e.toJson()).toList()});
          await Clipboard.setData(ClipboardData(text: data));
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('JSON backup copied to clipboard')));
        }),
      ])),
      const SizedBox(height: 14),
      GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Android application', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6), const Text('Install the latest signed release build on a compatible Android device.'),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: () => Clipboard.setData(const ClipboardData(text: 'https://github.com/kennedy-blip/maziwa-vault/releases/latest/download/MaziwaVault.apk')).then((_) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('APK release link copied. Open it in your browser to download.')));
        }), icon: const Icon(Icons.android), label: const Text('Copy Android APK download link')),
      ])),
      const SizedBox(height: 24),
      Center(child: Text('MAZIWAVAULT • VERSION 1.0.0', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.5))),
    ]);
  }
}

class _SettingValue extends StatelessWidget {
  const _SettingValue({required this.label, required this.value, required this.onSave});
  final String label;
  final double value;
  final Future<void> Function(double) onSave;
  @override
  Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, title: Text(label), subtitle: Text(value.toStringAsFixed(2)), trailing: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {
    final c = TextEditingController(text: value.toStringAsFixed(2));
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(label), content: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true)), actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
      FilledButton(onPressed: () { final v = double.tryParse(c.text); if (v != null && v > 0) onSave(v); Navigator.pop(ctx); }, child: const Text('Save')),
    ]);
  }));
}
