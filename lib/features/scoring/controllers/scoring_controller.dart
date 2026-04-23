import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/match_settings.dart';
import '../../../core/models/team.dart';
import '../../../core/models/player.dart';
import '../../../core/models/ball_event.dart';
import '../../../core/models/completed_match.dart';
import '../../app_controller.dart';
import '../../home/screens/home_screen.dart';
import '../../../core/theme/app_theme.dart';

class ScoringController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Save state whenever events change
    ever(allEvents, (_) => _saveOngoingState());
  }

  void _saveOngoingState() {
    if (matchSettings.value != null && matchResult.value.isEmpty) {
      if (striker.value != null &&
          nonStriker.value != null &&
          bowler.value != null) {
        Get.find<AppController>().saveOngoingMatch(
          settings: matchSettings.value!,
          events: allEvents,
          strikerId: striker.value!.id,
          nonStrikerId: nonStriker.value!.id,
          bowlerId: bowler.value!.id,
          isFirstInnings: isFirstInnings.value,
          targetRuns: targetRuns.value,
          team1: team1Ref,
          team2: team2Ref,
          baselineStats: baselineStats,
        );
      }
    }
  }

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

  var outPlayersIds = <String>[].obs;
  var lastOverBowlerId = Rxn<String>();

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

  // Over-by-over scoring for graphs (T10/T20)
  var innings1OverRuns = <int>[].obs;
  var innings2OverRuns = <int>[].obs;

  // Milestone tracking
  var lastMilestone = Rxn<Map<String, dynamic>>();

  bool get isShortFormat {
    final overs = matchSettings.value?.totalOvers ?? 0;
    return overs == 10 || overs == 20;
  }

  void setupMatch(MatchSettings settings) {
    matchSettings.value = settings;
    var mainCtrl = Get.find<AppController>();
    Team team1 = mainCtrl.teams.firstWhere((t) => t.id == settings.team1Id);
    Team team2 = mainCtrl.teams.firstWhere((t) => t.id == settings.team2Id);

    team1Ref = Team(
      id: team1.id,
      name: team1.name,
      players: team1.players
          .where((p) => settings.playingSquad1.contains(p.id))
          .toList(),
    );
    team2Ref = Team(
      id: team2.id,
      name: team2.name,
      players: team2.players
          .where((p) => settings.playingSquad2.contains(p.id))
          .toList(),
    );

    if (team1Ref.players.isEmpty) team1Ref.players.addAll(team1.players);
    if (team2Ref.players.isEmpty) team2Ref.players.addAll(team2.players);

    batTeamRef =
        (settings.tossWinnerId == team1Ref.id && settings.optTo == 'Bat') ||
            (settings.tossWinnerId != team1Ref.id && settings.optTo != 'Bat')
        ? team1Ref
        : team2Ref;
    bowlTeamRef = batTeamRef == team1Ref ? team2Ref : team1Ref;

    allEvents.clear();
    _startInnings(batTeamRef, bowlTeamRef);
    _saveBaseline([...team1Ref.players, ...team2Ref.players]);
  }

  void resumeMatch(
    MatchSettings settings,
    List<BallEvent> events,
    Map<String, dynamic> ongoingData,
  ) {
    matchSettings.value = settings;
    var mainCtrl = Get.find<AppController>();
    Team team1 = mainCtrl.teams.firstWhere((t) => t.id == settings.team1Id);
    Team team2 = mainCtrl.teams.firstWhere((t) => t.id == settings.team2Id);

    // Restore teams from saved data if available to keep custom players
    team1Ref = ongoingData['team1'] != null
        ? Team.fromJson(ongoingData['team1'])
        : team1;
    team2Ref = ongoingData['team2'] != null
        ? Team.fromJson(ongoingData['team2'])
        : team2;

    // Use these refs for batting/bowling state
    batTeamRef =
        (settings.tossWinnerId == team1Ref.id && settings.optTo == 'Bat') ||
            (settings.tossWinnerId != team1Ref.id && settings.optTo != 'Bat')
        ? team1Ref
        : team2Ref;
    bowlTeamRef = batTeamRef == team1Ref ? team2Ref : team1Ref;

    // Restore baseline stats
    if (ongoingData['baselineStats'] != null) {
      baselineStats = Map<String, Map<String, dynamic>>.from(
        (ongoingData['baselineStats'] as Map).map(
          (k, v) => MapEntry(k as String, Map<String, dynamic>.from(v as Map)),
        ),
      );
    } else {
      _saveBaseline([...team1Ref.players, ...team2Ref.players]);
    }
    allEvents.assignAll(events);

    batTeamName.value = batTeamRef.name;
    bowlTeamName.value = bowlTeamRef.name;

    // Restore current players and state
    striker.value = batTeamRef.players.firstWhereOrNull(
      (p) => p.id == (ongoingData['strikerId'] ?? ""),
    );
    nonStriker.value = batTeamRef.players.firstWhereOrNull(
      (p) => p.id == (ongoingData['nonStrikerId'] ?? ""),
    );
    bowler.value = bowlTeamRef.players.firstWhereOrNull(
      (p) => p.id == (ongoingData['bowlerId'] ?? ""),
    );

    // Fallback if not found
    striker.value ??= batTeamRef.players[0];
    nonStriker.value ??= batTeamRef.players[1];
    bowler.value ??= bowlTeamRef.players[0];

    isFirstInnings.value = ongoingData['isFirstInnings'] ?? true;
    targetRuns.value = ongoingData['targetRuns'] ?? 0;

    _rebuildFromEvents();
  }

  void _startInnings(Team batTeam, Team bowlTeam) {
    batTeamName.value = batTeam.name;
    bowlTeamName.value = bowlTeam.name;
    striker.value = batTeam.players[0];
    nonStriker.value = batTeam.players[1];
    bowler.value = bowlTeam.players[0];

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
    if (role == 'striker') {
      striker.value = p;
    } else if (role == 'nonStriker') {
      nonStriker.value = p;
    } else if (role == 'bowler') {
      bowler.value = p;
    }
    _saveOngoingState();
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
        'catches': p.catches,
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
        p.catches = baselineStats[p.id]!['catches'] ?? 0;
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
    String? outPlayerId,
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
        getPlayerMatchOversBowled(pBowler) >=
            matchSettings.value!.maxOversPerBowler &&
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
        outPlayerId: outPlayerId,
        batsmanRuns: batsmanRuns,
        innings: isFirstInnings.value ? 1 : 2,
      ),
    );

    selectedWagonDirection.value = "";

    // Track runs before rebuild for milestone detection
    int runsBefore = getPlayerMatchRuns(striker.value);

    if (runs % 2 != 0 && extraType == "") swapBatsmen();

    _rebuildFromEvents();

    // Milestone detection (only for T10/T20)
    if (isShortFormat && !isWicket) {
      // After swap, the player who scored may now be nonStriker
      Player? scoringPlayer = (runs % 2 != 0 && extraType == "")
          ? nonStriker.value
          : striker.value;
      int runsAfter = getPlayerMatchRuns(scoringPlayer);
      if (runsBefore < 50 && runsAfter >= 50) {
        _triggerMilestone(scoringPlayer!, 50);
      } else if (runsBefore < 100 && runsAfter >= 100) {
        _triggerMilestone(scoringPlayer!, 100);
      }
    }

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
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 8),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Select Next ${role.capitalizeFirst}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Divider(color: AppTheme.border),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    color: AppTheme.primaryLight,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Add New Custom Player',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryLight,
                  ),
                ),
                onTap: () {
                  Get.back(); // Close bottom sheet
                  _addNewPlayerDialog(role, team);
                },
              ),
              Divider(color: AppTheme.border),
              ...team.players
                  .where((p) {
                    if (role == 'striker' || role == 'nonStriker') {
                      if (p.id == striker.value?.id ||
                          p.id == nonStriker.value?.id)
                        return false;
                      if (outPlayersIds.contains(p.id)) return false;
                    } else if (role == 'bowler') {
                      if (p.id == lastOverBowlerId.value) return false;
                    }
                    return true;
                  })
                  .map(
                    (p) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.surfaceElevated,
                        child: Text(
                          p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(
                        p.name,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        changePlayer(role, p);
                        Get.back();
                      },
                    ),
                  ),
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
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
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
                  'catches': 0,
                };
                changePlayer(role, newPlayer);
                Get.back();
              }
            },
            child: Text('Add & Select'),
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

    int simOvers = 0;
    int simBalls = 0;
    int simRuns = 0;
    int simWickets = 0;
    List<String> simHistory = [];

    int currentInnings = 1;
    String? currentBowler;
    String? finishedOverBowler;
    List<String> currentOuts = [];

    // Over-by-over tracking for graphs
    List<int> i1Overs = [];
    List<int> i2Overs = [];
    int overRunAccum = 0;

    for (var e in allEvents) {
      if (e.innings != currentInnings) {
        // Save partial over before switching innings
        if (overRunAccum > 0 || simBalls > 0) {
          i1Overs.add(overRunAccum);
        }
        currentInnings = e.innings;
        simOvers = 0;
        simBalls = 0;
        simRuns = 0;
        simWickets = 0;
        simHistory.clear();
        finishedOverBowler = null;
        currentOuts.clear();
        overRunAccum = 0;
      }

      currentBowler = e.bowlerId;

      // Support custom players by searching in the match's active team references
      List<Player> localPlayers = [...team1Ref.players, ...team2Ref.players];
      Player pStriker = localPlayers.firstWhere(
        (p) => p.id == e.strikerId,
        orElse: () => Player(id: e.strikerId, name: 'Unknown'),
      );
      Player pBowler = localPlayers.firstWhere(
        (p) => p.id == e.bowlerId,
        orElse: () => Player(id: e.bowlerId, name: 'Unknown'),
      );

      if (e.extraType == "") {
        simRuns += e.runs;
        simBalls++;
        pStriker.runsScored += e.runs;
        pStriker.ballsFaced += 1;
        if (e.runs == 4) pStriker.fours++;
        if (e.runs == 6) pStriker.sixes++;
        simHistory.add(e.isWicket ? 'W' : e.runs.toString());
      } else {
        simRuns += e.runs;
        if (e.extraType == 'NB') {
          simHistory.add('${e.runs}NB');
          pStriker.runsScored += e.batsmanRuns;
          if (e.batsmanRuns == 4) pStriker.fours++;
          if (e.batsmanRuns == 6) pStriker.sixes++;
          pStriker.ballsFaced += 1;
        } else {
          simHistory.add(e.extraType);
          if (e.extraType != 'WD') {
            pStriker.runsScored += e.runs > 0 ? e.runs - 1 : 0;
            pStriker.ballsFaced += 1;
          }
        }
      }

      pBowler.runsConceded += e.runs;
      overRunAccum += e.runs;

      if (e.isWicket) {
        simWickets++;
        currentOuts.add(e.outPlayerId ?? e.strikerId);
        if (e.wicketType != 'Run Out') {
          pBowler.wicketsTaken++;
        }
        if (e.catcherId != null) {
          Player? pCatcher = localPlayers.firstWhereOrNull(
            (p) => p.id == e.catcherId,
          );
          if (pCatcher != null) {
            pCatcher.catches++;
            pCatcher.updateMVPPoints();
          }
        }
      }

      if (simBalls == 6) {
        simBalls = 0;
        simOvers++;
        pBowler.oversBowled++;
        simHistory.clear();
        finishedOverBowler = currentBowler;
        // Record completed over runs
        if (currentInnings == 1) {
          i1Overs.add(overRunAccum);
        } else {
          i2Overs.add(overRunAccum);
        }
        overRunAccum = 0;
      }

      pStriker.updateMVPPoints();
      pBowler.updateMVPPoints();
    }

    if (!isFirstInnings.value && currentInnings == 1) {
      simOvers = 0;
      simBalls = 0;
      simRuns = 0;
      simWickets = 0;
      simHistory.clear();
      finishedOverBowler = null;
      currentOuts.clear();
    }

    currentOvers.value = simOvers;
    currentBalls.value = simBalls;
    totalRuns.value = simRuns;
    wickets.value = simWickets;

    outPlayersIds.assignAll(currentOuts);
    lastOverBowlerId.value = finishedOverBowler;

    historyRuns.clear();
    historyRuns.addAll(simHistory);

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

    // Update over-by-over graph data
    innings1OverRuns.assignAll(i1Overs);
    innings2OverRuns.assignAll(i2Overs);

    Get.find<AppController>().saveData();
  }

  void _triggerMilestone(Player player, int milestone) {
    int runs = getPlayerMatchRuns(player);
    int balls = getPlayerMatchBalls(player);
    int fours =
        (player.fours) - ((baselineStats[player.id]?['fours'] as int?) ?? 0);
    int sixes =
        (player.sixes) - ((baselineStats[player.id]?['sixes'] as int?) ?? 0);
    double sr = balls > 0 ? (runs / balls) * 100 : 0.0;

    lastMilestone.value = {
      'name': player.name,
      'milestone': milestone,
      'runs': runs,
      'balls': balls,
      'fours': fours,
      'sixes': sixes,
      'strikeRate': sr,
    };
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
  int get ballsRemaining =>
      (matchSettings.value!.totalOvers * 6) -
      (currentOvers.value * 6 + currentBalls.value);

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

    int t1Wins = 0, t1Losses = 0, t1Points = 0;
    int t2Wins = 0, t2Losses = 0, t2Points = 0;

    // Distribute team Win/Loss
    if (matchResult.value.contains(team1Ref.name) &&
        !matchResult.value.contains('Tied')) {
      t1Wins = 1;
      t2Losses = 1;
      t1Points = 2;
    } else if (matchResult.value.contains(team2Ref.name) &&
        !matchResult.value.contains('Tied')) {
      t2Wins = 1;
      t1Losses = 1;
      t2Points = 2;
    } else {
      t1Points = 1;
      t2Points = 1;
    }

    int t1RunsScored = 0,
        t1OversFaced = 0,
        t1RunsConceded = 0,
        t1OversBowled = 0;
    int t2RunsScored = 0,
        t2OversFaced = 0,
        t2RunsConceded = 0,
        t2OversBowled = 0;

    if (batTeamRef.id == team1Ref.id) {
      t1RunsScored = totalRuns.value;
      t1OversFaced = currentOvers.value;
      t2RunsConceded = totalRuns.value;
      t2OversBowled = currentOvers.value;

      t2RunsScored = targetRuns.value > 0 ? targetRuns.value - 1 : 0;
      t2OversFaced = matchSettings.value!.totalOvers;
      t1RunsConceded = targetRuns.value > 0 ? targetRuns.value - 1 : 0;
      t1OversBowled = matchSettings.value!.totalOvers;
    } else {
      t2RunsScored = totalRuns.value;
      t2OversFaced = currentOvers.value;
      t1RunsConceded = totalRuns.value;
      t1OversBowled = currentOvers.value;

      t1RunsScored = targetRuns.value > 0 ? targetRuns.value - 1 : 0;
      t1OversFaced = matchSettings.value!.totalOvers;
      t2RunsConceded = targetRuns.value > 0 ? targetRuns.value - 1 : 0;
      t2OversBowled = matchSettings.value!.totalOvers;
    }

    // Apply the deltas
    team1Ref.wins += t1Wins;
    team1Ref.losses += t1Losses;
    team1Ref.points += t1Points;
    team1Ref.matchesPlayed++;
    team2Ref.wins += t2Wins;
    team2Ref.losses += t2Losses;
    team2Ref.points += t2Points;
    team2Ref.matchesPlayed++;

    team1Ref.totalRunsScored += t1RunsScored;
    team1Ref.totalOversFaced += t1OversFaced;
    team1Ref.totalRunsConceded += t1RunsConceded;
    team1Ref.totalOversBowled += t1OversBowled;

    team2Ref.totalRunsScored += t2RunsScored;
    team2Ref.totalOversFaced += t2OversFaced;
    team2Ref.totalRunsConceded += t2RunsConceded;
    team2Ref.totalOversBowled += t2OversBowled;

    Map<String, dynamic> team1Deltas = {
      'wins': t1Wins,
      'losses': t1Losses,
      'points': t1Points,
      'matchesPlayed': 1,
      'runsScored': t1RunsScored,
      'oversFaced': t1OversFaced,
      'runsConceded': t1RunsConceded,
      'oversBowled': t1OversBowled,
    };
    Map<String, dynamic> team2Deltas = {
      'wins': t2Wins,
      'losses': t2Losses,
      'points': t2Points,
      'matchesPlayed': 1,
      'runsScored': t2RunsScored,
      'oversFaced': t2OversFaced,
      'runsConceded': t2RunsConceded,
      'oversBowled': t2OversBowled,
    };

    // Calculate Detailed Stats and Man of the Match
    List<Map<String, dynamic>> battingStats = [];
    List<Map<String, dynamic>> bowlingStats = [];
    Map<String, dynamic> playerDeltas = {};
    Player? motm;
    int maxMatchMVP = -100;

    List<Player> allMatchPlayers = [...team1Ref.players, ...team2Ref.players];
    for (var p in allMatchPlayers) {
      p.matchesPlayed++;

      int r = getPlayerMatchRuns(p);
      int b = getPlayerMatchBalls(p);
      int w = getPlayerMatchWickets(p);
      int rc = getPlayerMatchRunsConceded(p);
      int o = getPlayerMatchOversBowled(p);

      int f = (p.fours) - ((baselineStats[p.id]?['fours'] as int?) ?? 0);
      int sx = (p.sixes) - ((baselineStats[p.id]?['sixes'] as int?) ?? 0);
      int c = (p.catches) - ((baselineStats[p.id]?['catches'] as int?) ?? 0);

      playerDeltas[p.id] = {
        'runsScored': r,
        'ballsFaced': b,
        'wicketsTaken': w,
        'runsConceded': rc,
        'oversBowled': o,
        'fours': f,
        'sixes': sx,
        'catches': c,
      };

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
    String i1S = firstInningsScore.value.isEmpty
        ? '${totalRuns.value}/${wickets.value}'
        : firstInningsScore.value;
    String i2S = firstInningsScore.value.isEmpty
        ? 'DNB'
        : '${totalRuns.value}/${wickets.value}';

    CompletedMatch cMatch = CompletedMatch(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      team1Name: team1Ref.name,
      team2Name: team2Ref.name,
      team1Id: team1Ref.id,
      team2Id: team2Ref.id,
      date: DateTime.now().toString().substring(0, 10),
      result: matchResult.value,
      tournamentId: matchSettings.value!.tournamentId,
      team1Score: batTeamRef.id == team1Ref.id ? i2S : i1S,
      team2Score: batTeamRef.id == team2Ref.id ? i2S : i1S,
      manOfTheMatch: motm?.name ?? "N/A",
      battingPerformances: battingStats,
      bowlingPerformances: bowlingStats,
      playerDeltas: playerDeltas,
      team1Deltas: team1Deltas,
      team2Deltas: team2Deltas,
    );

    mainCtrl.completedMatches.add(cMatch);
    mainCtrl.saveData();
    mainCtrl.clearOngoingMatch();

    Get.offAll(() => const HomeScreen());
  }
}
