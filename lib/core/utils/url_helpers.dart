import 'package:lumina/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlHelpers {
  UrlHelpers._();

  static Future<bool> launchUrlSafe(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static Future<bool> launchWhatsApp({String? message}) {
    final text = Uri.encodeComponent(
      message ??
          'السلام عليكم بشمهندس حسام — عايز أسجّل في الجلسة الافتتاحية في البرمجة.',
    );
    return launchUrlSafe(
      'https://wa.me/${AppConstants.instructorWhatsApp}?text=$text',
    );
  }

  static Future<bool> launchEmail({String? subject, String? body}) {
    final s = Uri.encodeComponent(
      subject ?? 'استفسار عن الجلسة الافتتاحية في البرمجة',
    );
    final b = Uri.encodeComponent(body ?? '');
    return launchUrlSafe(
      'mailto:${AppConstants.instructorEmail}?subject=$s&body=$b',
    );
  }

  static Future<bool> launchLinkedIn() =>
      launchUrlSafe(AppConstants.instructorLinkedIn);
  static Future<bool> launchFacebook() =>
      launchUrlSafe(AppConstants.instructorFacebook);
}
