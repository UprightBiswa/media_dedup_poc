import 'dart:io';

import 'package:media_dedup_poc/core/logging/app_logger.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaPermissionService {
  MediaPermissionService({required AppLogger logger}) : _logger = logger;

  final AppLogger _logger;

  Future<bool> requestMediaAccess({
    bool allowUserSelectedFolderFallback = false,
  }) async {
    if (Platform.isAndroid) {
      return _requestAndroidMediaAccess(
        allowUserSelectedFolderFallback: allowUserSelectedFolderFallback,
      );
    }

    final status = await Permission.photos.request();
    final granted = status.isGranted || status.isLimited;
    if (granted) {
      _logger.info('MediaPermissionService', 'Granted photo library access');
      return true;
    }

    _logger.warning(
      'MediaPermissionService',
      'Photo library access was not granted on this platform',
    );
    return false;
  }

  Future<bool> _requestAndroidMediaAccess({
    required bool allowUserSelectedFolderFallback,
  }) async {
    final currentStatuses = await <Permission>[
      Permission.photos,
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    final granted = currentStatuses.values.any(
      (status) => status.isGranted || status.isLimited,
    );
    if (granted) {
      _logger.info(
        'MediaPermissionService',
        'Android media access granted by runtime permission',
      );
      return true;
    }

    if (allowUserSelectedFolderFallback) {
      _logger.warning(
        'MediaPermissionService',
        'Runtime permission denied. Continuing because the user selected a folder explicitly.',
      );
      return true;
    }

    _logger.warning(
      'MediaPermissionService',
      'Android media access was not granted',
    );
    return false;
  }
}
