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
  String _selectedMemberFilter = 'Todos';

  final List<String> _familyMembers = [
    'Todos',
    'Adultos',
    'Crianças',
    'Bebê',
    'Pet',
    'Geral / Farmácia',
  ];

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

  void _showTemplatesModal() {
    AppHaptics.selection();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 14),
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: MaceioColors.oceanLight,
                    child: Icon(Icons.auto_awesome, color: MaceioColors.turquoiseDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sugestões Inteligentes de Mala 🌴', style: MaceioTypography.titleLarge),
                        Text('Adicione kits essenciais com 1 clique', style: MaceioTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildTemplateOption(
                title: 'Kit Praia & Sol Essencial',
                subtitle: 'Protetor solar, óculos UV, sapatilha aquática, bolsa estanque',
                icon: Icons.beach_access,
                color: MaceioColors.turquoisePrimary,
                onAdd: () async {
                  Navigator.pop(context);
                  await _service.addItem(name: 'Protetor Solar FPS 50+', category: 'Praia & Sol', member: 'Todos', quantity: 2);
                  await _service.addItem(name: 'Sapatilha Aquática de Neoprene', category: 'Praia & Sol', member: 'Adultos', quantity: 2);
                  await _service.addItem(name: 'Bolsa Estanque Celular', category: 'Praia & Sol', member: 'Todos', quantity: 2);
                  _loadData();
                },
              ),
              const SizedBox(height: 10),
              _buildTemplateOption(
                title: 'Kit Farmácia da Família 💊',
                subtitle: 'Dramin, antialérgico, dipirona, curativos e repelente',
                icon: Icons.medical_services,
                color: MaceioColors.coralAccent,
                onAdd: () async {
                  Navigator.pop(context);
                  await _service.addItem(name: 'Dramin / Enjoo para barco', category: 'Farmácia', member: 'Geral / Farmácia', quantity: 1);
                  await _service.addItem(name: 'Repelente & Pós-Sol Aloe Vera', category: 'Farmácia', member: 'Geral / Farmácia', quantity: 1);
                  await _service.addItem(name: 'Kit Curativos e Antisséptico', category: 'Farmácia', member: 'Geral / Farmácia', quantity: 1);
                  _loadData();
                },
              ),
              const SizedBox(height: 10),
              _buildTemplateOption(
                title: 'Kit Criança & Bebê 👶',
                subtitle: 'Boia de braço, fraldas de piscina, chapéu UV e talco',
                icon: Icons.child_care,
                color: MaceioColors.palmGreen,
                onAdd: () async {
                  Navigator.pop(context);
                  await _service.addItem(name: 'Boia de Braço / Colete Infantil', category: 'Praia & Sol', member: 'Crianças', quantity: 1);
                  await _service.addItem(name: 'Fraldas Aquáticas para Piscina', category: 'Higiene', member: 'Bebê', quantity: 1);
                  await _service.addItem(name: 'Chapéu com Proteção Nuca UV', category: 'Roupas', member: 'Crianças', quantity: 2);
                  _loadData();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemplateOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onAdd,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: MaceioColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: MaceioTypography.titleMedium.copyWith(fontSize: 14)),
        subtitle: Text(subtitle, style: MaceioTypography.caption),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            AppHaptics.medium();
            onAdd();
          },
          child: const Text('Adicionar', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _showPackingItemModal({PackingItem? itemToEdit}) {
    AppHaptics.selection();
    final isEditing = itemToEdit != null;
    final nameController = TextEditingController(text: itemToEdit?.name ?? '');
    final quantityController = TextEditingController(text: itemToEdit?.quantity.toString() ?? '1');
    String selectedCategory = itemToEdit?.category ?? 'Praia & Sol';
    String selectedMember = itemToEdit?.member ?? (_selectedMemberFilter == 'Todos' ? 'Adultos' : _selectedMemberFilter);

    final categories = ['Praia & Sol', 'Roupas', 'Documentos', 'Farmácia', 'Eletrônicos', 'Higiene'];
    final members = ['Adultos', 'Crianças', 'Bebê', 'Pet', 'Geral / Farmácia', 'Todos'];

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
                              isEditing ? 'Atualize o responsável ou quantidade' : 'Defina de quem é e o que levar',
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
                        child: DropdownButtonFormField<String>(
                          value: members.contains(selectedMember) ? selectedMember : members.first,
                          decoration: InputDecoration(
                            labelText: 'De quem é?',
                            prefixIcon: const Icon(Icons.person_outline, size: 18),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: members.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedMember = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: categories.contains(selectedCategory) ? selectedCategory : categories.first,
                          decoration: InputDecoration(
                            labelText: 'Categoria',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedCategory = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantidade',
                      prefixIcon: const Icon(Icons.numbers, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
                              member: selectedMember,
                              quantity: qty,
                              isPacked: itemToEdit.isPacked,
                            );
                          } else {
                            await _service.addItem(
                              name: name,
                              category: selectedCategory,
                              member: selectedMember,
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
    AppHaptics.light();
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
                AppHaptics.medium();
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
              subtitle: 'Organização colaborativa da bagagem',
              badge: 'Mala Inteligente',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.auto_awesome, color: MaceioColors.turquoiseDark),
                    tooltip: 'Kits e Sugestões',
                    onPressed: _showTemplatesModal,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: MaceioColors.turquoisePrimary),
                    onPressed: _loadData,
                  ),
                ],
              ),
            ),

            // Seletor de Membro da Família (Horizontal Tabs)
            Container(
              height: 46,
              margin: const EdgeInsets.only(bottom: 6),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: _familyMembers.length,
                itemBuilder: (context, index) {
                  final member = _familyMembers[index];
                  final isSelected = _selectedMemberFilter == member;
                  return ChoiceChip(
                    label: Text(member),
                    selected: isSelected,
                    selectedColor: MaceioColors.palmGreen,
                    backgroundColor: MaceioColors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : MaceioColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? MaceioColors.palmGreen : MaceioColors.border,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        AppHaptics.selection();
                        setState(() {
                          _selectedMemberFilter = member;
                        });
                      }
                    },
                  );
                },
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
                  final allItems = data?.items ?? [];
                  
                  // Filter by member if not "Todos"
                  final filteredItems = _selectedMemberFilter == 'Todos'
                      ? allItems
                      : allItems.where((i) => i.member.toLowerCase() == _selectedMemberFilter.toLowerCase() || i.member == 'Todos').toList();

                  final memberPackedCount = filteredItems.filter((i) => i.isPacked).length;
                  final memberTotalCount = filteredItems.length;
                  final memberPercentage = memberTotalCount > 0 ? ((memberPackedCount / memberTotalCount) * 100).round() : 0;

                  // Group items by category
                  final grouped = <String, List<PackingItem>>{};
                  for (final item in filteredItems) {
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
                                  'PROGRESSO • $_selectedMemberFilter'.toUpperCase(),
                                  style: MaceioTypography.caption.copyWith(color: Colors.white70, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '$memberPackedCount de $memberTotalCount prontos',
                                  style: MaceioTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$memberPercentage% Pronto na Mala',
                              style: MaceioTypography.titleLarge.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: (memberPercentage / 100).clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(MaceioColors.sunYellow),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (filteredItems.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const Icon(Icons.luggage_outlined, size: 48, color: MaceioColors.textMuted),
                              const SizedBox(height: 12),
                              Text('Nenhum item para "$_selectedMemberFilter"', style: MaceioTypography.titleMedium),
                              const SizedBox(height: 6),
                              Text('Use o botão abaixo ou adicione sugestões inteligentes', style: MaceioTypography.caption, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              MaceioButton(
                                label: 'Ver Kits Prontos 🌴',
                                isSecondary: true,
                                icon: Icons.auto_awesome,
                                onPressed: _showTemplatesModal,
                              ),
                            ],
                          ),
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(group.key, style: MaceioTypography.titleMedium),
                                      Text('${group.value.length} itens', style: MaceioTypography.caption),
                                    ],
                                  ),
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
                                            AppHaptics.light();
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
                                        subtitle: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: MaceioColors.surfaceElevated,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                item.member,
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: MaceioColors.turquoiseDark),
                                              ),
                                            ),
                                            if (item.quantity > 1) ...[
                                              const SizedBox(width: 8),
                                              Text('Qtd: ${item.quantity}', style: MaceioTypography.caption),
                                            ],
                                          ],
                                        ),
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

