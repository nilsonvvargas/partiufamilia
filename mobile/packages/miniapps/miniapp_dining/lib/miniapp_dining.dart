import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'services/dining_service.dart';
import 'views/dining_view.dart';

class DiningMiniApp implements MiniAppContract {
  @override
  String get id => 'dining';

  @override
  String get title => 'Jantares';

  @override
  IconData get icon => Icons.restaurant;

  @override
  String get rootRoute => '/dining';

  @override
  Future<void> initialize() async {
    ServiceLocator.instance.register<DiningService>(DiningService());
  }

  @override
  Widget buildMainView(BuildContext context) {
    return const DiningView();
  }

  @override
  Map<String, WidgetBuilder> get routes => {
        '/dining': (context) => const DiningView(),
      };
}
