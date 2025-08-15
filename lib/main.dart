import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pendu/screens/home_screen.dart';
import 'package:pendu/utilities/constants.dart';
import 'package:pendu/screens/loading_screen.dart'; // Assurez-vous d'importer LoadingScreen
import 'package:hive/hive.dart';
// Nécessaire pour getApplicationDocumentsDirectory() si vous le réactivez

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive.init(appDocumentDirectory.path); est pour les plateformes desktop/mobile où vous avez un système de fichiers.
  // Pour le web, Hive.init("") est correct car il utilise IndexedDB.
  // Décommentez la ligne suivante si vous ciblez d'autres plateformes que le web et que vous voulez utiliser le chemin du document
  // final appDocumentDirectory = await getApplicationDocumentsDirectory();
  // Hive.init(appDocumentDirectory.path);
  Hive.init(""); // Correct pour le WEB

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        'scorePage': (context) => LoadingScreen(), // Dirige vers LoadingScreen pour charger les scores
      },
      debugShowCheckedModeBanner: false, // enleve la banniere debug sur l'application
    );
  }
}