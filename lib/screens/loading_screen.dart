import 'package:flutter/material.dart';
import 'package:pendu/screens/score_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    queryScores();
  }

  void queryScores() async {
    //final database = score_database.openDB();
    //var queryResult = await score_database.scores(database);
    final queryResult = await Hive.openBox<Map>('score');

    var myList = queryResult.values.toList();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ScoreScreen(
            query: myList,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SpinKitDoubleBounce(
          color: Colors.white,
          size: 100.0,
        ),
      ),
    );
  }
}
