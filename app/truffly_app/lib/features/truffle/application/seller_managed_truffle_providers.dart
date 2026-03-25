import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/truffle/data/seller_managed_truffle_service.dart';
import 'package:truffly_app/features/truffle/domain/seller_managed_truffle_item.dart';
import 'package:truffly_app/features/truffle/domain/seller_managed_truffle_status.dart';

final sellerManagedTruffleServiceProvider =
    Provider<SellerManagedTruffleService>((ref) {
      return SellerManagedTruffleService(ref.read(supabaseClientProvider));
    });

final sellerManagedTrufflesProvider =
    FutureProvider<List<SellerManagedTruffleItem>>((ref) {
      return ref.read(sellerManagedTruffleServiceProvider).fetchCurrentSellerTruffles();
    });

final sellerManagedTruffleTabProvider =
    StateProvider<SellerManagedTruffleStatus>((ref) {
      return SellerManagedTruffleStatus.active;
    });

final sellerManagedTruffleDeleteProvider =
    NotifierProvider<SellerManagedTruffleDeleteNotifier, Set<String>>(
      SellerManagedTruffleDeleteNotifier.new,
    );

final class SellerManagedTruffleDeleteNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  Future<void> deleteTruffle(String truffleId) async {
    if (state.contains(truffleId)) return;

    state = {...state, truffleId};
    try {
      await ref.read(sellerManagedTruffleServiceProvider).deleteTruffle(truffleId);
    } finally {
      final next = Set<String>.from(state)..remove(truffleId);
      state = next;
    }
  }
}
