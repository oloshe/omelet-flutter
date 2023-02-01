import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omelet/pages/image_joint/image_joint_page.dart';
import 'package:visual_console/visual_console.dart';

import 'common/index.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  await Utils.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          color: Colors.yellow,
          foregroundColor: Colors.black,
          titleTextStyle: GoogleFonts.maShanZheng(
            textStyle: const TextStyle(
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        ),
        // buttonTheme: const ButtonThemeData(
        //   buttonColor: Colors.blue,
        //   textTheme: ButtonTextTheme.primary,
        // ),
        // textButtonTheme: TextButtonThemeData(
        //   style: ButtonStyle(
        //     foregroundColor: MaterialStateProperty.all(Colors.blue),
        //   ),
        // ),
      ),
      debugShowCheckedModeBanner: false,
      navigatorKey: Utils.navigatorKey,
      home: ScreenAdaptor(
        child: const ImageJointPage(),
      ),
      builder: (context, child) => Stack(
        children: [
          child!,
          const Console(),
        ],
      ),
    );
  }
}
