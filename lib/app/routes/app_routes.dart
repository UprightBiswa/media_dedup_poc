import 'package:get/get.dart';
import 'package:media_dedup_poc/features/media_scan/presentation/pages/dashboard_page.dart';

class AppRoutes {
  static const dashboard = '/';

  static final pages = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: dashboard,
      page: () => const DashboardPage(),
    ),
  ];
}
