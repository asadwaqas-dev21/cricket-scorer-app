import 'package:cricket_score/core/models/team.dart';
import 'package:cricket_score/core/models/tournament.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../app_controller.dart';
import '../../scoring/controllers/scoring_controller.dart';
import '../../../core/models/match_settings.dart';
import '../../scoring/screens/scoring_screen.dart';

class MatchSetupScreen extends StatefulWidget {
  @override
  _MatchSetupScreenState createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  final mainController = Get.find<AppController>();

  String? team1Id;
  String? team2Id;
  String? tossWinnerId;
  String optTo = 'Bat';
  int totalOvers = 20;
  int maxOversPerBowler = 4;
  String? tournamentId;
  List<String> playingSquad1 = [];
  List<String> playingSquad2 = [];

  final overOptions = [2, 4, 5, 10, 20];
  bool isCustomOver = false;
  final customOverController = TextEditingController();

  void _startMatch() {
    if (team1Id == null || team2Id == null || tossWinnerId == null) {
      Get.snackbar(
        'Incomplete Setup',
        'Please select teams and toss winner',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (team1Id == team2Id) {
      Get.snackbar(
        'Invalid Selection',
        'Team 1 and Team 2 cannot be the same',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    int finalOvers = totalOvers;
    if (isCustomOver) {
      finalOvers = int.tryParse(customOverController.text) ?? 0;
      if (finalOvers <= 0) {
        Get.snackbar(
          'Invalid Overs',
          'Please enter a valid number of overs',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    int bowlerOvers;
    if (finalOvers <= 2) {
      bowlerOvers = 1;
    } else if (finalOvers <= 5) {
      bowlerOvers = 2;
    } else if (finalOvers <= 10) {
      bowlerOvers = 3;
    } else {
      bowlerOvers = (finalOvers / 5).ceil();
    }

    var scoringController = Get.put(ScoringController());
    scoringController.setupMatch(
      MatchSettings(
        totalOvers: finalOvers,
        team1Id: team1Id!,
        team2Id: team2Id!,
        tossWinnerId: tossWinnerId!,
        optTo: optTo,
        maxOversPerBowler: bowlerOvers,
        tournamentId: tournamentId,
        playingSquad1: playingSquad1,
        playingSquad2: playingSquad2,
      ),
    );

    Get.off(() => ScoringScreen());
  }

  @override
  Widget build(BuildContext context) {
    var teams = mainController.teams;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppTheme.surface),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Match Setup',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Configure your match',
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tournament
                    if (mainController.tournaments.isNotEmpty) ...[
                      _buildSectionLabel('TOURNAMENT (OPTIONAL)'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.emoji_events_rounded,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        value: tournamentId,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text(
                              'None (Friendly Match)',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                          ...mainController.tournaments
                              .map<DropdownMenuItem<String>>(
                                (Tournament t) => DropdownMenuItem<String>(
                                  value: t.id,
                                  child: Text(
                                    t.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            tournamentId = val;
                            team1Id = null;
                            team2Id = null;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    _buildSectionLabel('TEAMS'),
                    const SizedBox(height: 8),
                    // Team 1 & 2 row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Team 1',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                            ),
                            isExpanded: true,
                            value: team1Id,
                            items: _filteredTeams(teams)
                                .map<DropdownMenuItem<String>>(
                                  (Team t) => DropdownMenuItem<String>(
                                    value: t.id,
                                    child: Text(
                                      t.name,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                team1Id = val;
                                if (tossWinnerId != team1Id &&
                                    tossWinnerId != team2Id) {
                                  tossWinnerId = null;
                                }
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: const Text(
                              'VS',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Team 2',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                            ),
                            isExpanded: true,
                            value: team2Id,
                            items: _filteredTeams(teams)
                                .map<DropdownMenuItem<String>>(
                                  (Team t) => DropdownMenuItem<String>(
                                    value: t.id,
                                    child: Text(
                                      t.name,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                team2Id = val;
                                if (tossWinnerId != team1Id &&
                                    tossWinnerId != team2Id) {
                                  tossWinnerId = null;
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    // Squad selectors
                    if (team1Id != null) ...[
                      const SizedBox(height: 10),
                      _squadButton(
                        'Team 1 Playing Squad',
                        playingSquad1.length,
                        () => _selectSquad(
                          teams.firstWhere((t) => t.id == team1Id!),
                          playingSquad1,
                        ),
                      ),
                    ],
                    if (team2Id != null) ...[
                      const SizedBox(height: 8),
                      _squadButton(
                        'Team 2 Playing Squad',
                        playingSquad2.length,
                        () => _selectSquad(
                          teams.firstWhere((t) => t.id == team2Id!),
                          playingSquad2,
                        ),
                      ),
                    ],

                    // Toss
                    if (team1Id != null && team2Id != null) ...[
                      const SizedBox(height: 20),
                      _buildSectionLabel('TOSS'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Won By',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                              ),
                              isExpanded: true,
                              value: tossWinnerId,
                              items: [
                                DropdownMenuItem(
                                  value: team1Id,
                                  child: Text(
                                    teams
                                        .firstWhere((t) => t.id == team1Id)
                                        .name,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: team2Id,
                                  child: Text(
                                    teams
                                        .firstWhere((t) => t.id == team2Id)
                                        .name,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              onChanged: (val) =>
                                  setState(() => tossWinnerId = val),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Elected To',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                              ),
                              isExpanded: true,
                              value: optTo,
                              items: ['Bat', 'Bowl']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) => setState(() => optTo = val!),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),
                    _buildSectionLabel('OVERS'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...overOptions.map(
                          (o) => _overChip(
                            '$o',
                            totalOvers == o && !isCustomOver,
                            () => setState(() {
                              totalOvers = o;
                              isCustomOver = false;
                            }),
                          ),
                        ),
                        _overChip(
                          'Custom',
                          isCustomOver,
                          () => setState(() => isCustomOver = true),
                        ),
                      ],
                    ),
                    if (isCustomOver) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: customOverController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Enter Overs',
                          prefixIcon: Icon(
                            Icons.timer_outlined,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: _startMatch,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_cricket_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Start Match',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Team> _filteredTeams(List<Team> teams) {
    return teams
        .where(
          (t) =>
              tournamentId == null ||
              mainController.tournaments
                  .firstWhere((tour) => tour.id == tournamentId)
                  .teamIds
                  .contains(t.id),
        )
        .toList();
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _squadButton(String label, int count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(
                Icons.people_rounded,
                color: AppTheme.primaryLight,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: count > 0
                    ? AppTheme.primary.withOpacity(0.2)
                    : AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count > 0 ? '$count selected' : 'Select',
                style: TextStyle(
                  fontSize: 12,
                  color: count > 0 ? AppTheme.primaryLight : AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.primaryGradient : null,
          color: selected ? null : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _selectSquad(team, List<String> selectedSquad) {
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('${team.name} Squad'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    children: team.players
                        .map<Widget>(
                          (p) => CheckboxListTile(
                            title: Text(
                              p.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            value: selectedSquad.contains(p.id),
                            onChanged: (val) {
                              setModalState(() {
                                if (val == true)
                                  selectedSquad.add(p.id);
                                else
                                  selectedSquad.remove(p.id);
                              });
                              setState(() {});
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
