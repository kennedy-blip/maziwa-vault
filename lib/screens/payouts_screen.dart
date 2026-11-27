import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../storage/app_store.dart';

class PayoutsScreen extends StatelessWidget {
  const PayoutsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppStore>();
    final status = <String, PayoutStatus>{for (final p in s.payouts) p.farmerId: p.status};
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text('Farmer payouts', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 5), Text('Rate: KSh ${s.ratePerLiter.toStringAsFixed(2)} / accepted litre • Current ledger'),
      const SizedBox(height: 18),
      GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Chilling tank utilization', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: s.tankUse, minHeight: 10, borderRadius: BorderRadius.circular(10)),
        const SizedBox(height: 8),
        Text('${s.acceptedTotal.toStringAsFixed(1)} L of ${s.tankCapacity.toStringAsFixed(0)} L capacity • ${(s.tankUse * 100).toStringAsFixed(1)}%'),
      ])),
      const SizedBox(height: 18),
      ...s.farmers.map((f) {
        final st = status[f.id] ?? PayoutStatus.pending;
        return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w700))), _status(st)]),
          const SizedBox(height: 12),
          Wrap(spacing: 18, runSpacing: 8, children: [
            _number('Accepted litres', '${s.acceptedLiters(f.id).toStringAsFixed(1)} L'),
            _number('Gross', 'KSh ${s.gross(f.id).toStringAsFixed(0)}'),
            _number('Feed credit', '− KSh ${s.deductions(f.id).toStringAsFixed(0)}'),
          ]),
          const Divider(height: 22),
          Row(children: [const Expanded(child: Text('Net payable', style: TextStyle(fontWeight: FontWeight.w700))), Text('KSh ${s.net(f.id).toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary))]),
          if (s.isManager) Align(alignment: Alignment.centerRight, child: PopupMenuButton<PayoutStatus>(tooltip: 'Update payout status', onSelected: (v) => s.setPayoutStatus(f.id, v), itemBuilder: (_) => PayoutStatus.values.map((v) => PopupMenuItem(value: v, child: Text(v.name.toUpperCase()))).toList(), child: const Padding(padding: EdgeInsets.all(8), child: Row(mainAxisSize: MainAxisSize.min, children: [Text('Manage payout'), Icon(Icons.expand_more)])))),
        ])));
      }),
    ]);
  }
  Widget _number(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 11)), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))]);
  Widget _status(PayoutStatus s) => Chip(label: Text(s.name.toUpperCase()), backgroundColor: (s == PayoutStatus.paid ? Colors.teal : s == PayoutStatus.approved ? Colors.blue : Colors.orange).withValues(alpha: .16), side: BorderSide.none);
}
