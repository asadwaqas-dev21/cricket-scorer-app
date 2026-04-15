import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      Get.snackbar('Error', 'Please select teams and toss winner');
      return;
    }
    if (team1Id == team2Id) {
      Get.snackbar('Error', 'Team 1 and Team 2 cannot be the same');
      return;
    }
    
    int finalOvers = totalOvers;
    if (isCustomOver) {
      finalOvers = int.tryParse(customOverController.text) ?? 0;
      if (finalOvers <= 0) {
        Get.snackbar('Error', 'Invalid custom over');
        return;
      }
    }

    int bowlerOvers = (finalOvers / 5).ceil();

    var scoringController = Get.put(ScoringController());
    scoringController.setupMatch(MatchSettings(
      totalOvers: finalOvers,
      team1Id: team1Id!,
      team2Id: team2Id!,
      tossWinnerId: tossWinnerId!,
      optTo: optTo,
      maxOversPerBowler: bowlerOvers,
      tournamentId: tournamentId,
      playingSquad1: playingSquad1,
      playingSquad2: playingSquad2,
    ));

    Get.off(() => ScoringScreen());
  }

  @override
  Widget build(BuildContext context) {
    var teams = mainController.teams;
    return Scaffold(
      appBar: AppBar(title: const Text('Match Setup'), backgroundColor: Colors.indigo, foregroundColor: Colors.white,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (mainController.tournaments.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tournament (Optional)'),
                value: tournamentId,
                items: [
                  const DropdownMenuItem(value: null, child: Text('None (Friendly Match)')),
                  ...mainController.tournaments.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))),
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

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Team 1'),
              value: team1Id,
              items: teams.where((t) => tournamentId == null || mainController.tournaments.firstWhere((tour) => tour.id == tournamentId).teamIds.contains(t.id)).map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
              onChanged: (val) {
                setState(() {
                  team1Id = val;
                  if (tossWinnerId != team1Id && tossWinnerId != team2Id) tossWinnerId = null;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Team 2'),
              value: team2Id,
              items: teams.where((t) => tournamentId == null || mainController.tournaments.firstWhere((tour) => tour.id == tournamentId).teamIds.contains(t.id)).map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
              onChanged: (val) {
                setState(() {
                  team2Id = val;
                  if (tossWinnerId != team1Id && tossWinnerId != team2Id) tossWinnerId = null;
                });
              },
            ),
            const SizedBox(height: 20),
            if (team1Id != null && team2Id != null) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Toss Won By'),
                value: tossWinnerId,
                items: [
                  DropdownMenuItem(value: team1Id, child: Text(teams.firstWhere((t) => t.id == team1Id).name)),
                  DropdownMenuItem(value: team2Id, child: Text(teams.firstWhere((t) => t.id == team2Id).name)),
                ],
                onChanged: (val) => setState(() => tossWinnerId = val),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Elected To'),
                value: optTo,
                items: ['Bat', 'Bowl'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => optTo = val!),
              ),
            ],
            if (team1Id != null) ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: Text('Select Team 1 Squad (${playingSquad1.length} selected)'),
                onPressed: () => _selectSquad(teams.firstWhere((t) => t.id == team1Id!), playingSquad1),
              ),
            ],
            if (team2Id != null) ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: Text('Select Team 2 Squad (${playingSquad2.length} selected)'),
                onPressed: () => _selectSquad(teams.firstWhere((t) => t.id == team2Id!), playingSquad2),
              ),
            ],
            const SizedBox(height: 20),
            const Text('Overs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: overOptions.map((o) => ChoiceChip(
                label: Text('$o'),
                selected: totalOvers == o && !isCustomOver,
                onSelected: (val) {
                  if (val) setState(() { totalOvers = o; isCustomOver = false; });
                },
              )).toList()..add(ChoiceChip(
                label: const Text('Custom'),
                selected: isCustomOver,
                onSelected: (val) {
                  if (val) setState(() { isCustomOver = true; });
                },
              )),
            ),
            if (isCustomOver)
              TextField(
                controller: customOverController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter Custom Overs'),
              ),
              

            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              onPressed: _startMatch,
              child: const Text('Start Match', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  void _selectSquad(team, List<String> selectedSquad) {
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: Text('Select ${team.name} Squad'),
            content: SingleChildScrollView(
              child: Column(
                children: team.players.map<Widget>((p) => CheckboxListTile(
                  title: Text(p.name),
                  value: selectedSquad.contains(p.id),
                  onChanged: (val) {
                    setModalState(() {
                      if (val == true) selectedSquad.add(p.id);
                      else selectedSquad.remove(p.id);
                    });
                    setState(() {});
                  },
                )).toList(),
              )
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))
            ]
          );
        });
      }
    );
  }
}
