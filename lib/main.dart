import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:media_dedup_poc/app/app.dart';
import 'package:media_dedup_poc/core/database/objectbox_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(await ObjectBoxService.create(), permanent: true);
  runApp(const MediaDedupApp());
}
