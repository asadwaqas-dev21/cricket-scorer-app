import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/match_settings.dart';
import '../../../core/models/team.dart';
import '../../../core/models/player.dart';
import '../../../core/models/ball_event.dart';
import '../../../core/models/completed_match.dart';
import '../../app_controller.dart';
import '../../home/screens/home_screen.dart';

class ScoringController extends GetxController {
  var matchSettings = Rxn<MatchSettings>();

  var currentOvers = 0.obs;
  var currentBalls = 0.obs;
  var totalRuns = 0.obs;
  var wickets = 0.obs;

  var historyRuns = <String>[].obs;
  var allEvents = <BallEvent>[].obs;

  var batTeamName = "".obs;
  var bowlTeamName = "".obs;

  var striker = Rxn<Player>();
  var nonStriker = Rxn<Player>();
  var bowler = Rxn<Player>();

  var isFirstInnings = true.obs;
  var targetRuns = 0.obs;
  var matchResult = "".obs;
  var firstInningsScore = "".obs;

  late Team team1Ref;
  late Team team2Ref;
  late Team batTeamRef;
  late Team bowlTeamRef;

  Map<String, Map<String, dynamic>> baselineStats = {};

  var selectedWagonDirection = "".obs;

  void setupMatch(MatchSettings settings) {
    matchSettings.value = settings;
    var mainCtrl = Get.find<AppController>();
    Team team1 = mainCtrl.teams.firstWhere((t) => t.id == settings.team1Id);
    Team team2 = mainCtrl.teams.firstWhere((t) => t.id == settings.team2Id);

    team1Ref = team1;
    team2Ref = team2;

    Team playingTeam1 = Team(
      id: team1.id,
      name: team1.name,
      players: team1.players
          .where((p) => settings.playingSquad1.contains(p.id))
          .toList(),
    );
    Team playingTeam2 = Team(
      id: team2.id,
      name: team2.name,
      players: team2.players
          .where((p) => settings.playingSquad2.contains(p.id))
          .toList(),
    );

    if (playingTeam1.players.isEmpty)
      playingTeam1.players.addAll(team1.players);
    if (playingTeam2.players.isEmpty)
      playingTeam2.players.addAll(team2.players);

    batTeamRef =
        (settings.tossWinnerId == team1.id && settings.optTo == 'Bat') ||
            (settings.tossWinnerId != team1.id && settings.optTo != 'Bat')
        ? playingTeam1
        : playingTeam2;
    bowlTeamRef = batTeamRef == playingTeam1 ? playingTeam2 : playingTeam1;

    // We can show player selection UI instead of default
    _startInnings(batTeamRef, bowlTeamRef);
    _saveBaseline([...team1.players, ...team2.players]);
  }

  void _startInnings(Team batTeam, Team bowlTeam) {
    batTeamName.value = batTeam.name;
    bowlTeamName.value = bowlTeam.name;
    striker.value = batTeam.players[0];
    nonStriker.value = batTeam.players[1];
    bowler.value = bowlTeam.players[0];

    allEvents.clear();
    _rebuildFromEvents();
  }

  void switchInnings() {
    isFirstInnings.value = false;
    targetRuns.value = totalRuns.value + 1;
    firstInningsScore.value = '${totalRuns.value}/${wickets.value}';

    // Switch references
    var temp = batTeamRef;
    batTeamRef = bowlTeamRef;
    bowlTeamRef = temp;

    Get.snackbar(
      'Innings Break',
      'Target for ${batTeamRef.name} is ${targetRuns.value} runs.',
    );
    _startInnings(batTeamRef, bowlTeamRef);
  }

  void changePlayer(String role, Player p) {
    if (role == 'striker')
      striker.value = p;
    else if (role == 'nonStriker')
      nonStriker.value = p;
    else if (role == 'bowler')
      bowler.value = p;
  }

