import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'create_trip_modal.dart';
import 'share_trip_modal.dart';
import 'join_trip_modal.dart';

class TripsListView extends StatefulWidget {
  final Function(TripModel) onSelectTrip;
  final VoidCallback onLogout;

  const TripsListView({
    super.key,
    required this.onSelectTrip,
    required this.onLogout,
  });

  @override
  State<TripsListView> createState() => _TripsListViewState();
}

class _TripsListViewState extends State<TripsListView> {
  final BffClient _bff = ServiceLocator.instance.get<BffClient>();
  late Future<List<TripModel>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  void _loadTrips() {
    setState(() {
      _tripsFuture = _fetchTrips();
    });
  }

  Future<List<TripModel>> _fetchTrips() async {
    final user = TripContext.instance.currentUser;
    String endpoint = '/api/v1/trips';
    if (user != null) {
      endpoint = '/api/v1/trips?userId=${Uri.encodeComponent(user.id)}&userEmail=${Uri.encodeComponent(user.email)}';
    }

    try {
      final response = await _bff.get(endpoint);
      if (response != null && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => TripModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching trips: $e');
    }
    return [];
  }

  void _showCreateTripModal() {
    CreateTripModal.show(
      context,
      onTripCreated: _loadTrips,
    );
  }

  void _showJoinTripModal() {
    JoinTripModal.show(
      context,
      onTripJoined: (trip) {
        _loadTrips();
      },
    );
  }

  void _showShareTripModal(TripModel trip) {
    ShareTripModal.show(context, trip);
  }

  Future<bool?> _confirmDeleteTrip(TripModel trip) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.delete_forever, color: MaceioColors.error),
              SizedBox(width: 8),
              Text('Excluir Viagem?'),
            ],
          ),
          content: Text(
            'Tem certeza que deseja remover a viagem para "${trip.destination}"?\nTodos os roteiros, gastos e informações serão excluídos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: MaceioColors.error),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir Viagem', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTrip(TripModel trip) async {
    try {
      await _bff.delete('/api/v1/trips/${trip.id}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viagem para ${trip.destination} excluída!'),
            backgroundColor: MaceioColors.coralAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _loadTrips();
    } catch (e) {
      debugPrint('Error deleting trip: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = TripContext.instance.currentUser;

    return Scaffold(
      backgroundColor: MaceioColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: MaceioColors.coralAccent,
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text('Nova Viagem', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _showCreateTripModal,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar com Perfil & Logout
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: MaceioColors.oceanLight,
                    child: Text(user?.avatar ?? '👨‍✈️', style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Família Partiu ✈️',
                          style: MaceioTypography.caption.copyWith(
                            color: MaceioColors.turquoisePrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Olá, ${user?.name ?? "Nilson"}!', style: MaceioTypography.titleLarge),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: MaceioColors.textMuted),
                    tooltip: 'Sair',
                    onPressed: widget.onLogout,
                  ),
                ],
              ),
            ),

            // Ações Rápidas: Nova Viagem & Entrar com Convite
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: MaceioColors.turquoisePrimary, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: MaceioColors.oceanLight.withValues(alpha: 0.4),
                      ),
                      icon: const Icon(Icons.confirmation_number_outlined, color: MaceioColors.turquoiseDark, size: 18),
                      label: const Text(
                        'Entrar com Convite',
                        style: TextStyle(color: MaceioColors.turquoiseDark, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: _showJoinTripModal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: MaceioColors.coralAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 1,
                      ),
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: const Text(
                        'Criar Viagem',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: _showCreateTripModal,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Banner Motivacional
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MaceioColors.turquoisePrimary, MaceioColors.oceanDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🗺️', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Viagens da Família',
                          style: MaceioTypography.titleMedium.copyWith(color: Colors.white),
                        ),
                        Text(
                          'Toque para abrir, compartilhe o código ou arraste 👈 para excluir:',
                          style: MaceioTypography.caption.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Lista de Viagens com Swipe-to-Delete (Dismissible)
            Expanded(
              child: FutureBuilder<List<TripModel>>(
                future: _tripsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: MaceioColors.turquoisePrimary));
                  }

                  final trips = snapshot.data ?? [];
                  if (trips.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: MaceioColors.surfaceElevated,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.flight_takeoff, size: 48, color: MaceioColors.turquoiseDark),
                            ),
                            const SizedBox(height: 16),
                            Text('Nenhuma viagem encontrada', style: MaceioTypography.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                              'Crie a primeira viagem da sua família ou use o código de convite recebido no WhatsApp!',
                              textAlign: TextAlign.center,
                              style: MaceioTypography.caption,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MaceioButton(
                                  label: 'Criar Viagem',
                                  icon: Icons.add,
                                  onPressed: _showCreateTripModal,
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  icon: const Icon(Icons.vpn_key_outlined, size: 18),
                                  label: const Text('Entrar com Código'),
                                  onPressed: _showJoinTripModal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      return Dismissible(
                        key: ValueKey(trip.id),
                        direction: DismissDirection.endToStart,
                        dragStartBehavior: DragStartBehavior.down,
                        dismissThresholds: const {DismissDirection.endToStart: 0.15},
                        confirmDismiss: (direction) => _confirmDeleteTrip(trip),
                        onDismissed: (direction) => _deleteTrip(trip),
                        secondaryBackground: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: MaceioColors.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Excluir Viagem',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.delete_sweep, color: Colors.white, size: 28),
                            ],
                          ),
                        ),
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: MaceioColors.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Excluir Viagem',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.delete_sweep, color: Colors.white, size: 28),
                            ],
                          ),
                        ),
                        child: _buildTripCard(trip),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(TripModel trip) {
    final isOngoing = trip.status == 'ongoing';

    String? countdownLabel;
    Color countdownColor = MaceioColors.oceanLight;
    Color countdownTextColor = MaceioColors.turquoiseDark;

    if (trip.startDate.isNotEmpty) {
      try {
        final start = DateTime.parse(trip.startDate);
        final today = DateTime.now();
        final startDay = DateTime(start.year, start.month, start.day);
        final todayDay = DateTime(today.year, today.month, today.day);
        final diffDays = startDay.difference(todayDay).inDays;

        if (diffDays > 0) {
          countdownLabel = '⏳ Faltam $diffDays ${diffDays == 1 ? "dia" : "dias"}';
          countdownColor = MaceioColors.oceanLight;
          countdownTextColor = MaceioColors.turquoiseDark;
        } else if (diffDays == 0) {
          countdownLabel = '🎉 É HOJE! ✈️';
          countdownColor = MaceioColors.coralLight;
          countdownTextColor = MaceioColors.coralAccent;
        } else if (trip.endDate.isNotEmpty) {
          final end = DateTime.parse(trip.endDate);
          final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
          if (today.isBefore(endDay)) {
            countdownLabel = '🌴 Acontecendo!';
            countdownColor = MaceioColors.palmGreen.withValues(alpha: 0.15);
            countdownTextColor = MaceioColors.palmGreen;
          }
        }
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: MaceioCard(
        padding: EdgeInsets.zero,
        onTap: () {
          TripContext.instance.activeTrip = trip;
          widget.onSelectTrip(trip);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: MaceioColors.oceanDeep,
                    child: trip.imageUrl.isNotEmpty
                        ? Image.network(
                            trip.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: MaceioColors.turquoiseDark,
                              child: const Icon(Icons.beach_access, size: 40, color: Colors.white70),
                            ),
                          )
                        : const Icon(Icons.beach_access, size: 40, color: Colors.white70),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isOngoing ? MaceioColors.coralAccent : MaceioColors.turquoisePrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trip.tag.toUpperCase(),
                      style: MaceioTypography.badge.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.more_vert, color: Colors.white, size: 18),
                    ),
                    onSelected: (val) {
                      if (val == 'share') {
                        _showShareTripModal(trip);
                      } else if (val == 'delete') {
                        _confirmDeleteTrip(trip).then((confirmed) {
                          if (confirmed == true) _deleteTrip(trip);
                        });
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, color: MaceioColors.turquoisePrimary, size: 18),
                            SizedBox(width: 8),
                            Text('Compartilhar com a Família'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: MaceioColors.error, size: 18),
                            SizedBox(width: 8),
                            Text('Excluir Viagem', style: TextStyle(color: MaceioColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${trip.totalDays} DIAS',
                      style: MaceioTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: MaceioColors.coralAccent),
                          const SizedBox(width: 4),
                          Text(
                            '${trip.destination} • ${trip.state}',
                            style: MaceioTypography.caption.copyWith(
                              color: MaceioColors.turquoiseDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (countdownLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: countdownColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            countdownLabel,
                            style: TextStyle(
                              color: countdownTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(trip.title, style: MaceioTypography.titleLarge.copyWith(fontSize: 18)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botão de Compartilhar
                      InkWell(
                        onTap: () => _showShareTripModal(trip),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: MaceioColors.oceanLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.share, size: 14, color: MaceioColors.turquoiseDark),
                              const SizedBox(width: 6),
                              Text(
                                trip.shareCode.isNotEmpty ? trip.shareCode : 'Compartilhar',
                                style: const TextStyle(
                                  color: MaceioColors.turquoiseDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Botão de Abrir Viagem
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: MaceioColors.turquoisePrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Abrir Viagem',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
