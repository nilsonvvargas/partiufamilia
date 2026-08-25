import 'package:flutter/widgets.dart';

/// Contrato padronizado que cada MiniApp deve implementar
abstract class MiniAppContract {
  /// Identificador único do miniapp (ex: 'itinerary', 'expenses')
  String get id;

  /// Título legível para exibição em menus e barras
  String get title;

  /// Ícone representativo do miniapp
  IconData get icon;

  /// Rota raiz do miniapp
  String get rootRoute;

  /// Inicialização de serviços e injeção de dependências do módulo
  Future<void> initialize();

  /// Cria o widget principal / tela raiz do miniapp
  Widget buildMainView(BuildContext context);

  /// Mapa de sub-rotas providas pelo miniapp
  Map<String, WidgetBuilder> get routes;
}
