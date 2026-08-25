import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'services/expense_service.dart';
import 'views/expenses_view.dart';

class ExpensesMiniApp implements MiniAppContract {
  @override
  String get id => 'expenses';

  @override
  String get title => 'Gastos';

  @override
  IconData get icon => Icons.attach_money;

  @override
  String get rootRoute => '/expenses';

  @override
  Future<void> initialize() async {
    ServiceLocator.instance.register<ExpenseService>(ExpenseService());
  }

  @override
  Widget buildMainView(BuildContext context) {
    return const ExpensesView();
  }

  @override
  Map<String, WidgetBuilder> get routes => {
        '/expenses': (context) => const ExpensesView(),
      };
}
