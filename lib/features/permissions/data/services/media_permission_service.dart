import 'package:media_dedup_poc/core/logging/app_logger.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaPermissionService {
  MediaPermissionService({required AppLogger logger}) : _logger = logger;

  final AppLogger _logger;

  Future<bool> requestMediaAccess() async {
    final permissions = <Permission>[
      Permission.photos,
      Permission.videos,
      Permission.storage,
      Permission.manageExternalStorage,
    ];

    for (final permission in permissions) {
      final status = await permission.request();
      if (status.isGranted || status.isLimited) {
        _logger.info('MediaPermissionService', 'Granted permission: $permission');
        return true;
      }
    }

    _logger.warning('MediaPermissionService', 'Media access was not granted');
    return false;
  }
}
