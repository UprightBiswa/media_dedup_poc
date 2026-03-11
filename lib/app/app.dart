import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_dedup_poc/app/bindings/initial_binding.dart';
import 'package:media_dedup_poc/app/routes/app_routes.dart';
import 'package:media_dedup_poc/app/theme/app_theme.dart';

class MediaDedupApp extends StatelessWidget {
  const MediaDedupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Media Dedup POC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.dashboard,
      initialBinding: InitialBinding(),
      getPages: AppRoutes.pages,
    );
  }
}
