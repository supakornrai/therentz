import 'package:url_launcher/url_launcher.dart';

class LocationService {
  // ลิงก์แผนที่ของร้าน
  static const String dealershipUrl = 'https://maps.app.goo.gl/kLn1iRaeocKnokEb8?g_st=ac';

  // ฟังก์ชันสำหรับเปิดแผนที่ไปยังตำแหน่งร้าน
  static Future<void> openDealershipLocation() async {
    final uri = Uri.parse(dealershipUrl);

    try {
      if (await canLaunchUrl(uri)) {
        // เปิดด้วยแอปแผนที่ในเครื่อง
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // เปิดผ่านเบราว์เซอร์หากไม่มีแอปแผนที่
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      // แผนสำรองสุดท้าย: เปิดภายในแอป
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }
}