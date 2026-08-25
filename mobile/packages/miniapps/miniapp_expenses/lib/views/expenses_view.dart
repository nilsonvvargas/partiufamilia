import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpensesView extends StatefulWidget {
  const ExpensesView({super.key});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  final ExpenseService _service = ExpenseService();
  late Future<({List<ExpenseItem> items, ExpensesSummary summary})> _future;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _future = _service.getExpenses();
    });
  }

  void _showExpenseModal({ExpenseItem? itemToEdit}) {
    final isEditing = itemToEdit != null;
    final titleController = TextEditingController(text: itemToEdit?.title ?? '');
    final amountController = TextEditingController(text: itemToEdit != null ? itemToEdit.amount.toString() : '');
    final paidByController = TextEditingController(text: itemToEdit?.paidBy ?? (TripContext.instance.currentUser?.name ?? 'Nilson'));
    String selectedCategory = itemToEdit?.category ?? 'Alimentação';
    final categories = ['Passeio', 'Alimentação', 'Transporte', 'Hospedagem', 'Compras'];

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
                        backgroundColor: MaceioColors.coralLight,
                        child: Icon(
                          isEditing ? Icons.edit : Icons.attach_money,
                          color: MaceioColors.coralAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Editar Despesa' : 'Novo Gasto na Viagem',
                              style: MaceioTypography.titleLarge,
                            ),
                            Text(
                              isEditing ? 'Atualize o valor ou categoria' : 'Registre despesas e divisão da família',
                              style: MaceioTypography.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Descrição (ex: Almoço no Janga)',
                      prefixIcon: const Icon(Icons.description_outlined, color: MaceioColors.turquoisePrimary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Valor (R\$)',
                            prefixText: 'R\$ ',
                            prefixIcon: const Icon(Icons.payments_outlined, color: MaceioColors.turquoisePrimary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: paidByController,
                    decoration: InputDecoration(
                      labelText: 'Quem Pagou?',
                      hintText: 'Ex: Nilson',
                      prefixIcon: const Icon(Icons.person_outline, color: MaceioColors.turquoisePrimary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: MaceioButton(
                      label: isEditing ? 'Salvar Alterações' : 'Salvar Despesa',
                      icon: isEditing ? Icons.save : Icons.add_circle_outline,
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
                        final paidBy = paidByController.text.trim().isNotEmpty ? paidByController.text.trim() : 'Nilson';

                        if (title.isNotEmpty && amount > 0) {
                          Navigator.pop(context);
                          if (isEditing) {
                            await _service.updateExpense(
                              id: itemToEdit.id,
                              title: title,
                              amount: amount,
                              category: selectedCategory,
                              paidBy: paidBy,
                            );
                          } else {
                            await _service.addExpense(
                              title: title,
                              amount: amount,
                              category: selectedCategory,
                              paidBy: paidBy,
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

  void _confirmDeleteExpense(ExpenseItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Despesa?'),
          content: Text('Deseja realmente excluir "${item.title}" (R\$ ${item.amount.toStringAsFixed(2)})?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: MaceioColors.error),
              onPressed: () async {
                Navigator.pop(context);
                await _service.deleteExpense(item.id);
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
        backgroundColor: MaceioColors.coralAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova Despesa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showExpenseModal(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MaceioHeader(
              title: activeTrip != null ? 'Gastos • ${activeTrip.destination}' : 'Gastos & Divisão',
              subtitle: 'Controle de custos da família em tempo real',
              badge: 'Orçamento da Viagem',
              trailing: IconButton(
                icon: const Icon(Icons.refresh, color: MaceioColors.turquoisePrimary),
                onPressed: _loadData,
              ),
            ),
            Expanded(
              child: FutureBuilder<({List<ExpenseItem> items, ExpensesSummary summary})>(
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
                          const Icon(Icons.error_outline, size: 48, color: MaceioColors.error),
                          const SizedBox(height: 8),
                          Text('Erro ao carregar despesas', style: MaceioTypography.titleMedium),
                          const SizedBox(height: 8),
                          MaceioButton(label: 'Tentar Novamente', onPressed: _loadData),
                        ],
                      ),
                    );
                  }

                  final data = snapshot.data;
                  final items = data?.items ?? [];
                  final summary = data?.summary;

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      // Total Spent Card
                      MaceioCard(
                        backgroundColor: MaceioColors.oceanDeep,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL GASTO NA VIAGEM',
                              style: MaceioTypography.caption.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'R\$ ${(summary?.totalAmount ?? 0).toStringAsFixed(2)}',
                              style: MaceioTypography.display.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: (summary?.byCategory.entries ?? []).map((e) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${e.key}: R\$ ${e.value.toStringAsFixed(0)}',
                                    style: MaceioTypography.caption.copyWith(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text('Histórico de Lançamentos', style: MaceioTypography.titleMedium),
                      const SizedBox(height: 12),

                      if (items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: Text('Nenhuma despesa registrada ainda.')),
                        )
                      else
                        ...items.map((item) {
                          return Dismissible(
                            key: Key(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: MaceioColors.error,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              _service.deleteExpense(item.id);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: MaceioCard(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(item.category).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(item.category),
                                        color: _getCategoryColor(item.category),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.title, style: MaceioTypography.titleMedium),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${item.category} • Pago por ${item.paidBy}',
                                            style: MaceioTypography.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'R\$ ${item.amount.toStringAsFixed(2)}',
                                          style: MaceioTypography.titleMedium.copyWith(
                                            color: MaceioColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () => _showExpenseModal(itemToEdit: item),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Icon(Icons.edit_outlined, size: 16, color: MaceioColors.turquoiseDark),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            InkWell(
                                              onTap: () => _confirmDeleteExpense(item),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Icon(Icons.delete_outline, size: 16, color: MaceioColors.error),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Passeio':
        return Icons.sailing;
      case 'Alimentação':
        return Icons.restaurant;
      case 'Transporte':
        return Icons.directions_car;
      case 'Hospedagem':
        return Icons.hotel;
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Passeio':
        return MaceioColors.turquoisePrimary;
      case 'Alimentação':
        return MaceioColors.coralAccent;
      case 'Transporte':
        return MaceioColors.oceanDeep;
      case 'Hospedagem':
        return MaceioColors.palmGreen;
      default:
        return MaceioColors.sunYellow;
    }
  }
}
