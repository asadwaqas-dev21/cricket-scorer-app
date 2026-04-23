import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../core/models/team.dart';
import '../core/models/player.dart';
import '../core/models/completed_match.dart';
import '../core/models/tournament.dart';
import '../core/models/match_settings.dart';
import '../core/models/ball_event.dart';

class AppController extends GetxController {
  var teams = <Team>[].obs;
  var completedMatches = <CompletedMatch>[].obs;
  var tournaments = <Tournament>[].obs;

  Box get _box => Hive.box('cricket_data');

  void saveOngoingMatch({
    required MatchSettings settings,
    required List<BallEvent> events,
    required String strikerId,
    required String nonStrikerId,
    required String bowlerId,
    required bool isFirstInnings,
    required int targetRuns,
    required Team team1,
    required Team team2,
    required Map<String, dynamic> baselineStats,
  }) {
    Map<String, dynamic> data = {
      'settings': settings.toJson(),
      'events': events.map((e) => e.toJson()).toList(),
      'strikerId': strikerId,
      'nonStrikerId': nonStrikerId,
      'bowlerId': bowlerId,
      'isFirstInnings': isFirstInnings,
      'targetRuns': targetRuns,
      'team1': team1.toJson(),
      'team2': team2.toJson(),
      'baselineStats': baselineStats,
    };
    _box.put('ongoing_match', jsonEncode(data));
  }

  void clearOngoingMatch() {
    _box.delete('ongoing_match');
  }

  Map<String, dynamic>? getOngoingMatch() {
    String? data = _box.get('ongoing_match');
    if (data == null) return null;
    try {
      return jsonDecode(data);
    } catch (e) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadData();
    syncStats();
    ever(teams, (_) => saveData());
  }

  void _loadData() {
    String? storedData = _box.get('teams_json');
    if (storedData != null && storedData.isNotEmpty) {
      try {
        List<dynamic> parsedList = jsonDecode(storedData);
        teams.value = parsedList.map((t) => Team.fromJson(t)).toList();
      } catch (e) {
        print("Error parsing stored data: $e");
      }
    }

    String? storedMatches = _box.get('matches_json');
    if (storedMatches != null && storedMatches.isNotEmpty) {
      try {
        List<dynamic> parsedMatches = jsonDecode(storedMatches);
        completedMatches.value = parsedMatches
            .map((m) => CompletedMatch.fromJson(m))
            .toList();
      } catch (e) {
        print("Error parsing stored matches: $e");
      }
    }

    String? storedTournaments = _box.get('tournaments_json');
    if (storedTournaments != null && storedTournaments.isNotEmpty) {
      try {
        List<dynamic> parsedTournaments = jsonDecode(storedTournaments);
        tournaments.value = parsedTournaments
            .map((t) => Tournament.fromJson(t))
            .toList();
      } catch (e) {
        print("Error parsing stored tournaments: $e");
      }
    }
  }

  void saveData() {
    String encoded = jsonEncode(teams.map((t) => t.toJson()).toList());
    _box.put('teams_json', encoded);

    String encodedMatches = jsonEncode(
      completedMatches.map((m) => m.toJson()).toList(),
    );
    _box.put('matches_json', encodedMatches);

    String encodedTournaments = jsonEncode(
      tournaments.map((t) => t.toJson()).toList(),
    );
    _box.put('tournaments_json', encodedTournaments);
  }

  void refreshData() {
    teams.refresh();
    saveData();
  }

  List<Player> getAllPlayers() => teams.expand((team) => team.players).toList();

  Player? getOrangeCap() {
    var all = getAllPlayers();
    if (all.isEmpty) return null;
    all.sort((a, b) => b.runsScored.compareTo(a.runsScored));
    return all.first;
  }

  Player? getPurpleCap() {
    var all = getAllPlayers();
    if (all.isEmpty) return null;
    all.sort((a, b) => b.wicketsTaken.compareTo(a.wicketsTaken));
    return all.first;
  }

  Player? getMVP() {
    var all = getAllPlayers();
    if (all.isEmpty) return null;
    all.sort((a, b) => b.mvpPoints.compareTo(a.mvpPoints));
    return all.first;
  }

