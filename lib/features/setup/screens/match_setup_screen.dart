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
  const MatchSetupScreen({super.key});

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

  // Track setup progress
  int get _completedSteps {
    int s = 0;
    if (team1Id != null) s++;
    if (team2Id != null) s++;
    if (tossWinnerId != null) s++;
    return s;
  }

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
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final bool canStart =
        team1Id != null &&
        team2Id != null &&
        tossWinnerId != null &&
        team1Id != team2Id;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.darkGradient),
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(top),
            // ── Body ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress indicator
                    _buildProgress(),
                    SizedBox(height: 24),

                    // Tournament
                    if (mainController.tournaments.isNotEmpty) ...[
                      _buildCard(
                        title: 'Tournament',
                        subtitle: 'Optional',
                        child: _buildTournamentPicker(),
                      ),
                      SizedBox(height: 16),
                    ],

                    // Teams
                    _buildCard(
                      title: 'Select Teams',
                      child: _buildTeamsPicker(teams),
                    ),

                    // Squad selectors
                    if (team1Id != null || team2Id != null) ...[
                      SizedBox(height: 16),
                      _buildCard(
                        title: 'Playing Squad',
                        subtitle: 'Optional',
                        child: Column(
                          children: [
                            if (team1Id != null)
                              _squadButton(
                                teams.firstWhere((t) => t.id == team1Id!).name,
                                playingSquad1.length,
                                () => _selectSquad(
                                  teams.firstWhere((t) => t.id == team1Id!),
                                  playingSquad1,
                                ),
                              ),
                            if (team1Id != null && team2Id != null)
                              SizedBox(height: 10),
                            if (team2Id != null)
                              _squadButton(
                                teams.firstWhere((t) => t.id == team2Id!).name,
                                playingSquad2.length,
                                () => _selectSquad(
                                  teams.firstWhere((t) => t.id == team2Id!),
                                  playingSquad2,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],

                    // Toss
                    if (team1Id != null &&
                        team2Id != null &&
                        team1Id != team2Id) ...[
                      SizedBox(height: 16),
                      _buildCard(title: 'Toss', child: _buildTossPicker(teams)),
                    ],

                    // Overs
                    SizedBox(height: 16),
                    _buildCard(title: 'Overs', child: _buildOversPicker()),

                    SizedBox(height: 28),

                    // Start button
                    _buildStartButton(canStart),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  HEADER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(double top) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 14, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A6B3C), Color(0xFF145230), Color(0xFF0E3E22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E4526).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Match Setup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Configure your match',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  PROGRESS DOTS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildProgress() {
    return Row(
      children: [
        _dot(team1Id != null, 'Team 1'),
        _line(team1Id != null && team2Id != null),
        _dot(team2Id != null, 'Team 2'),
        _line(team2Id != null && tossWinnerId != null),
        _dot(tossWinnerId != null, 'Toss'),
      ],
    );
  }

  Widget _dot(bool done, String label) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppTheme.primaryLight : AppTheme.surfaceCard,
            border: Border.all(
              color: done ? AppTheme.primaryLight : AppTheme.border,
              width: 2,
            ),
          ),
          child: done
              ? Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : null,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: done ? AppTheme.textPrimary : AppTheme.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _line(bool active) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: 18),
        child: Container(
          height: 2,
          margin: EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryLight : AppTheme.border,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  CARD WRAPPER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  TOURNAMENT PICKER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTournamentPicker() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.emoji_events_rounded, color: AppTheme.textMuted),
      ),
      initialValue: tournamentId,
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(
            'None (Friendly Match)',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        ...mainController.tournaments.map<DropdownMenuItem<String>>(
          (Tournament t) => DropdownMenuItem<String>(
            value: t.id,
            child: Text(t.name, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: (val) => setState(() {
        tournamentId = val;
        team1Id = null;
        team2Id = null;
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  TEAMS PICKER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTeamsPicker(List<Team> teams) {
    final filtered = _filteredTeams(teams);
    return Row(
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
            initialValue: team1Id,
            items: filtered
                .where((t) => t.id != team2Id)
                .map<DropdownMenuItem<String>>(
                  (Team t) => DropdownMenuItem<String>(
                    value: t.id,
                    child: Text(
                      t.name,
                      style: TextStyle(color: AppTheme.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() {
              team1Id = val;
              if (tossWinnerId != team1Id && tossWinnerId != team2Id)
                tossWinnerId = null;
            }),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              'VS',
              style: TextStyle(
                fontSize: 11,
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
            initialValue: team2Id,
            items: filtered
                .where((t) => t.id != team1Id)
                .map<DropdownMenuItem<String>>(
                  (Team t) => DropdownMenuItem<String>(
                    value: t.id,
                    child: Text(
                      t.name,
                      style: TextStyle(color: AppTheme.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() {
              team2Id = val;
              if (tossWinnerId != team1Id && tossWinnerId != team2Id)
                tossWinnerId = null;
            }),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  TOSS PICKER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTossPicker(List<Team> teams) {
    return Row(
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
            initialValue: tossWinnerId,
            items: [
              DropdownMenuItem(
                value: team1Id,
                child: Text(
                  teams.firstWhere((t) => t.id == team1Id).name,
                  style: TextStyle(color: AppTheme.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownMenuItem(
                value: team2Id,
                child: Text(
                  teams.firstWhere((t) => t.id == team2Id).name,
                  style: TextStyle(color: AppTheme.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            onChanged: (val) => setState(() => tossWinnerId = val),
          ),
        ),
        SizedBox(width: 12),
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
            initialValue: optTo,
            items: ['Bat', 'Bowl']
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => optTo = val!),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  OVERS PICKER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildOversPicker() {
    return Column(
      children: [
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
          SizedBox(height: 14),
          TextField(
            controller: customOverController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: 'Enter Overs',
              prefixIcon: Icon(Icons.timer_outlined, color: AppTheme.textMuted),
            ),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  START BUTTON
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStartButton(bool canStart) {
    return AnimatedOpacity(
      opacity: canStart ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: canStart ? _startMatch : null,
          child: Ink(
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: canStart
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                'Start Match',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
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

  Widget _squadButton(String teamName, int count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                teamName,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: count > 0
                    ? AppTheme.primary.withOpacity(0.2)
                    : AppTheme.surfaceCard,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.primaryGradient : null,
          color: selected ? null : AppTheme.surfaceElevated,
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
                              style: TextStyle(color: AppTheme.textPrimary),
                            ),
                            value: selectedSquad.contains(p.id),
                            onChanged: (val) {
                              setModalState(() {
                                if (val == true) {
                                  selectedSquad.add(p.id);
                                } else {
                                  selectedSquad.remove(p.id);
                                }
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
                  child: Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
