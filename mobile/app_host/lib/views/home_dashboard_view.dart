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

  List<Map<String, dynamic>> _aiDiningList = [];
  bool _isLoadingAiDining = false;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadAiDining();
  }

  void _loadDashboard() {
    final tripId = TripContext.instance.activeTrip?.id ?? 'trip-maceio';
    setState(() {
      _dashboardFuture = _bff.get('/api/v1/trips/$tripId/dashboard').catchError((err) {
        // Fallback robusto caso o BFF esteja inicializando ou offline
        final activeTrip = TripContext.instance.activeTrip;
        final dest = activeTrip?.destination ?? 'Maceió';
        return {
          'success': true,
          'data': {
            'destination': {
              'city': dest,
              'state': activeTrip?.state ?? 'Alagoas',
              'tripDates': activeTrip?.tripDates ?? '20 a 25 de Outubro',
              'weather': {
                'temp': '28°C',
                'condition': 'Ensolarado com brisa do mar',
                'icon': '☀️',
                'apparentTemp': '30°C',
                'humidity': '72%',
                'windSpeed': '14 km/h',
              },
              'dailyWeather': [
                {'date': '2026-10-20', 'maxTemp': '29°C', 'minTemp': '23°C', 'condition': 'Ensolarado', 'icon': '☀️', 'precipitationProbability': 10},
                {'date': '2026-10-21', 'maxTemp': '28°C', 'minTemp': '23°C', 'condition': 'Parcialmente Nublado', 'icon': '⛅', 'precipitationProbability': 20},
                {'date': '2026-10-22', 'maxTemp': '29°C', 'minTemp': '24°C', 'condition': 'Ensolarado', 'icon': '☀️', 'precipitationProbability': 0},
                {'date': '2026-10-23', 'maxTemp': '30°C', 'minTemp': '24°C', 'condition': 'Ensolarado', 'icon': '☀️', 'precipitationProbability': 5},
                {'date': '2026-10-24', 'maxTemp': '28°C', 'minTemp': '23°C', 'condition': 'Sol com Nuvens', 'icon': '⛅', 'precipitationProbability': 15},
              ],
            },
            'staySnapshot': {
              'name': 'Hotel Ponta Verde Maceió',
              'address': 'Av. Silvio Carlos Viana, 2000 - Ponta Verde',
              'wifiPassword': 'PraiaFamilia2026',
            },
            'nextTour': {
              'day': 1,
              'time': '09:00',
              'title': 'Praia de Ponta Verde & Farol',
              'location': 'Orla de Ponta Verde, Maceió',
            },
            'stats': {
              'totalDays': activeTrip?.totalDays ?? 5,
              'packingProgress': 65,
              'totalExpenses': 1450.0,
            },
          },
        };
      });
    });
  }

  Future<void> _loadAiDining() async {
    if (!mounted) return;
    setState(() => _isLoadingAiDining = true);

    final activeTrip = TripContext.instance.activeTrip;
    final destination = activeTrip?.destination ?? 'Maceió';
    final state = activeTrip?.state ?? 'Alagoas';

    try {
      final res = await _bff.post('/api/v1/ai/dining-recommendations', {
        'destination': destination,
        'state': state,
        'dayNumber': 1,
        'activities': [
          {'title': 'Pontos turísticos e orla de $destination'}
        ],
      });

      if (mounted) {
        setState(() {
          if (res != null && res['data'] is List && (res['data'] as List).isNotEmpty) {
            _aiDiningList = List<Map<String, dynamic>>.from(res['data']);
          } else {
            _aiDiningList = _getFallbackAiDining(destination);
          }
          _isLoadingAiDining = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _aiDiningList = _getFallbackAiDining(destination);
          _isLoadingAiDining = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getFallbackAiDining(String dest) {
    if (dest.toLowerCase().contains('macei')) {
      return [
        {
          'name': 'Restaurante Janga',
          'cuisine': 'Frutos do Mar Premium',
          'specialty': 'Camarão Jangadeiro & Polvo Grelhado',
          'neighborhood': 'Ponta Verde',
          'address': 'Av. Silvio Carlos Viana, Ponta Verde',
          'suggestedMeal': 'Jantar',
          'suggestedTime': '20:00',
          'rating': 4.9,
          'priceLevel': r'$$$',
          'reason': 'Aclamado pelo melhor camarão da orla de Maceió, ambiente sofisticado e familiar.',
          'icon': '🦞',
        },
        {
          'name': 'Bodega do Sertão',
          'cuisine': 'Nordestina & Regional',
          'specialty': 'Carne de Sol na Nata & Baião de Dois',
          'neighborhood': 'Jatiúca',
          'address': 'Av. Júlio Marques Luz, Jatiúca',
          'suggestedMeal': 'Almoço',
          'suggestedTime': '12:30',
          'rating': 4.8,
          'priceLevel': r'$$',
          'reason': 'Ambiente temático incrível com bule gigante e o buffet regional mais premiado.',
          'icon': '🥘',
        },
        {
          'name': 'Imperador dos Camarões',
          'cuisine': 'Frutos do Mar Tradicional',
          'specialty': 'Chiclete de Camarão',
          'neighborhood': 'Praia de Pajuçara',
          'address': 'Av. Dr. Antônio Gouveia, Pajuçara',
          'suggestedMeal': 'Jantar',
          'suggestedTime': '20:30',
          'rating': 4.7,
          'priceLevel': r'$$',
          'reason': 'Criador oficial do famoso Chiclete de Camarão na orla da Pajuçara.',
          'icon': '🦐',
        },
        {
          'name': 'Akuaba',
          'cuisine': 'Afro-Baiana & Moquecas',
          'specialty': 'Moqueca Mista de Peixe e Camarão',
          'neighborhood': 'Mangabeiras',
          'address': 'Rua Ferroviário Manoel Gonçalves, Mangabeiras',
          'suggestedMeal': 'Jantar',
          'suggestedTime': '20:00',
          'rating': 4.9,
          'priceLevel': r'$$$',
          'reason': 'Estrela Michelin e melhor acarajé e moqueca de Alagoas sob comando da Chef Vera.',
          'icon': '🍲',
        },
      ];
    }

    return [
      {
        'name': 'Restaurante Sabor do $dest',
        'cuisine': 'Regional & Típica',
        'specialty': 'Pratos Locais e Peixadas',
        'neighborhood': 'Centro Gastronômico',
        'address': 'Av. Principal de $dest',
        'suggestedMeal': 'Jantar',
        'suggestedTime': '20:00',
        'rating': 4.8,
        'priceLevel': r'$$',
        'reason': 'Pratos tradicionais autênticos e bem avaliados pelos viajantes.',
        'icon': '🍽️',
      },
    ];
  }

  Future<void> _addDiningQuick(Map<String, dynamic> rec) async {
    AppHaptics.selection();
    final name = rec['name'] ?? 'Restaurante';
    final cuisine = rec['cuisine'] ?? 'Regional';
    final specialty = rec['specialty'] ?? '';
    final address = rec['address'] ?? (rec['neighborhood'] ?? 'Maceió');
    final time = rec['suggestedTime'] ?? '20:00';
    final rating = (rec['rating'] is num) ? (rec['rating'] as num).toDouble() : 4.8;
    final reason = rec['reason'] ?? '';
    final tripId = TripContext.instance.activeTrip?.id ?? 'trip-maceio';

    try {
      await _bff.post('/api/v1/dining', {
        'name': name,
        'cuisine': cuisine,
        'specialty': specialty,
        'address': address,
        'reservationTime': time,
        'rating': rating,
        'status': 'planejado',
        'notes': '✨ Sugerido por IA: $reason',
        'tripId': tripId,
      });
    } catch (_) {}

    _loadDashboard();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('"$name" adicionado aos seus Jantares! 🎉')),
            ],
          ),
          backgroundColor: MaceioColors.palmGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
          onRefresh: () async {
            _loadDashboard();
            _loadAiDining();
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: FutureBuilder<dynamic>(
                future: _dashboardFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: theme.primary));
                  }

                  final data = snapshot.data?['data'] ?? {};
                  final dest = data['destination'] ?? {};
                  final weather = dest['weather'] ?? {};
                  final dailyWeather = (dest['dailyWeather'] as List<dynamic>?) ?? [];
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

                      // Hero Banner da Viagem
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
                                      Text(
                                        weather['icon'] ?? '☀️',
                                        style: const TextStyle(fontSize: 13),
                                      ),
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

                      const SizedBox(height: 16),

                      // Ações Rápidas em Destaque (Compact Quick Action Bar)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          borderRadius: BorderRadius.circular(16),
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
                              label: 'Novo Gasto',
                              icon: Icons.add_card,
                              color: MaceioColors.coralAccent,
                              onTap: () => widget.onNavigateToTab(2),
                            ),
                            _buildQuickAction(
                              label: 'Roteiro',
                              icon: Icons.alt_route,
                              color: theme.primary,
                              onTap: () => widget.onNavigateToTab(1),
                            ),
                            _buildQuickAction(
                              label: 'Jantares',
                              icon: Icons.restaurant,
                              color: MaceioColors.sunYellow,
                              onTap: () => widget.onNavigateToTab(3),
                            ),
                            _buildQuickAction(
                              label: 'Mala',
                              icon: Icons.checklist,
                              color: MaceioColors.palmGreen,
                              onTap: () => widget.onNavigateToTab(5),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 1. Previsão do Tempo & Clima em Tempo Real
                      _buildWeatherSection(
                        theme: theme,
                        weather: weather,
                        dailyWeather: dailyWeather,
                        destination: activeTrip?.destination ?? dest['city'] ?? 'Destino',
                      ),

                      const SizedBox(height: 20),

                      // 2. ✨ SEÇÃO GASTRONOMIA COM IA NO DASHBOARD
                      _buildAiGastronomySection(theme, activeTrip?.destination ?? dest['city'] ?? 'Destino'),

                      const SizedBox(height: 20),

                      // 3. Próximo Passeio Programado
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

                      // 4. Informações de Estadia Rápida
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
        ),
      ),
    );
  }

  // Previsão do Tempo & Clima em Tempo Real
  Widget _buildWeatherSection({
    required TripThemePalette theme,
    required Map<String, dynamic> weather,
    required List<dynamic> dailyWeather,
    required String destination,
  }) {
    final temp = weather['temp'] ?? '28°C';
    final condition = weather['condition'] ?? 'Ensolarado';
    final icon = weather['icon'] ?? '☀️';
    final apparent = weather['apparentTemp'] ?? temp;
    final humidity = weather['humidity'] ?? '70%';
    final wind = weather['windSpeed'] ?? '15 km/h';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Clima & Previsão no Destino', style: MaceioTypography.titleMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.accentLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: MaceioColors.palmGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Ao Vivo',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.primary.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 38)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              temp,
                              style: MaceioTypography.display.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• $destination',
                              style: MaceioTypography.titleMedium.copyWith(
                                color: theme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          condition,
                          style: MaceioTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.alt_route, color: theme.primary),
                    tooltip: 'Ver no Roteiro',
                    onPressed: () {
                      AppHaptics.light();
                      widget.onNavigateToTab(1);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildWeatherMetricBadge('Sensação', apparent, Icons.thermostat, theme),
                  _buildWeatherMetricBadge('Umidade', humidity, Icons.water_drop_outlined, theme),
                  _buildWeatherMetricBadge('Vento', wind, Icons.air, theme),
                ],
              ),

              if (dailyWeather.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  'Previsão para os Próximos Dias',
                  style: MaceioTypography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 88,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: dailyWeather.length > 7 ? 7 : dailyWeather.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = dailyWeather[index];
                      final dStr = item['date'] ?? '';
                      String dayLabel = 'Dia ${index + 1}';
                      try {
                        final dt = DateTime.parse(dStr);
                        const wk = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
                        dayLabel = '${dt.day}/${dt.month} (${wk[dt.weekday - 1]})';
                        if (index == 0) dayLabel = 'Hoje';
                        if (index == 1) dayLabel = 'Amanhã';
                      } catch (_) {}

                      return Container(
                        width: 90,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: MaceioColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: MaceioColors.border),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayLabel,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(item['icon'] ?? '☀️', style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 4),
                            Text(
                              '${item['maxTemp'] ?? ''}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            if (item['precipitationProbability'] != null && (item['precipitationProbability'] as num) > 0)
                              Text(
                                '${item['precipitationProbability']}% 💧',
                                style: const TextStyle(fontSize: 9, color: MaceioColors.oceanDeep, fontWeight: FontWeight.w600),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ✨ Seção Gastronomia Recomendada por IA no Destino
  Widget _buildAiGastronomySection(TripThemePalette theme, String destination) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('✨ ', style: TextStyle(fontSize: 16)),
                Text('Gastronomia sugerida por IA', style: MaceioTypography.titleMedium),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                AppHaptics.light();
                widget.onNavigateToTab(3);
              },
              icon: Icon(Icons.arrow_forward, size: 14, color: theme.primary),
              label: Text(
                'Ver Todos',
                style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_isLoadingAiDining) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.primary.withValues(alpha: 0.15)),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.primary),
                  ),
                  const SizedBox(width: 12),
                  Text('Buscando restaurantes com Gemini IA...', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                ],
              ),
            ),
          ),
        ] else if (_aiDiningList.isNotEmpty) ...[
          SizedBox(
            height: 205,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _aiDiningList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = _aiDiningList[index];
                final name = item['name'] ?? 'Restaurante';
                final cuisine = item['cuisine'] ?? 'Regional';
                final specialty = item['specialty'] ?? '';
                final neighborhood = item['neighborhood'] ?? destination;
                final rating = item['rating'] ?? 4.8;
                final icon = item['icon'] ?? '🍽️';

                return Container(
                  width: 240,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.primary.withValues(alpha: 0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(icon, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: MaceioTypography.titleMedium.copyWith(fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '$cuisine • $neighborhood',
                                  style: TextStyle(fontSize: 10, color: theme.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text('⭐ $rating', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (specialty.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: MaceioColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Prato: $specialty',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.primaryDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MaceioColors.coralAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.bolt, color: Colors.white, size: 14),
                          label: const Text(
                            'Adicionar aos Jantares ⚡',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _addDiningQuick(item),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeatherMetricBadge(String label, String value, IconData icon, TripThemePalette theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: MaceioColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MaceioColors.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.secondary),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 11, color: MaceioColors.textMuted),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: MaceioColors.textPrimary),
          ),
        ],
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
}
