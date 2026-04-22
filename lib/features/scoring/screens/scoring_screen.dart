import 'package:cricket_score/core/models/player.dart';
import 'package:cricket_score/core/models/team.dart';
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
          padding: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
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
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
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
                    const SizedBox(width: 10),
                    Text(
                      'Select ${role.capitalizeFirst}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: AppTheme.border, height: 1),
              // Add new player option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: AppTheme.accent,
                    size: 18,
                  ),
                ),
                title: const Text(
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
              const Divider(color: AppTheme.border, height: 1),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: team.players
                      .map(
                        (p) => ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppTheme.primary.withOpacity(0.2),
                            child: Text(
                              p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: AppTheme.primaryLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          title: Text(
                            p.name,
                            style: const TextStyle(
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
              const SizedBox(height: 16),
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
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
                };
                controller.changePlayer(role, newPlayer);
                Navigator.pop(context);
              }
            },
            child: const Text('Add & Select'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppTheme.surface),
        child: Obx(() {
          if (controller.matchSettings.value == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }
          return Column(
            children: [
              // ── Live Scoreboard Header ──
              _buildScoreboard(),
              // ── Batsmen & Bowler ──
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildBatsmenPanel(context),
                      _buildBowlerPanel(context),
                      _buildThisOver(),
                      const SizedBox(height: 12),
                      // ── Match Over or Scoring Buttons ──
                      if (controller.matchResult.value.isNotEmpty)
                        _buildMatchResultBanner()
                      else
                        _buildScoringButtons(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildScoreboard() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
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
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () => Get.back(),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        controller.batTeamName.value,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
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
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
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
            const SizedBox(height: 8),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${controller.currentOvers.value}.${controller.currentBalls.value} / ${controller.matchSettings.value!.totalOvers} OV',
                      style: const TextStyle(
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
                    const SizedBox(height: 6),
                    if (!controller.isFirstInnings.value) ...[
                      _rateChip(
                        'RRR',
                        controller.requiredRunRate.toStringAsFixed(2),
                        AppTheme.accent.withOpacity(0.3),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    if (controller.isFirstInnings.value == false)
                      const SizedBox.shrink()
                    else
                      const SizedBox(height: 4),
                  ],
                ),
              ],
            ),
            if (!controller.isFirstInnings.value) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.flag_rounded,
                      color: AppTheme.accent,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'TARGET: ${controller.targetRuns.value}',
                      style: const TextStyle(
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label  ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
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
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.sports_cricket_rounded,
                      color: AppTheme.primaryLight,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
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
            const Divider(color: AppTheme.border, height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
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
                const SizedBox(width: 4),
                Icon(Icons.edit_rounded, size: 10, color: AppTheme.textMuted),
              ],
            ),
            const SizedBox(height: 4),
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
            const SizedBox(height: 2),
            Text(
              '${controller.getPlayerMatchRuns(player)}(${controller.getPlayerMatchBalls(player)}) SR:${controller.getPlayerMatchStrikeRate(player).toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
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
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.sports_baseball_rounded,
                  color: AppTheme.blue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BOWLING',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
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
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.edit_rounded,
                size: 14,
                color: AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThisOver() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const Text(
              'THIS OVER',
              style: TextStyle(
                fontSize: 9,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Text(
            'SCORING',
            style: TextStyle(
              fontSize: 9,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
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
              const SizedBox(width: 8),
              Expanded(
                child: _scoreBtn(
                  context,
                  '1',
                  () => controller.recordEvent(runs: 1),
                  bgColor: AppTheme.surfaceCard,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _scoreBtn(
                  context,
                  '2',
                  () => controller.recordEvent(runs: 2),
                  bgColor: AppTheme.surfaceCard,
                ),
              ),
              const SizedBox(width: 8),
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
          const SizedBox(height: 8),
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
              const SizedBox(width: 8),
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
              const SizedBox(width: 8),
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
          const SizedBox(height: 8),
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
              const SizedBox(width: 8),
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
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              size: 48,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.matchResult.value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => controller.finalizeAndExit(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
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
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Row(
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
                    value: selectedType,
                    dropdownColor: AppTheme.surfaceElevated,
                    style: const TextStyle(color: AppTheme.textPrimary),
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
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Caught By'),
                      value: catcherId,
                      dropdownColor: AppTheme.surfaceElevated,
                      style: const TextStyle(color: AppTheme.textPrimary),
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
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
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
                      runs: 0,
                      isWicket: true,
                      wicketType: selectedType,
                      catcherId: catcherId,
                    );
                  },
                  child: const Text('OUT!'),
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
              title: const Text('No Ball'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Runs scored off the bat:',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
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
                  child: const Text('Cancel'),
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
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