  void _saveBaseline(List<Player> players) {
    baselineStats.clear();
    for (var p in players) {
      baselineStats[p.id] = {
        'runsScored': p.runsScored,
        'ballsFaced': p.ballsFaced,
        'wicketsTaken': p.wicketsTaken,
        'oversBowled': p.oversBowled,
        'runsConceded': p.runsConceded,
        'fours': p.fours,
        'sixes': p.sixes,
      };
    }
  }

  void _restoreBaseline() {
    var mainCtrl = Get.find<AppController>();
    List<Player> allPlayers = mainCtrl.getAllPlayers();
    for (var p in allPlayers) {
      if (baselineStats.containsKey(p.id)) {
        p.runsScored = baselineStats[p.id]!['runsScored'];
        p.ballsFaced = baselineStats[p.id]!['ballsFaced'];
        p.wicketsTaken = baselineStats[p.id]!['wicketsTaken'];
        p.oversBowled = baselineStats[p.id]!['oversBowled'];
        p.runsConceded = baselineStats[p.id]!['runsConceded'];
        p.fours = baselineStats[p.id]!['fours'] ?? 0;
        p.sixes = baselineStats[p.id]!['sixes'] ?? 0;
        p.updateMVPPoints();
      }
    }
  }

  void recordEvent({
    required int runs,
    bool isWicket = false,
    String extraType = "",
    String wicketType = "",
    String? catcherId,
    int batsmanRuns = 0,
  }) {
    if (matchSettings.value == null) return;
    int maxOvers = matchSettings.value!.totalOvers;

    // Safety check BEFORE adding event
    if (currentOvers.value >= maxOvers ||
        wickets.value >= 10 ||
        matchResult.value.isNotEmpty) {
      Get.snackbar('Match Status', 'Innings / Match is already over.');
      return;
    }

    var pBowler = bowler.value;
    if (pBowler != null &&
        getPlayerMatchOversBowled(pBowler) >= matchSettings.value!.maxOversPerBowler &&
        extraType == "") {
      Get.snackbar(
        'Limit Reached',
        'This bowler has completed their max overs (${matchSettings.value!.maxOversPerBowler}) for the match.',
      );
      return;
    }

    allEvents.add(
      BallEvent(
        runs: runs,
        isWicket: isWicket,
        extraType: extraType,
        strikerId: striker.value!.id,
        bowlerId: bowler.value!.id,
        wagonDirection: selectedWagonDirection.value,
        wicketType: wicketType,
        catcherId: catcherId,
        batsmanRuns: batsmanRuns,
      ),
    );

    selectedWagonDirection.value = "";

    if (runs % 2 != 0 && extraType == "") swapBatsmen();

    _rebuildFromEvents();

    if (currentBalls.value == 0 &&
        currentOvers.value > 0 &&
        currentOvers.value < maxOvers) {
      swapBatsmen();
      promptNextPlayer('bowler');
    }

    if (isWicket &&
        wickets.value < 10 &&
        !(!isFirstInnings.value && totalRuns.value >= targetRuns.value)) {
      promptNextPlayer('striker');
    }

    _checkInningsEnd(maxOvers);
  }

  void promptNextPlayer(String role) {
    // Avoid double prompts if innings is over
    if (!isFirstInnings.value && totalRuns.value >= targetRuns.value) return;

    var team = (role == 'bowler') ? bowlTeamRef : batTeamRef;

    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Next ${role.capitalizeFirst}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_add, color: Colors.indigo),
                title: const Text(
                  'Add New Custom Player',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                onTap: () {
                  Get.back(); // Close bottom sheet
                  _addNewPlayerDialog(role, team);
                },
              ),
              const Divider(),
              ...team.players
                  .map(
                    (p) => ListTile(
                      title: Text(p.name),
                      onTap: () {
                        changePlayer(role, p);
                        Get.back();
                      },
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
    );
  }

