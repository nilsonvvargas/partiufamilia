import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:app_host/main.dart';
import 'package:miniapp_itinerary/miniapp_itinerary.dart';
import 'package:miniapp_expenses/miniapp_expenses.dart';
import 'package:miniapp_dining/miniapp_dining.dart';
import 'package:miniapp_stay/miniapp_stay.dart';
import 'package:miniapp_packing/miniapp_packing.dart';
import 'package:miniapp_contacts/miniapp_contacts.dart';

void main() {
  setUpAll(() async {
    final bffClient = BffClient(baseUrl: 'http://localhost:3001');
    ServiceLocator.instance.register<BffClient>(bffClient);

    final miniapps = <MiniAppContract>[
      ItineraryMiniApp(),
      ExpensesMiniApp(),
      DiningMiniApp(),
      StayMiniApp(),
      PackingMiniApp(),
      ContactsMiniApp(),
    ];

    for (final app in miniapps) {
      ServiceLocator.instance.registerMiniApp(app);
      await app.initialize();
    }
  });

  testWidgets('App smoke test e inicialização do Família Partiu', (WidgetTester tester) async {
    await tester.pumpWidget(const FamiliaPartiuApp());
    expect(find.byType(FamiliaPartiuApp), findsOneWidget);
    expect(ServiceLocator.instance.registeredMiniApps.length, 6);
  });
}
