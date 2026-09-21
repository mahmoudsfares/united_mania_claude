import 'package:flutter/material.dart';

import 'core/routing/app_router.dart';
import 'core/utils/app_strings.dart';
import 'core/utils/app_theme.dart';
import 'core/utils/routes.dart';

void main() {
  runApp(const UnitedManiaApp());
}

class UnitedManiaApp extends StatelessWidget {
  const UnitedManiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      theme: AppTheme.theme,
      initialRoute: Routes.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
