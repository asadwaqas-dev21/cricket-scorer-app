import 'player.dart';

class Team {
  String id;
  String name;
  List<Player> players;
  int matchesPlayed;
  int wins;
  int losses;
  int points;
  
  int totalRunsScored;
  int totalOversFaced;
  int totalRunsConceded;
  int totalOversBowled;

  Team({
    required this.id,
    required this.name,
    required this.players,
    this.matchesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.points = 0,
    this.totalRunsScored = 0,
    this.totalOversFaced = 0,
    this.totalRunsConceded = 0,
    this.totalOversBowled = 0,
  });

  double get netRunRate {
    double runRateScored = totalOversFaced > 0 ? totalRunsScored / totalOversFaced : 0.0;
    double runRateConceded = totalOversBowled > 0 ? totalRunsConceded / totalOversBowled : 0.0;
    return runRateScored - runRateConceded;
  }

  double get runRate {
    // Force analyzer refresh
    return totalOversFaced > 0 ? totalRunsScored / totalOversFaced : 0.0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'players': players.map((p) => p.toJson()).toList(),
    'matchesPlayed': matchesPlayed,
    'wins': wins,
    'losses': losses,
    'points': points,
    'totalRunsScored': totalRunsScored,
    'totalOversFaced': totalOversFaced,
    'totalRunsConceded': totalRunsConceded,
    'totalOversBowled': totalOversBowled,
  };

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json['id'],
    name: json['name'],
    players: (json['players'] as List).map((p) => Player.fromJson(Map<String, dynamic>.from(p))).toList(),
    matchesPlayed: json['matchesPlayed'] ?? 0,
    wins: json['wins'] ?? 0,
    losses: json['losses'] ?? 0,
    points: json['points'] ?? 0,
    totalRunsScored: json['totalRunsScored'] ?? 0,
    totalOversFaced: json['totalOversFaced'] ?? 0,
    totalRunsConceded: json['totalRunsConceded'] ?? 0,
    totalOversBowled: json['totalOversBowled'] ?? 0,
  );
}
