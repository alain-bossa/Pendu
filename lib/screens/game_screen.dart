import 'package:flutter/material.dart';
import 'package:pendu/screens/home_screen.dart';
import 'package:pendu/utilities/alphabet.dart';
import 'package:pendu/components/word_button.dart';
import 'package:pendu/utilities/constants.dart';
import 'package:pendu/utilities/hangman_words.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:math';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:hive/hive.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.hangmanObject});

  final HangmanWords hangmanObject;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int lives = 3;
  Alphabet englishAlphabet = Alphabet();
  late String word;
  late String word_original;
  late String hiddenWord;
  List<String> wordList = [];
  List<int> hintLetters = [];
  late List<bool> buttonStatus;
  late bool hintStatus;
  int hangState = 0;
  int wordCount = 0;
  bool finishedGame = false;
  bool resetGame = false;

  void newGame() {
    setState(() {
      widget.hangmanObject.resetWords();
      englishAlphabet = Alphabet();
      lives = 5;
      wordCount = 0;
      finishedGame = false;
      resetGame = false;
      initWords();
    });
  }

  Widget createButton(index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 6.0),
      child: Center(
        child: WordButton(
          buttonTitle: englishAlphabet.alphabet[index], //.toUpperCase(),
          onPress: buttonStatus[index] ? () => wordPress(index) : () {},
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
    hintStatus = true;
    hangState = 0;
    buttonStatus = List.generate(35, (index) {
      return true;
    });
    wordList = [];
    hintLetters = [];
    word_original = widget.hangmanObject.getWord();
    word = word_original;
    if (word.isNotEmpty) {
      hiddenWord = widget.hangmanObject.getHiddenWord(word.length);
    } else {
      returnHomePage();
    }

    for (int i = 0; i < word.length; i++) {
      wordList.add(word[i]);
      hintLetters.add(i);
    }
  }

  Future<void> wordPress(int index) async {
    var scoreBox = await Hive.box<Map>('score');
    if (lives == 0) {
      returnHomePage();
    }

    if (finishedGame) {
      setState(() {
        resetGame = true;
      });
      return;
    }

    bool check = false;
    setState(() {
      for (int i = 0; i < wordList.length; i++) {
        if (wordList[i].toLowerCase() ==
            englishAlphabet.alphabet[index].toLowerCase()) {
          check = true;
          wordList[i] = '';
          hiddenWord = hiddenWord.replaceFirst(RegExp('_'), word[i], i);
        }
      }
      for (int i = 0; i < wordList.length; i++) {
        if (wordList[i] == '') {
          hintLetters.remove(i);
        }
      }
      if (!check) {
        hangState += 1;
      }

      if (hangState == 6) {
        finishedGame = true;
        lives -= 1;
        if (lives < 1) {
          if (wordCount > 0) {
            final score = {
              'id': 1,
              'scoreDate': DateTime.now().toString(),
              'userScore': wordCount
            };
            scoreBox.add(score);
          }
          Alert(
              style: kGameOverAlertStyle,
              context: context,
              title: "Game Over!",
              desc: "Ton score est $wordCount",
              buttons: [
                DialogButton(
                  color: kDialogButtonColor,
                  onPressed: () => returnHomePage(),
                  child: Icon(
                    MdiIcons.home,
                    size: 30.0,
                  ),
                ),
                DialogButton(
                  onPressed: () {
                    newGame();
                    Navigator.pop(context);
                  },
                  color: kDialogButtonColor,
                  child: Icon(MdiIcons.refresh, size: 30.0),
                ),
              ]).show();
        } else {
          Alert(
            context: context,
            style: kFailedAlertStyle,
            type: AlertType.error,
            title: word,
//            desc: "You Lost!",
            buttons: [
              DialogButton(
                radius: BorderRadius.circular(10),
                width: 127,
                color: kDialogButtonColor,
                height: 52,
                child: Icon(
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
      }

      buttonStatus[index] = false;
      if (hiddenWord == word) {
        finishedGame = true;
        Alert(
          context: context,
          style: kSuccessAlertStyle,
          type: AlertType.success,
          title: word,
//          desc: "You guessed it right!",
          buttons: [
            DialogButton(
              radius: BorderRadius.circular(10),
              width: 127,
              color: kDialogButtonColor,
              height: 52,
              child: Icon(
                MdiIcons.arrowRightThick,
                size: 30.0,
              ),
              onPressed: () {
                setState(() {
                  wordCount += 1;
                  Navigator.pop(context);
                  initWords();
                });
              },
            )
          ],
        ).show();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initWords();
  }

  @override
  Widget build(BuildContext context) {
    if (resetGame) {
      setState(() {
        initWords();
      });
    }
    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
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
                            Row(
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          6.0, 10.0, 6.0, 15.0),
                                      alignment: Alignment.topLeft,
                                      child: IconButton(
                                        tooltip: 'Home',
                                        iconSize: 35,
                                        icon: Icon(MdiIcons.home),
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          56.0, 10.0, 6.0, 15.0),
                                      child: IconButton(
                                        tooltip: 'Vies',
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        iconSize: 39,
                                        icon: Icon(MdiIcons.heart),
                                        onPressed: () {},
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          64, 15, 0, 0.8),
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        height: 38,
                                        width: 38,
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Text(
                                              lives.toString() == "1"
                                                  ? "I"
                                                  : lives.toString(),
                                              style: const TextStyle(
                                                color: Color(0xFF2C1E68),
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'PatrickHand',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              child: Text(
                                wordCount == 1 ? "I" : '$wordCount',
                                style: kWordCounterTextStyle,
                              ),
                            ),
                            SizedBox(
                              child: IconButton(
                                tooltip: 'Aide',
                                iconSize: 39,
                                icon: Icon(MdiIcons.lightbulb),
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onPressed: hintStatus
                                    ? () {
                                        int rand = Random()
                                            .nextInt(hintLetters.length);
                                        wordPress(englishAlphabet.alphabet
                                            .indexOf(
                                                wordList[hintLetters[rand]]));
                                        hintStatus = false;
                                      }
                                    : null,
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
                                  child: Text(hiddenWord,
                                      maxLines: 2,
                                      style: const TextStyle(fontSize: 36)))
                              /*Text(
                              hiddenWord,
                              //style: kWordTextStyle,
                              maxLines: 3,
                              style: TextStyle(fontSize: 60.0),
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                            ),*/
                              ),
                        ),
                      ),
                    ],
                  )),
              Container(
                padding: const EdgeInsets.fromLTRB(10.0, 2.0, 8.0, 10.0),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  //columnWidths: {1: FlexColumnWidth(10)},
                  children: [
                    TableRow(children: [
                      TableCell(
                        child: createButton(0),
                      ),
                      TableCell(
                        child: createButton(1),
                      ),
                      TableCell(
                        child: createButton(2),
                      ),
                      TableCell(
                        child: createButton(3),
                      ),
                      TableCell(
                        child: createButton(4),
                      ),
                      TableCell(
                        child: createButton(5),
                      ),
                      TableCell(
                        child: createButton(6),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(
                        child: createButton(7),
                      ),
                      TableCell(
                        child: createButton(8),
                      ),
                      TableCell(
                        child: createButton(9),
                      ),
                      TableCell(
                        child: createButton(10),
                      ),
                      TableCell(
                        child: createButton(11),
                      ),
                      TableCell(
                        child: createButton(12),
                      ),
                      TableCell(
                        child: createButton(13),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(
                        child: createButton(14),
                      ),
                      TableCell(
                        child: createButton(15),
                      ),
                      TableCell(
                        child: createButton(16),
                      ),
                      TableCell(
                        child: createButton(17),
                      ),
                      TableCell(
                        child: createButton(18),
                      ),
                      TableCell(
                        child: createButton(19),
                      ),
                      TableCell(
                        child: createButton(20),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(
                        child: createButton(21),
                      ),
                      TableCell(
                        child: createButton(22),
                      ),
                      TableCell(
                        child: createButton(23),
                      ),
                      TableCell(
                        child: createButton(24),
                      ),
                      TableCell(
                        child: createButton(25),
                      ),
                      TableCell(
                        child: createButton(26),
                      ),
                      TableCell(
                        child: createButton(27),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(
                        child: createButton(28),
                      ),
                      TableCell(
                        child: createButton(29),
                      ),
                      TableCell(
                        child: createButton(30),
                      ),
                      TableCell(
                        child: createButton(31),
                      ),
                      TableCell(
                        child: createButton(32),
                      ),
                      TableCell(
                        child: createButton(33),
                      ),
                      TableCell(
                        child: createButton(34),
                      ),
                      // const TableCell(
                      //   child: Text(''),
                      // ),
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
