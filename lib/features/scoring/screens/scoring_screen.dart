import 'package:cricket_score/core/models/player.dart';
import 'package:cricket_score/core/models/team.dart';
import 'package:cricket_score/features/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cricket_score/core/theme/app_theme.dart';
import 'package:cricket_score/features/scoring/controllers/scoring_controller.dart';

class ScoringScreen extends StatelessWidget {
  final ScoringController controller = Get.find<ScoringController>();

  ScoringScreen({super.key});

  void _changePlayer(BuildContext context, String role) {
    var team = (role == 'bowler')
        ? controller.bowlTeamRef
        : controller.batTeamRef;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        role == 'bowler'
                            ? Icons.sports_baseball
                            : Icons.sports_cricket,
                        color: AppTheme.primaryLight,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Select ${role.capitalizeFirst}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Divider(color: AppTheme.border, height: 1),
              // Add new player option
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    color: AppTheme.accent,
                    size: 18,
                  ),
                ),
                title: Text(
                  'Add Custom Player',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _addNewPlayerDialog(context, role, team);
                },
              ),
              Divider(color: AppTheme.border, height: 1),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: team.players
                      .where((p) {
                        if (role == 'striker' || role == 'nonStriker') {
                          if (p.id == controller.striker.value?.id ||
                              p.id == controller.nonStriker.value?.id) {
                            return false;
                          }
                          if (controller.outPlayersIds.contains(p.id)) {
                            return false;
                          }
                        } else if (role == 'bowler') {
                          if (p.id == controller.lastOverBowlerId.value) {
                            return false;
                          }
                        }
                        return true;
                      })
                      .map(
                        (p) => ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppTheme.primary.withOpacity(0.2),
                            child: Text(
                              p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: AppTheme.primaryLight,
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
                            controller.changePlayer(role, p);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _addNewPlayerDialog(BuildContext context, String role, Team team) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add New ${role.capitalizeFirst}'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Enter player name',
            labelText: 'Player Name',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                String newId =
                    '${team.id}_${DateTime.now().millisecondsSinceEpoch}';
                Player newPlayer = Player(
                  id: newId,
                  name: nameController.text.trim(),
                );
                team.players.add(newPlayer);
                controller.baselineStats[newPlayer.id] = {
                  'runsScored': 0,
                  'ballsFaced': 0,
                  'wicketsTaken': 0,
                  'oversBowled': 0,
                  'runsConceded': 0,
                  'fours': 0,
                  'sixes': 0,
                  'catches': 0,
                };
                controller.changePlayer(role, newPlayer);
                Navigator.pop(context);
              }
            },
            child: Text('Add & Select'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for milestone celebrations
    ever(controller.lastMilestone, (milestone) {
      if (milestone != null) {
        _showMilestoneDialog(context, milestone);
        controller.lastMilestone.value = null;
      }
    });

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppTheme.accent),
                SizedBox(width: 8),
                Text(
                  'Exit Match?',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              ],
            ),
            content: Text(
              'Your match progress is auto-saved. You can resume from the home screen.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            backgroundColor: AppTheme.surfaceElevated,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.find<AppController>().clearOngoingMatch();
                  Get.delete<ScoringController>();
                  Navigator.pop(context, true);
                },
                child: Text('Discard', style: TextStyle(color: AppTheme.red)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // _saveOngoingState is already called on every event change via ever()
                  Get.delete<ScoringController>();
                  Navigator.pop(context, true);
                },
                child: Text(
                  'Save & Exit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: AppTheme.surface),
          child: Obx(() {
            if (controller.matchSettings.value == null) {
              return Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }
            return Column(
              children: [
                // ── Live Scoreboard Header ──
                _buildScoreboard(context),
                // ── Batsmen & Bowler ──
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildBatsmenPanel(context),
                        _buildBowlerPanel(context),
                        _buildThisOver(),
                        // ── Over-by-over Graph (T10/T20 only) ──
                        if (controller.isShortFormat) _buildOverGraph(),
                        SizedBox(height: 12),
                        // ── Match Over or Scoring Buttons ──
                        if (controller.matchResult.value.isNotEmpty)
                          _buildMatchResultBanner()
                        else
                          _buildScoringButtons(context),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildScoreboard(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top row: team name + undo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    final shouldPop = await Navigator.maybePop(context);
                    if (!shouldPop) {
                      // MaybePop handles WillPopScope automatically
                    }
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        controller.batTeamName.value,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'BATTING',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.undo_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  tooltip: 'Undo Last Ball',
                  onPressed: () => controller.undoLast(),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Big score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.totalRuns.value}/${controller.wickets.value}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${controller.currentOvers.value}.${controller.currentBalls.value} / ${controller.matchSettings.value!.totalOvers} OV',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _rateChip(
                      'CRR',
                      controller.runRate.toStringAsFixed(2),
                      Colors.white.withOpacity(0.2),
                    ),
                    SizedBox(height: 6),
                    if (!controller.isFirstInnings.value) ...[
                      _rateChip(
                        'RRR',
                        controller.requiredRunRate.toStringAsFixed(2),
                        AppTheme.accent.withOpacity(0.3),
                      ),
                      SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.red.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.red.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          'Need ${controller.runsNeeded} in ${controller.ballsRemaining}b',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    if (controller.isFirstInnings.value == false)
                      SizedBox.shrink()
                    else
                      SizedBox(height: 4),
                  ],
                ),
              ],
            ),
            if (!controller.isFirstInnings.value) ...[
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flag_rounded, color: AppTheme.accent, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'TARGET: ${controller.targetRuns.value}',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _rateChip(String label, String value, Color bg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label  ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatsmenPanel(BuildContext context) {
    return Obx(
      () => Container(
        margin: EdgeInsets.fromLTRB(12, 12, 12, 0),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.sports_cricket_rounded,
                      color: AppTheme.primaryLight,
                      size: 14,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'BATTING',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => controller.swapBatsmen(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            color: AppTheme.primaryLight,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'SWAP',
                            style: TextStyle(
                              color: AppTheme.primaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: AppTheme.border, height: 16),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  Expanded(child: _batsmanTile(context, 'striker', true)),
                  Container(width: 1, height: 54, color: AppTheme.border),
                  Expanded(child: _batsmanTile(context, 'nonStriker', false)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _batsmanTile(BuildContext context, String role, bool isStriker) {
    final player = isStriker
        ? controller.striker.value
        : controller.nonStriker.value;
    return GestureDetector(
      onTap: () => _changePlayer(context, role),
      child: Padding(
        padding: EdgeInsets.only(
          left: isStriker ? 0 : 12,
          right: isStriker ? 12 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isStriker ? '🏏 ON STRIKE' : 'NON-STRIKER',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isStriker ? AppTheme.accent : AppTheme.textMuted,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.edit_rounded, size: 10, color: AppTheme.textMuted),
              ],
            ),
            SizedBox(height: 4),
            Text(
              player?.name ?? 'Select Player',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: player != null
                    ? AppTheme.textPrimary
                    : AppTheme.textMuted,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            Text(
              '${controller.getPlayerMatchRuns(player)}(${controller.getPlayerMatchBalls(player)}) SR:${controller.getPlayerMatchStrikeRate(player).toStringAsFixed(0)}',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBowlerPanel(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () => _changePlayer(context, 'bowler'),
        child: Container(
          margin: EdgeInsets.fromLTRB(12, 8, 12, 0),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.sports_baseball_rounded,
                  color: AppTheme.blue,
                  size: 18,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BOWLING',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      controller.bowler.value?.name ?? 'Select Bowler',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: controller.bowler.value != null
                            ? AppTheme.textPrimary
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${controller.getPlayerMatchWickets(controller.bowler.value)}-${controller.getPlayerMatchRunsConceded(controller.bowler.value)} (${controller.getPlayerMatchOversBowled(controller.bowler.value)})',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.edit_rounded, size: 14, color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThisOver() {
    return Obx(
      () => Container(
        margin: EdgeInsets.fromLTRB(12, 8, 12, 0),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Text(
              'THIS OVER',
              style: TextStyle(
                fontSize: 9,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: controller.historyRuns.map((r) {
                  Color bg;
                  Color fg = Colors.white;
                  if (r == 'W') {
                    bg = AppTheme.red;
                  } else if (r == '4') {
                    bg = AppTheme.blue;
                  } else if (r == '6') {
                    bg = const Color(0xFF7B5EA7);
                  } else if (r == 'WD' || r == 'NB') {
                    bg = AppTheme.textMuted;
                    fg = AppTheme.textPrimary;
                  } else {
                    bg = AppTheme.surfaceElevated;
                    fg = AppTheme.textSecondary;
                  }
                  return Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      r,
                      style: TextStyle(
                        color: fg,
                        fontSize: r.length > 1 ? 9 : 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoringButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10),
          Text(
            'SCORING',
            style: TextStyle(
              fontSize: 9,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 8),
          // Runs row: 0, 1, 2, 3
          Row(
            children: [
              Expanded(
                child: _scoreBtn(
                  context,
                  '0',
                  () => controller.recordEvent(runs: 0),
                  bgColor: AppTheme.surfaceCard,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _scoreBtn(
                  context,
                  '1',
                  () => controller.recordEvent(runs: 1),
                  bgColor: AppTheme.surfaceCard,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _scoreBtn(
                  context,
                  '2',
                  () => controller.recordEvent(runs: 2),
                  bgColor: AppTheme.surfaceCard,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _scoreBtn(
                  context,
                  '3',
                  () => controller.recordEvent(runs: 3),
                  bgColor: AppTheme.surfaceCard,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Special row: 4, 6, W, WD, NB
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _scoreBtn(
                  context,
                  '4',
                  () => controller.recordEvent(runs: 4),
                  gradient: AppTheme.blueGradient,
                  featured: true,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _scoreBtn(
                  context,
                  '6',
                  () => controller.recordEvent(runs: 6),
                  gradient: AppTheme.purpleGradient,
                  featured: true,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _scoreBtn(
                  context,
                  'W',
                  () => _showWicketDialog(context),
                  gradient: AppTheme.redGradient,
                  featured: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _scoreBtn(
                  context,
                  'WIDE',
                  () => controller.recordEvent(runs: 1, extraType: 'WD'),
                  bgColor: AppTheme.surfaceElevated,
                  smallText: true,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _scoreBtn(
                  context,
                  'NO BALL',
                  () => _showNBDialog(context),
                  bgColor: AppTheme.surfaceElevated,
                  smallText: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scoreBtn(
    BuildContext context,
    String label,
    VoidCallback onTap, {
    Color? bgColor,
    Gradient? gradient,
    bool featured = false,
    bool smallText = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: featured ? 62 : 52,
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? bgColor : null,
          borderRadius: BorderRadius.circular(14),
          border: gradient == null ? Border.all(color: AppTheme.border) : null,
          boxShadow: gradient != null
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: smallText ? 13 : (featured ? 24 : 20),
            fontWeight: FontWeight.w900,
            color: gradient != null ? Colors.white : AppTheme.textPrimary,
            letterSpacing: smallText ? 1 : -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchResultBanner() {
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A6B3C), Color(0xFF0A3D22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              size: 48,
              color: AppTheme.accent,
            ),
          ),
          SizedBox(height: 16),
          Text(
            controller.matchResult.value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () => controller.finalizeAndExit(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Finish & Save Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWicketDialog(BuildContext context) {
    String selectedType = 'Bowled';
    String? catcherId;
    String? outPlayerId = controller.striker.value?.id;
    String extraType = "";
    int batsmanRuns = 0;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.sports_cricket_rounded, color: AppTheme.red),
                  SizedBox(width: 10),
                  Text('Wicket Details'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Dismissal Type',
                    ),
                    initialValue: selectedType,
                    dropdownColor: AppTheme.surfaceElevated,
                    style: TextStyle(color: AppTheme.textPrimary),
                    items: ['Bowled', 'Caught', 'Run Out', 'LBW', 'Stumped']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedType = val!;
                        if (selectedType != 'Caught') catcherId = null;
                      });
                    },
                  ),
                  if (selectedType == 'Caught') ...[
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Caught By'),
                      initialValue: catcherId,
                      dropdownColor: AppTheme.surfaceElevated,
                      style: TextStyle(color: AppTheme.textPrimary),
                      items: controller.bowlTeamRef.players
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setModalState(() => catcherId = val);
                      },
                    ),
                  ],
                  if (selectedType == 'Run Out') ...[
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Who got out?',
                      ),
                      initialValue: outPlayerId,
                      dropdownColor: AppTheme.surfaceElevated,
                      style: TextStyle(color: AppTheme.textPrimary),
                      items: [
                        if (controller.striker.value != null)
                          DropdownMenuItem(
                            value: controller.striker.value!.id,
                            child: Text(
                              '${controller.striker.value!.name} (Striker)',
                            ),
                          ),
                        if (controller.nonStriker.value != null)
                          DropdownMenuItem(
                            value: controller.nonStriker.value!.id,
                            child: Text(
                              '${controller.nonStriker.value!.name} (Non-Striker)',
                            ),
                          ),
                      ],
                      onChanged: (val) {
                        setModalState(() => outPlayerId = val);
                      },
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Delivery Type',
                      ),
                      initialValue: extraType,
                      dropdownColor: AppTheme.surfaceElevated,
                      style: TextStyle(color: AppTheme.textPrimary),
                      items: [
                        DropdownMenuItem(
                          value: "",
                          child: Text('Legal Delivery'),
                        ),
                        DropdownMenuItem(value: "WD", child: Text('Wide Ball')),
                        DropdownMenuItem(value: "NB", child: Text('No Ball')),
                      ],
                      onChanged: (val) {
                        setModalState(() => extraType = val!);
                      },
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Runs Completed Before Out',
                      ),
                      initialValue: batsmanRuns,
                      dropdownColor: AppTheme.surfaceElevated,
                      style: TextStyle(color: AppTheme.textPrimary),
                      items: List.generate(
                        7,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Text('$index'),
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() => batsmanRuns = val!);
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (selectedType == 'Caught' && catcherId == null) {
                      Get.snackbar('Error', 'Please select who took the catch');
                      return;
                    }
                    Navigator.pop(ctx);
                    controller.recordEvent(
                      runs: (selectedType == 'Run Out' && extraType != "")
                          ? 1 + batsmanRuns
                          : batsmanRuns,
                      isWicket: true,
                      wicketType: selectedType,
                      catcherId: catcherId,
                      outPlayerId: selectedType == 'Run Out'
                          ? outPlayerId
                          : null,
                      extraType: selectedType == 'Run Out' ? extraType : "",
                      batsmanRuns: selectedType == 'Run Out' ? batsmanRuns : 0,
                    );
                  },
                  child: Text('OUT!'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showNBDialog(BuildContext context) {
    int runsOffBat = 0;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('No Ball'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Runs scored off the bat:',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [0, 1, 2, 3, 4, 6].map((r) {
                      final selected = runsOffBat == r;
                      return GestureDetector(
                        onTap: () => setModalState(() => runsOffBat = r),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: selected
                                ? AppTheme.primaryGradient
                                : null,
                            color: selected ? null : AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.border,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '+$r',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    controller.recordEvent(
                      runs: 1 + runsOffBat,
                      extraType: 'NB',
                      batsmanRuns: runsOffBat,
                    );
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  RUN PROGRESSION "WORM" GRAPH (T10/T20 only)
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildOverGraph() {
    final i1 = controller.innings1OverRuns;
    final i2 = controller.innings2OverRuns;
    if (i1.isEmpty && i2.isEmpty) return SizedBox.shrink();

    // Build cumulative totals
    List<int> cumI1 = [];
    List<int> cumI2 = [];
    int sum = 0;
    for (var r in i1) {
      sum += r;
      cumI1.add(sum);
    }
    sum = 0;
    for (var r in i2) {
      sum += r;
      cumI2.add(sum);
    }

    int maxScore = 1;
    if (cumI1.isNotEmpty && cumI1.last > maxScore) maxScore = cumI1.last;
    if (cumI2.isNotEmpty && cumI2.last > maxScore) maxScore = cumI2.last;
    maxScore = (maxScore * 1.15).ceil();

    int totalOvers = controller.matchSettings.value!.totalOvers;

    String team1Name = '';
    String team2Name = '';
    if (controller.isFirstInnings.value) {
      team1Name = controller.batTeamName.value;
      team2Name = controller.bowlTeamName.value;
    } else {
      team1Name = controller.bowlTeamName.value;
      team2Name = controller.batTeamName.value;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart_rounded,
                color: AppTheme.primaryLight,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Run Progression',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (cumI1.isNotEmpty)
                Text(
                  '${cumI1.last}',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              if (cumI2.isNotEmpty) ...[
                Text(
                  ' vs ',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                Text(
                  '${cumI2.last}',
                  style: TextStyle(
                    color: Color(0xFF42A5F5),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              _legendDot(Color(0xFF4CAF50), team1Name),
              SizedBox(width: 16),
              if (cumI2.isNotEmpty) _legendDot(Color(0xFF42A5F5), team2Name),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, 140),
                  painter: _WormGraphPainter(
                    cumInnings1: cumI1,
                    cumInnings2: cumI2,
                    maxScore: maxScore,
                    totalOvers: totalOvers,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${totalOvers ~/ 4}',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${totalOvers ~/ 2}',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(totalOvers * 3) ~/ 4}',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$totalOvers',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  MILESTONE CELEBRATION (50 / 100)
  // ─────────────────────────────────────────────────────────────────────────────
  void _showMilestoneDialog(BuildContext context, Map<String, dynamic> data) {
    final int milestone = data['milestone'];
    final bool isCentury = milestone >= 100;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isCentury
                  ? [Color(0xFF1A237E), Color(0xFF311B92)]
                  : [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (isCentury ? Color(0xFF311B92) : Color(0xFF2E7D32))
                    .withOpacity(0.5),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCentury ? Icons.emoji_events_rounded : Icons.star_rounded,
                  color: Color(0xFFFFD700),
                  size: 40,
                ),
              ),
              SizedBox(height: 16),
              Text(
                isCentury ? '🎉 CENTURY! 🎉' : '👏 HALF CENTURY! 👏',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFFD700),
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                data['name'] ?? '',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _mileStat('Runs', '${data['runs']}', Color(0xFFFFD700)),
                    _mileDivider(),
                    _mileStat('Balls', '${data['balls']}', Colors.white),
                    _mileDivider(),
                    _mileStat('4s', '${data['fours']}', Color(0xFF4CAF50)),
                    _mileDivider(),
                    _mileStat('6s', '${data['sixes']}', Color(0xFFFF5722)),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'SR: ${(data['strikeRate'] as double).toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mileStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _mileDivider() =>
      Container(width: 1, height: 36, color: Colors.white24);
}

// ─────────────────────────────────────────────────────────────────────────────
//  CUSTOM PAINTER — Cumulative "Worm" line graph
// ─────────────────────────────────────────────────────────────────────────────
class _WormGraphPainter extends CustomPainter {
  final List<int> cumInnings1;
  final List<int> cumInnings2;
  final int maxScore;
  final int totalOvers;

  _WormGraphPainter({
    required this.cumInnings1,
    required this.cumInnings2,
    required this.maxScore,
    required this.totalOvers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double pad = 4;
    final double chartW = w - pad * 2;
    final double chartH = h - pad * 2;

    // Grid lines
    final gridPaint = Paint()
      ..color = Color(0x18FFFFFF)
      ..strokeWidth = 0.8;
    for (int i = 0; i <= 4; i++) {
      double y = pad + chartH - (chartH * i / 4);
      canvas.drawLine(Offset(pad, y), Offset(w - pad, y), gridPaint);
    }

    // Vertical guides every 5 overs
    final dashPaint = Paint()
      ..color = Color(0x10FFFFFF)
      ..strokeWidth = 0.5;
    for (int i = 5; i < totalOvers; i += 5) {
      double x = pad + (i / totalOvers) * chartW;
      canvas.drawLine(Offset(x, pad), Offset(x, h - pad), dashPaint);
    }

    // Draw innings lines
    if (cumInnings1.isNotEmpty) {
      _drawWorm(
        canvas,
        cumInnings1,
        chartW,
        chartH,
        pad,
        Color(0xFF4CAF50),
        Color(0x264CAF50),
      );
    }
    if (cumInnings2.isNotEmpty) {
      _drawWorm(
        canvas,
        cumInnings2,
        chartW,
        chartH,
        pad,
        Color(0xFF42A5F5),
        Color(0x2642A5F5),
      );
    }
  }

  void _drawWorm(
    Canvas canvas,
    List<int> data,
    double chartW,
    double chartH,
    double pad,
    Color lineColor,
    Color fillColor,
  ) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    Path linePath = Path();
    Path fillPath = Path();

    double baseY = pad + chartH;

    double x0 = pad + (1 / totalOvers) * chartW;
    double y0 = pad + chartH - (data[0] / maxScore) * chartH;

    fillPath.moveTo(x0, baseY);
    fillPath.lineTo(x0, y0);
    linePath.moveTo(x0, y0);

    for (int i = 1; i < data.length; i++) {
      double x = pad + ((i + 1) / totalOvers) * chartW;
      double y = pad + chartH - (data[i] / maxScore) * chartH;
      linePath.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    double lastX = pad + (data.length / totalOvers) * chartW;
    fillPath.lineTo(lastX, baseY);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    // Dots at each data point
    for (int i = 0; i < data.length; i++) {
      double x = pad + ((i + 1) / totalOvers) * chartW;
      double y = pad + chartH - (data[i] / maxScore) * chartH;
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
      canvas.drawCircle(
        Offset(x, y),
        3.5,
        Paint()
          ..color = Color(0xFF0D1B2A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
