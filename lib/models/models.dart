import 'dart:convert';

enum QualityStatus { accepted, rejectedWatered, rejectedAcidic }
enum Session { am, pm }
enum PayoutStatus { pending, approved, paid }
enum UserRole { manager, clerk }
enum VaultTheme { pasture, daylight, cooler }

class Farmer {
  const Farmer({required this.id, required this.name, required this.memberId, required this.route, required this.herdCount, required this.phone});
  final String id, name, memberId, route, phone;
  final int herdCount;
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'memberId': memberId, 'route': route, 'herdCount': herdCount, 'phone': phone};
  factory Farmer.fromJson(Map<String, dynamic> j) => Farmer(id: j['id'], name: j['name'], memberId: j['memberId'], route: j['route'], herdCount: j['herdCount'] ?? 0, phone: j['phone'] ?? '');
}

class Delivery {
  const Delivery({required this.id, required this.farmerId, required this.liters, required this.density, required this.status, required this.session, required this.createdAt, this.note = ''});
  final String id, farmerId, note;
  final double liters, density;
  final QualityStatus status;
  final Session session;
  final DateTime createdAt;
  Map<String, dynamic> toJson() => {'id': id, 'farmerId': farmerId, 'liters': liters, 'density': density, 'status': status.name, 'session': session.name, 'createdAt': createdAt.toIso8601String(), 'note': note};
  factory Delivery.fromJson(Map<String, dynamic> j) => Delivery(id: j['id'], farmerId: j['farmerId'], liters: (j['liters'] as num).toDouble(), density: (j['density'] as num).toDouble(), status: QualityStatus.values.firstWhere((e) => e.name == j['status'], orElse: () => QualityStatus.accepted), session: Session.values.firstWhere((e) => e.name == j['session'], orElse: () => Session.am), createdAt: DateTime.parse(j['createdAt']), note: j['note'] ?? '');
}

class Advance {
  const Advance({required this.id, required this.farmerId, required this.description, required this.amount, required this.createdAt});
  final String id, farmerId, description;
  final double amount;
  final DateTime createdAt;
  Map<String, dynamic> toJson() => {'id': id, 'farmerId': farmerId, 'description': description, 'amount': amount, 'createdAt': createdAt.toIso8601String()};
  factory Advance.fromJson(Map<String, dynamic> j) => Advance(id: j['id'], farmerId: j['farmerId'], description: j['description'], amount: (j['amount'] as num).toDouble(), createdAt: DateTime.parse(j['createdAt']));
}

class Payout {
  const Payout({required this.farmerId, required this.status, required this.period});
  final String farmerId, period;
  final PayoutStatus status;
  Payout copyWith({PayoutStatus? status}) => Payout(farmerId: farmerId, period: period, status: status ?? this.status);
  Map<String, dynamic> toJson() => {'farmerId': farmerId, 'status': status.name, 'period': period};
  factory Payout.fromJson(Map<String, dynamic> j) => Payout(farmerId: j['farmerId'], status: PayoutStatus.values.firstWhere((e) => e.name == j['status'], orElse: () => PayoutStatus.pending), period: j['period'] ?? 'Current period');
}

String encodeList<T>(List<T> values, Map<String, dynamic> Function(T) mapper) => jsonEncode(values.map(mapper).toList());
