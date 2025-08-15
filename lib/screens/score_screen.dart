import 'package:flutter/material.dart';
import 'package:pendu/utilities/constants.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart'; // Import pour formater la date

class ScoreScreen extends StatelessWidget {
  final List<Map<dynamic, dynamic>> query; // Spécifier le type de la requête

  const ScoreScreen({super.key, required this.query}); // Le rendre obligatoire

  List<TableRow> createRow(List<Map<dynamic, dynamic>> query) {
    List<TableRow> rows = [];

    // Trier la requête par score décroissant (si plusieurs parties réussies)
    query.sort((a, b) => (b['userScore'] as int).compareTo(a['userScore'] as int));

    rows.add(
      const TableRow(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 15.0),
            child: Center(
              child: Text(
                "Rang",
                style: kHighScoreTableHeaders,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 15.0),
            child: Center(
              child: Text(
                "Date",
                style: kHighScoreTableHeaders,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 15.0),
            child: Center(
              child: Text(
                "Score",
                style: kHighScoreTableHeaders,
              ),
            ),
          ),
        ],
      ),
    );

    int numOfRows = query.length;
    List<String> topRanks = ["🥇", "🥈", "🥉"];

    for (var i = 0; i < numOfRows && i < 10; i++) { // Afficher jusqu'à 10 meilleurs scores
      var scoreEntry = query[i];
      // Accéder directement aux valeurs de la Map
      String scoreDateString = scoreEntry['scoreDate'] as String;
      int userScore = scoreEntry['userScore'] as int;

      // Formater la date pour un affichage plus lisible
      DateTime dateTime = DateTime.parse(scoreDateString);
      String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);

      Widget rankItem = TableCell(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            i < 3 ? '${topRanks[i]} ${i + 1}' : '${i + 1}',
            style: kHighScoreTableRowsStyle,
            textAlign: TextAlign.center,
          ),
        ),
      );
      Widget dateItem = TableCell(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formattedDate,
              style: kHighScoreTableRowsStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
      Widget scoreItem = TableCell(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            userScore.toString(),
            style: kHighScoreTableRowsStyle,
            textAlign: TextAlign.center,
          ),
        ),
      );
      rows.add(
        TableRow(
          children: [rankItem, dateItem, scoreItem],
        ),
      );
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: query.isEmpty // Vérifier si la liste est vide
            ? Stack(
          children: <Widget>[
            const Center(
              child: Text(
                "Aucun score pour le moment !",
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(6.0, 10.0, 6.0, 15.0),
              alignment: Alignment.topLeft,
              child: IconButton(
                tooltip: 'Accueil',
                iconSize: 35,
                icon: Icon(MdiIcons.home), // Removed 'const' here
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        )
            : Column(
          children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: <Widget>[
                Container(
                  padding:
                  const EdgeInsets.fromLTRB(6.0, 10.0, 6.0, 15.0),
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: 'Accueil',
                    iconSize: 35,
                    icon: Icon(MdiIcons.home), // Removed 'const' here
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Center(
                  child: Container(
                    margin:
                    const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 15.0),
                    child: const Text(
                      'Meilleurs Scores',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 45.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  defaultVerticalAlignment:
                  TableCellVerticalAlignment.middle,
                  textBaseline: TextBaseline.alphabetic,
                  children: createRow(query),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}