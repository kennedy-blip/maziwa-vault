import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/models.dart';
import 'storage/app_store.dart';
import 'theme/app_theme.dart';
import 'screens/intake_screen.dart';
import 'screens/deductions_screen.dart';
import 'screens/payouts_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.load();
  runApp(ChangeNotifierProvider.value(value: store, child: const MaziwaVaultApp()));
}

class MaziwaVaultApp extends StatelessWidget {
  const MaziwaVaultApp({super.key});
  @override
  Widget build(BuildContext context) => Consumer<AppStore>(builder: (context, store, _) =>
    MaterialApp(title: 'MaziwaVault', debugShowCheckedModeBanner: false,
      theme: VaultColors.theme(store.theme), home: const VaultShell()));
}

class VaultShell extends StatefulWidget {
  const VaultShell({super.key});
  @override
  State<VaultShell> createState() => _VaultShellState();
}
class _VaultShellState extends State<VaultShell> {
  int index = 0;
  final screens = const [IntakeScreen(), DeductionsScreen(), PayoutsScreen(), SettingsScreen()];
  final labels = const ['Intake', 'Deductions', 'Payouts', 'Settings'];
  final icons = const [Icons.water_drop_outlined, Icons.receipt_long, Icons.account_balance_wallet_outlined, Icons.tune];
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      appBar: AppBar(title: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .16), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.water_drop, color: Theme.of(context).colorScheme.primary)),
        const SizedBox(width: 11),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('MaziwaVault', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)), Text('COOPERATIVE OPERATIONS', style: TextStyle(fontSize: 9, letterSpacing: 1.5))]),
      ]),
      actions: [if (wide) Padding(padding: const EdgeInsets.only(right: 18), child: Center(child: Chip(avatar: const Icon(Icons.shield_outlined, size: 16), label: Text(store.role == UserRole.manager ? 'Manager' : 'Route clerk'))))]),
      body: Row(children: [
        if (wide) NavigationRail(selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v), labelType: NavigationRailLabelType.all,
          destinations: List.generate(4, (i) => NavigationRailDestination(icon: Icon(icons[i]), label: Text(labels[i])))),
        Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 260), child: KeyedSubtree(key: ValueKey(index), child: screens[index]))),
      ]),
      bottomNavigationBar: wide ? null : NavigationBar(selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v),
        destinations: List.generate(4, (i) => NavigationDestination(icon: Icon(icons[i]), label: labels[i]))),
    );
  }
}
