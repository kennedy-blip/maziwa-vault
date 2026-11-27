import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppStore extends ChangeNotifier {
  static const _key = 'maziwa_vault_v1';
  List<Farmer> farmers = [];
  List<Delivery> deliveries = [];
  List<Advance> advances = [];
  List<Payout> payouts = [];
  double ratePerLiter = 52;
  double tankCapacity = 5000;
  UserRole role = UserRole.manager;
  VaultTheme theme = VaultTheme.pasture;
  bool ready = false;
  bool get isManager => role == UserRole.manager;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        farmers = (j['farmers'] as List? ?? []).map((e) => Farmer.fromJson(Map<String, dynamic>.from(e))).toList();
        deliveries = (j['deliveries'] as List? ?? []).map((e) => Delivery.fromJson(Map<String, dynamic>.from(e))).toList();
        advances = (j['advances'] as List? ?? []).map((e) => Advance.fromJson(Map<String, dynamic>.from(e))).toList();
        payouts = (j['payouts'] as List? ?? []).map((e) => Payout.fromJson(Map<String, dynamic>.from(e))).toList();
        ratePerLiter = (j['ratePerLiter'] as num?)?.toDouble() ?? 52;
        tankCapacity = (j['tankCapacity'] as num?)?.toDouble() ?? 5000;
        role = UserRole.values.firstWhere((e) => e.name == j['role'], orElse: () => UserRole.manager);
        theme = VaultTheme.values.firstWhere((e) => e.name == j['theme'], orElse: () => VaultTheme.pasture);
      } catch (_) {
        farmers = [];
        deliveries = [];
        advances = [];
        payouts = [];
      }
    }
    if (farmers.isEmpty) _seed();
    ready = true;
    await save();
    notifyListeners();
  }

  void _seed() {
    farmers = [
      const Farmer(id: 'F-001', name: 'Mary Wanjiku', memberId: 'MV-001', route: 'Kikuyu North', herdCount: 4, phone: '07•• ••• 102'),
      const Farmer(id: 'F-002', name: 'Peter Kamau', memberId: 'MV-002', route: 'Kikuyu North', herdCount: 6, phone: '07•• ••• 284'),
      const Farmer(id: 'F-003', name: 'Grace Njeri', memberId: 'MV-003', route: 'Limuru East', herdCount: 3, phone: '07•• ••• 391'),
    ];
    deliveries = [
      Delivery(id: 'D-101', farmerId: 'F-001', liters: 18.5, density: 1.029, status: QualityStatus.accepted, session: Session.am, createdAt: DateTime.now()),
      Delivery(id: 'D-102', farmerId: 'F-002', liters: 24, density: 1.027, status: QualityStatus.accepted, session: Session.am, createdAt: DateTime.now()),
      Delivery(id: 'D-103', farmerId: 'F-003', liters: 12, density: 1.018, status: QualityStatus.rejectedWatered, session: Session.am, createdAt: DateTime.now()),
    ];
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode({
      'farmers': farmers.map((e) => e.toJson()).toList(),
      'deliveries': deliveries.map((e) => e.toJson()).toList(),
      'advances': advances.map((e) => e.toJson()).toList(),
      'payouts': payouts.map((e) => e.toJson()).toList(),
      'ratePerLiter': ratePerLiter, 'tankCapacity': tankCapacity,
      'role': role.name, 'theme': theme.name,
    }));
  }

  Future<void> addFarmer(Farmer f) async { farmers.add(f); await save(); notifyListeners(); }
  Future<void> addDelivery(Delivery d) async { deliveries.insert(0, d); await save(); notifyListeners(); }
  Future<void> addAdvance(Advance a) async { advances.insert(0, a); await save(); notifyListeners(); }
  Future<void> updateAdvance(Advance a) async { if (!isManager) return; final i = advances.indexWhere((item) => item.id == a.id); if (i < 0) return; advances[i] = a; await save(); notifyListeners(); }
  Future<void> removeAdvance(String id) async { if (!isManager) return; advances.removeWhere((item) => item.id == id); await save(); notifyListeners(); }
  Future<void> setRole(UserRole v) async { role = v; await save(); notifyListeners(); }
  Future<void> setTheme(VaultTheme v) async { theme = v; await save(); notifyListeners(); }
  Future<void> setRate(double v) async { if (isManager) { ratePerLiter = v; await save(); notifyListeners(); } }
  Future<void> setTankCapacity(double v) async { if (isManager) { tankCapacity = v; await save(); notifyListeners(); } }
  Future<void> setPayoutStatus(String farmerId, PayoutStatus status) async {
    if (!isManager) return;
    final period = DateTime.now().toString().substring(0, 7);
    final i = payouts.indexWhere((p) => p.farmerId == farmerId && p.period == period);
    if (i < 0) { payouts.add(Payout(farmerId: farmerId, status: status, period: period)); }
    else { payouts[i] = payouts[i].copyWith(status: status); }
    await save(); notifyListeners();
  }
  double acceptedLiters(String farmerId) => deliveries.where((d) => d.farmerId == farmerId && d.status == QualityStatus.accepted).fold(0, (s, d) => s + d.liters);
  double deductions(String farmerId) => advances.where((a) => a.farmerId == farmerId).fold(0, (s, a) => s + a.amount);
  double gross(String farmerId) => acceptedLiters(farmerId) * ratePerLiter;
  double net(String farmerId) => (gross(farmerId) - deductions(farmerId)).clamp(0, double.infinity).toDouble();
  double get acceptedTotal => deliveries.where((d) => d.status == QualityStatus.accepted).fold(0, (s, d) => s + d.liters);
  double get rejectedTotal => deliveries.where((d) => d.status != QualityStatus.accepted).fold(0, (s, d) => s + d.liters);
  double get tankUse => (acceptedTotal / tankCapacity).clamp(0, 1).toDouble();
  String farmerName(String id) {
    final matches = farmers.where((f) => f.id == id);
    return matches.isEmpty ? 'Unknown farmer' : matches.first.name;
  }
}
