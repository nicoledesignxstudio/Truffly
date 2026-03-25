import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/profile/data/seller_profile_service.dart';
import 'package:truffly_app/features/profile/domain/seller_profile_detail.dart';
import 'package:truffly_app/features/profile/domain/seller_review_item.dart';

final sellerProfileServiceProvider = Provider<SellerProfileService>((ref) {
  return SellerProfileService(ref.read(supabaseClientProvider));
});

final sellerProfileProvider =
    FutureProvider.family<SellerProfileDetail, String>((ref, sellerId) {
  return ref.read(sellerProfileServiceProvider).fetchSellerProfile(sellerId);
});

final sellerReviewsProvider =
    FutureProvider.family<List<SellerReviewItem>, String>((ref, sellerId) {
  return ref.read(sellerProfileServiceProvider).fetchSellerReviews(sellerId);
});
