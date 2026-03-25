import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/account/application/account_details_notifier.dart';
import 'package:truffly_app/features/account/application/account_details_providers.dart';
import 'package:truffly_app/features/account/data/account_details_service.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';

class _FakeAccountDetailsService implements AccountDetailsService {
  _FakeAccountDetailsService(this.profile);

  final CurrentUserProfile profile;
  int updateProfileCalls = 0;
  int updateEmailCalls = 0;
  String? lastUpdatedEmail;

  @override
  Future<AuthResult<CurrentUserProfile>> loadCurrentProfile() async {
    return AuthSuccess<CurrentUserProfile>(profile);
  }

  @override
  Future<AuthResult<AuthUnit>> updateProfile({
    required String firstName,
    required String lastName,
    required String countryCode,
    required String? region,
    required String? bio,
    required String? profileImageUrl,
    required bool isSeller,
  }) async {
    updateProfileCalls += 1;
    return const AuthSuccess<AuthUnit>(AuthUnit.value);
  }

  @override
  Future<AuthResult<AuthUnit>> updateEmail({
    required String email,
  }) async {
    updateEmailCalls += 1;
    lastUpdatedEmail = email;
    return const AuthSuccess<AuthUnit>(AuthUnit.value);
  }
}

class _MutableAuthNotifier extends AuthNotifier {
  _MutableAuthNotifier({
    required this.initialState,
    this.refreshedState,
  });

  final AuthState initialState;
  final AuthState? refreshedState;
  int refreshCalls = 0;

  @override
  AuthState build() => initialState;

  @override
  Future<AuthResult<AuthUnit>> refreshAuthState() async {
    refreshCalls += 1;
    if (refreshedState != null) {
      state = refreshedState!;
    }
    return const AuthSuccess<AuthUnit>(AuthUnit.value);
  }
}

CurrentUserProfile _profile({
  String email = 'verified@test.com',
}) {
  return CurrentUserProfile(
    userId: 'u1',
    email: email,
    onboardingCompleted: true,
    firstName: 'Mario',
    lastName: 'Rossi',
    role: 'buyer',
    sellerStatus: 'not_requested',
    countryCode: 'IT',
    region: 'TOSCANA',
    bio: null,
    profileImageUrl: null,
  );
}

Future<void> _pumpLoadedState(ProviderContainer container) async {
  container.read(accountDetailsNotifierProvider);
  await Future<void>.microtask(() {});
  await Future<void>.microtask(() {});
}

void main() {
  test(
    'email change triggers auth refresh and moves auth state to authenticated_unverified',
    () async {
      final service = _FakeAccountDetailsService(_profile());
      final authNotifier = _MutableAuthNotifier(
        initialState: const AuthAuthenticatedReady(
          userId: 'u1',
          email: 'verified@test.com',
        ),
        refreshedState: const AuthAuthenticatedUnverified(
          userId: 'u1',
          email: 'new-email@test.com',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          accountDetailsServiceProvider.overrideWithValue(service),
          authNotifierProvider.overrideWith(() => authNotifier),
        ],
      );
      addTearDown(container.dispose);

      await _pumpLoadedState(container);

      final accountNotifier = container.read(accountDetailsNotifierProvider.notifier);
      accountNotifier.updateEmail('new-email@test.com');

      final submitResult = await accountNotifier.submit();

      expect(
        submitResult,
        const AccountDetailsSubmissionResult(emailChanged: true),
      );
      expect(service.updateProfileCalls, 1);
      expect(service.updateEmailCalls, 1);
      expect(service.lastUpdatedEmail, 'new-email@test.com');

      expect(authNotifier.refreshCalls, 1);
      expect(
        container.read(authNotifierProvider),
        const AuthAuthenticatedUnverified(
          userId: 'u1',
          email: 'new-email@test.com',
        ),
      );
    },
  );

  test(
    'name-only change keeps auth state ready and does not trigger auth refresh',
    () async {
      final service = _FakeAccountDetailsService(_profile());
      final authNotifier = _MutableAuthNotifier(
        initialState: const AuthAuthenticatedReady(
          userId: 'u1',
          email: 'verified@test.com',
        ),
        refreshedState: const AuthAuthenticatedUnverified(
          userId: 'u1',
          email: 'verified@test.com',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          accountDetailsServiceProvider.overrideWithValue(service),
          authNotifierProvider.overrideWith(() => authNotifier),
        ],
      );
      addTearDown(container.dispose);

      await _pumpLoadedState(container);

      final accountNotifier = container.read(accountDetailsNotifierProvider.notifier);
      accountNotifier.updateFirstName('Luigi');

      final submitResult = await accountNotifier.submit();

      expect(
        submitResult,
        const AccountDetailsSubmissionResult(emailChanged: false),
      );
      expect(service.updateProfileCalls, 1);
      expect(service.updateEmailCalls, 0);
      expect(authNotifier.refreshCalls, 0);
      expect(
        container.read(authNotifierProvider),
        const AuthAuthenticatedReady(
          userId: 'u1',
          email: 'verified@test.com',
        ),
      );
    },
  );
}