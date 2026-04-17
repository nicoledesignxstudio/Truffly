import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final sellerStripeOnboardingLauncherProvider =
    Provider<SellerStripeOnboardingLauncher>((ref) {
      return const SellerStripeOnboardingLauncher();
    });

class SellerStripeOnboardingLauncher {
  const SellerStripeOnboardingLauncher();

  Future<bool> openOnboarding(Uri uri) async {
    if (uri.scheme != 'https' && uri.scheme != 'http') {
      return false;
    }

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
