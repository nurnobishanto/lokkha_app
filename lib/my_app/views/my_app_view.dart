import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/bindings/initial_bindings.dart';
import '../../app/data/local/my_shared_pref.dart';
import '../../app/helper/global.dart';
import '../../app/routes/app_pages.dart';
import '../../config/constants/app_strings.dart';
import '../../config/theme/my_theme.dart';
import '../../config/translations/localization_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("MyApp Started....");

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          initialBinding: InitialBindings(),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          locale: MySharedPref.getCurrentLocal(),
          translations: LocalizationService.getInstance(),
          theme: MyTheme.getThemeData(isLight: true),
          darkTheme: MyTheme.getThemeData(isLight: false),
          themeMode: MySharedPref.getThemeMode() == 'dark'
              ? ThemeMode.dark
              : (MySharedPref.getThemeMode() == 'system' ? ThemeMode.system : ThemeMode.light),
          builder: (context, widget) {
            printAppInfo();
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: widget!,
            );
          },
        );
      },
    );
  }
}
