import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../models/dining_model.dart';
import '../services/dining_service.dart';

class DiningView extends StatefulWidget {
  const DiningView({super.key});

  @override
  State<DiningView> createState() => _DiningViewState();
}

class _DiningViewState extends State<DiningView> {
  final DiningService _service = DiningService();
  final BffClient _bffClient = ServiceLocator.instance.get<BffClient>();

  late Future<List<DiningItem>> _future;
  late List<TripDayInfo> _tripDays;
  int _selectedDayNumber = 1;

  List<Map<String, dynamic>> _aiRecommendations = [];
  bool _isLoadingAi = false;

  @override
  void initState() {
    super.initState();
    _initDays();
    _loadData();
  }

  void _initDays() {
    final activeTrip = TripContext.instance.activeTrip;
    _tripDays = TripDayInfo.generateDaysForTrip(
      startDateStr: activeTrip?.startDate,
      endDateStr: activeTrip?.endDate,
      totalDaysCount: activeTrip?.totalDays,
    );
    if (_tripDays.isEmpty) {
      _tripDays = TripDayInfo.generateDaysForTrip(
        startDateStr: null,
        endDateStr: null,
        totalDaysCount: 5,
      );
    }
    _selectedDayNumber = 1;
    _loadAiRecommendations();
  }

  void _loadData() {
    setState(() {
      _future = _service.getDinings();
    });
  }

  TripDayInfo get _currentDayInfo {
    return _tripDays.firstWhere(
      (d) => d.dayNumber == _selectedDayNumber,
      orElse: () => _tripDays.first,
    );
  }

  Future<void> _loadAiRecommendations() async {
    if (!mounted) return;
    setState(() {
      _isLoadingAi = true;
    });

    try {
      final activeTrip = TripContext.instance.activeTrip;
      final destination = activeTrip?.destination ?? 'Maceió';
      final state = activeTrip?.state ?? 'Alagoas';
      final tripId = activeTrip?.id ?? 'trip-maceio';

      // 1. Fetch activities for selected day to give accurate context to AI
      List<dynamic> dayActivities = [];
      try {
        final itRes = await _bffClient.get('/api/v1/itinerary?tripId=$tripId');
        if (itRes != null && itRes['data'] is List) {
          dayActivities = (itRes['data'] as List)
              .where((i) => i['day'] == _selectedDayNumber)
              .map((i) => {
                    'title': i['title'] ?? '',
                    'location': i['location'] ?? '',
                    'tag': i['tag'] ?? '',
                  })
              .toList();
        }
      } catch (_) {}

      // 2. Query Gemini AI for tailored dining spots
      final recs = await _service.getAiRecommendations(
        dayNumber: _selectedDayNumber,
        destination: destination,
        state: state,
        activities: dayActivities,
      );

      if (mounted) {
        setState(() {
          _aiRecommendations = recs;
          _isLoadingAi = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingAi = false;
        });
      }
    }
  }

