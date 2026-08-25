import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../models/packing_model.dart';
import '../services/packing_service.dart';

class PackingView extends StatefulWidget {
  const PackingView({super.key});

  @override
  State<PackingView> createState() => _PackingViewState();
}

class _PackingViewState extends State<PackingView> {
  final PackingService _service = PackingService();
  late Future<({List<PackingItem> items, PackingStats stats})> _future;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _future = _service.getPackingList();
    });
  }

  void _showPackingItemModal({PackingItem? itemToEdit}) {
    final isEditing = itemToEdit != null;
    final nameController = TextEditingController(text: itemToEdit?.name ?? '');
    final quantityController = TextEditingController(text: itemToEdit?.quantity.toString() ?? '1');
    String selectedCategory = itemToEdit?.category ?? 'Praia & Sol';
    final categories = ['Praia & Sol', 'Roupas', 'Documentos', 'Farmácia', 'Eletrônicos'];

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
                        backgroundColor: MaceioColors.palmGreen.withValues(alpha: 0.15),
                        child: Icon(
                          isEditing ? Icons.edit : Icons.luggage,
                          color: MaceioColors.palmGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Editar Item da Mala' : 'Adicionar Item na Mala',
                              style: MaceioTypography.titleLarge,
                            ),
                            Text(
                              isEditing ? 'Atualize a quantidade ou categoria' : 'Não se esqueça de nada para a viagem',
                              style: MaceioTypography.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nome do item (ex: Snorkel, Protetor Solar)',
                      prefixIcon: const Icon(Icons.check_box_outlined, color: MaceioColors.turquoisePrimary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: categories.contains(selectedCategory) ? selectedCategory : categories.first,
                          decoration: InputDecoration(
                            labelText: 'Categoria',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedCategory = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Qtd',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: MaceioButton(
                      label: isEditing ? 'Salvar Alterações' : 'Adicionar à Mala',
                      icon: isEditing ? Icons.save : Icons.add_circle_outline,
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final qty = int.tryParse(quantityController.text.trim()) ?? 1;

                        if (name.isNotEmpty) {
                          Navigator.pop(context);
                          if (isEditing) {
                            await _service.updateItem(
                              id: itemToEdit.id,
                              name: name,
                              category: selectedCategory,
                              quantity: qty,
                              isPacked: itemToEdit.isPacked,
                            );
                          } else {
                            await _service.addItem(
                              name: name,
                              category: selectedCategory,
                              quantity: qty,
                            );
                          }
                          _loadData();
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteItem(PackingItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Item?'),
          content: Text('Deseja remover "${item.name}" da mala?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: MaceioColors.error),
              onPressed: () async {
                Navigator.pop(context);
                await _service.deleteItem(item.id);
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
        backgroundColor: MaceioColors.palmGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showPackingItemModal(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MaceioHeader(
              title: activeTrip != null ? 'Malas • ${activeTrip.destination}' : 'Checklist de Malas',
              subtitle: 'Garanta que nada fique para trás',
              badge: 'Bagagem da Família',
              trailing: IconButton(
                icon: const Icon(Icons.refresh, color: MaceioColors.turquoisePrimary),
                onPressed: _loadData,
              ),
            ),
            Expanded(
              child: FutureBuilder<({List<PackingItem> items, PackingStats stats})>(
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
                          const Icon(Icons.luggage, size: 48, color: MaceioColors.error),
                          const SizedBox(height: 8),
                          Text('Erro ao carregar checklist', style: MaceioTypography.titleMedium),
                          const SizedBox(height: 8),
                          MaceioButton(label: 'Tentar Novamente', onPressed: _loadData),
                        ],
                      ),
                    );
                  }

                  final data = snapshot.data;
                  final items = data?.items ?? [];
                  final stats = data?.stats;

                  // Group items by category
                  final grouped = <String, List<PackingItem>>{};
                  for (final item in items) {
                    grouped.putIfAbsent(item.category, () => []).add(item);
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      // Progress Card
                      MaceioCard(
                        backgroundColor: MaceioColors.palmGreen,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PROGRESSO DA MALA',
                                  style: MaceioTypography.caption.copyWith(color: Colors.white70),
                                ),
                                Text(
                                  '${stats?.packedCount ?? 0} de ${stats?.totalCount ?? 0} prontos',
                                  style: MaceioTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${stats?.progressPercentage ?? 0}% Organizado',
                              style: MaceioTypography.titleLarge.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: ((stats?.progressPercentage ?? 0) / 100).clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(MaceioColors.sunYellow),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: Text('Nenhum item na mala ainda.')),
                        )
                      else
                        ...grouped.entries.map((group) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                  child: Text(group.key, style: MaceioTypography.titleMedium),
                                ),
                                MaceioCard(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Column(
                                    children: group.value.map((item) {
                                      return ListTile(
                                        leading: Checkbox(
                                          activeColor: MaceioColors.turquoisePrimary,
                                          value: item.isPacked,
                                          onChanged: (_) async {
                                            await _service.togglePacked(item.id);
                                            _loadData();
                                          },
                                        ),
                                        title: Text(
                                          item.name,
                                          style: MaceioTypography.bodyLarge.copyWith(
                                            decoration: item.isPacked ? TextDecoration.lineThrough : null,
                                            color: item.isPacked ? MaceioColors.textMuted : MaceioColors.textPrimary,
                                          ),
                                        ),
                                        subtitle: item.quantity > 1
                                            ? Text('Quantidade: ${item.quantity}', style: MaceioTypography.caption)
                                            : null,
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, size: 18, color: MaceioColors.turquoiseDark),
                                              tooltip: 'Editar',
                                              onPressed: () => _showPackingItemModal(itemToEdit: item),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 18, color: MaceioColors.error),
                                              tooltip: 'Excluir',
                                              onPressed: () => _confirmDeleteItem(item),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 80),
                    ],
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
