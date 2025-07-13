class ScoreRecord {
  final int? id;
  final String playerName;
  final int score;
  final int timeInSeconds;
  final DateTime date;
  
  ScoreRecord({
    this.id,
    required this.playerName,
    required this.score,
    required this.timeInSeconds,
    required this.date,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playerName': playerName,
      'score': score,
      'timeInSeconds': timeInSeconds,
      'date': date.toIso8601String(),
    };
  }
  
  factory ScoreRecord.fromMap(Map<String, dynamic> map) {
    return ScoreRecord(
      id: map['id'],
      playerName: map['playerName'],
      score: map['score'],
      timeInSeconds: map['timeInSeconds'],
      date: DateTime.parse(map['date']),
    );
  }
}
