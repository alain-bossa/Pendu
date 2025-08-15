import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pendu/components/action_button.dart';
import 'package:pendu/utilities/hangman_words.dart';
import 'game_screen.dart';
import 'loading_screen.dart';

// ignore: use_key_in_widget_constructors
class HomeScreen extends StatefulWidget {
  final HangmanWords hangmanWords = HangmanWords();

  @override
  _HomeScreenState createState() => _HomeScreenState();

  final queryResult = Hive.openBox<Map>(
      'score'); // AC rajouter car il faut initialiser l'ouverture de la base
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    widget.hangmanWords.readWords();
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Center(
            child: Container(
              margin: const EdgeInsets.fromLTRB(8.0, 1.0, 8.0, 8.0),
              child: const Text(
                'Jeu du pendu',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 58.0,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 3.0),
              ),
            ),
          ),
          Center(
            child: Image.asset(
              'images/gallow.png',
              height: height * 0.49,
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
          Center(
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
//                    width: 155,
                    height: 64,
                    child: ActionButton(
                      buttonTitle: 'C\'est parti !',
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameScreen(
                              hangmanObject: widget.hangmanWords,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 18.0,
                  ),
                  SizedBox(
//                    width: 155,
                    height: 64,
                    child: ActionButton(
                      buttonTitle: 'High Scores',
                      onPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoadingScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}
