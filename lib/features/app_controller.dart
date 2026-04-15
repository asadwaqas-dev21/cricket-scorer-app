import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../core/models/team.dart';
import '../core/models/player.dart';
import '../core/models/completed_match.dart';
import '../core/models/tournament.dart';

class AppController extends GetxController {
  var teams = <Team>[].obs;
  var completedMatches = <CompletedMatch>[].obs;
  var tournaments = <Tournament>[].obs;

  Box get _box => Hive.box('cricket_data');

  @override
  void onInit() {
    super.onInit();
    _loadData();
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
        completedMatches.value = parsedMatches.map((m) => CompletedMatch.fromJson(m)).toList();
      } catch (e) {
        print("Error parsing stored matches: $e");
      }
    }

    String? storedTournaments = _box.get('tournaments_json');
    if (storedTournaments != null && storedTournaments.isNotEmpty) {
      try {
        List<dynamic> parsedTournaments = jsonDecode(storedTournaments);
        tournaments.value = parsedTournaments.map((t) => Tournament.fromJson(t)).toList();
      } catch (e) {
        print("Error parsing stored tournaments: $e");
      }
    }
  }

  void saveData() {
    String encoded = jsonEncode(teams.map((t) => t.toJson()).toList());
    _box.put('teams_json', encoded);

    String encodedMatches = jsonEncode(completedMatches.map((m) => m.toJson()).toList());
    _box.put('matches_json', encodedMatches);

    String encodedTournaments = jsonEncode(tournaments.map((t) => t.toJson()).toList());
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
}
