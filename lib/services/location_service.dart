import 'package:url_launcher/url_launcher.dart';

class LocationService {
  static final String dealershipUrl = 'https://maps.app.goo.gl/kLn1iRaeocKnokEb8?g_st=ac';

  static Future<void> openDealershipLocation() async {
    final uri = Uri.parse(dealershipUrl);

    try {
      if (await canLaunchUrl(uri)) {

        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {

        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {

      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }
}