  void _addNewPlayerDialog(String role, Team team) {
    final TextEditingController nameController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('Add New ${role.capitalizeFirst}'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Enter player name',
            labelText: 'Player Name',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                String newId =
                    '${team.id}_${DateTime.now().millisecondsSinceEpoch}';
                Player newPlayer = Player(
                  id: newId,
                  name: nameController.text.trim(),
                );
                team.players.add(newPlayer);
                baselineStats[newPlayer.id] = {
                  'runsScored': 0,
                  'ballsFaced': 0,
                  'wicketsTaken': 0,
                  'oversBowled': 0,
                  'runsConceded': 0,
                  'fours': 0,
                  'sixes': 0,
                };
                changePlayer(role, newPlayer);
                Get.back();
              }
            },
            child: const Text('Add & Select'),
          ),
        ],
      ),
    );
  }

  void _checkInningsEnd(int maxOvers) {
    if (!isFirstInnings.value && totalRuns.value >= targetRuns.value) {
      matchResult.value = '${batTeamRef.name} won the match!';
      Get.defaultDialog(title: 'Match Over', middleText: matchResult.value);
    } else if (currentOvers.value >= maxOvers || wickets.value >= 10) {
      if (isFirstInnings.value) {
        switchInnings();
      } else {
        if (totalRuns.value == targetRuns.value - 1) {
          matchResult.value = 'Match Tied!';
        } else {
          matchResult.value = '${bowlTeamRef.name} won the match!';
        }
        Get.defaultDialog(title: 'Match Over', middleText: matchResult.value);
      }
    }
  }

  void undoLast() {
    if (allEvents.isNotEmpty) {
      var last = allEvents.removeLast();
      if (currentBalls.value == 0 && currentOvers.value > 0) {
        swapBatsmen();
      }
      if (last.runs % 2 != 0 && last.extraType == "") {
        swapBatsmen();
      }
      _rebuildFromEvents();
    } else {
      Get.snackbar('Cannot Undo', 'No actions to undo.');
    }
  }

  void _rebuildFromEvents() {
    _restoreBaseline();

    currentOvers.value = 0;
    currentBalls.value = 0;
    totalRuns.value = 0;
    wickets.value = 0;
    historyRuns.clear();

    for (var e in allEvents) {
      var mainCtrl = Get.find<AppController>();
      Player pStriker = mainCtrl.getAllPlayers().firstWhere(
        (p) => p.id == e.strikerId,
      );
      Player pBowler = mainCtrl.getAllPlayers().firstWhere(
        (p) => p.id == e.bowlerId,
      );

      if (e.extraType == "") {
        totalRuns.value += e.runs;
        currentBalls.value++;
        pStriker.runsScored += e.runs;
        pStriker.ballsFaced += 1;
        if (e.runs == 4) pStriker.fours++;
        if (e.runs == 6) pStriker.sixes++;
        historyRuns.add(e.isWicket ? 'W' : e.runs.toString());
      } else {
        totalRuns.value += e.runs;
        if (e.extraType == 'NB') {
          historyRuns.add('${e.runs}NB');
          pStriker.runsScored += e.batsmanRuns;
          if (e.batsmanRuns == 4) pStriker.fours++;
          if (e.batsmanRuns == 6) pStriker.sixes++;
          pStriker.ballsFaced += 1;
        } else {
          historyRuns.add(e.extraType);
          if (e.extraType != 'WD') {
            pStriker.runsScored += e.runs > 0 ? e.runs - 1 : 0;
            pStriker.ballsFaced += 1;
          }
        }
      }

      pBowler.runsConceded += e.runs;

      if (e.isWicket) {
        wickets.value++;
        if (e.wicketType != 'Run Out') {
          pBowler.wicketsTaken++;
        }
        if (e.catcherId != null) {
          Player? pCatcher = mainCtrl.getAllPlayers().firstWhereOrNull(
            (p) => p.id == e.catcherId,
          );
          if (pCatcher != null) {
            pCatcher.catches++;
            pCatcher.updateMVPPoints();
          }
        }
      }

      if (currentBalls.value == 6) {
        currentBalls.value = 0;
        currentOvers.value++;
        pBowler.oversBowled++;
        historyRuns.clear();
      }

      pStriker.updateMVPPoints();
      pBowler.updateMVPPoints();
    }

    // Check if match was won
    int maxOvers = matchSettings.value!.totalOvers;
    if (!isFirstInnings.value && totalRuns.value >= targetRuns.value) {
      matchResult.value = '${batTeamRef.name} won the match!';
    } else if (!isFirstInnings.value &&
        (currentOvers.value >= maxOvers || wickets.value >= 10)) {
      if (totalRuns.value == targetRuns.value - 1) {
        matchResult.value = 'Match Tied!';
      } else {
        matchResult.value = '${bowlTeamRef.name} won the match!';
      }
    } else {
      matchResult.value = "";
    }

    striker.refresh();
    nonStriker.refresh();
    bowler.refresh();

    Get.find<AppController>().saveData();
  }

  void swapBatsmen() {
    var temp = striker.value;
    striker.value = nonStriker.value;
    nonStriker.value = temp;
  }

  double get runRate => ((currentOvers.value * 6) + currentBalls.value) > 0
      ? (totalRuns.value / ((currentOvers.value * 6) + currentBalls.value)) * 6
      : 0.0;

  int get runsNeeded => targetRuns.value - totalRuns.value;
  int get ballsRemaining => (matchSettings.value!.totalOvers * 6) - (currentOvers.value * 6 + currentBalls.value);

  double get requiredRunRate {
    if (isFirstInnings.value) return 0.0;
    int balls = ballsRemaining;
    return balls > 0 ? (runsNeeded / balls) * 6 : 0.0;
  }

  int getPlayerMatchRuns(Player? p) =>
      (p?.runsScored ?? 0) -
      ((p != null && baselineStats.containsKey(p.id))
          ? baselineStats[p.id]!['runsScored'] as int
          : 0);
  int getPlayerMatchBalls(Player? p) =>
      (p?.ballsFaced ?? 0) -
      ((p != null && baselineStats.containsKey(p.id))
          ? baselineStats[p.id]!['ballsFaced'] as int
          : 0);
  int getPlayerMatchWickets(Player? p) =>
      (p?.wicketsTaken ?? 0) -
      ((p != null && baselineStats.containsKey(p.id))
          ? baselineStats[p.id]!['wicketsTaken'] as int
          : 0);
  int getPlayerMatchRunsConceded(Player? p) =>
      (p?.runsConceded ?? 0) -
      ((p != null && baselineStats.containsKey(p.id))
          ? baselineStats[p.id]!['runsConceded'] as int
          : 0);
  int getPlayerMatchOversBowled(Player? p) =>
      (p?.oversBowled ?? 0) -
      ((p != null && baselineStats.containsKey(p.id))
          ? baselineStats[p.id]!['oversBowled'] as int
          : 0);

  double getPlayerMatchStrikeRate(Player? p) {
    int r = getPlayerMatchRuns(p);
    int b = getPlayerMatchBalls(p);
    return b > 0 ? (r / b) * 100 : 0.0;
  }

  void finalizeAndExit() {
    var mainCtrl = Get.find<AppController>();
    
    // Distribute team Win/Loss
    if (matchResult.value.contains(team1Ref.name) && !matchResult.value.contains('Tied')) {
      team1Ref.wins++;
      team2Ref.losses++;
      team1Ref.points += 2;
    } else if (matchResult.value.contains(team2Ref.name) && !matchResult.value.contains('Tied')) {
      team2Ref.wins++;
      team1Ref.losses++;
      team2Ref.points += 2;
    } else {
      team1Ref.points += 1;
      team2Ref.points += 1;
    }
    team1Ref.matchesPlayed++;
    team2Ref.matchesPlayed++;

    // Tally up team total aggregate (simplistic approach based on direct additions)
    if (batTeamRef.id == team1Ref.id) {
       team1Ref.totalRunsScored += totalRuns.value;
       team1Ref.totalOversFaced += currentOvers.value;
       team2Ref.totalRunsConceded += totalRuns.value;
       team2Ref.totalOversBowled += currentOvers.value;
       
       team2Ref.totalRunsScored += targetRuns.value > 0 ? targetRuns.value - 1 : 0;
       team2Ref.totalOversFaced += matchSettings.value!.totalOvers; // fallback approximation 
       team1Ref.totalRunsConceded += targetRuns.value > 0 ? targetRuns.value - 1 : 0;
       team1Ref.totalOversBowled += matchSettings.value!.totalOvers;
    } else {
       // Reverse logic for team2 batting second
       team2Ref.totalRunsScored += totalRuns.value;
       team2Ref.totalOversFaced += currentOvers.value;
       team1Ref.totalRunsConceded += totalRuns.value;
       team1Ref.totalOversBowled += currentOvers.value;

       team1Ref.totalRunsScored += targetRuns.value > 0 ? targetRuns.value - 1 : 0;
       team1Ref.totalOversFaced += matchSettings.value!.totalOvers; 
       team2Ref.totalRunsConceded += targetRuns.value > 0 ? targetRuns.value - 1 : 0;
       team2Ref.totalOversBowled += matchSettings.value!.totalOvers;
    }

    // Calculate Detailed Stats and Man of the Match
    List<Map<String, dynamic>> battingStats = [];
    List<Map<String, dynamic>> bowlingStats = [];
    Player? motm;
    int maxMatchMVP = -100;

    List<Player> allMatchPlayers = [...team1Ref.players, ...team2Ref.players];
    for (var p in allMatchPlayers) {
      int r = getPlayerMatchRuns(p);
      int b = getPlayerMatchBalls(p);
      int w = getPlayerMatchWickets(p);
      int rc = getPlayerMatchRunsConceded(p);
      int o = getPlayerMatchOversBowled(p);
      
      // Local match MVP calculation
      int matchMVP = r + (w * 20); // Simple version for MOTM

      if (matchMVP > maxMatchMVP) {
        maxMatchMVP = matchMVP;
        motm = p;
      }

      if (r > 0 || b > 0) {
        battingStats.add({
          'name': p.name,
          'runs': r,
          'balls': b,
          'team': team1Ref.players.contains(p) ? team1Ref.name : team2Ref.name,
        });
      }
      if (o > 0 || rc > 0 || w > 0) {
        bowlingStats.add({
          'name': p.name,
          'overs': o,
          'wickets': w,
          'runs': rc,
          'team': team1Ref.players.contains(p) ? team1Ref.name : team2Ref.name,
        });
      }
    }

    // Build History Match
    String i1S = firstInningsScore.value.isEmpty ? '${totalRuns.value}/${wickets.value}' : firstInningsScore.value; 
    String i2S = firstInningsScore.value.isEmpty ? 'DNB' : '${totalRuns.value}/${wickets.value}';

    CompletedMatch cMatch = CompletedMatch(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      team1Name: team1Ref.name,
      team2Name: team2Ref.name,
      date: DateTime.now().toString().substring(0, 10),
      result: matchResult.value,
      tournamentId: matchSettings.value!.tournamentId,
      team1Score: batTeamRef.id == team1Ref.id ? i2S : i1S,
      team2Score: batTeamRef.id == team2Ref.id ? i2S : i1S,
      manOfTheMatch: motm?.name ?? "N/A",
      battingPerformances: battingStats,
      bowlingPerformances: bowlingStats,
    );

    mainCtrl.completedMatches.add(cMatch);
    mainCtrl.saveData();

    Get.offAll(() => const HomeScreen());
  }
}
