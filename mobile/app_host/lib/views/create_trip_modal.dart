import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';

class DestinationPreset {
  final String destination;
  final String state;
  final String defaultTitle;
  final String emoji;
  final String imageUrl;

  const DestinationPreset({
    required this.destination,
    required this.state,
    required this.defaultTitle,
    required this.emoji,
    required this.imageUrl,
  });
}

const List<DestinationPreset> kPopularDestinations = [
  DestinationPreset(
    destination: 'Maceió',
    state: 'Alagoas',
    defaultTitle: 'Piscinas Naturais & Praias de Maceió 🏖️',
    emoji: '🏖️',
    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
  ),
  DestinationPreset(
    destination: 'Fernando de Noronha',
    state: 'Pernambuco',
    defaultTitle: 'Mergulho & Baía dos Porcos 🐬🤿',
    emoji: '🐬',
    imageUrl: 'https://images.unsplash.com/photo-1516815231560-8f41ec531527?auto=format&fit=crop&w=800&q=80',
  ),
  DestinationPreset(
    destination: 'Maragogi',
    state: 'Alagoas',
    defaultTitle: 'Caribe Brasileiro & Galés 🌴🐠',
    emoji: '🐠',
    imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=800&q=80',
  ),
  DestinationPreset(
    destination: 'Gramado e Canela',
    state: 'Rio Grande do Sul',
    defaultTitle: 'Natal Luz & Rota dos Vinhos 🎄🍇',
    emoji: '🍇',
    imageUrl: 'https://images.unsplash.com/photo-1517411032315-54ef2cb783bb?auto=format&fit=crop&w=800&q=80',
  ),
  DestinationPreset(
    destination: 'Porto de Galinhas',
    state: 'Pernambuco',
    defaultTitle: 'Passeio de Jangada & Corais ⛵🏝️',
    emoji: '🏝️',
    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
  ),
  DestinationPreset(
    destination: 'Rio de Janeiro',
    state: 'Rio de Janeiro',
    defaultTitle: 'Copacabana & Cristo Redentor ⛰️☀️',
    emoji: '⛰️',
    imageUrl: 'https://images.unsplash.com/photo-1483729558449-99ef09a8c325?auto=format&fit=crop&w=800&q=80',
  ),
];

class CreateTripModal extends StatefulWidget {
  final VoidCallback onTripCreated;

  const CreateTripModal({super.key, required this.onTripCreated});

  static Future<void> show(BuildContext context, {required VoidCallback onTripCreated}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateTripModal(onTripCreated: onTripCreated),
    );
  }

  @override
  State<CreateTripModal> createState() => _CreateTripModalState();
}

class _CreateTripModalState extends State<CreateTripModal> {
  final BffClient _bff = ServiceLocator.instance.get<BffClient>();

  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController(text: '3500');

  late DateTimeRange _dateRange;
  String _selectedImageUrl = 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80';
  DestinationPreset? _selectedPreset;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Default to a 6-day trip starting in 2 weeks
    final start = DateTime.now().add(const Duration(days: 14));
    final end = start.add(const Duration(days: 5));
    _dateRange = DateTimeRange(start: start, end: end);
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _stateController.dispose();
    _titleController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  int get _totalDays => _dateRange.end.difference(_dateRange.start).inDays + 1;

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateShort(DateTime date) {
    const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
  }

