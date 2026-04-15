
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
}
