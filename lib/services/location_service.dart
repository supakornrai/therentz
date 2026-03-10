import 'package:url_launcher/url_launcher.dart';

class LocationService {

  static double dealershipLat = 13.8774;
  static double dealershipLng = 100.5967;

  static Future<void> openDealershipLocation() async {
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$dealershipLat,$dealershipLng');
    final appleMapsUrl = Uri.parse('https://maps.apple.com/?q=$dealershipLat,$dealershipLng');
    final googleMapsScheme = Uri.parse('comgooglemaps://?q=$dealershipLat,$dealershipLng');
    final geoScheme = Uri.parse('geo:$dealershipLat,$dealershipLng');

    try {
      if (await canLaunchUrl(googleMapsScheme)) {
        await launchUrl(googleMapsScheme);
      } else if (await canLaunchUrl(geoScheme)) {
        await launchUrl(geoScheme);
      } else if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        // Last resort: try to launch the URL directly without canLaunchUrl check
        // because canLaunchUrl can be unreliable on some devices/emulators
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // If everything fails, try to launch in-app browser or just log the error
      try {
        await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
      } catch (e) {
        rethrow;
      }
    }
  }
}