import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Score {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final DateTime scoreDate;

  @HiveField(2)
  final int userScore;

  Score({required this.id, required this.scoreDate, required this.userScore});
}
