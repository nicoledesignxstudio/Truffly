import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/account/application/account_details_notifier.dart';
import 'package:truffly_app/features/account/application/account_details_providers.dart';
import 'package:truffly_app/features/account/data/account_details_service.dart';
import 'package:truffly_app/features/account/domain/account_details_state.dart';
import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';

class _FakeAccountDetailsService implements AccountDetailsService {
  _FakeAccountDetailsService(this.profile);

  final CurrentUserProfile profile;
  int updateProfileCalls = 0;
  int updateEmailCalls = 0;
  Map<String, Object?>? lastProfilePayload;
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
    lastProfilePayload = {
      'firstName': firstName,
      'lastName': lastName,
      'countryCode': countryCode,
      'region': region,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'isSeller': isSeller,
    };
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

CurrentUserProfile _profile({
  required bool isSeller,
  String email = 'user@test.com',
  String countryCode = 'IT',
  String? region = 'TOSCANA',
}) {
  return CurrentUserProfile(
    userId: 'u1',
    email: email,
    onboardingCompleted: true,
    firstName: 'Mario',
    lastName: 'Rossi',
    role: isSeller ? 'seller' : 'buyer',
    sellerStatus: isSeller ? 'approved' : 'not_requested',
    countryCode: countryCode,
    region: region,
    bio: isSeller ? 'Bio seller' : null,
    profileImageUrl: isSeller ? 'https://example.com/avatar.jpg' : null,
  );
}

Future<void> _pumpLoadedState(ProviderContainer container) async {
  container.read(accountDetailsNotifierProvider);
  await Future<void>.microtask(() {});
  await Future<void>.microtask(() {});
}

void main() {
  test('submit with profile-only changes updates public users only', () async {
    final service = _FakeAccountDetailsService(_profile(isSeller: false));
    final container = ProviderContainer(
      overrides: [
        accountDetailsServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await _pumpLoadedState(container);

    final notifier = container.read(accountDetailsNotifierProvider.notifier);
    notifier.updateFirstName('Luigi');
    final result = await notifier.submit();

    expect(result, const AccountDetailsSubmissionResult(emailChanged: false));
    expect(service.updateProfileCalls, 1);
    expect(service.updateEmailCalls, 0);
    expect(service.lastProfilePayload?['firstName'], 'Luigi');
  });

  test('submit with changed email updates profile and Supabase Auth email', () async {
    final service = _FakeAccountDetailsService(_profile(isSeller: false));
    final container = ProviderContainer(
      overrides: [
        accountDetailsServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await _pumpLoadedState(container);

    final notifier = container.read(accountDetailsNotifierProvider.notifier);
    notifier.updateEmail('new-address@test.com');
    final result = await notifier.submit();

    expect(result, const AccountDetailsSubmissionResult(emailChanged: true));
    expect(service.updateProfileCalls, 0);
    expect(service.updateEmailCalls, 1);
    expect(service.lastUpdatedEmail, 'new-address@test.com');
  });

  test('changing country away from Italy clears region in form state', () async {
    final service = _FakeAccountDetailsService(_profile(isSeller: false));
    final container = ProviderContainer(
      overrides: [
        accountDetailsServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await _pumpLoadedState(container);

    final notifier = container.read(accountDetailsNotifierProvider.notifier);
    notifier.updateCountryCode('FR');

    final state = container.read(accountDetailsNotifierProvider);
    expect(state.form?.countryCode, 'FR');
    expect(state.form?.region, isNull);
  });

  test('Italy requires region before submit succeeds', () async {
    final service = _FakeAccountDetailsService(
      _profile(isSeller: false, countryCode: 'IT', region: null),
    );
    final container = ProviderContainer(
      overrides: [
        accountDetailsServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await _pumpLoadedState(container);

    final notifier = container.read(accountDetailsNotifierProvider.notifier);
    notifier.updateFirstName('Luigi');
    final result = await notifier.submit();

    expect(result, isNull);
    expect(notifier.errorFor(AccountDetailsField.region), 'region_required');
    expect(service.updateProfileCalls, 0);
  });

  test('non-European country codes are rejected before submit', () async {
    final service = _FakeAccountDetailsService(_profile(isSeller: false));
    final container = ProviderContainer(
      overrides: [
        accountDetailsServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await _pumpLoadedState(container);

    final notifier = container.read(accountDetailsNotifierProvider.notifier);
    notifier.updateCountryCode('US');
    notifier.updateFirstName('Luigi');
    final result = await notifier.submit();

    expect(result, isNull);
    expect(
      notifier.errorFor(AccountDetailsField.countryCode),
      'country_invalid',
    );
    expect(service.updateProfileCalls, 0);
  });
}
