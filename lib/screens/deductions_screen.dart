import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../storage/app_store.dart';
import '../theme/app_theme.dart';

class DeductionsScreen extends StatelessWidget {
  const DeductionsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppStore>();
    final total = s.advances.fold<double>(0, (v, a) => v + a.amount);
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text('Agrovet & feed credit', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 5), const Text('Track every input issued against a member account.'),
      const SizedBox(height: 18),
      GlassPanel(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Outstanding advances'), SizedBox(height: 5), Text('Total recorded credit')]), Text('KSh ${total.toStringAsFixed(0)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: Colors.amber))])),
      const SizedBox(height: 18),
      if (!s.isManager) const Text('Clerk access: you may issue advances; manager approval is required for waivers and edits.'),
      ...s.advances.map((a) => Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined)), title: Text(a.description), subtitle: Text('${s.farmerName(a.farmerId)} • ${a.createdAt.toLocal().toString().substring(0, 10)}'), trailing: s.isManager ? PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'edit') _edit(context, s, a);
              if (action == 'waive') _waive(context, s, a);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit advance')),
              PopupMenuItem(value: 'waive', child: Text('Waive / remove')),
            ],
          ) : Text('KSh ${a.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))))),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: s.farmers.isEmpty ? null : () => _issue(context, s), icon: const Icon(Icons.add), label: const Text('Issue feed / service advance')),
    ]);
  }
  static Future<void> _edit(BuildContext context, AppStore s, Advance a) async {
    final description = TextEditingController(text: a.description);
    final amount = TextEditingController(text: a.amount.toStringAsFixed(2));
    await showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Edit farmer advance'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: description, decoration: const InputDecoration(labelText: 'Input / service')),
        TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount (KSh)')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          final value = double.tryParse(amount.text);
          if (value == null || value <= 0 || description.text.trim().isEmpty) return;
          s.updateAdvance(Advance(id: a.id, farmerId: a.farmerId, description: description.text.trim(), amount: value, createdAt: a.createdAt));
          Navigator.pop(ctx);
        }, child: const Text('Save changes')),
      ],
    ));
  }

  static Future<void> _waive(BuildContext context, AppStore s, Advance a) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Waive this advance?'),
      content: Text('Remove "${a.description}" (KSh ${a.amount.toStringAsFixed(0)}) from ${s.farmerName(a.farmerId)} account?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Waive advance')),
      ],
    ));
    if (confirmed == true) await s.removeAdvance(a.id);
  }

  static Future<void> _issue(BuildContext context, AppStore s) async {
    String farmer = s.farmers.first.id;
    final description = TextEditingController(text: 'Dairy meal'), amount = TextEditingController();
    await showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(title: const Text('Issue farmer advance'), content: Column(mainAxisSize: MainAxisSize.min, children: [
      DropdownButtonFormField<String>(value: farmer, decoration: const InputDecoration(labelText: 'Farmer account'), items: s.farmers.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(), onChanged: (v) => set(() => farmer = v!)),
      TextField(controller: description, decoration: const InputDecoration(labelText: 'Input / service')),
      TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (KSh)')),
    ]), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), FilledButton(onPressed: () {
      final value = double.tryParse(amount.text);
      if (value == null || value <= 0 || description.text.trim().isEmpty) return;
      s.addAdvance(Advance(id: 'A-${DateTime.now().microsecondsSinceEpoch}', farmerId: farmer, description: description.text.trim(), amount: value, createdAt: DateTime.now()));
      Navigator.pop(ctx);
    }, child: const Text('Record advance'))])));
  }
}
