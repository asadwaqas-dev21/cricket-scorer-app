import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_controller.dart';
import '../../../core/models/tournament.dart';
import '../../../core/models/team.dart';
import 'tournament_detail_screen.dart';

class ManageTournamentsScreen extends StatelessWidget {
  final AppController controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.tournaments.isEmpty) {
          return const Center(child: Text('No Tournaments yet. Tap + to add one.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.tournaments.length,
          itemBuilder: (context, index) {
            Tournament t = controller.tournaments[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text('${t.teamIds.length} Teams | Started: ${t.startDate}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.to(() => TournamentDetailScreen(tournament: t)),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () => _addTournamentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addTournamentDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    List<String> selectedTeamIds = [];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('New Tournament'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Tournament Name'),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 20),
                  const Text('Select Participating Teams', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  ...controller.teams.map((team) => CheckboxListTile(
                    title: Text(team.name),
                    value: selectedTeamIds.contains(team.id),
                    onChanged: (val) {
                      setModalState(() {
                        if (val == true) selectedTeamIds.add(team.id);
                        else selectedTeamIds.remove(team.id);
                      });
                    },
                  )).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Please enter tournament name');
                    return;
                  }
                  if (selectedTeamIds.length < 2) {
                    Get.snackbar('Error', 'Select at least 2 teams');
                    return;
                  }
                  
                  Tournament newT = Tournament(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    teamIds: selectedTeamIds,
                    startDate: DateTime.now().toString().substring(0, 10),
                  );
                  
                  controller.tournaments.add(newT);
                  controller.saveData();
                  Navigator.pop(ctx);
                },
                child: const Text('Create'),
              )
            ],
          );
        });
      }
    );
  }
}
