import 'package:flutter/material.dart';
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
  late Future<List<DiningItem>> _future;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _future = _service.getDinings();
    });
  }

  void _showDiningModal({DiningItem? itemToEdit}) {
    final isEditing = itemToEdit != null;
    final nameController = TextEditingController(text: itemToEdit?.name ?? '');
    final cuisineController = TextEditingController(text: itemToEdit?.cuisine ?? 'Frutos do Mar');
    final specialtyController = TextEditingController(text: itemToEdit?.specialty ?? '');
    final addressController = TextEditingController(text: itemToEdit?.address ?? '');
    final timeController = TextEditingController(text: itemToEdit?.reservationTime ?? '20:00');
    final ratingController = TextEditingController(text: itemToEdit?.rating.toString() ?? '4.8');
    final notesController = TextEditingController(text: itemToEdit?.notes ?? '');
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

                    // Tipo de Culinária e Especialidade
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
                              labelText: 'Horário (ex: 20:00)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Prato Destaque / Especialidade
                    TextField(
                      controller: specialtyController,
                      decoration: InputDecoration(
                        labelText: 'Prato Destaque / Especialidade',
                        hintText: 'Ex: Camarão Jangadeiro com Arroz Cremoso',
                        prefixIcon: const Icon(Icons.star, color: MaceioColors.sunYellow),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Endereço
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Endereço / Bairro',
                        hintText: 'Ex: Av. Silvio Carlos Viana, Ponta Verde',
                        prefixIcon: const Icon(Icons.location_on_outlined, color: MaceioColors.turquoisePrimary),
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

                    // Observações
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Dicas / Observações da Família',
                        hintText: 'Ex: Fazer reserva com 2 dias de antecedência para mesa na varanda',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: MaceioButton(
                        label: isEditing ? 'Salvar Alterações' : 'Adicionar aos Jantares',
                        icon: isEditing ? Icons.save : Icons.add_circle_outline,
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) return;

                          Navigator.pop(context);

                          final cuisine = cuisineController.text.trim().isNotEmpty
                              ? cuisineController.text.trim()
                              : 'Regional';
                          final specialty = specialtyController.text.trim().isNotEmpty
                              ? specialtyController.text.trim()
                              : 'Prato do Chef';
                          final address = addressController.text.trim().isNotEmpty
                              ? addressController.text.trim()
                              : 'Maceió, AL';
                          final reservationTime = timeController.text.trim().isNotEmpty
                              ? timeController.text.trim()
                              : '20:00';
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
              subtitle: 'Sabores e reservas imperdíveis da família',
              badge: 'Gastronomia',
              trailing: IconButton(
                icon: const Icon(Icons.refresh, color: MaceioColors.turquoisePrimary),
                onPressed: _loadData,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<DiningItem>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: MaceioColors.turquoisePrimary));
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.restaurant, size: 48, color: MaceioColors.textMuted),
                          const SizedBox(height: 8),
                          Text('Erro ao carregar restaurantes', style: MaceioTypography.titleMedium),
                          const SizedBox(height: 8),
                          MaceioButton(label: 'Tentar Novamente', onPressed: _loadData),
                        ],
                      ),
                    );
                  }

                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.restaurant_menu, size: 48, color: MaceioColors.textMuted),
                          const SizedBox(height: 12),
                          Text('Nenhum restaurante cadastrado ainda.', style: MaceioTypography.titleMedium),
                          const SizedBox(height: 8),
                          MaceioButton(label: 'Adicionar Restaurante', onPressed: () => _showDiningModal()),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isReserved = item.status == 'reservado';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: MaceioCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: MaceioColors.coralLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.restaurant_menu, color: MaceioColors.coralAccent),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, style: MaceioTypography.titleMedium),
                                        const SizedBox(height: 2),
                                        Text(item.cuisine, style: MaceioTypography.caption.copyWith(color: MaceioColors.turquoiseDark)),
                                      ],
                                    ),
                                  ),
                                  MaceioChip(
                                    label: isReserved ? 'RESERVADO' : item.status.toUpperCase(),
                                    color: isReserved ? MaceioColors.turquoisePrimary : MaceioColors.sandWarm,
                                    textColor: isReserved ? Colors.white : MaceioColors.textSecondary,
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: MaceioColors.textMuted, size: 20),
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        _showDiningModal(itemToEdit: item);
                                      } else if (val == 'delete') {
                                        _confirmDelete(item);
                                      }
                                    },
                                    itemBuilder: (context) => [
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
                              const SizedBox(height: 12),

                              // Prato especial
                              if (item.specialty.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: MaceioColors.sandWarm,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, size: 16, color: MaceioColors.sunYellow),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Destaque: ${item.specialty}',
                                          style: MaceioTypography.caption.copyWith(
                                            color: MaceioColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],

                              // Endereço e Horário
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 14, color: MaceioColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(item.reservationTime, style: MaceioTypography.caption),
                                  const Spacer(),
                                  const Icon(Icons.star_rate, size: 14, color: MaceioColors.sunYellow),
                                  const SizedBox(width: 2),
                                  Text('${item.rating}', style: MaceioTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (item.address.isNotEmpty)
                                InkWell(
                                  onTap: () {
                                    final activeTrip = TripContext.instance.activeTrip;
                                    final query = item.address.contains(activeTrip?.destination ?? '')
                                        ? item.address
                                        : '${item.address}, ${activeTrip?.destination ?? ""}';
                                    MapUtils.openGoogleMaps(query);
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 14, color: MaceioColors.coralAccent),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            item.address,
                                            style: MaceioTypography.caption.copyWith(
                                              color: MaceioColors.turquoiseDark,
                                              fontWeight: FontWeight.w600,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.open_in_new, size: 12, color: MaceioColors.turquoiseDark),
                                      ],
                                    ),
                                  ),
                                ),
                              if (item.notes.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(item.notes, style: MaceioTypography.bodyMedium.copyWith(fontStyle: FontStyle.italic)),
                              ],
                              const SizedBox(height: 10),

                              // Card Footer Action
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.edit_outlined, size: 16, color: MaceioColors.turquoiseDark),
                                    label: const Text('Editar', style: TextStyle(color: MaceioColors.turquoiseDark, fontSize: 12)),
                                    onPressed: () => _showDiningModal(itemToEdit: item),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.delete_outline, size: 16, color: MaceioColors.error),
                                    label: const Text('Excluir', style: TextStyle(color: MaceioColors.error, fontSize: 12)),
                                    onPressed: () => _confirmDelete(item),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
}
