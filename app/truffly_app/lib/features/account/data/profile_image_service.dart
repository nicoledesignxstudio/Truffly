import 'dart:async';
import 'dart:io';

import 'package:image/image.dart' as image_lib;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/core/config/local_backend_url_resolver.dart';
import 'package:truffly_app/core/config/runtime_config.dart';

abstract class ProfileImageService {
  Future<String> uploadProfileImage({
    required File imageFile,
    required String fileName,
    required String contentType,
    String? previousProfileImageUrl,
  });

  Future<void> removeProfileImage({
    String? currentProfileImageUrl,
  });
}

final class ProfileImageUploadException implements Exception {
  const ProfileImageUploadException(this.failure, {this.cause});

  final ProfileImageUploadFailure failure;
  final Object? cause;
}

enum ProfileImageUploadFailure {
  unauthenticated,
  fileTooLarge,
  unsupportedFormat,
  invalidImage,
  uploadFailed,
  permissionDenied,
  deleteFailed,
  unknown,
}

final class SupabaseProfileImageService implements ProfileImageService {
  SupabaseProfileImageService(this._supabaseClient);

  static const String _bucketId = 'profile_images';
  static const int _maxBytes = 5 * 1024 * 1024;
  static const Set<String> _supportedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  final SupabaseClient _supabaseClient;

  @override
  Future<String> uploadProfileImage({
    required File imageFile,
    required String fileName,
    required String contentType,
    String? previousProfileImageUrl,
  }) async {
    final authUser = _supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw const ProfileImageUploadException(
        ProfileImageUploadFailure.unauthenticated,
      );
    }

    final resolvedContentType = _normalizeContentType(contentType);
    final extension = _resolveExtension(fileName, resolvedContentType);
    if (extension == null) {
      throw const ProfileImageUploadException(
        ProfileImageUploadFailure.unsupportedFormat,
      );
    }

    final bytes = await imageFile.readAsBytes();
    if (bytes.length > _maxBytes) {
      throw const ProfileImageUploadException(
        ProfileImageUploadFailure.fileTooLarge,
      );
    }

    if (image_lib.decodeImage(bytes) == null) {
      throw const ProfileImageUploadException(
        ProfileImageUploadFailure.invalidImage,
      );
    }

    final storagePath = _buildStoragePath(authUser.id, extension);
    final storage = _supabaseClient.storage.from(_bucketId);

    try {
      await storage.upload(
        storagePath,
        imageFile,
        fileOptions: FileOptions(
          contentType: resolvedContentType,
          upsert: false,
        ),
      );
    } catch (error) {
      throw ProfileImageUploadException(
        _mapStorageError(error),
        cause: error,
      );
    }

    final publicUrl = _normalizeAbsoluteUrl(
      storage.getPublicUrl(storagePath),
    );

    try {
      await _supabaseClient
          .from('users')
          .update({'profile_image_url': publicUrl})
          .eq('id', authUser.id)
          .select('id')
          .single();
    } catch (error) {
      await _bestEffortRemove(storage, storagePath);
      throw ProfileImageUploadException(
        _mapDatabaseError(error),
        cause: error,
      );
    }

    await _bestEffortDeletePreviousImage(
      storage: storage,
      previousProfileImageUrl: previousProfileImageUrl,
      newStoragePath: storagePath,
    );

    return publicUrl;
  }

  @override
  Future<void> removeProfileImage({
    String? currentProfileImageUrl,
  }) async {
    final authUser = _supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw const ProfileImageUploadException(
        ProfileImageUploadFailure.unauthenticated,
      );
    }

    final storage = _supabaseClient.storage.from(_bucketId);
    final currentPath = _extractStoragePath(currentProfileImageUrl);

    try {
      await _supabaseClient
          .from('users')
          .update({'profile_image_url': null})
          .eq('id', authUser.id)
          .select('id')
          .single();
    } catch (error) {
      throw ProfileImageUploadException(
        _mapDatabaseError(error),
        cause: error,
      );
    }

    if (currentPath == null) return;
    await _bestEffortRemove(storage, currentPath);
  }

  Future<void> _bestEffortDeletePreviousImage({
    required dynamic storage,
    required String? previousProfileImageUrl,
    required String newStoragePath,
  }) async {
    final previousPath = _extractStoragePath(previousProfileImageUrl);
    if (previousPath == null || previousPath == newStoragePath) return;

    await _bestEffortRemove(storage, previousPath);
  }

  Future<void> _bestEffortRemove(
    dynamic storage,
    String storagePath,
  ) async {
    try {
      await storage.remove([storagePath]);
    } catch (_) {
      // Best effort cleanup. The new profile image is already the source of truth.
    }
  }

  String _buildStoragePath(String userId, String extension) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return '$userId/$timestamp.$extension';
  }

  String? _resolveExtension(String fileName, String contentType) {
    final fileExtension = _extractFileExtension(fileName);
    if (fileExtension != null && _supportedExtensions.contains(fileExtension)) {
      return fileExtension;
    }

    return switch (contentType) {
      'image/jpeg' => 'jpg',
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => null,
    };
  }

  String? _extractFileExtension(String fileName) {
    final trimmed = fileName.trim();
    if (trimmed.isEmpty) return null;

    final dotIndex = trimmed.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == trimmed.length - 1) return null;

    return trimmed.substring(dotIndex + 1).toLowerCase();
  }

  String _normalizeContentType(String contentType) {
    final normalized = contentType.trim().toLowerCase();
    if (normalized == 'image/jpg') return 'image/jpeg';
    return normalized;
  }

  String _normalizeAbsoluteUrl(String value) {
    try {
      return LocalBackendUrlResolver.normalize(
        value,
        androidHostOverride: RuntimeConfig.androidDeviceHost,
      );
    } on StateError {
      return value;
    }
  }

  String? _extractStoragePath(String? rawUrl) {
    final normalized = rawUrl?.trim();
    if (normalized == null || normalized.isEmpty) return null;

    if (normalized.startsWith('$_bucketId/')) {
      return normalized.substring(_bucketId.length + 1);
    }

    if (normalized.startsWith('/$_bucketId/')) {
      return normalized.substring(_bucketId.length + 2);
    }

    final uri = Uri.tryParse(normalized);
    if (uri == null) return null;

    final bucketIndex = uri.pathSegments.indexOf(_bucketId);
    if (bucketIndex == -1 || bucketIndex >= uri.pathSegments.length - 1) {
      return null;
    }

    return uri.pathSegments.sublist(bucketIndex + 1).join('/');
  }

  ProfileImageUploadFailure _mapStorageError(Object error) {
    if (error is TimeoutException) {
      return ProfileImageUploadFailure.uploadFailed;
    }

    if (error is StorageException) {
      final message = error.message.toLowerCase();
      final statusCode = int.tryParse(error.statusCode.toString());
      if (message.contains('permission denied') ||
          message.contains('not authorized') ||
          statusCode == 401 ||
          statusCode == 403) {
        return ProfileImageUploadFailure.permissionDenied;
      }
      return ProfileImageUploadFailure.uploadFailed;
    }

    return ProfileImageUploadFailure.unknown;
  }

  ProfileImageUploadFailure _mapDatabaseError(Object error) {
    if (error is PostgrestException) {
      if (error.code == '42501') {
        return ProfileImageUploadFailure.permissionDenied;
      }
      return ProfileImageUploadFailure.uploadFailed;
    }

    if (error is SocketException || error is HttpException) {
      return ProfileImageUploadFailure.uploadFailed;
    }

    return ProfileImageUploadFailure.unknown;
  }
}
