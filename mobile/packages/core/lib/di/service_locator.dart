import 'package:core/contracts/miniapp_contract.dart';
import 'package:core/network/bff_client.dart';

class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};
  final List<MiniAppContract> _registeredMiniApps = [];

  void register<T>(T service) {
    _services[T] = service;
  }

  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Serviço do tipo $T não registrado no ServiceLocator.');
    }
    return service as T;
  }

  void registerMiniApp(MiniAppContract miniApp) {
    if (!_registeredMiniApps.any((m) => m.id == miniApp.id)) {
      _registeredMiniApps.add(miniApp);
    }
  }

  List<MiniAppContract> get registeredMiniApps => List.unmodifiable(_registeredMiniApps);

  MiniAppContract? getMiniAppById(String id) {
    try {
      return _registeredMiniApps.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
