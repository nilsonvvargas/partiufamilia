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
    final theme = MaceioColors.getThemeForDestination(
      activeTrip?.destination ?? 'Maceió',
      activeTrip?.state ?? 'Alagoas',
    );

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: theme.primary,
          onRefresh: () async => _loadDashboard(),
          child: FutureBuilder<dynamic>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: theme.primary));
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
                  // Header com Troca de Viagem & Compartilhamento
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          AppHaptics.light();
                          widget.onBackToTrips();
                        },
                        icon: Icon(Icons.arrow_back, size: 18, color: theme.secondary),
                        label: Text(
                          'Todas as Viagens',
                          style: TextStyle(
                            color: theme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (activeTrip != null)
                            IconButton(
                              icon: Icon(Icons.share, color: theme.secondary, size: 20),
                              tooltip: 'Compartilhar Viagem com a Família',
                              onPressed: () {
                                AppHaptics.selection();
                                ShareTripModal.show(context, activeTrip);
                              },
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.accentLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Família Partiu ✈️',
                              style: MaceioTypography.caption.copyWith(
                                color: theme.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Hero Banner da Viagem com Tema Dinâmico
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: theme.heroGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                activeTrip?.tripDates ?? dest['tripDates'] ?? 'Em breve',
                                style: MaceioTypography.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.wb_sunny, color: MaceioColors.sunYellow, size: 15),
                                  const SizedBox(width: 5),
                                  Text(
                                    weather['temp'] ?? '28°C',
                                    style: MaceioTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '${activeTrip?.destination ?? dest['city'] ?? "Destino"} 📍',
                          style: MaceioTypography.display.copyWith(color: Colors.white, fontSize: 25),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activeTrip?.title ?? dest['title'] ?? 'Viagem em Família',
                          style: MaceioTypography.titleMedium.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMiniStat('Duração', '${stats['totalDays'] ?? activeTrip?.totalDays ?? 5} dias', Icons.calendar_today),
                              _buildStatDivider(),
                              _buildMiniStat('Mala', '${stats['packingProgress'] ?? 0}%', Icons.luggage),
                              _buildStatDivider(),
                              _buildMiniStat('Gastos', 'R\$ ${(stats['totalExpenses'] ?? 0).toStringAsFixed(0)}', Icons.attach_money),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Countdown Card Dinâmico
                  TripCountdownCard(
                    startDateStr: activeTrip?.startDate ?? dest['startDate'],
                    endDateStr: activeTrip?.endDate ?? dest['endDate'],
                    destination: activeTrip?.destination ?? dest['city'] ?? 'seu destino',
                  ),

                  const SizedBox(height: 18),

                  // Ações Rápidas em Destaque (Quick Action Bar)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: theme.primary.withValues(alpha: 0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAction(
                          label: 'Lançar Gasto',
                          icon: Icons.add_card,
                          color: MaceioColors.coralAccent,
                          onTap: () => widget.onNavigateToTab(2),
                        ),
                        _buildQuickAction(
                          label: 'Ver Roteiro',
                          icon: Icons.alt_route,
                          color: theme.primary,
                          onTap: () => widget.onNavigateToTab(1),
                        ),
                        _buildQuickAction(
                          label: 'Checklist Mala',
                          icon: Icons.checklist,
                          color: MaceioColors.palmGreen,
                          onTap: () => widget.onNavigateToTab(5),
                        ),
                        _buildQuickAction(
                          label: 'Contatos / SOS',
                          icon: Icons.support_agent,
                          color: theme.secondary,
                          onTap: () => widget.onNavigateToTab(6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Hub de MiniApps
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Módulos da Viagem', style: MaceioTypography.titleMedium),
                      Text('6 MiniApps', style: MaceioTypography.caption.copyWith(color: theme.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _buildModuleButton('Roteiro', Icons.map, theme.primary, () => widget.onNavigateToTab(1)),
                      _buildModuleButton('Gastos', Icons.attach_money, MaceioColors.coralAccent, () => widget.onNavigateToTab(2)),
                      _buildModuleButton('Jantares', Icons.restaurant, MaceioColors.sunYellow, () => widget.onNavigateToTab(3)),
                      _buildModuleButton('Estadia', Icons.hotel, theme.secondary, () => widget.onNavigateToTab(4)),
                      _buildModuleButton('Mala Familiar', Icons.luggage, MaceioColors.palmGreen, () => widget.onNavigateToTab(5)),
                      _buildModuleButton('Contatos', Icons.people, theme.primaryDark, () => widget.onNavigateToTab(6)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Próximo Passeio Programado
                  Text('Próxima Atividade Programada', style: MaceioTypography.titleMedium),
                  const SizedBox(height: 8),
                  if (nextTour != null && nextTour['title'] != null && (nextTour['title'] as String).isNotEmpty) ...[
                    MaceioCard(
                      onTap: () {
                        AppHaptics.light();
                        widget.onNavigateToTab(1);
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.secondaryLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.beach_access, color: theme.primary, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MaceioChip(
                                  label: 'DIA ${nextTour['day'] ?? 1} • ${nextTour['time'] ?? '09:00'}',
                                  color: theme.secondaryLight,
                                  textColor: theme.primaryDark,
                                ),
                                const SizedBox(height: 4),
                                Text(nextTour['title'] ?? '', style: MaceioTypography.titleMedium),
                                if (nextTour['location'] != null && (nextTour['location'] as String).isNotEmpty)
                                  Text(nextTour['location'], style: MaceioTypography.caption),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: theme.textSecondary),
                        ],
                      ),
                    ),
                  ] else ...[
                    MaceioCard(
                      onTap: () {
                        AppHaptics.light();
                        widget.onNavigateToTab(1);
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MaceioColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.add_task, color: theme.primaryDark, size: 24),
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
                          Icon(Icons.add_circle_outline, color: theme.primaryDark, size: 20),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Informações de Estadia Rápida
                  Text('Sua Hospedagem', style: MaceioTypography.titleMedium),
                  const SizedBox(height: 8),
                  if (stay != null && stay['name'] != null && (stay['name'] as String).isNotEmpty) ...[
                    MaceioCard(
                      onTap: () {
                        AppHaptics.light();
                        widget.onNavigateToTab(4);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.hotel_class, color: theme.secondary),
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
                                    AppHaptics.medium();
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
                      onTap: () {
                        AppHaptics.light();
                        widget.onNavigateToTab(4);
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MaceioColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.hotel, color: theme.secondary, size: 24),
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
                          Icon(Icons.add_circle_outline, color: theme.secondary, size: 20),
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
        Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: MaceioTypography.titleMedium.copyWith(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            Text(label, style: MaceioTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.8), fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 22,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }

  Widget _buildQuickAction({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        AppHaptics.light();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: MaceioColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return MaceioCard(
      onTap: () {
        AppHaptics.light();
        onTap();
      },
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

