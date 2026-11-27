import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../storage/app_store.dart';
import '../theme/app_theme.dart';

class IntakeScreen extends StatelessWidget {
  const IntakeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppStore>();
    return ListView(padding: const EdgeInsets.all(20), children: [
      _heading(context, 'Milk intake ledger', 'Capture every delivery. Keep the tally transparent.', () => _addFarmer(context, s)),
      const SizedBox(height: 18),
      Wrap(spacing: 12, runSpacing: 12, children: [
        _metric(context, 'Accepted today', '${s.acceptedTotal.toStringAsFixed(1)} L', Icons.water_drop, Colors.teal),
        _metric(context, 'Rejected', '${s.rejectedTotal.toStringAsFixed(1)} L', Icons.report_gmailerrorred, Colors.orange),
        _metric(context, 'Farmers', '${s.farmers.length}', Icons.groups_2, Colors.lightBlue),
      ]),
      const SizedBox(height: 20),
      GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Collection activity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)), Text('${s.deliveries.length} records', style: Theme.of(context).textTheme.labelMedium)]),
        const SizedBox(height: 10),
        if (s.deliveries.isEmpty) const Text('No deliveries recorded yet.'),
        ...s.deliveries.take(30).map((d) {
          final f = s.farmers.where((x) => x.id == d.farmerId).firstOrNull;
          final accepted = d.status == QualityStatus.accepted;
          return ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor: (accepted ? Colors.teal : Colors.orange).withValues(alpha: .15), child: Icon(accepted ? Icons.check : Icons.warning_amber, color: accepted ? Colors.teal : Colors.orange)),
            title: Text(f?.name ?? 'Unknown farmer', style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${d.session.name.toUpperCase()} • ${d.density.toStringAsFixed(3)} density • ${d.status.name.replaceAll('rejected', 'Rejected ')}'),
            trailing: Text('${d.liters.toStringAsFixed(1)} L', style: const TextStyle(fontWeight: FontWeight.w800)));
        }),
      ])),
      const SizedBox(height: 18),
      FilledButton.icon(onPressed: s.farmers.isEmpty ? null : () => _addDelivery(context, s), icon: const Icon(Icons.add), label: const Text('Record milk delivery')),
    ]);
  }

  static Widget _heading(BuildContext c, String title, String subtitle, VoidCallback action) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(c).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(subtitle)])),
    IconButton.filledTonal(onPressed: action, icon: const Icon(Icons.person_add_alt_1), tooltip: 'Add farmer'),
  ]);
  static Widget _metric(BuildContext c, String label, String value, IconData icon, Color color) => SizedBox(width: 175, child: GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color), const SizedBox(height: 10), Text(value, style: Theme.of(c).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), Text(label, style: Theme.of(c).textTheme.labelMedium)])));
  static Future<void> _addFarmer(BuildContext context, AppStore s) async {
    final name = TextEditingController(), member = TextEditingController(), route = TextEditingController(text: 'Kikuyu North'), herd = TextEditingController(text: '2'), phone = TextEditingController();
    await showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Register farmer'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Farmer full name')),
      TextField(controller: member, decoration: const InputDecoration(labelText: 'Member ID')),
      TextField(controller: route, decoration: const InputDecoration(labelText: 'Route / zone')),
      TextField(controller: herd, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Herd count')),
      TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone (optional)')),
    ])), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), FilledButton(onPressed: () {
      if (name.text.trim().isEmpty || member.text.trim().isEmpty) return;
      s.addFarmer(Farmer(id: 'F-${DateTime.now().microsecondsSinceEpoch}', name: name.text.trim(), memberId: member.text.trim(), route: route.text.trim(), herdCount: int.tryParse(herd.text) ?? 0, phone: phone.text.trim()));
      Navigator.pop(ctx);
    }, child: const Text('Save farmer'))]));
  }
  static Future<void> _addDelivery(BuildContext context, AppStore s) async {
    String farmer = s.farmers.first.id, session = 'am', quality = 'accepted';
    final liters = TextEditingController(), density = TextEditingController(text: '1.028'), note = TextEditingController();
    await showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(title: const Text('New milk delivery'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      DropdownButtonFormField<String>(value: farmer, decoration: const InputDecoration(labelText: 'Farmer'), items: s.farmers.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(), onChanged: (v) => set(() => farmer = v!)),
      DropdownButtonFormField<String>(value: session, decoration: const InputDecoration(labelText: 'Collection session'), items: const [DropdownMenuItem(value: 'am', child: Text('Morning (AM)')), DropdownMenuItem(value: 'pm', child: Text('Evening (PM)'))], onChanged: (v) => set(() => session = v!)),
      TextField(controller: liters, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Liters received')),
      TextField(controller: density, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Lactometer / density reading')),
      DropdownButtonFormField<String>(value: quality, decoration: const InputDecoration(labelText: 'Quality decision'), items: const [DropdownMenuItem(value: 'accepted', child: Text('Accepted')), DropdownMenuItem(value: 'rejectedWatered', child: Text('Rejected — suspected watering')), DropdownMenuItem(value: 'rejectedAcidic', child: Text('Rejected — acidic'))], onChanged: (v) => set(() => quality = v!)),
      TextField(controller: note, decoration: const InputDecoration(labelText: 'Notes / reason (optional)')),
    ])), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), FilledButton(onPressed: () {
      final l = double.tryParse(liters.text), d = double.tryParse(density.text);
      if (l == null || l <= 0 || d == null) return;
      s.addDelivery(Delivery(id: 'D-${DateTime.now().microsecondsSinceEpoch}', farmerId: farmer, liters: l, density: d, status: QualityStatus.values.firstWhere((e) => e.name == quality), session: Session.values.firstWhere((e) => e.name == session), createdAt: DateTime.now(), note: note.text));
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery saved on this device')));
    }, child: const Text('Save delivery'))])));
  }
}
