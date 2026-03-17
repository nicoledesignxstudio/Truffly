import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/truffle/data/publish_truffle_image_validation_service.dart';
import 'package:truffly_app/features/truffle/data/publish_truffle_service.dart';
import 'package:truffly_app/features/truffle/domain/seller_publish_access.dart';
import 'package:truffly_app/features/truffle/domain/seller_publish_gate_state.dart';

final publishTruffleServiceProvider = Provider<PublishTruffleService>((ref) {
  return PublishTruffleService(ref.read(supabaseClientProvider));
});

final publishTruffleImageValidationServiceProvider =
    Provider<PublishTruffleImageValidationService>((ref) {
      return PublishTruffleImageValidationService();
    });

final currentSellerPublishAccessProvider =
    FutureProvider<SellerPublishAccess>((ref) {
  return ref.read(publishTruffleServiceProvider).getCurrentSellerPublishAccess();
});

final currentSellerPublishGateStateProvider = Provider<SellerPublishGateState>((
  ref,
) {
  final accessAsync = ref.watch(currentSellerPublishAccessProvider);

  return accessAsync.when(
    data: (access) {
      if (access.canPublish) {
        return SellerPublishGateState.allowed(region: access.region);
      }
      return const SellerPublishGateState.notAllowed();
    },
    loading: SellerPublishGateState.loading,
    error: (_, _) => const SellerPublishGateState.error(),
  );
});
