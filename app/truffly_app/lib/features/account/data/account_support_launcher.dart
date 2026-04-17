import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

const supportEmailAddress = 'support@truffly.com';

final accountSupportLauncherProvider = Provider<AccountSupportLauncher>((ref) {
  return const AccountSupportLauncher();
});

class AccountSupportLauncher {
  const AccountSupportLauncher();

  Future<bool> composeSupportEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmailAddress,
      queryParameters: const {
        'subject': 'Truffly support',
      },
    );

    if (!await canLaunchUrl(uri)) {
      return false;
    }

    return launchUrl(uri);
  }
}
