class CompletedMatch {
  String id;
  String team1Name;
  String team2Name;
  String date;
  String result;
  String team1Score;
  String team2Score;
  String? team1Id;
  String? team2Id;
  String? tournamentId;
  String manOfTheMatch;
  List<Map<String, dynamic>> battingPerformances;
  List<Map<String, dynamic>> bowlingPerformances;
  Map<String, dynamic> playerDeltas;
  Map<String, dynamic> team1Deltas;
  Map<String, dynamic> team2Deltas;

  CompletedMatch({
    required this.id,
    required this.team1Name,
    required this.team2Name,
    this.team1Id,
    this.team2Id,
    required this.date,
    required this.result,
    required this.team1Score,
    required this.team2Score,
    this.tournamentId,
    this.manOfTheMatch = "N/A",
    this.battingPerformances = const [],
    this.bowlingPerformances = const [],
    this.playerDeltas = const {},
    this.team1Deltas = const {},
    this.team2Deltas = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'team1Name': team1Name,
    'team2Name': team2Name,
    'team1Id': team1Id,
    'team2Id': team2Id,
    'date': date,
    'result': result,
    'team1Score': team1Score,
    'team2Score': team2Score,
    'tournamentId': tournamentId,
    'manOfTheMatch': manOfTheMatch,
    'battingPerformances': battingPerformances,
    'bowlingPerformances': bowlingPerformances,
    'playerDeltas': playerDeltas,
    'team1Deltas': team1Deltas,
    'team2Deltas': team2Deltas,
  };

  factory CompletedMatch.fromJson(Map<String, dynamic> json) => CompletedMatch(
    id: json['id'],
    team1Name: json['team1Name'],
    team2Name: json['team2Name'],
    team1Id: json['team1Id'],
    team2Id: json['team2Id'],
    date: json['date'],
    result: json['result'],
    team1Score: json['team1Score'],
    team2Score: json['team2Score'],
    tournamentId: json['tournamentId'],
    manOfTheMatch: json['manOfTheMatch'] ?? "N/A",
    battingPerformances: List<Map<String, dynamic>>.from(
      json['battingPerformances'] ?? [],
    ),
    bowlingPerformances: List<Map<String, dynamic>>.from(
      json['bowlingPerformances'] ?? [],
    ),
    playerDeltas: Map<String, dynamic>.from(json['playerDeltas'] ?? {}),
    team1Deltas: Map<String, dynamic>.from(json['team1Deltas'] ?? {}),
    team2Deltas: Map<String, dynamic>.from(json['team2Deltas'] ?? {}),
  );
}
