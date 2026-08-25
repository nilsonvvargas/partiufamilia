import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';

class DebtSettlement {
  final String from;
  final String to;
  final double amount;
  final String pixKey;

  DebtSettlement({
    required this.from,
    required this.to,
    required this.amount,
    required this.pixKey,
  });
}

class ExpensesView extends StatefulWidget {
  const ExpensesView({super.key});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> with SingleTickerProviderStateMixin {
  final ExpenseService _service = ExpenseService();
  late Future<({List<ExpenseItem> items, ExpensesSummary summary})> _future;
  late TabController _tabController;

  final List<String> _defaultMembers = ['Nilson', 'Patrícia', 'Lucas', 'Mariana'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _future = _service.getExpenses();
    });
  }

  List<DebtSettlement> _calculateSettlements(List<ExpenseItem> items) {
    if (items.isEmpty) return [];

    final balances = <String, double>{};
    for (final m in _defaultMembers) {
      balances[m] = 0.0;
    }

    for (final exp in items) {
      final payer = exp.paidBy;
      final splits = exp.splitWith.isEmpty ? [payer] : exp.splitWith;
      final splitAmount = exp.amount / splits.length;

      balances[payer] = (balances[payer] ?? 0.0) + exp.amount;

      for (final person in splits) {
        balances[person] = (balances[person] ?? 0.0) - splitAmount;
      }
    }

    final debtors = <MapEntry<String, double>>[];
    final creditors = <MapEntry<String, double>>[];

    balances.forEach((person, balance) {
      if (balance < -0.01) {
        debtors.add(MapEntry(person, -balance));
      } else if (balance > 0.01) {
        creditors.add(MapEntry(person, balance));
      }
    });

    final settlements = <DebtSettlement>[];
    int dIdx = 0;
    int cIdx = 0;

    while (dIdx < debtors.length && cIdx < creditors.length) {
      final debtor = debtors[dIdx].key;
      final dAmount = debtors[dIdx].value;

      final creditor = creditors[cIdx].key;
      final cAmount = creditors[cIdx].value;

      final settledAmount = dAmount < cAmount ? dAmount : cAmount;
      if (settledAmount > 0.01) {
        settlements.add(DebtSettlement(
          from: debtor,
          to: creditor,
          amount: settledAmount,
          pixKey: '${creditor.toLowerCase()}@partiufamilia.com.br',
        ));
      }

      if (dAmount < cAmount) {
        creditors[cIdx] = MapEntry(creditor, cAmount - settledAmount);
        dIdx++;
      } else if (dAmount > cAmount) {
        debtors[dIdx] = MapEntry(debtor, dAmount - settledAmount);
        cIdx++;
      } else {
        dIdx++;
        cIdx++;
      }
    }

    return settlements;
  }

  void _showExpenseModal({ExpenseItem? itemToEdit}) {
    AppHaptics.selection();
    final isEditing = itemToEdit != null;
    final titleController = TextEditingController(text: itemToEdit?.title ?? '');
    final amountController = TextEditingController(text: itemToEdit != null ? itemToEdit.amount.toString() : '');
    String selectedPaidBy = itemToEdit?.paidBy ?? 'Nilson';
    String selectedCategory = itemToEdit?.category ?? 'Alimentação';
    List<String> selectedSplits = List<String>.from(itemToEdit?.splitWith ?? _defaultMembers);

    final categories = ['Passeio', 'Alimentação', 'Transporte', 'Hospedagem', 'Compras', 'Outros'];

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
                                isEditing ? 'Atualize o valor ou rateio' : 'Defina quem pagou e como será dividido',
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
                        labelText: 'Descrição (ex: Almoço no Janga, Barco)',
                        prefixIcon: const Icon(Icons.description_outlined, color: MaceioColors.coralAccent),
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
                              labelText: 'Valor Total',
                              prefixText: 'R\$ ',
                              prefixIcon: const Icon(Icons.payments_outlined, color: MaceioColors.coralAccent),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
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
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _defaultMembers.contains(selectedPaidBy) ? selectedPaidBy : _defaultMembers.first,
                      decoration: InputDecoration(
                        labelText: 'Quem pagou essa conta?',
                        prefixIcon: const Icon(Icons.person, color: MaceioColors.turquoiseDark),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _defaultMembers.map((m) => DropdownMenuItem(value: m, child: Text('$m (Pagador)'))).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedPaidBy = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    Text('Dividir esta despesa entre:', style: MaceioTypography.titleMedium.copyWith(fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _defaultMembers.map((m) {
                        final isIncluded = selectedSplits.contains(m);
                        return FilterChip(
                          label: Text(m),
                          selected: isIncluded,
                          selectedColor: MaceioColors.coralLight,
                          checkmarkColor: MaceioColors.coralAccent,
                          labelStyle: TextStyle(
                            color: isIncluded ? MaceioColors.coralAccent : MaceioColors.textPrimary,
                            fontWeight: isIncluded ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                selectedSplits.add(m);
                              } else {
                                if (selectedSplits.length > 1) {
                                  selectedSplits.remove(m);
                                }
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: MaceioButton(
                        label: isEditing ? 'Salvar Alterações' : 'Salvar Despesa',
                        icon: isEditing ? Icons.save : Icons.add_circle_outline,
                        customColor: MaceioColors.coralAccent,
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;

                          if (title.isNotEmpty && amount > 0) {
                            Navigator.pop(context);
                            if (isEditing) {
                              await _service.updateExpense(
                                id: itemToEdit.id,
                                title: title,
                                amount: amount,
                                category: selectedCategory,
                                paidBy: selectedPaidBy,
                                splitWith: selectedSplits,
                              );
                            } else {
                              await _service.addExpense(
                                title: title,
                                amount: amount,
                                category: selectedCategory,
                                paidBy: selectedPaidBy,
                                splitWith: selectedSplits,
                              );
                            }
                            _loadData();
                          }
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

  void _confirmDeleteExpense(ExpenseItem item) {
    AppHaptics.light();
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
                AppHaptics.medium();
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
    final budget = activeTrip?.budget ?? 3500.0;

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
              subtitle: 'Rateio justo e controle em tempo real',
              badge: 'Splitwise Integrado',
              trailing: IconButton(
                icon: const Icon(Icons.refresh, color: MaceioColors.turquoisePrimary),
                onPressed: _loadData,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: MaceioColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: MaceioColors.coralAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: MaceioColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                onTap: (_) => AppHaptics.selection(),
                tabs: const [
                  Tab(text: 'Extrato de Gastos 📝'),
                  Tab(text: 'Rateio & PIX 💸'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<({List<ExpenseItem> items, ExpensesSummary summary})>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: MaceioColors.coralAccent));
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
                  final totalSpent = summary?.totalAmount ?? 0.0;
                  final budgetPercentage = ((totalSpent / budget) * 100).round();
                  final settlements = _calculateSettlements(items);

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: [
                          MaceioCard(
                            backgroundColor: MaceioColors.oceanDeep,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'TOTAL GASTO NA VIAGEM',
                                      style: MaceioTypography.caption.copyWith(color: Colors.white70),
                                    ),
                                    Text(
                                      'Orçamento: R\$ ${budget.toStringAsFixed(0)}',
                                      style: MaceioTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'R\$ ${totalSpent.toStringAsFixed(2)}',
                                  style: MaceioTypography.display.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: (totalSpent / budget).clamp(0.0, 1.0),
                                    minHeight: 6,
                                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      totalSpent > budget ? MaceioColors.error : MaceioColors.sunYellow,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$budgetPercentage% do orçamento estimado utilizado',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
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
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Lançamentos da Família', style: MaceioTypography.titleMedium),
                          const SizedBox(height: 8),
                          if (items.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(child: Text('Nenhuma despesa registrada ainda.')),
                            )
                          else
                            ...items.map((item) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: MaceioCard(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: MaceioColors.coralLight,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.receipt_long, color: MaceioColors.coralAccent, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.title, style: MaceioTypography.titleMedium.copyWith(fontSize: 14)),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Text(
                                                  'Pago por ${item.paidBy}',
                                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: MaceioColors.oceanDeep),
                                                ),
                                                const SizedBox(width: 6),
                                                Text('• ${item.splitWith.length} pessoas', style: MaceioTypography.caption),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'R\$ ${item.amount.toStringAsFixed(2)}',
                                            style: MaceioTypography.titleMedium.copyWith(color: MaceioColors.textPrimary),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined, size: 16, color: MaceioColors.turquoiseDark),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                onPressed: () => _showExpenseModal(itemToEdit: item),
                                              ),
                                              const SizedBox(width: 10),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, size: 16, color: MaceioColors.error),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                onPressed: () => _confirmDeleteExpense(item),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          const SizedBox(height: 80),
                        ],
                      ),
                      ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [MaceioColors.turquoiseDark, MaceioColors.oceanDeep],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                const Text('⚖️', style: TextStyle(fontSize: 32)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Balanço Inteligente de Divisão',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Cálculo líquido automático de quem deve a quem para quitar a viagem com 1 PIX.',
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text('Liquidação Pendente (${settlements.length})', style: MaceioTypography.titleMedium),
                          const SizedBox(height: 8),
                          if (settlements.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(32),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  const Icon(Icons.check_circle_outline, size: 48, color: MaceioColors.success),
                                  const SizedBox(height: 10),
                                  Text('Tudo Quitado! 🎉', style: MaceioTypography.titleMedium),
                                  const SizedBox(height: 4),
                                  Text('Ninguém deve nada a ninguém no momento.', style: MaceioTypography.caption),
                                ],
                              ),
                            )
                          else
                            ...settlements.map((s) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: MaceioCard(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: MaceioColors.coralLight,
                                            child: Text(s.from[0], style: const TextStyle(fontWeight: FontWeight.bold, color: MaceioColors.coralAccent)),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    style: TextStyle(color: MaceioColors.textPrimary, fontSize: 14),
                                                    children: [
                                                      TextSpan(text: s.from, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                      const TextSpan(text: ' deve pagar para '),
                                                      TextSpan(text: s.to, style: const TextStyle(fontWeight: FontWeight.bold, color: MaceioColors.turquoiseDark)),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text('Chave: ${s.pixKey}', style: MaceioTypography.caption),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'R\$ ${s.amount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: MaceioColors.coralAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: MaceioColors.turquoisePrimary,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                              ),
                                              icon: const Icon(Icons.copy, size: 16),
                                              label: const Text('Copiar Chave PIX', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                              onPressed: () {
                                                AppHaptics.medium();
                                                Clipboard.setData(ClipboardData(text: s.pixKey));
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Chave PIX de ${s.to} copiada! (R\$ ${s.amount.toStringAsFixed(2)})'),
                                                    backgroundColor: MaceioColors.turquoiseDark,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          const SizedBox(height: 80),
                        ],
                      ),
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
