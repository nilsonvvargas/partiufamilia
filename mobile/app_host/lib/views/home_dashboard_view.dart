import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'share_trip_modal.dart';

class HomeDashboardView extends StatefulWidget {
  final Function(int) onNavigateToTab;
  final VoidCallback onBackToTrips;

  const HomeDashboardView({
    super.key,
    required this.onNavigateToTab,
    required this.onBackToTrips,
  });

  @override
  State<HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends State<HomeDashboardView> {
  final BffClient _bff = ServiceLocator.instance.get<BffClient>();
  late Future<dynamic> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    final tripId = TripContext.instance.activeTrip?.id ?? 'trip-maceio';
    setState(() {
      _dashboardFuture = _bff.get('/api/v1/trips/$tripId/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTrip = TripContext.instance.activeTrip;

    return Scaffold(
      backgroundColor: MaceioColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: MaceioColors.turquoisePrimary,
          onRefresh: () async => _loadDashboard(),
          child: FutureBuilder<dynamic>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: MaceioColors.turquoisePrimary));
              }

              final data = snapshot.data?['data'] ?? {};
              final dest = data['destination'] ?? {};
              final weather = dest['weather'] ?? {};
              final stay = data['staySnapshot'];
              final nextTour = data['nextTour'];
              final stats = data['stats'] ?? {};

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Header com Troca de Viagem
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: widget.onBackToTrips,
                        icon: const Icon(Icons.arrow_back, size: 18, color: MaceioColors.oceanDeep),
                        label: const Text(
                          'Todas as Viagens',
                          style: TextStyle(
                            color: MaceioColors.oceanDeep,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (activeTrip != null)
                            IconButton(
                              icon: const Icon(Icons.share, color: MaceioColors.oceanDeep, size: 20),
                              tooltip: 'Compartilhar Viagem com a Família',
                              onPressed: () => ShareTripModal.show(context, activeTrip),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: MaceioColors.coralLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Família Partiu ✈️',
                              style: MaceioTypography.caption.copyWith(
                                color: MaceioColors.coralAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Hero Banner da Viagem Selecionada
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [MaceioColors.turquoisePrimary, MaceioColors.oceanDeep],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: MaceioColors.turquoisePrimary.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              activeTrip?.tripDates ?? dest['tripDates'] ?? 'Em breve',
                              style: MaceioTypography.caption.copyWith(color: Colors.white70),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.wb_sunny, color: MaceioColors.sunYellow, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    weather['temp'] ?? '28°C',
                                    style: MaceioTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${activeTrip?.destination ?? dest['city'] ?? "Destino"} ✈️',
                          style: MaceioTypography.display.copyWith(color: Colors.white, fontSize: 24),
                        ),
                        Text(
                          activeTrip?.title ?? dest['title'] ?? 'Viagem em Família',
                          style: MaceioTypography.titleMedium.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildMiniStat('Roteiro', '${stats['totalDays'] ?? activeTrip?.totalDays ?? 5} dias', Icons.calendar_today),
                            const SizedBox(width: 16),
                            _buildMiniStat('Mala', '${stats['packingProgress'] ?? 0}%', Icons.luggage),
                            const SizedBox(width: 16),
                            _buildMiniStat('Gastos', 'R\$ ${(stats['totalExpenses'] ?? 0).toStringAsFixed(0)}', Icons.attach_money),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Countdown Card
                  TripCountdownCard(
                    startDateStr: activeTrip?.startDate ?? dest['startDate'],
                    endDateStr: activeTrip?.endDate ?? dest['endDate'],
                    destination: activeTrip?.destination ?? dest['city'] ?? 'seu destino',
                  ),

                  const SizedBox(height: 20),

                  // Hub de MiniApps (Grid Rápido)
                  Text('Módulos da Viagem (MiniApps)', style: MaceioTypography.titleMedium),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _buildModuleButton('Roteiro', Icons.map, MaceioColors.turquoisePrimary, () => widget.onNavigateToTab(1)),
                      _buildModuleButton('Gastos', Icons.attach_money, MaceioColors.coralAccent, () => widget.onNavigateToTab(2)),
                      _buildModuleButton('Jantares', Icons.restaurant, MaceioColors.sunYellow, () => widget.onNavigateToTab(3)),
                      _buildModuleButton('Estadia', Icons.hotel, MaceioColors.oceanDeep, () => widget.onNavigateToTab(4)),
                      _buildModuleButton('Mala', Icons.luggage, MaceioColors.palmGreen, () => widget.onNavigateToTab(5)),
                      _buildModuleButton('Contatos', Icons.people, MaceioColors.turquoiseDark, () => widget.onNavigateToTab(6)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Próximo Passeio Programado (100% Dinâmico)
                  Text('Próximo Passeio Programado', style: MaceioTypography.titleMedium),
                  const SizedBox(height: 8),
                  if (nextTour != null && nextTour['title'] != null && (nextTour['title'] as String).isNotEmpty) ...[
                    MaceioCard(
                      onTap: () => widget.onNavigateToTab(1),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: MaceioColors.oceanLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.beach_access, color: MaceioColors.turquoisePrimary, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MaceioChip(
                                  label: 'DIA ${nextTour['day'] ?? 1} • ${nextTour['time'] ?? '09:00'}',
                                  color: MaceioColors.oceanLight,
                                ),
                                const SizedBox(height: 4),
                                Text(nextTour['title'] ?? '', style: MaceioTypography.titleMedium),
                                if (nextTour['location'] != null && (nextTour['location'] as String).isNotEmpty)
                                  Text(nextTour['location'], style: MaceioTypography.caption),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: MaceioColors.textMuted),
                        ],
                      ),
                    ),
                  ] else ...[
                    MaceioCard(
                      onTap: () => widget.onNavigateToTab(1),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MaceioColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add_task, color: MaceioColors.turquoiseDark, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nenhum passeio programado ainda', style: MaceioTypography.titleMedium.copyWith(fontSize: 14)),
                                Text('Toque para planejar seu roteiro por horários', style: MaceioTypography.caption),
                              ],
                            ),
                          ),
                          const Icon(Icons.add_circle_outline, color: MaceioColors.turquoiseDark, size: 20),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Informações de Estadia Rápida (100% Dinâmico)
                  Text('Sua Hospedagem', style: MaceioTypography.titleMedium),
                  const SizedBox(height: 8),
                  if (stay != null && stay['name'] != null && (stay['name'] as String).isNotEmpty) ...[
                    MaceioCard(
                      onTap: () => widget.onNavigateToTab(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.hotel_class, color: MaceioColors.oceanDeep),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(stay['name'] ?? 'Hotel / Pousada', style: MaceioTypography.titleMedium),
                              ),
                              const Icon(Icons.chevron_right, color: MaceioColors.textMuted),
                            ],
                          ),
                          if (stay['address'] != null && (stay['address'] as String).isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(stay['address'], style: MaceioTypography.caption),
                          ],
                          if (stay['wifiPassword'] != null && (stay['wifiPassword'] as String).isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Wi-Fi: ${stay['wifiPassword']}',
                                  style: MaceioTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: stay['wifiPassword']));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Senha do Wi-Fi copiada!')),
                                    );
                                  },
                                  icon: const Icon(Icons.copy, size: 14),
                                  label: const Text('Copiar'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else ...[
                    MaceioCard(
                      onTap: () => widget.onNavigateToTab(4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MaceioColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.hotel, color: MaceioColors.oceanDeep, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nenhuma hospedagem cadastrada', style: MaceioTypography.titleMedium.copyWith(fontSize: 14)),
                                Text('Toque para cadastrar hotel, check-in e Wi-Fi', style: MaceioTypography.caption),
                              ],
                            ),
                          ),
                          const Icon(Icons.add_circle_outline, color: MaceioColors.oceanDeep, size: 20),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: MaceioTypography.titleMedium.copyWith(color: Colors.white, fontSize: 13)),
            Text(label, style: MaceioTypography.caption.copyWith(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildModuleButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return MaceioCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: MaceioTypography.caption.copyWith(
              color: MaceioColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
