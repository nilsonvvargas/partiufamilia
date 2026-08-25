import 'package:url_launcher/url_launcher.dart';

class ContactLauncherUtils {
  static Future<bool> openWhatsApp({required String phoneOrNumber, String? text}) async {
    final clean = phoneOrNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return false;

    final number = clean.startsWith('55') ? clean : '55$clean';
    final messageParam = text != null && text.isNotEmpty ? '?text=${Uri.encodeComponent(text)}' : '';
    final uri = Uri.parse('https://wa.me/$number$messageParam');

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        return await launchUrl(uri);
      } catch (_) {
        return false;
      }
    }
  }

  static Future<bool> makePhoneCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) return false;

    final uri = Uri.parse('tel:$clean');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
