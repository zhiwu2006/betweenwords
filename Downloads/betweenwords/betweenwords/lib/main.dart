import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/unit_list_page.dart';
import 'providers/theme_provider.dart';
import 'providers/study_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => StudyStateProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return GetMaterialApp(
              title: 'Between Words',
              theme: ThemeData(
                primarySwatch: Colors.blue,
                textTheme: GoogleFonts.poppinsTextTheme(
                  Theme.of(context).textTheme,
                ),
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              darkTheme: ThemeData.dark().copyWith(
                textTheme: GoogleFonts.poppinsTextTheme(
                  ThemeData.dark().textTheme,
                ),
              ),
              themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              debugShowCheckedModeBanner: false,
              home: UnitListPage(),
            );
          },
        );
      },
    );
  }
} 