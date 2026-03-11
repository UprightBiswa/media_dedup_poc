import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:media_dedup_poc/objectbox.g.dart';

class ObjectBoxService {
  ObjectBoxService._(this.store, this.admin);

  final Store store;
  final Admin? admin;

  static Future<ObjectBoxService> create() async {
    final directory = await getApplicationDocumentsDirectory();
    final store = await openStore(
      directory: p.join(directory.path, 'media_dedup_objectbox'),
    );
    Admin? admin;
    if (Admin.isAvailable()) {
      admin = Admin(store);
    }
    return ObjectBoxService._(store, admin);
  }
}
