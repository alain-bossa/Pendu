import 'package:flutter/material.dart';
import 'package:pendu/screens/home_screen.dart';
import 'package:pendu/utilities/alphabet.dart';
import 'package:pendu/components/word_button.dart';
import 'package:pendu/utilities/constants.dart';
import 'package:pendu/utilities/hangman_words.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:hive/hive.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.hangmanObject});

  final HangmanWords hangmanObject;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Suppression de la variable 'lives'
  int failedGames = 0; // Compteur pour les parties perdues
  Alphabet englishAlphabet = Alphabet();
  late String word;
  late String word_original;
  late String hiddenWord;
  List<String> wordList = [];
  List<int> hintLetters = [];
  late List<bool> buttonStatus;
  late List<Color> buttonColors; // Pour changer la couleur des boutons
  // Suppression de 'hintStatus' car l'aide n'est plus souhaitée
  // late bool hintStatus;
  int hangState = 0;
  int wordCount = 0; // Cette variable comptera désormais les parties réussies
  bool finishedGame = false;
  bool resetGame = false;

  @override
  void initState() {
    super.initState(); // Toujours appeler super.initState() en premier
    initWords();
  }

  void newGame() {
    setState(() {
      widget.hangmanObject.resetWords();
      englishAlphabet = Alphabet();
      wordCount = 0; // Réinitialiser le compteur de parties réussies
      failedGames = 0; // Réinitialiser le compteur de parties perdues
      finishedGame = false;
      resetGame = false;
      initWords();
    });
  }

  Widget createButton(int index) { // Ajout du type int pour index
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 6.0),
      child: Center(
        child: WordButton(
          buttonTitle: englishAlphabet.alphabet[index],
          onPress: buttonStatus[index] ? () => wordPress(index) : null, // Utiliser null pour un bouton désactivé
          color: buttonColors[index], // Passer la couleur de votre liste
        ),
      ),
    );
  }

  void returnHomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
      ModalRoute.withName('homePage'),
    );
  }

  void initWords() {
    finishedGame = false;
    resetGame = false;
    // hintStatus = true; // Plus d'aide
    hangState = 0;
    buttonStatus = List.generate(englishAlphabet.alphabet.length, (index) {
      return true;
    });
    buttonColors = List.generate(englishAlphabet.alphabet.length, (index) => kWordButtonColor); // Initialiser tous les boutons avec la couleur par défaut
    wordList = [];
    hintLetters = [];
    word_original = widget.hangmanObject.getWord();

    if (word_original.isNotEmpty) {
      word = word_original.trim(); // Supprimer les espaces blancs/nouvelles lignes
      hiddenWord = widget.hangmanObject.getHiddenWord(word.length);
    } else {
      // Si plus de mots, revenir à la page d'accueil
      Alert(
        context: context,
        style: kGameOverAlertStyle,
        title: "Pas de mots!",
        desc: "Tous les mots ont été utilisés. Veuillez recommencer le jeu.",
        buttons: [
          DialogButton(
            color: kDialogButtonColor,
            onPressed: () => returnHomePage(),
            child: Icon(MdiIcons.home, size: 30.0), // Supprimé 'const' ici
          ),
        ],
      ).show();
      return; // Quitter pour éviter un traitement ultérieur avec un mot vide
    }

    for (int i = 0; i < word.length; i++) {
      wordList.add(word[i]);
      hintLetters.add(i);
    }
  }

  Future<void> wordPress(int index) async {
    var scoreBox = await Hive.box<Map>('score');

    if (finishedGame) {
      setState(() {
        resetGame = true;
      });
      return;
    }

    bool check = false;
    // Définir immédiatement l'état et la couleur du bouton pour éviter de le presser à nouveau
    setState(() {
      buttonStatus[index] = false;
      buttonColors[index] = Colors.grey; // Changer la couleur du bouton pressé
    });

    for (int i = 0; i < wordList.length; i++) {
      if (wordList[i].toLowerCase() ==
          englishAlphabet.alphabet[index].toLowerCase()) {
        check = true;
        wordList[i] = '';
        // Manière correcte de remplacer un caractère à l'index
        hiddenWord = hiddenWord.substring(0, i) + word[i] + hiddenWord.substring(i + 1);
      }
    }

    // Reconstruire hintLetters en fonction des '_' restants dans hiddenWord
    hintLetters = [];
    for (int i = 0; i < hiddenWord.length; i++) {
      if (hiddenWord[i] == '_') {
        hintLetters.add(i);
      }
    }

    if (!check) {
      setState(() {
        hangState += 1;
      });
    }

    if (hangState == 6) { // Pendu complet
      finishedGame = true;
      failedGames++; // Incrémenter les parties perdues

      // Afficher l'alerte 'Perdu'
      Alert(
        context: context,
        style: kFailedAlertStyle,
        type: AlertType.error,
        title: "Perdu!",
        desc: "Le mot était : $word\nParties gagnées : $wordCount\nParties perdues : $failedGames",
        buttons: [
          DialogButton(
            radius: BorderRadius.circular(10),
            width: 127,
            color: kDialogButtonColor,
            height: 52,
            child: Icon( // Supprimé 'const' ici
              MdiIcons.arrowRightThick,
              size: 30.0,
            ),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
                initWords();
              });
            },
          ),
        ],
      ).show();
    }

    if (hiddenWord == word) { // Mot deviné correctement
      finishedGame = true;
      wordCount++; // Incrémenter les parties réussies

      // Sauvegarder le score pour les parties réussies
      final score = {
        'id': DateTime.now().millisecondsSinceEpoch, // ID unique
        'scoreDate': DateTime.now().toString(),
        'userScore': wordCount
      };
      scoreBox.add(score);

      // Afficher l'alerte 'Gagné'
      Alert(
        context: context,
        style: kSuccessAlertStyle,
        type: AlertType.success,
        title: "Gagné !",
        desc: "Le mot était : $word\nParties gagnées : $wordCount\nParties perdues : $failedGames",
        buttons: [
          DialogButton(
            radius: BorderRadius.circular(10),
            width: 127,
            color: kDialogButtonColor,
            height: 52,
            child: Icon( // Supprimé 'const' ici
              MdiIcons.arrowRightThick,
              size: 30.0,
            ),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
                initWords();
              });
            },
          )
        ],
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    // La logique de 'resetGame' est gérée par les DialogButtons qui appellent initWords()
    // et Navigator.pop(context), donc ce bloc peut être omis ici ou utilisé pour un autre type de réinitialisation.
    // if (resetGame) {
    //   initWords();
    // }
    return PopScope(
       child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6.0, 8.0, 6.0, 35.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // Colonne des scores et bouton d'accueil
                          Column(
                            children: <Widget>[
                              // Bouton Accueil
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                    6.0, 10.0, 6.0, 15.0),
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                  tooltip: 'Accueil',
                                  iconSize: 35,
                                  icon: Icon(MdiIcons.home), // Supprimé 'const' ici
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onPressed: () {
                                    returnHomePage(); // Utiliser la fonction dédiée
                                  },
                                ),
                              ),
                              // Affichage des parties gagnées

                            ],
                          ),
                          // Affichage des parties perdues
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0, top: 0.0),
                            child: Text(
                              'Perdu: $failedGames',
                              style: kWordCounterTextStyle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 0.0),
                            child: Text(
                              'Gagné: $wordCount',
                              style: kWordCounterTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.asset(
                            'images/$hangState.png',
                            height: 1001,
                            width: 991,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 35.0),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: SizedBox(
                            width: 600,
                            child: Text(
                              hiddenWord,
                              maxLines: 2,
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10.0, 2.0, 8.0, 10.0),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    TableRow(children: [
                      TableCell(child: createButton(0)),
                      TableCell(child: createButton(1)),
                      TableCell(child: createButton(2)),
                      TableCell(child: createButton(3)),
                      TableCell(child: createButton(4)),
                      TableCell(child: createButton(5)),
                      TableCell(child: createButton(6)),
                    ]),
                    TableRow(children: [
                      TableCell(child: createButton(7)),
                      TableCell(child: createButton(8)),
                      TableCell(child: createButton(9)),
                      TableCell(child: createButton(10)),
                      TableCell(child: createButton(11)),
                      TableCell(child: createButton(12)),
                      TableCell(child: createButton(13)),
                    ]),
                    TableRow(children: [
                      TableCell(child: createButton(14)),
                      TableCell(child: createButton(15)),
                      TableCell(child: createButton(16)),
                      TableCell(child: createButton(17)),
                      TableCell(child: createButton(18)),
                      TableCell(child: createButton(19)),
                      TableCell(child: createButton(20)),
                    ]),
                    TableRow(children: [
                      TableCell(child: createButton(21)),
                      TableCell(child: createButton(22)),
                      TableCell(child: createButton(23)),
                      TableCell(child: createButton(24)),
                      TableCell(child: createButton(25)),
                      TableCell(child: createButton(26)),
                      TableCell(child: createButton(27)),
                    ]),
                    TableRow(children: [
                      TableCell(child: createButton(28)),
                      TableCell(child: createButton(29)),
                      TableCell(child: createButton(30)),
                      TableCell(child: createButton(31)),
                      TableCell(child: createButton(32)),
                      TableCell(child: createButton(33)),
                      TableCell(child: createButton(34)),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}