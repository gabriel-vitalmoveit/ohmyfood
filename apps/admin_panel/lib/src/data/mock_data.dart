class LiveOrderMarker {
  LiveOrderMarker({
    required this.id,
    required this.status,
    required this.lat,
    required this.lng,
    required this.courierName,
    required this.customerName,
  });

  final String id;
  final String status;
  final double lat;
  final double lng;
  final String courierName;
  final String customerName;
}

class AdminMetric {
  AdminMetric({required this.label, required this.value, this.delta});

  final String label;
  final String value;
  final String? delta;
}

final liveOrders = <LiveOrderMarker>[
  LiveOrderMarker(
    id: 'ord-600',
    status: 'ON_THE_WAY',
    lat: 38.7223,
    lng: -9.1393,
    courierName: 'João F.',
    customerName: 'Ana S.',
  ),
  LiveOrderMarker(
    id: 'ord-601',
    status: 'PICKUP',
    lat: 38.7167,
    lng: -9.1333,
    courierName: 'Rita C.',
    customerName: 'Miguel A.',
  ),
];

final adminDashboardMetrics = [
  AdminMetric(label: 'Pedidos nas últimas 24h', value: '482', delta: '+12%'),
  AdminMetric(label: 'Estafetas online', value: '128', delta: '+5%'),
  AdminMetric(label: 'Restaurantes ativos', value: '342'),
  AdminMetric(label: 'SLA médio', value: '31 min', delta: '-2 min'),
];

final entitiesSnapshot = {
  'Restaurantes pendentes': 12,
  'Estafetas por validar': 35,
  'Clientes bloqueados': 4,
};

final campaignTemplates = [
  {
    'name': 'Lisboa Happy Hour',
    'reach': 'Zona Baixa/Chiado',
    'budget': '300 €',
    'status': 'Ativa',
  },
  {
    'name': 'Farmácias madrugada',
    'reach': 'Lisboa + Oeiras',
    'budget': '150 €',
    'status': 'Agendada',
  },
];

final financeSnapshot = [
  {'title': 'Volume diário', 'value': '12 430 €'},
  {'title': 'Taxas OhMyFood', 'value': '2 315 €'},
  {'title': 'Reembolsos pendentes', 'value': '14'},
];
