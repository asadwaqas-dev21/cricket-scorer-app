
class MatchSettings {
  int totalOvers;
  String team1Id;
  String team2Id;
  String tossWinnerId;
  String optTo;
  int maxOversPerBowler;
  String? tournamentId;
  List<String> playingSquad1;
  List<String> playingSquad2;

  MatchSettings({
    required this.totalOvers,
    required this.team1Id,
    required this.team2Id,
    required this.tossWinnerId,
    required this.optTo,
    required this.maxOversPerBowler,
    this.tournamentId,
    required this.playingSquad1,
    required this.playingSquad2,
  });

  Map<String, dynamic> toJson() => {
        'totalOvers': totalOvers,
        'team1Id': team1Id,
        'team2Id': team2Id,
        'tossWinnerId': tossWinnerId,
        'optTo': optTo,
        'maxOversPerBowler': maxOversPerBowler,
        'tournamentId': tournamentId,
        'playingSquad1': playingSquad1,
        'playingSquad2': playingSquad2,
      };

  factory MatchSettings.fromJson(Map<String, dynamic> json) => MatchSettings(
        totalOvers: json['totalOvers'],
        team1Id: json['team1Id'],
        team2Id: json['team2Id'],
        tossWinnerId: json['tossWinnerId'],
        optTo: json['optTo'],
        maxOversPerBowler: json['maxOversPerBowler'],
        tournamentId: json['tournamentId'],
        playingSquad1: List<String>.from(json['playingSquad1'] ?? []),
        playingSquad2: List<String>.from(json['playingSquad2'] ?? []),
      );
}
