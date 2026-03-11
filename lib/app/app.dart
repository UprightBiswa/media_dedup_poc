import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_dedup_poc/app/routes/app_routes.dart';
import 'package:media_dedup_poc/app/theme/app_theme.dart';
import 'package:media_dedup_poc/features/media_scan/presentation/controllers/scan_controller.dart';

class MediaDedupApp extends StatelessWidget {
  const MediaDedupApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ScanController(), permanent: true);

    return GetMaterialApp(
      title: 'Media Dedup POC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.dashboard,
      getPages: AppRoutes.pages,
    );
  }
}
