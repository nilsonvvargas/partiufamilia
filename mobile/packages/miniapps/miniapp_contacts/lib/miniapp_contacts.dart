import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'services/contact_service.dart';
import 'views/contacts_view.dart';

class ContactsMiniApp implements MiniAppContract {
  @override
  String get id => 'contacts';

  @override
  String get title => 'Contatos';

  @override
  IconData get icon => Icons.people_outline;

  @override
  String get rootRoute => '/contacts';

  @override
  Future<void> initialize() async {
    ServiceLocator.instance.register<ContactService>(ContactService());
  }

  @override
  Widget buildMainView(BuildContext context) {
    return const ContactsView();
  }

  @override
  Map<String, WidgetBuilder> get routes => {
        '/contacts': (context) => const ContactsView(),
      };
}
