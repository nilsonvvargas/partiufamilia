import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';

// Import MiniApps
import 'package:miniapp_itinerary/miniapp_itinerary.dart';
import 'package:miniapp_expenses/miniapp_expenses.dart';
import 'package:miniapp_dining/miniapp_dining.dart';
import 'package:miniapp_stay/miniapp_stay.dart';
import 'package:miniapp_packing/miniapp_packing.dart';
import 'package:miniapp_contacts/miniapp_contacts.dart';

import 'views/login_view.dart';
import 'views/trips_list_view.dart';
import 'views/home_dashboard_view.dart';

import 'package:flutter/foundation.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializa Core & BFF Client com detecção dinâmica (Produção HTTPS / Rede Local / Dev)
  String baseUrl = 'http://localhost:3001';
  if (kIsWeb) {
    final uri = Uri.base;
    if (uri.scheme == 'https' || uri.host.contains('vercel.app')) {
      // Produção na Nuvem (Vercel HTTPS): mesma origem segura
      baseUrl = '${uri.scheme}://${uri.host}';
    } else if (uri.host.isNotEmpty && uri.host != 'localhost') {
      // Rede Local / Celular no Wi-Fi
      baseUrl = 'http://${uri.host}:3001';
    } else {
      // Localhost
      baseUrl = 'http://localhost:3001';
    }
  } else {
    baseUrl = 'http://192.168.15.49:3001';
  }

  final bffClient = BffClient(baseUrl: baseUrl);
  ServiceLocator.instance.register<BffClient>(bffClient);

  // 2. Registro dos MiniApps na arquitetura modular
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

  runApp(const FamiliaPartiuApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class FamiliaPartiuApp extends StatelessWidget {
  const FamiliaPartiuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Família Partiu!',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: MaceioColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: MaceioColors.turquoisePrimary,
          primary: MaceioColors.turquoisePrimary,
          secondary: MaceioColors.coralAccent,
          surface: MaceioColors.surface,
        ),
      ),
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserModel?>(
      valueListenable: TripContext.instance.currentUserNotifier,
      builder: (context, user, _) {
        if (user == null) {
          return LoginView(
            onLoginSuccess: () => setState(() {}),
          );
        }

        return ValueListenableBuilder<TripModel?>(
          valueListenable: TripContext.instance.activeTripNotifier,
          builder: (context, activeTrip, _) {
            if (activeTrip == null) {
              return TripsListView(
                onSelectTrip: (trip) => setState(() {}),
                onLogout: () {
                  TripContext.instance.logout();
                  setState(() {});
                },
              );
            }

            return TripShell(
              activeTrip: activeTrip,
              onBackToTrips: () {
                TripContext.instance.activeTrip = null;
                setState(() {});
              },
            );
          },
        );
      },
    );
  }
}

class TripShell extends StatefulWidget {
  final TripModel activeTrip;
  final VoidCallback onBackToTrips;

  const TripShell({
    super.key,
    required this.activeTrip,
    required this.onBackToTrips,
  });

  @override
  State<TripShell> createState() => _TripShellState();
}

class _TripShellState extends State<TripShell> {
  int _currentIndex = 0;
  int _tabKey = 0;

  void _onSelectTab(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 0) {
        _tabKey++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final registeredApps = ServiceLocator.instance.registeredMiniApps;

    final List<Widget> pages = [
      HomeDashboardView(
        key: ValueKey('dashboard-${widget.activeTrip.id}-$_tabKey'),
        onNavigateToTab: _onSelectTab,
        onBackToTrips: widget.onBackToTrips,
      ),
      ...registeredApps.map((app) => app.buildMainView(context)),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onSelectTab,
        backgroundColor: MaceioColors.surface,
        indicatorColor: MaceioColors.oceanLight,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: MaceioColors.turquoiseDark),
            label: 'Início',
          ),
          ...registeredApps.map((app) {
            return NavigationDestination(
              icon: Icon(app.icon),
              selectedIcon: Icon(app.icon, color: MaceioColors.turquoiseDark),
              label: app.title,
            );
          }),
        ],
      ),
    );
  }
}
