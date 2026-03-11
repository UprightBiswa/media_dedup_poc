import 'package:file_picker/file_picker.dart';
import 'package:media_dedup_poc/core/logging/app_logger.dart';

class MediaSourceService {
  MediaSourceService({required AppLogger logger}) : _logger = logger;

  final AppLogger _logger;

  Future<String?> pickDirectory() async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose a media folder',
    );
    _logger.info('MediaSourceService', 'Selected source: ${path ?? 'none'}');
    return path;
  }
}