  Future<void> _addAiRecommendationDirectly(Map<String, dynamic> rec) async {
    AppHaptics.selection();
    final name = rec['name'] ?? 'Restaurante';
    final cuisine = rec['cuisine'] ?? 'Regional';
    final specialty = rec['specialty'] ?? '';
    final address = rec['address'] ?? (rec['neighborhood'] ?? 'Maceió');
    final time = rec['suggestedTime'] ?? '20:00';
    final rating = (rec['rating'] is num) ? (rec['rating'] as num).toDouble() : 4.8;
    final reason = rec['reason'] ?? '';

    await _service.addDining(
      name: name,
      cuisine: cuisine,
      specialty: specialty,
      address: address,
      reservationTime: time,
      rating: rating,
      status: 'planejado',
      notes: '✨ Sugerido por IA para o Dia $_selectedDayNumber: $reason',
    );

    _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('"$name" adicionado aos Jantares com 1 toque! 🎉'),
              ),
            ],
          ),
          backgroundColor: MaceioColors.palmGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showDiningModal({DiningItem? itemToEdit, Map<String, dynamic>? initialData}) {
    final isEditing = itemToEdit != null;
    final nameController = TextEditingController(text: itemToEdit?.name ?? initialData?['name'] ?? '');
    final cuisineController = TextEditingController(text: itemToEdit?.cuisine ?? initialData?['cuisine'] ?? 'Frutos do Mar');
    final specialtyController = TextEditingController(text: itemToEdit?.specialty ?? initialData?['specialty'] ?? '');
    final addressController = TextEditingController(text: itemToEdit?.address ?? initialData?['address'] ?? '');
    final timeController = TextEditingController(text: itemToEdit?.reservationTime ?? initialData?['suggestedTime'] ?? '20:00');
    final ratingController = TextEditingController(text: itemToEdit?.rating.toString() ?? (initialData?['rating']?.toString() ?? '4.8'));
    final notesController = TextEditingController(text: itemToEdit?.notes ?? (initialData?['reason'] != null ? '✨ IA: ${initialData!['reason']}' : ''));
    String selectedStatus = itemToEdit?.status ?? 'planejado';

    final statuses = ['planejado', 'reservado', 'visitado'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: MaceioColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: MaceioColors.coralLight,
                          child: Icon(
                            isEditing ? Icons.edit : Icons.restaurant,
                            color: MaceioColors.coralAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? 'Editar Restaurante' : 'Novo Restaurante / Jantar',
                                style: MaceioTypography.titleLarge,
                              ),
                              Text(
                                isEditing ? 'Atualize as informações da reserva' : 'Adicione uma experiência gastronômica',
                                style: MaceioTypography.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Quick AI Suggestions Pills in modal
                    if (!isEditing && _aiRecommendations.isNotEmpty) ...[
                      Text('Sugestões Rápidas da IA para este Dia:', style: MaceioTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _aiRecommendations.map((rec) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                avatar: Text(rec['icon'] ?? '🍽️'),
                                label: Text(rec['name'] ?? '', style: const TextStyle(fontSize: 12)),
                                backgroundColor: MaceioColors.surfaceElevated,
                                side: BorderSide(color: MaceioColors.turquoisePrimary.withValues(alpha: 0.3)),
                                onPressed: () {
                                  setModalState(() {
                                    nameController.text = rec['name'] ?? '';
                                    cuisineController.text = rec['cuisine'] ?? 'Regional';
                                    specialtyController.text = rec['specialty'] ?? '';
                                    addressController.text = rec['address'] ?? '';
                                    timeController.text = rec['suggestedTime'] ?? '20:00';
                                    ratingController.text = (rec['rating'] ?? 4.8).toString();
                                    notesController.text = '✨ Sugerido por IA: ${rec['reason'] ?? ""}';
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Nome
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome do Restaurante',
                        hintText: 'Ex: Restaurante Janga',
                        prefixIcon: const Icon(Icons.restaurant_menu, color: MaceioColors.turquoisePrimary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Culinária e Horário
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cuisineController,
                            decoration: InputDecoration(
                              labelText: 'Culinária',
                              hintText: 'Ex: Frutos do Mar',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: timeController,
                            decoration: InputDecoration(
                              labelText: 'Horário Previsto',
                              hintText: 'Ex: 20:00',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Prato Destaque
                    TextField(
                      controller: specialtyController,
                      decoration: InputDecoration(
                        labelText: 'Prato Destaque / Especialidade',
                        hintText: 'Ex: Camarão Jangadeiro / Peixada ao Coco',
                        prefixIcon: const Icon(Icons.star, color: MaceioColors.sunYellow),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Endereço / Bairro
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Endereço / Bairro (Google Maps)',
                        hintText: 'Ex: Av. Silvio Carlos Viana, Ponta Verde',
                        prefixIcon: const Icon(Icons.location_on_outlined, color: MaceioColors.coralAccent),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.map_outlined, color: MaceioColors.turquoisePrimary),
                          onPressed: () {
                            final loc = addressController.text.trim();
                            if (loc.isNotEmpty) MapUtils.openGoogleMaps(loc);
                          },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Status e Nota
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedStatus,
                            decoration: InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: statuses
                                .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedStatus = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: ratingController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Avaliação (1 a 5)',
                              prefixIcon: const Icon(Icons.star_rate, color: MaceioColors.sunYellow),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Observações / Dicas
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Dicas / Reserva / Observações',
                        hintText: 'Ex: Pedir mesa na varanda...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: MaceioButton(
                        label: isEditing ? 'Salvar Alterações' : 'Salvar Restaurante',
                        icon: isEditing ? Icons.save : Icons.add_task,
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) return;

                          Navigator.pop(context);

                          final cuisine = cuisineController.text.trim().isNotEmpty ? cuisineController.text.trim() : 'Regional';
                          final specialty = specialtyController.text.trim();
                          final address = addressController.text.trim();
                          final reservationTime = timeController.text.trim().isNotEmpty ? timeController.text.trim() : '20:00';
                          final rating = double.tryParse(ratingController.text.trim()) ?? 4.8;
                          final notes = notesController.text.trim();

                          if (isEditing) {
                            await _service.updateDining(
                              id: itemToEdit.id,
                              name: name,
                              cuisine: cuisine,
                              specialty: specialty,
                              address: address,
                              reservationTime: reservationTime,
                              rating: rating,
                              status: selectedStatus,
                              notes: notes,
                            );
                          } else {
                            await _service.addDining(
                              name: name,
                              cuisine: cuisine,
                              specialty: specialty,
                              address: address,
                              reservationTime: reservationTime,
                              rating: rating,
                              status: selectedStatus,
                              notes: notes,
                            );
                          }

                          _loadData();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(DiningItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Restaurante?'),
          content: Text('Tem certeza que deseja remover "${item.name}" da lista?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: MaceioColors.error),
              onPressed: () async {
                Navigator.pop(context);
                await _service.deleteDining(item.id);
                _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Restaurante excluído com sucesso!')),
                  );
                }
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTrip = TripContext.instance.activeTrip;

    return Scaffold(
      backgroundColor: MaceioColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: MaceioColors.coralAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo Restaurante', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showDiningModal(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MaceioHeader(
              title: activeTrip != null ? 'Jantares • ${activeTrip.destination}' : 'Jantares & Gastronomia',
              subtitle: 'Recomendações inteligentes e reservas da família',
              badge: '${_tripDays.length} Dias',
              trailing: IconButton(
                icon: const Icon(Icons.refresh, color: MaceioColors.turquoisePrimary),
                onPressed: () {
                  _loadData();
                  _loadAiRecommendations();
                },
              ),
            ),

            // 1. Seletor de Dias Estilo iFood
            _buildIfoodDaySelector(),

            // 2. Conteúdo Principal
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                children: [
                  // Seção Inteligente de IA
                  _buildAiRecommendationsSection(),

                  const SizedBox(height: 24),

                  // Seção de Restaurantes Cadastrados na Viagem
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Seus Restaurantes Salvos', style: MaceioTypography.titleMedium),
                      TextButton.icon(
                        onPressed: () => _showDiningModal(),
                        icon: const Icon(Icons.add, size: 16, color: MaceioColors.coralAccent),
                        label: const Text('Adicionar', style: TextStyle(color: MaceioColors.coralAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  FutureBuilder<List<DiningItem>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(color: MaceioColors.turquoisePrimary),
                        ));
                      }

                      final items = snapshot.data ?? [];
                      if (items.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: MaceioColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: MaceioColors.border),
                          ),
                          child: Column(
                            children: [
                              const Text('🍽️', style: TextStyle(fontSize: 36)),
                              const SizedBox(height: 8),
                              Text('Nenhum restaurante salvo ainda', style: MaceioTypography.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                'Escolha uma das sugestões da IA acima com 1 toque ou adicione manualmente.',
                                textAlign: TextAlign.center,
                                style: MaceioTypography.caption,
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: items.map((item) => _buildSavedDiningCard(item)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Barra de Navegação de Dias Estilo iFood
  Widget _buildIfoodDaySelector() {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: MaceioColors.surface,
        border: Border(
          bottom: BorderSide(color: MaceioColors.border.withValues(alpha: 0.8)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _tripDays.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final dayInfo = _tripDays[index];
          final isSelected = dayInfo.dayNumber == _selectedDayNumber;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDayNumber = dayInfo.dayNumber;
              });
              _loadAiRecommendations();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [MaceioColors.coralAccent, Color(0xFFD34E26)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : MaceioColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? MaceioColors.coralAccent : MaceioColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: MaceioColors.coralAccent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayInfo.dayLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isSelected ? Colors.white70 : MaceioColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${dayInfo.dateShort} (${dayInfo.weekdayShort})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : MaceioColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 2. Seção de Sugestões de IA por Dia e Localização
  Widget _buildAiRecommendationsSection() {
    final currentDay = _currentDayInfo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MaceioColors.oceanDeep.withValues(alpha: 0.04),
            MaceioColors.turquoisePrimary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MaceioColors.turquoisePrimary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: MaceioColors.turquoisePrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome, color: MaceioColors.turquoisePrimary, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sugestões da IA para o ${currentDay.dayLabel}',
                        style: MaceioTypography.titleMedium.copyWith(fontSize: 15),
                      ),
                      Text(
                        'Baseado nos passeios e praias de ${currentDay.dateShort}',
                        style: MaceioTypography.caption.copyWith(color: MaceioColors.turquoiseDark, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: _isLoadingAi
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: MaceioColors.turquoisePrimary),
                      )
                    : const Icon(Icons.refresh, size: 18, color: MaceioColors.turquoisePrimary),
                tooltip: 'Regerar com IA',
                onPressed: _isLoadingAi ? null : _loadAiRecommendations,
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (_isLoadingAi) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: MaceioColors.turquoisePrimary),
                    SizedBox(height: 10),
                    Text('Buscando os melhores restaurantes no caminho do dia com IA...', style: TextStyle(fontSize: 12, color: MaceioColors.textMuted)),
                  ],
                ),
              ),
            ),
          ] else if (_aiRecommendations.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('Nenhuma sugestão encontrada para este dia.', style: MaceioTypography.caption),
              ),
            ),
          ] else ...[
            // Carrossel de Restaurantes da IA com Botão de 1 Toque
            SizedBox(
              height: 235,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _aiRecommendations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final rec = _aiRecommendations[index];
                  return _buildAiRestaurantCard(rec);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 3. Card Visual de Restaurante Sugerido pela IA
  Widget _buildAiRestaurantCard(Map<String, dynamic> rec) {
    final name = rec['name'] ?? 'Restaurante';
    final cuisine = rec['cuisine'] ?? 'Regional';
    final specialty = rec['specialty'] ?? '';
    final neighborhood = rec['neighborhood'] ?? '';
    final meal = rec['suggestedMeal'] ?? 'Jantar';
    final rating = rec['rating'] ?? 4.8;
    final price = rec['priceLevel'] ?? r'$$';
    final reason = rec['reason'] ?? '';
    final icon = rec['icon'] ?? '🍽️';

    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MaceioColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MaceioColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: MaceioTypography.titleMedium.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$cuisine • $neighborhood',
                      style: MaceioTypography.caption.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Prato Destaque
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: MaceioColors.sandWarm,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: MaceioColors.sunYellow, size: 12),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    specialty,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: MaceioColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Justificativa da IA
          Expanded(
            child: Text(
              reason,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('⭐ $rating • $price', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: MaceioColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(meal, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: MaceioColors.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Botão 1-Click Add
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: MaceioColors.turquoisePrimary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              icon: const Icon(Icons.bolt, color: Colors.white, size: 16),
              label: const Text(
                'Adicionar com 1 Toque ⚡',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _addAiRecommendationDirectly(rec),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Card de Restaurante Já Salvo
  Widget _buildSavedDiningCard(DiningItem item) {
    Color statusColor;
    String statusLabel;
    switch (item.status.toLowerCase()) {
      case 'reservado':
        statusColor = MaceioColors.success;
        statusLabel = 'RESERVADO';
        break;
      case 'visitado':
        statusColor = MaceioColors.textMuted;
        statusLabel = 'VISITADO';
        break;
      default:
        statusColor = MaceioColors.coralAccent;
        statusLabel = 'PLANEJADO';
    }

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      dragStartBehavior: DragStartBehavior.down,
      dismissThresholds: const {DismissDirection.endToStart: 0.15},
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Excluir Restaurante?'),
            content: Text('Deseja remover "${item.name}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: MaceioColors.error),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Excluir', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        await _service.deleteDining(item.id);
        _loadData();
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: MaceioColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: MaceioCard(
          onTap: () => _showDiningModal(itemToEdit: item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.restaurant, color: MaceioColors.coralAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: MaceioTypography.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18, color: MaceioColors.textMuted),
                    onSelected: (val) async {
                      if (val == 'edit') {
                        _showDiningModal(itemToEdit: item);
                      } else if (val == 'delete') {
                        _confirmDelete(item);
                      } else {
                        await _service.updateStatus(item.id, val);
                        _loadData();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'planejado', child: Text('Marcar como Planejado')),
                      const PopupMenuItem(value: 'reservado', child: Text('Marcar como Reservado')),
                      const PopupMenuItem(value: 'visitado', child: Text('Marcar como Visitado')),
                      const PopupMenuDivider(),
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      const PopupMenuItem(value: 'delete', child: Text('Excluir', style: TextStyle(color: MaceioColors.error))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Row(
                children: [
                  MaceioChip(label: statusLabel, color: statusColor.withValues(alpha: 0.15), textColor: statusColor),
                  const SizedBox(width: 8),
                  Text('⏰ ${item.reservationTime}', style: MaceioTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text('⭐ ${item.rating}', style: MaceioTypography.caption.copyWith(fontWeight: FontWeight.bold, color: MaceioColors.sunYellow)),
                ],
              ),

              if (item.specialty.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('Prato: ${item.specialty}', style: MaceioTypography.bodyMedium),
              ],

              if (item.address.isNotEmpty) ...[
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => MapUtils.openGoogleMaps(item.address),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: MaceioColors.turquoisePrimary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.address,
                          style: MaceioTypography.caption.copyWith(
                            color: MaceioColors.turquoiseDark,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (item.notes.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MaceioColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(item.notes, style: const TextStyle(fontSize: 11, color: MaceioColors.textMuted)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
