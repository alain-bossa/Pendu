import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pendu/screens/home_screen.dart';
import 'package:pendu/utilities/constants.dart';
import 'package:pendu/screens/score_screen.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

//import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> main() async {
  // if (Platform.isWindows || Platform.isLinux) {
  //   // Initialize FFI
  //   sqfliteFfiInit();
  // }
  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.
  //databaseFactory = databaseFactoryFfiWeb;
  //var path = Directory.current.path;
  WidgetsFlutterBinding.ensureInitialized();
  /*final appDocumentDirectory =
      await getApplicationDocumentsDirectory(); // a supprimer pour le WEB
  Hive.init(appDocumentDirectory.path); */
  Hive.init(""); //  pour le WEB

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    //DesktopWindow.setWindowSize(
    //    const Size(830, 1400)); // taille écran iPhone 11
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: kTooltipColor,
            borderRadius: BorderRadius.circular(5.0),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 172, 172, 172),
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'PatrickHand'),
      ),
      initialRoute: 'homePage',
      routes: {
        'homePage': (context) => HomeScreen(),
        'scorePage': (context) => ScoreScreen(),
      },
      debugShowCheckedModeBanner:
          false, // enleve la banniere debug sur l'application
    );
  }
}
