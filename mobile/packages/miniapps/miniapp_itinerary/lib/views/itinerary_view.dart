import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../models/itinerary_model.dart';
import '../services/itinerary_service.dart';

class ItineraryView extends StatefulWidget {
  const ItineraryView({super.key});

  @override
  State<ItineraryView> createState() => _ItineraryViewState();
}

class _ItineraryViewState extends State<ItineraryView> {
  final ItineraryService _service = ItineraryService();
  late Future<List<ItineraryItem>> _itinerariesFuture;

  int _selectedDayNumber = 1;
  late List<TripDayInfo> _tripDays;

  // Generic categories versatile for all destinations
  static const List<String> kGenericCategories = [
    'Hospedagem & Check-in 🏨',
    'Passeio & Ponto Turístico 🗺️',
    'Evento, Show & Teatro 🎟️',
    'Gastronomia & Restaurante 🍽️',
    'Natureza & Ecoturismo 🌲',
    'Praia, Piscina & Águas 🏖️',
    'Compras & Mercado 🛍️',
    'Deslocamento & Transfer 🚗',
    'Descanso & Lazer ☕',
    'Outro ✨',
  ];

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
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final activeTrip = TripContext.instance.activeTrip;
      final city = activeTrip?.destination ?? 'Maceió';
      final state = activeTrip?.state ?? 'Alagoas';
      final bff = ServiceLocator.instance.get<BffClient>();
      final res = await bff.get('/api/v1/weather?city=$city&state=$state');
      if (res != null && res['data'] != null) {
        final daily = (res['data']['daily'] as List<dynamic>?) ?? [];
        if (daily.isNotEmpty && mounted) {
          setState(() {
            _tripDays = _tripDays.map((day) {
              var match = daily.firstWhere(
                (d) => d['date'] == day.isoDate,
                orElse: () => null,
              );
              if (match == null && day.dayNumber <= daily.length) {
                match = daily[day.dayNumber - 1];
              }

              if (match != null) {
                return day.copyWithWeather(
                  maxTemp: match['maxTemp'],
                  minTemp: match['minTemp'],
                  weatherCondition: match['condition'],
                  weatherIcon: match['icon'],
                  rainProbability: match['precipitationProbability'] != null
                      ? (match['precipitationProbability'] as num).toInt()
                      : null,
                );
              }
              return day;
            }).toList();
          });
        }
      }
    } catch (_) {}
  }

  void _loadData() {
    setState(() {
      _itinerariesFuture = _service.getItineraries();
    });
    _loadWeather();
  }

  TripDayInfo get _currentDayInfo {
    return _tripDays.firstWhere(
      (d) => d.dayNumber == _selectedDayNumber,
      orElse: () => _tripDays.first,
    );
  }

  void _openLocationInMaps(String location) {
    final activeTrip = TripContext.instance.activeTrip;
    final query = location.contains(activeTrip?.destination ?? '')
        ? location
        : '$location, ${activeTrip?.destination ?? ""}';

    MapUtils.openGoogleMaps(query);
  }

  void _showActivityModal({ItineraryItem? itemToEdit}) {
    final isEditing = itemToEdit != null;
    final targetDay = itemToEdit?.day ?? _selectedDayNumber;
    final targetDayInfo = _tripDays.firstWhere(
      (d) => d.dayNumber == targetDay,
      orElse: () => _currentDayInfo,
    );

    final titleController = TextEditingController(text: itemToEdit?.title ?? '');
    final dayController = TextEditingController(text: targetDay.toString());
    final locationController = TextEditingController(text: itemToEdit?.location ?? '');
    final timeController = TextEditingController(text: itemToEdit?.time ?? '09:00');
    final tideTimeController = TextEditingController(text: itemToEdit?.tideTime ?? '');
    final descriptionController = TextEditingController(text: itemToEdit?.description ?? '');
    final dateController = TextEditingController(text: itemToEdit?.date ?? targetDayInfo.dateShort);

    String selectedTag = itemToEdit?.tag ?? kGenericCategories.first;
    if (!kGenericCategories.contains(selectedTag)) {
      // If legacy or custom tag, keep it as valid
      selectedTag = kGenericCategories.first;
    }

    String imageUrl = itemToEdit?.imageUrl ??
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80';

    final quickTimes = ['08:00', '09:30', '11:30', '14:00', '16:30', '19:30'];

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
                          backgroundColor: MaceioColors.turquoisePrimary.withValues(alpha: 0.15),
                          child: Icon(
                            isEditing ? Icons.edit_calendar : Icons.add_circle,
                            color: MaceioColors.turquoisePrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? 'Editar Atividade' : 'Nova Atividade no Dia $targetDay',
                                style: MaceioTypography.titleLarge,
                              ),
                              Text(
                                '${targetDayInfo.fullWeekdayLabel} • ${targetDayInfo.dateShort}',
                                style: MaceioTypography.caption.copyWith(
                                  color: MaceioColors.turquoiseDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Horário e Seletor Rápido
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: timeController,
                            decoration: InputDecoration(
                              labelText: 'Horário Previsto',
                              hintText: 'Ex: 09:30',
                              prefixIcon: const Icon(Icons.access_time, color: MaceioColors.turquoisePrimary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: dayController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Dia nº',
                              prefixIcon: const Icon(Icons.calendar_today, size: 18, color: MaceioColors.turquoisePrimary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Sugestões de Horários
                    Wrap(
                      spacing: 6,
                      children: quickTimes.map((t) {
                        return ActionChip(
                          label: Text(t, style: const TextStyle(fontSize: 12)),
                          backgroundColor: MaceioColors.surfaceElevated,
                          side: BorderSide.none,
                          onPressed: () {
                            setModalState(() {
                              timeController.text = t;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    // Título da Atividade
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Título da Atividade / Passeio',
                        hintText: 'Ex: Visita ao Museu / Passeio de Barco',
                        prefixIcon: const Icon(Icons.star_outline, color: MaceioColors.turquoisePrimary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Categoria Genérica (Serve para todas as viagens)
                    DropdownButtonFormField<String>(
                      value: selectedTag,
                      decoration: InputDecoration(
                        labelText: 'Categoria / Tipo',
                        prefixIcon: const Icon(Icons.category_outlined, color: MaceioColors.turquoisePrimary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: kGenericCategories.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedTag = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Endereço / Localização para Google Maps
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Endereço / Local (Google Maps)',
                        hintText: 'Ex: Av. Silvio Carlos Viana, 1500 ou Parque Ibirapuera',
                        prefixIcon: const Icon(Icons.pin_drop_outlined, color: MaceioColors.coralAccent),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.map_outlined, color: MaceioColors.turquoisePrimary),
                          tooltip: 'Testar no Google Maps',
                          onPressed: () {
                            final loc = locationController.text.trim();
                            if (loc.isNotEmpty) {
                              _openLocationInMaps(loc);
                            }
                          },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tábua de Maré / Dica de Horário (Opcional)
                    TextField(
                      controller: tideTimeController,
                      decoration: InputDecoration(
                        labelText: 'Observação de Horário / Maré (Opcional)',
                        hintText: 'Ex: Melhor horário: Pôr do sol às 17h30 ou Maré baixa: 0.2m',
                        prefixIcon: const Icon(Icons.info_outline, color: MaceioColors.oceanDeep),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Descrição / Dicas
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Dicas / Ingressos / Informações Extras',
                        hintText: 'Ex: Comprar ingressos online com antecedência...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: MaceioButton(
                        label: isEditing ? 'Salvar Alterações' : 'Inserir na Trilha do Dia $targetDay',
                        icon: isEditing ? Icons.save : Icons.add_task,
                        onPressed: () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) return;

                          Navigator.pop(context);

                          final day = int.tryParse(dayController.text.trim()) ?? targetDay;
                          final location = locationController.text.trim();
                          final time = timeController.text.trim().isNotEmpty ? timeController.text.trim() : '09:00';
                          final tideTime = tideTimeController.text.trim().isNotEmpty
                              ? tideTimeController.text.trim()
                              : null;
                          final description = descriptionController.text.trim();
                          final date = dateController.text.trim().isNotEmpty
                              ? dateController.text.trim()
                              : targetDayInfo.dateShort;

                          if (isEditing) {
                            await _service.updateItinerary(
                              id: itemToEdit.id,
                              title: title,
                              day: day,
                              location: location,
                              description: description,
                              time: time,
                              tideTime: tideTime,
                              tag: selectedTag,
                              imageUrl: imageUrl,
                              date: date,
                              status: itemToEdit.status,
                            );
                          } else {
                            await _service.addItinerary(
                              title: title,
                              day: day,
                              location: location,
                              description: description,
                              time: time,
                              tideTime: tideTime,
                              tag: selectedTag,
                              imageUrl: imageUrl,
                              date: date,
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

  void _confirmDelete(ItineraryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Atividade?'),
          content: Text('Tem certeza que deseja remover "${item.title}" da trilha?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: MaceioColors.error),
              onPressed: () async {
                Navigator.pop(context);
                await _service.deleteItinerary(item.id);
                _loadData();
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
        backgroundColor: MaceioColors.turquoisePrimary,
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: Text('Adicionar no Dia $_selectedDayNumber', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showActivityModal(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Principal
            MaceioHeader(
              title: activeTrip != null ? 'Roteiro • ${activeTrip.destination}' : 'Roteiro da Viagem',
              subtitle: 'Trilha cronológica dos seus dias de viagem',
              badge: '${_tripDays.length} Dias na Trilha',
              trailing: IconButton(
                icon: const Icon(Icons.refresh, color: MaceioColors.turquoisePrimary),
                onPressed: _loadData,
              ),
            ),

            // SELETOR DE DIAS ESTILO IFOOD (STICKY HORIZONTAL CAPSULES)
            _buildIfoodDaySelector(),

            // CONTEÚDO PRINCIPAL (TRILHA DO DIA)
            Expanded(
              child: FutureBuilder<List<ItineraryItem>>(
                future: _itinerariesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: MaceioColors.turquoisePrimary));
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 48, color: MaceioColors.textMuted),
                          const SizedBox(height: 12),
                          Text('Erro ao carregar roteiro', style: MaceioTypography.titleMedium),
                          const SizedBox(height: 8),
                          MaceioButton(label: 'Tentar Novamente', onPressed: _loadData),
                        ],
                      ),
                    );
                  }

                  final allItems = snapshot.data ?? [];
                  final dayItems = allItems.where((i) => i.day == _selectedDayNumber).toList();

                  // Sort items by time
                  dayItems.sort((a, b) => a.time.compareTo(b.time));

                  return _buildDayTimelineContent(dayItems);
                },
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
      height: 78,
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
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [MaceioColors.turquoisePrimary, MaceioColors.turquoiseDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : MaceioColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? MaceioColors.turquoisePrimary : MaceioColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: MaceioColors.turquoisePrimary.withValues(alpha: 0.3),
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
                  if (dayInfo.maxTemp != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(dayInfo.weatherIcon ?? '☀️', style: const TextStyle(fontSize: 10)),
                        const SizedBox(width: 3),
                        Text(
                          '${dayInfo.maxTemp}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : MaceioColors.turquoiseDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 2. Conteúdo da Trilha do Dia Selecionado
  Widget _buildDayTimelineContent(List<ItineraryItem> items) {
    final completedCount = items.where((i) => i.status == 'completed').length;
    final totalCount = items.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final currentDay = _currentDayInfo;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        // Card de Resumo do Dia Atual
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [MaceioColors.oceanDeep, MaceioColors.turquoiseDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: MaceioColors.oceanDeep.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${currentDay.dayLabel.toUpperCase()} • ${currentDay.weekdayShort.toUpperCase()}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '$completedCount de $totalCount concluídos',
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                currentDay.fullDateLabel,
                style: MaceioTypography.titleLarge.copyWith(color: Colors.white, fontSize: 19),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(MaceioColors.sunYellow),
                ),
              ),

              // Previsão do Tempo do Dia Selecionado
              if (currentDay.maxTemp != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Text(currentDay.weatherIcon ?? '☀️', style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  currentDay.weatherCondition ?? 'Tempo Bom',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${currentDay.minTemp} a ${currentDay.maxTemp}',
                                  style: const TextStyle(
                                    color: MaceioColors.sunYellow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentDay.rainProbability != null && currentDay.rainProbability! > 0
                                  ? '🌧️ ${currentDay.rainProbability}% de probabilidade de chuva'
                                  : '☀️ Dia favorável para passeios ao ar livre',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trilha do Dia (${items.length} ${items.length == 1 ? "atividade" : "atividades"})',
              style: MaceioTypography.titleMedium,
            ),
            TextButton.icon(
              onPressed: () => _showActivityModal(),
              icon: const Icon(Icons.add, size: 16, color: MaceioColors.turquoiseDark),
              label: const Text('Adicionar', style: TextStyle(color: MaceioColors.turquoiseDark, fontWeight: FontWeight.bold)),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (items.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: MaceioColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: MaceioColors.border),
            ),
            child: Column(
              children: [
                const Text('🗺️', style: TextStyle(fontSize: 42)),
                const SizedBox(height: 10),
                Text(
                  'Nenhuma atividade para o ${currentDay.dayLabel}',
                  style: MaceioTypography.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Planeje seus passeios, eventos e restaurantes por horário.',
                  textAlign: TextAlign.center,
                  style: MaceioTypography.caption,
                ),
                const SizedBox(height: 16),
                MaceioButton(
                  label: 'Adicionar Atividade às 09h',
                  icon: Icons.add,
                  onPressed: () => _showActivityModal(),
                ),
              ],
            ),
          ),
        ] else ...[
          // TRILHA VERTICAL COM LINHAS E NÓS
          ...List.generate(items.length, (index) {
            final item = items[index];
            final isFirst = index == 0;
            final isLast = index == items.length - 1;
            return _buildTimelineStep(
              item: item,
              isFirst: isFirst,
              isLast: isLast,
              index: index,
            );
          }),

          const SizedBox(height: 16),

          // Banner Inteligente de Restaurantes da IA
          _buildDiningSuggestionsPrompt(items),
        ],
      ],
    );
  }

  // 3. Nó e Card da Trilha Vertical (Timeline Node + Card)
  Widget _buildTimelineStep({
    required ItineraryItem item,
    required bool isFirst,
    required bool isLast,
    required int index,
  }) {
    final isCompleted = item.status == 'completed';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha e Nó da Trilha
          SizedBox(
            width: 36,
            child: Column(
              children: [
                // Linha superior
                Container(
                  width: 2.5,
                  height: isFirst ? 14 : 20,
                  color: isFirst
                      ? Colors.transparent
                      : (isCompleted ? MaceioColors.turquoisePrimary : MaceioColors.border),
                ),
                // Nó Circular do Horário
                GestureDetector(
                  onTap: () async {
                    final newStatus = isCompleted ? 'planned' : 'completed';
                    await _service.updateStatus(item.id, newStatus);
                    _loadData();
                  },
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? MaceioColors.turquoisePrimary : MaceioColors.surface,
                      border: Border.all(
                        color: isCompleted ? MaceioColors.turquoisePrimary : MaceioColors.turquoiseDark,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isCompleted ? MaceioColors.turquoisePrimary : Colors.black)
                              .withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: MaceioColors.turquoiseDark,
                              ),
                            ),
                    ),
                  ),
                ),
                // Linha inferior conectando ao próximo
                Expanded(
                  child: Container(
                    width: 2.5,
                    color: isLast
                        ? Colors.transparent
                        : (isCompleted ? MaceioColors.turquoisePrimary : MaceioColors.border),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Card da Atividade na Trilha com Swipe-to-Delete (Dismissible)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                dragStartBehavior: DragStartBehavior.down,
                dismissThresholds: const {DismissDirection.endToStart: 0.15},
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.delete_outline, color: MaceioColors.error),
                          SizedBox(width: 8),
                          Text('Excluir Atividade?'),
                        ],
                      ),
                      content: Text('Deseja remover "${item.title}" da trilha?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: MaceioColors.error),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Excluir', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  await _service.deleteItinerary(item.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Atividade "${item.title}" excluída da trilha!'),
                        backgroundColor: MaceioColors.coralAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  _loadData();
                },
                secondaryBackground: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: MaceioColors.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Excluir',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.delete_outline, color: Colors.white, size: 22),
                    ],
                  ),
                ),
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: MaceioColors.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Excluir',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.delete_outline, color: Colors.white, size: 22),
                    ],
                  ),
                ),
                child: MaceioCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header do Card: Horário & Categoria
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? MaceioColors.success.withValues(alpha: 0.12)
                                  : MaceioColors.oceanLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 13,
                                  color: isCompleted ? MaceioColors.success : MaceioColors.turquoiseDark,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.time,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted ? MaceioColors.success : MaceioColors.turquoiseDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.tag,
                              style: MaceioTypography.caption.copyWith(
                                color: MaceioColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: MaceioColors.textMuted, size: 18),
                            onSelected: (val) {
                              if (val == 'edit') {
                                _showActivityModal(itemToEdit: item);
                              } else if (val == 'delete') {
                                _confirmDelete(item);
                              } else if (val == 'maps' && item.location.isNotEmpty) {
                                _openLocationInMaps(item.location);
                              }
                            },
                            itemBuilder: (context) => [
                              if (item.location.isNotEmpty)
                                const PopupMenuItem(
                                  value: 'maps',
                                  child: Row(
                                    children: [
                                      Icon(Icons.map_outlined, size: 18, color: MaceioColors.coralAccent),
                                      SizedBox(width: 8),
                                      Text('Abrir no Google Maps'),
                                    ],
                                  ),
                                ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18, color: MaceioColors.turquoiseDark),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 18, color: MaceioColors.error),
                                    SizedBox(width: 8),
                                    Text('Excluir', style: TextStyle(color: MaceioColors.error)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Título da Atividade
                      Text(
                        item.title,
                        style: MaceioTypography.titleMedium.copyWith(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? MaceioColors.textMuted : MaceioColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),

                      // Localização com Botão Clicável do Google Maps
                      if (item.location.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _openLocationInMaps(item.location),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: MaceioColors.oceanLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: MaceioColors.turquoisePrimary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.place, size: 14, color: MaceioColors.coralAccent),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    item.location,
                                    style: MaceioTypography.caption.copyWith(
                                      color: MaceioColors.turquoiseDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: MaceioColors.turquoisePrimary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'MAPS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Icon(Icons.open_in_new, size: 10, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Tábua de Maré / Dica de Horário (se houver)
                      if (item.tideTime != null && item.tideTime!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: MaceioColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 14, color: MaceioColors.oceanDeep),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.tideTime!,
                                  style: MaceioTypography.caption.copyWith(
                                    color: MaceioColors.oceanDeep,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Descrição
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.description,
                          style: MaceioTypography.bodyMedium.copyWith(fontSize: 13),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Footer com Botão de Concluir
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              final newStatus = isCompleted ? 'planned' : 'completed';
                              await _service.updateStatus(item.id, newStatus);
                              _loadData();
                            },
                            icon: Icon(
                              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                              size: 18,
                              color: isCompleted ? MaceioColors.success : MaceioColors.turquoisePrimary,
                            ),
                            label: Text(
                              isCompleted ? 'Concluído' : 'Marcar como Feito',
                              style: TextStyle(
                                color: isCompleted ? MaceioColors.success : MaceioColors.turquoisePrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 16, color: MaceioColors.turquoiseDark),
                                tooltip: 'Editar',
                                onPressed: () => _showActivityModal(itemToEdit: item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 16, color: MaceioColors.error),
                                tooltip: 'Excluir',
                                onPressed: () => _confirmDelete(item),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Banner e Drawer de Onde Comer no Dia com Gemini IA
  Widget _buildDiningSuggestionsPrompt(List<ItineraryItem> dayItems) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MaceioColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MaceioColors.coralAccent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: MaceioColors.coralAccent.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MaceioColors.coralLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant, color: MaceioColors.coralAccent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Onde Comer Perto das Atrações? 🍽️',
                      style: MaceioTypography.titleMedium.copyWith(fontSize: 14),
                    ),
                    Text(
                      'Sugestões da IA baseadas nos passeios do Dia $_selectedDayNumber',
                      style: MaceioTypography.caption.copyWith(color: MaceioColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: MaceioColors.coralAccent),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.auto_awesome, color: MaceioColors.coralAccent, size: 16),
              label: const Text(
                'Ver Restaurantes Recomendados pela IA ⚡',
                style: TextStyle(color: MaceioColors.coralAccent, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              onPressed: () => _showAiDiningDrawer(dayItems),
            ),
          ),
        ],
      ),
    );
  }

  void _showAiDiningDrawer(List<ItineraryItem> dayItems) {
    AppHaptics.light();
    final activeTrip = TripContext.instance.activeTrip;
    final destination = activeTrip?.destination ?? 'Maceió';
    final state = activeTrip?.state ?? 'Alagoas';
    final bff = ServiceLocator.instance.get<BffClient>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FutureBuilder<dynamic>(
          future: bff.post('/api/v1/ai/dining-recommendations', {
            'destination': destination,
            'state': state,
            'dayNumber': _selectedDayNumber,
            'activities': dayItems.map((i) => {'title': i.title, 'location': i.location, 'tag': i.tag}).toList(),
          }),
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final recs = (snapshot.data?['data'] as List<dynamic>?) ?? [];

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: MaceioColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
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
                      const CircleAvatar(
                        backgroundColor: MaceioColors.coralLight,
                        child: Icon(Icons.auto_awesome, color: MaceioColors.coralAccent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Restaurantes Recomendados pela IA', style: MaceioTypography.titleLarge),
                            Text('Perto do seu roteiro no Dia $_selectedDayNumber', style: MaceioTypography.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (isLoading) ...[
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: MaceioColors.coralAccent),
                            SizedBox(height: 12),
                            Text('A IA está selecionando os melhores restaurantes no caminho...', style: TextStyle(color: MaceioColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  ] else if (recs.isEmpty) ...[
                    const Expanded(
                      child: Center(child: Text('Nenhuma sugestão encontrada.')),
                    ),
                  ] else ...[
                    Expanded(
                      child: ListView.separated(
                        itemCount: recs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final rec = recs[index];
                          final name = rec['name'] ?? 'Restaurante';
                          final specialty = rec['specialty'] ?? '';
                          final cuisine = rec['cuisine'] ?? 'Regional';
                          final address = rec['address'] ?? '';
                          final rating = rec['rating'] ?? 4.8;
                          final price = rec['priceLevel'] ?? r'$$';
                          final reason = rec['reason'] ?? '';
                          final meal = rec['suggestedMeal'] ?? 'Jantar';
                          final time = rec['suggestedTime'] ?? '20:00';
                          final icon = rec['icon'] ?? '🍽️';

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: MaceioColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: MaceioColors.border),
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
                                          Text(name, style: MaceioTypography.titleMedium.copyWith(fontSize: 15)),
                                          Text('$cuisine • $address', style: MaceioTypography.caption),
                                        ],
                                      ),
                                    ),
                                    Text('⭐ $rating • $price', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                if (specialty.isNotEmpty)
                                  Text('Prato: $specialty', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MaceioColors.turquoiseDark)),
                                const SizedBox(height: 4),
                                Text(reason, style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: MaceioColors.coralAccent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    icon: const Icon(Icons.add_task, color: Colors.white, size: 16),
                                    label: Text(
                                      'Inserir na Trilha às $time ($meal) ⚡',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _service.addItinerary(
                                        title: '$name ($meal)',
                                        day: _selectedDayNumber,
                                        location: address,
                                        description: 'Prato: $specialty. $reason',
                                        time: time,
                                        tag: 'Gastronomia & Restaurante 🍽️',
                                        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
                                        date: _currentDayInfo.dateShort,
                                      );
                                      _loadData();
                                      if (mounted) {
                                        ScaffoldMessenger.of(this.context).showSnackBar(
                                          SnackBar(
                                            content: Text('"$name" adicionado à trilha do Dia $_selectedDayNumber! 🎉'),
                                            backgroundColor: MaceioColors.palmGreen,
                                          ),
                                        );
                                      }
                                    },
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
              ),
            );
          },
        );
      },
    );
  }
}