  void syncStats() {
    for (var team in teams) {
      team.wins = 0;
      team.losses = 0;
      team.points = 0;
      team.matchesPlayed = 0;
      team.totalRunsScored = 0;
      team.totalOversFaced = 0;
      team.totalRunsConceded = 0;
      team.totalOversBowled = 0;
      for (var p in team.players) {
        p.runsScored = 0;
        p.ballsFaced = 0;
        p.wicketsTaken = 0;
        p.oversBowled = 0;
        p.runsConceded = 0;
        p.catches = 0;
        p.mvpPoints = 0;
        p.fours = 0;
        p.sixes = 0;
        p.matchesPlayed = 0;
      }
    }

    // 2. Add back stats from existing matches
    var allPlayers = getAllPlayers();
    for (var match in completedMatches) {
      // Re-apply team1 stats
      if (match.team1Id != null) {
        var team1 = teams.firstWhereOrNull((t) => t.id == match.team1Id);
        if (team1 != null && match.team1Deltas.isNotEmpty) {
          team1.wins += (match.team1Deltas['wins'] as int? ?? 0);
          team1.losses += (match.team1Deltas['losses'] as int? ?? 0);
          team1.points += (match.team1Deltas['points'] as int? ?? 0);
          team1.matchesPlayed +=
              (match.team1Deltas['matchesPlayed'] as int? ?? 0);
          team1.totalRunsScored +=
              (match.team1Deltas['runsScored'] as int? ?? 0);
          team1.totalOversFaced +=
              (match.team1Deltas['oversFaced'] as int? ?? 0);
          team1.totalRunsConceded +=
              (match.team1Deltas['runsConceded'] as int? ?? 0);
          team1.totalOversBowled +=
              (match.team1Deltas['oversBowled'] as int? ?? 0);
        }
      }

      // Re-apply team2 stats
      if (match.team2Id != null) {
        var team2 = teams.firstWhereOrNull((t) => t.id == match.team2Id);
        if (team2 != null && match.team2Deltas.isNotEmpty) {
          team2.wins += (match.team2Deltas['wins'] as int? ?? 0);
          team2.losses += (match.team2Deltas['losses'] as int? ?? 0);
          team2.points += (match.team2Deltas['points'] as int? ?? 0);
          team2.matchesPlayed +=
              (match.team2Deltas['matchesPlayed'] as int? ?? 0);
          team2.totalRunsScored +=
              (match.team2Deltas['runsScored'] as int? ?? 0);
          team2.totalOversFaced +=
              (match.team2Deltas['oversFaced'] as int? ?? 0);
          team2.totalRunsConceded +=
              (match.team2Deltas['runsConceded'] as int? ?? 0);
          team2.totalOversBowled +=
              (match.team2Deltas['oversBowled'] as int? ?? 0);
        }
      }

      // Re-apply player stats
      if (match.playerDeltas.isNotEmpty) {
        for (var entry in match.playerDeltas.entries) {
          var pId = entry.key;
          var p = allPlayers.firstWhereOrNull((player) => player.id == pId);
          if (p != null) {
            var d = entry.value;
            p.matchesPlayed += 1;
            p.runsScored += (d['runsScored'] as int? ?? 0);
            p.ballsFaced += (d['ballsFaced'] as int? ?? 0);
            p.wicketsTaken += (d['wicketsTaken'] as int? ?? 0);
            p.runsConceded += (d['runsConceded'] as int? ?? 0);
            p.oversBowled += (d['oversBowled'] as int? ?? 0);
            p.fours += (d['fours'] as int? ?? 0);
            p.sixes += (d['sixes'] as int? ?? 0);
            p.catches += (d['catches'] as int? ?? 0);
            p.updateMVPPoints();
          }
        }
      }
    }

    refreshData();
  }

  void deleteMatch(String matchId) {
    var matchIndex = completedMatches.indexWhere((m) => m.id == matchId);
    if (matchIndex == -1) return;

    completedMatches.removeAt(matchIndex);
    syncStats();
  }
}
