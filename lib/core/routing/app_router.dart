import 'package:flutter/material.dart';

import '../../features/news_feed/news_feed_screen.dart';
import '../di/app_di.dart';
import '../utils/app_strings.dart';
import '../utils/routes.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              NewsFeedScreen(cubit: AppDi.newsFeedCubit),
        );
      default:
        return MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              Scaffold(body: Center(child: Text(AppStrings.routeNotFound))),
        );
    }
  }
}
