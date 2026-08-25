import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareUtils {
  static Future<bool> openWhatsApp(String text) async {
    final encoded = Uri.encodeComponent(text);
    final whatsappUrl = Uri.parse('https://wa.me/?text=$encoded');

    try {
      return await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      try {
        return await launchUrl(whatsappUrl);
      } catch (_) {
        return false;
      }
    }
  }

  static void copyToClipboard(BuildContext context, String text, {String feedbackMessage = 'Copiado para a área de transferência!'}) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(feedbackMessage),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
