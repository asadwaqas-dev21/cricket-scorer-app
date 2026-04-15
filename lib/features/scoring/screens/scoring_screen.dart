import 'package:cricket_score/core/models/player.dart';
import 'package:cricket_score/core/models/team.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/scoring_controller.dart';

class ScoringScreen extends StatelessWidget {
  final ScoringController controller = Get.find<ScoringController>();

  void _changePlayer(BuildContext context, String role) {
    var team = (role == 'bowler')
        ? controller.bowlTeamRef
        : controller.batTeamRef;
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select ${role.capitalizeFirst}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                Navigator.pop(context); // Close bottom sheet
                _addNewPlayerDialog(context, role, team);
              },
            ),
            const Divider(),
            ...team.players
                .map(
                  (p) => ListTile(
                    title: Text(p.name),
                    onTap: () {
                      controller.changePlayer(role, p);
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ],
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
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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

                // Initialize baseline stats for the Undo Engine to not crash
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
      appBar: AppBar(
        title: const Text('Live Scoring'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () => controller.undoLast(),
            tooltip: 'Undo Last Ball',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.matchSettings.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.indigo.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${controller.batTeamName} (Bat)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${controller.totalRuns.value}/${controller.wickets.value}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        Text(
                          'Overs: ${controller.currentOvers.value}.${controller.currentBalls.value} / ${controller.matchSettings.value!.totalOvers}',
                        ),
                        if (!controller.isFirstInnings.value)
                          Text(
                            'Target: ${controller.targetRuns.value}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'CRR: ${controller.runRate.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (!controller.isFirstInnings.value) ...[
                          Text(
                            'RRR: ${controller.requiredRunRate.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Need ${controller.runsNeeded} in ${controller.ballsRemaining} balls',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 2, height: 2),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Striker (Bat)',
                            style: TextStyle(color: Colors.grey),
                          ),
                          InkWell(
                            onTap: () => _changePlayer(context, 'striker'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${controller.striker.value?.name ?? "Select"}',
                                  style: const TextStyle(
                                    color: Colors.indigo,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Colors.indigo,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${controller.getPlayerMatchRuns(controller.striker.value)} (${controller.getPlayerMatchBalls(controller.striker.value)})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'SR: ${controller.getPlayerMatchStrikeRate(controller.striker.value).toStringAsFixed(1)}',
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: () => controller.swapBatsmen(),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Non-Striker',
                            style: TextStyle(color: Colors.grey),
                          ),
                          InkWell(
                            onTap: () => _changePlayer(context, 'nonStriker'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${controller.nonStriker.value?.name ?? "Select"}',
                                  style: const TextStyle(
                                    color: Colors.indigo,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Colors.indigo,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${controller.getPlayerMatchRuns(controller.nonStriker.value)} (${controller.getPlayerMatchBalls(controller.nonStriker.value)})',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 2),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text('Bowler', style: TextStyle(color: Colors.grey)),
                    InkWell(
                      onTap: () => _changePlayer(context, 'bowler'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${controller.bowler.value?.name ?? "Select"}',
                            style: const TextStyle(
                              color: Colors.indigo,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.indigo,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${controller.getPlayerMatchWickets(controller.bowler.value)}-${controller.getPlayerMatchRunsConceded(controller.bowler.value)} (${controller.getPlayerMatchOversBowled(controller.bowler.value)})',
                    ),
                  ],
                ),
              ),
              const Divider(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Text(
                      'This Over: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        children: controller.historyRuns
                            .map(
                              (r) => CircleAvatar(
                                radius: 14,
                                backgroundColor: r == 'W'
                                    ? Colors.red
                                    : Colors.indigo.shade200,
                                child: Text(
                                  r,
                                  style: TextStyle(
                                    color: r == 'W'
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (controller.matchResult.value.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 64,
                        color: Colors.yellow,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.matchResult.value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => controller.finalizeAndExit(),
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'Finish & Save Report',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              else
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.5,
                  children: [
                    _scoreBtn('0', () => controller.recordEvent(runs: 0)),
                    _scoreBtn('1', () => controller.recordEvent(runs: 1)),
                    _scoreBtn('2', () => controller.recordEvent(runs: 2)),
                    _scoreBtn('3', () => controller.recordEvent(runs: 3)),
                    _scoreBtn(
                      '4',
                      () => controller.recordEvent(runs: 4),
                      color: Colors.blue,
                    ),
                    _scoreBtn(
                      '6',
                      () => controller.recordEvent(runs: 6),
                      color: Colors.purple,
                    ),
                    _scoreBtn(
                      'W',
                      () => _showWicketDialog(context),
                      color: Colors.red,
                    ),
                    _scoreBtn(
                      'WD',
                      () => controller.recordEvent(runs: 1, extraType: 'WD'),
                    ),
                    _scoreBtn('NB', () => _showNBDialog(context)),
                  ],
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
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
              title: const Text(
                'Wicket Details',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Method'),
                    value: selectedType,
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
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Caught By'),
                      value: catcherId,
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
                    backgroundColor: Colors.red,
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
                  child: const Text('Out!'),
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
              title: const Text('No Ball Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'How many extra runs were scored off the bat?',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [0, 1, 2, 3, 4, 6]
                        .map(
                          (r) => ChoiceChip(
                            label: Text(
                              '+$r',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: runsOffBat == r
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            selectedColor: Colors.indigo,
                            selected: runsOffBat == r,
                            onSelected: (val) {
                              if (val) setModalState(() => runsOffBat = r);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Total NB runs added to Team = 1 penalty + runsOffBat
                    controller.recordEvent(
                      runs: 1 + runsOffBat,
                      extraType: 'NB',
                      batsmanRuns: runsOffBat,
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _scoreBtn(String label, VoidCallback onTap, {Color? color}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.grey.shade300,
        foregroundColor: color != null ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