  String _getWeekdayName(DateTime date) {
    const days = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    return days[date.weekday - 1];
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      initialDateRange: _dateRange,
      helpText: 'SELECIONE O PERÍODO DA VIAGEM',
      cancelText: 'CANCELAR',
      confirmText: 'CONFIRMAR',
      saveText: 'SALVAR',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: MaceioColors.turquoisePrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: MaceioColors.textPrimary,
              secondary: MaceioColors.oceanDeep,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _selectPreset(DestinationPreset preset) {
    setState(() {
      _selectedPreset = preset;
      _destinationController.text = preset.destination;
      _stateController.text = preset.state;
      _titleController.text = preset.defaultTitle;
      _selectedImageUrl = preset.imageUrl;
      _errorMessage = null;
    });
  }

  Future<void> _submitTrip() async {
    final destination = _destinationController.text.trim();
    if (destination.isEmpty) {
      setState(() => _errorMessage = 'Informe o destino da viagem');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final startDateStr = _dateRange.start.toIso8601String().split('T')[0];
    final endDateStr = _dateRange.end.toIso8601String().split('T')[0];
    final tripDatesFormatted = '${_formatDateShort(_dateRange.start)} - ${_formatDate(_dateRange.end)}';

    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : 'Viagem para $destination ✈️';

    final user = TripContext.instance.currentUser;

    try {
      await _bff.post('/api/v1/trips', {
        'destination': destination,
        'state': _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : 'Brasil',
        'title': title,
        'startDate': startDateStr,
        'endDate': endDateStr,
        'tripDates': tripDatesFormatted,
        'imageUrl': _selectedImageUrl,
        'budget': _budgetController.text.trim(),
        'totalDays': _totalDays,
        'ownerId': user?.id,
        'ownerEmail': user?.email,
        'ownerName': user?.name,
      });

      if (mounted) {
        Navigator.pop(context);
        widget.onTripCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text('Viagem "$destination" criada com sucesso! ✈️')),
              ],
            ),
            backgroundColor: MaceioColors.turquoisePrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Falha ao salvar viagem. Tente novamente.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: MaceioColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Header Banner
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [MaceioColors.coralAccent, MaceioColors.sunYellow],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: MaceioColors.coralAccent.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text('✈️', style: TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Planejar Nova Viagem',
                          style: MaceioTypography.display.copyWith(
                            fontSize: 22,
                            color: MaceioColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Escolha o destino e selecione as datas no calendário',
                          style: MaceioTypography.caption.copyWith(color: MaceioColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: MaceioColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: MaceioColors.border),

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Sugestões de Destinos Rápidos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Destinos em Destaque', style: MaceioTypography.titleMedium),
                        Text('Toque para preencher', style: MaceioTypography.caption.copyWith(color: MaceioColors.turquoiseDark)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: kPopularDestinations.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final p = kPopularDestinations[index];
                          final isSelected = _selectedPreset?.destination == p.destination;
                          return ChoiceChip(
                            label: Text('${p.emoji} ${p.destination}'),
                            selected: isSelected,
                            onSelected: (_) => _selectPreset(p),
                            selectedColor: MaceioColors.oceanLight,
                            backgroundColor: MaceioColors.surfaceElevated,
                            side: BorderSide(
                              color: isSelected ? MaceioColors.turquoisePrimary : Colors.transparent,
                              width: 1.5,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected ? MaceioColors.turquoiseDark : MaceioColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Section 2: Destino e Estado Fields
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _destinationController,
                            onChanged: (_) => setState(() => _selectedPreset = null),
                            decoration: InputDecoration(
                              labelText: 'Destino da Viagem',
                              hintText: 'Ex: Fernando de Noronha',
                              prefixIcon: const Icon(Icons.place_outlined, color: MaceioColors.turquoisePrimary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: MaceioColors.turquoisePrimary, width: 2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _stateController,
                            decoration: InputDecoration(
                              labelText: 'Estado/UF',
                              hintText: 'Ex: Pernambuco',
                              prefixIcon: const Icon(Icons.map_outlined, color: MaceioColors.turquoisePrimary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: MaceioColors.turquoisePrimary, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Section 3: Título da Viagem
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Título da Viagem (Opcional)',
                        hintText: 'Ex: Férias com a Família em Maceió 🌊',
                        prefixIcon: const Icon(Icons.star_outline_rounded, color: MaceioColors.turquoisePrimary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: MaceioColors.turquoisePrimary, width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section 4: CALENDÁRIO / SELETOR DE DATAS (DESTAQUE VISUAL)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Período no Calendário', style: MaceioTypography.titleMedium),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: MaceioColors.oceanLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '✨ $_totalDays DIAS DE VIAGEM',
                            style: MaceioTypography.badge.copyWith(
                              color: MaceioColors.turquoiseDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Card Interativo do Calendário
                    InkWell(
                      onTap: _pickDateRange,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: MaceioColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: MaceioColors.turquoisePrimary.withValues(alpha: 0.5), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: MaceioColors.turquoisePrimary.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Data de Ida
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: MaceioColors.border),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.flight_takeoff, size: 16, color: MaceioColors.turquoisePrimary),
                                            const SizedBox(width: 6),
                                            Text(
                                              'DATA DE IDA',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: MaceioColors.turquoiseDark,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _formatDate(_dateRange.start),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: MaceioColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          _getWeekdayName(_dateRange.start),
                                          style: MaceioTypography.caption.copyWith(color: MaceioColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Icon(Icons.arrow_forward_rounded, color: MaceioColors.turquoisePrimary),
                                ),

                                // Data de Volta
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: MaceioColors.border),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.flight_land, size: 16, color: MaceioColors.coralAccent),
                                            const SizedBox(width: 6),
                                            Text(
                                              'DATA DE VOLTA',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: MaceioColors.coralAccent,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _formatDate(_dateRange.end),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: MaceioColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          _getWeekdayName(_dateRange.end),
                                          style: MaceioTypography.caption.copyWith(color: MaceioColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // CTA abrir calendário
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_month, size: 18, color: MaceioColors.turquoiseDark),
                                const SizedBox(width: 6),
                                Text(
                                  'Toque para alterar no calendário',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: MaceioColors.turquoiseDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section 5: Orçamento Estimado
                    Text('Orçamento Previsto da Família (R\$)', style: MaceioTypography.titleMedium),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Valor Total Estimado',
                        prefixIcon: const Icon(Icons.payments_outlined, color: MaceioColors.turquoisePrimary),
                        prefixText: 'R\$ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: MaceioColors.turquoisePrimary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['2000', '3500', '5000', '8000'].map((val) {
                        return ActionChip(
                          label: Text('R\$ $val'),
                          backgroundColor: MaceioColors.surfaceElevated,
                          side: BorderSide.none,
                          onPressed: () => setState(() => _budgetController.text = val),
                        );
                      }).toList(),
                    ),

                    // Error Message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: MaceioColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: MaceioColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, size: 18, color: MaceioColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: MaceioTypography.bodyMedium.copyWith(color: MaceioColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: MaceioButton(
                        label: 'Criar e Organizar Viagem',
                        icon: Icons.flight_takeoff,
                        isLoading: _isLoading,
                        onPressed: _submitTrip,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
