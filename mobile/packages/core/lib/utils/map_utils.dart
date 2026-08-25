import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  static Future<bool> openGoogleMaps(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return false;

    final encoded = Uri.encodeComponent(trimmed);
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');

    try {
      return await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      try {
        return await launchUrl(googleMapsUrl);
      } catch (_) {
        return false;
      }
    }
  }
}
