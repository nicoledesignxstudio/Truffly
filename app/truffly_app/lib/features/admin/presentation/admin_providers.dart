import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/admin/data/admin_application_dto.dart';
import 'package:truffly_app/features/admin/data/admin_repository.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';

final currentUserIsAdminProvider = Provider<bool>((ref) {
  ref.watch(authNotifierProvider);
  final user = ref.watch(supabaseClientProvider).auth.currentUser;
  return user?.appMetadata['role'] == 'admin';
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.read(supabaseClientProvider));
});

final adminSellerApplicationsProvider =
    FutureProvider<List<AdminSellerApplication>>((ref) async {
      ref.watch(authNotifierProvider);
      return ref.read(adminRepositoryProvider).listPendingApplications();
    });

final adminSellerApplicationProvider =
    Provider.family<AdminSellerApplication?, String>((ref, userId) {
      final applications = ref
          .watch(adminSellerApplicationsProvider)
          .valueOrNull;
      if (applications == null) return null;
      for (final application in applications) {
        if (application.userId == userId) return application;
      }
      return null;
    });

final adminSellerApplicationDocumentsProvider =
    FutureProvider.family<AdminSellerApplicationDocuments, String>((
      ref,
      userId,
    ) async {
      ref.watch(authNotifierProvider);
      return ref.read(adminRepositoryProvider).getApplicationDocuments(userId);
    });
