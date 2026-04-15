class CompletedMatch {
  String id;
  String team1Name;
  String team2Name;
  String date;
  String result;
  String team1Score;
  String team2Score;
  String? tournamentId;
  String manOfTheMatch;
  List<Map<String, dynamic>> battingPerformances;
  List<Map<String, dynamic>> bowlingPerformances;

  CompletedMatch({
    required this.id,
    required this.team1Name,
    required this.team2Name,
    required this.date,
    required this.result,
    required this.team1Score,
    required this.team2Score,
    this.tournamentId,
    this.manOfTheMatch = "N/A",
    this.battingPerformances = const [],
    this.bowlingPerformances = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'team1Name': team1Name,
    'team2Name': team2Name,
    'date': date,
    'result': result,
    'team1Score': team1Score,
    'team2Score': team2Score,
    'tournamentId': tournamentId,
    'manOfTheMatch': manOfTheMatch,
    'battingPerformances': battingPerformances,
    'bowlingPerformances': bowlingPerformances,
  };

  factory CompletedMatch.fromJson(Map<String, dynamic> json) => CompletedMatch(
    id: json['id'],
    team1Name: json['team1Name'],
    team2Name: json['team2Name'],
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
  );
}
