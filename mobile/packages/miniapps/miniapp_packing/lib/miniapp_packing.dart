import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'services/packing_service.dart';
import 'views/packing_view.dart';

class PackingMiniApp implements MiniAppContract {
  @override
  String get id => 'packing';

  @override
  String get title => 'Mala';

  @override
  IconData get icon => Icons.luggage_outlined;

  @override
  String get rootRoute => '/packing';

  @override
  Future<void> initialize() async {
    ServiceLocator.instance.register<PackingService>(PackingService());
  }

  @override
  Widget buildMainView(BuildContext context) {
    return const PackingView();
  }

  @override
  Map<String, WidgetBuilder> get routes => {
        '/packing': (context) => const PackingView(),
      };
}
