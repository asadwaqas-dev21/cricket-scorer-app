import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_controller.dart';
import '../../../core/models/team.dart';
import '../../../core/models/player.dart';
import '../../stats/screens/player_profile_screen.dart';

class ManageTeamsScreen extends StatelessWidget {
  final AppController controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Teams'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Obx(() {
        if (controller.teams.isEmpty) {
           return const Center(child: Text('No Teams yet. Tap + to add a team.'));
        }
        return ListView.builder(
          itemCount: controller.teams.length,
          itemBuilder: (context, index) {
            Team t = controller.teams[index];
            return ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editTeamDialog(context, t),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTeamConfirm(context, t),
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: Text('${t.players.length} Players in Squad'),
              children: [
                ...t.players.map((p) => ListTile(
                  title: Text(p.name),
                  leading: const Icon(Icons.person),
                  onTap: () => Get.to(() => PlayerProfileScreen(player: p)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                        onPressed: () => _editPlayerDialog(context, t, p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => _deletePlayerConfirm(context, t, p),
                      ),
                    ],
                  ),
                )),
                ListTile(
                  leading: const Icon(Icons.add_circle, color: Colors.indigo),
                  title: const Text('Add Player', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                  onTap: () => _addPlayerDialog(context, t),
                )
              ],
            );
          }
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () => _addTeamDialog(context),
        child: const Icon(Icons.group_add),
      ),
    );
  }

  void _addTeamDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Team'),
        content: TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Team Name'), autofocus: true, textCapitalization: TextCapitalization.words),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                controller.teams.add(Team(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  players: [],
                ));
                controller.refreshData();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          )
        ]
      )
    );
  }

  void _addPlayerDialog(BuildContext context, Team team) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Player to Squad'),
        content: TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Player Name'), autofocus: true, textCapitalization: TextCapitalization.words),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                team.players.add(Player(
                  id: '${team.id}_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text.trim(),
                ));
                controller.refreshData();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          )
        ]
      )
    );
  }

  void _editTeamDialog(BuildContext context, Team team) {
    final TextEditingController nameController = TextEditingController(text: team.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Team'),
        content: TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Team Name'), autofocus: true, textCapitalization: TextCapitalization.words),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                team.name = nameController.text.trim();
                controller.refreshData();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          )
        ]
      )
    );
  }

  void _deleteTeamConfirm(BuildContext context, Team team) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text('Are you sure you want to delete ${team.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.teams.remove(team);
              controller.refreshData();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          )
        ]
      )
    );
  }

  void _editPlayerDialog(BuildContext context, Team team, Player player) {
    final TextEditingController nameController = TextEditingController(text: player.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Player'),
        content: TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Player Name'), autofocus: true, textCapitalization: TextCapitalization.words),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                player.name = nameController.text.trim();
                controller.refreshData();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          )
        ]
      )
    );
  }

  void _deletePlayerConfirm(BuildContext context, Team team, Player player) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text('Are you sure you want to delete ${player.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              team.players.remove(player);
              controller.refreshData();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          )
        ]
      )
    );
  }
}
