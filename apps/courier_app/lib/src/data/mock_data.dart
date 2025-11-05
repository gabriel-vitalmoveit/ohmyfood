import 'package:shared_models/shared_models.dart';

class CourierOrderViewModel {
  CourierOrderViewModel({
    required this.id,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.distanceKm,
    required this.earningCents,
    required this.status,
    required this.readyInMinutes,
    required this.customerName,
  });

  final String id;
  final String pickupAddress;
  final String dropoffAddress;
  final double distanceKm;
  final int earningCents;
  final OrderStatus status;
  final int readyInMinutes;
  final String customerName;
}

class CourierStats {
  const CourierStats({
    required this.completedToday,
    required this.kilometers,
    required this.earningsTodayCents,
    required this.rating,
  });

  final int completedToday;
  final double kilometers;
  final int earningsTodayCents;
  final double rating;
}

final courierStats = const CourierStats(
  completedToday: 6,
  kilometers: 24.5,
  earningsTodayCents: 4320,
  rating: 4.92,
);

final availableCourierOrders = <CourierOrderViewModel>[
  CourierOrderViewModel(
    id: 'ord-201',
    pickupAddress: 'Tasca do Bairro, Bairro Alto',
    dropoffAddress: 'Av. Liberdade 90, Lisboa',
    distanceKm: 2.4,
    earningCents: 420,
    status: OrderStatus.preparing,
    readyInMinutes: 6,
    customerName: 'Miguel',
  ),
  CourierOrderViewModel(
    id: 'ord-202',
    pickupAddress: 'Mercado Fresco, Saldanha',
    dropoffAddress: 'Rua Morais Soares 45',
    distanceKm: 3.1,
    earningCents: 510,
    status: OrderStatus.awaitingAcceptance,
    readyInMinutes: 2,
    customerName: 'Joana',
  ),
  CourierOrderViewModel(
    id: 'ord-203',
    pickupAddress: 'Farmácia Lisboa 24h, Chiado',
    dropoffAddress: 'Rua do Alecrim 11',
    distanceKm: 1.2,
    earningCents: 360,
    status: OrderStatus.awaitingAcceptance,
    readyInMinutes: 0,
    customerName: 'Pedro',
  ),
];

final weeklyEarnings = {
  'Seg': 3200,
  'Ter': 4100,
  'Qua': 3680,
  'Qui': 4500,
  'Sex': 5120,
  'Sáb': 6200,
  'Dom': 2800,
};
