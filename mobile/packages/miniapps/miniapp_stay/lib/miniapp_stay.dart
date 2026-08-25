import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'services/stay_service.dart';
import 'views/stay_view.dart';

class StayMiniApp implements MiniAppContract {
  @override
  String get id => 'stay';

  @override
  String get title => 'Estadia';

  @override
  IconData get icon => Icons.hotel_outlined;

  @override
  String get rootRoute => '/stay';

  @override
  Future<void> initialize() async {
    ServiceLocator.instance.register<StayService>(StayService());
  }

  @override
  Widget buildMainView(BuildContext context) {
    return const StayView();
  }

  @override
  Map<String, WidgetBuilder> get routes => {
        '/stay': (context) => const StayView(),
      };
}
