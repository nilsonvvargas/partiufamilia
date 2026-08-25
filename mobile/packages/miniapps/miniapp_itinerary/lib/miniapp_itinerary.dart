import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'services/itinerary_service.dart';
import 'views/itinerary_view.dart';

class ItineraryMiniApp implements MiniAppContract {
  @override
  String get id => 'itinerary';

  @override
  String get title => 'Roteiro';

  @override
  IconData get icon => Icons.map_outlined;

  @override
  String get rootRoute => '/itinerary';

  @override
  Future<void> initialize() async {
    ServiceLocator.instance.register<ItineraryService>(ItineraryService());
  }

  @override
  Widget buildMainView(BuildContext context) {
    return const ItineraryView();
  }

  @override
  Map<String, WidgetBuilder> get routes => {
        '/itinerary': (context) => const ItineraryView(),
      };
}
