import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../app_controller.dart';
import '../../../core/models/team.dart';
import '../../../core/models/player.dart';
import '../../stats/screens/player_profile_screen.dart';

class ManageTeamsScreen extends StatelessWidget {
  final AppController controller = Get.find<AppController>();

  ManageTeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: AppTheme.surface),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16, right: 16, bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Teams & Players',
                            style: TextStyle(color: Colors.white, fontSize: 22,
                                fontWeight: FontWeight.w800)),
                        Text('Manage rosters',
                            style: TextStyle(color: Colors.white60, fontSize: 13)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _addTeamDialog(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.group_add_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text('New Team',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: Obx(() {
                if (controller.teams.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.groups_rounded, size: 64, color: AppTheme.textMuted),
                        SizedBox(height: 16),
                        Text('No Teams Yet',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary)),
                        SizedBox(height: 8),
                        Text('Tap "New Team" to create your first team.',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: controller.teams.length,
                  itemBuilder: (context, index) {
                    Team t = controller.teams[index];
                    return _buildTeamCard(context, t);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, Team t) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              t.name.isNotEmpty ? t.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900,
              ),
            ),
          ),
          title: Text(t.name,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16,
                  color: AppTheme.textPrimary)),
          subtitle: Text('${t.players.length} players',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconAction(Icons.edit_rounded, AppTheme.blue,
                      () => _editTeamDialog(context, t)),
              SizedBox(width: 4),
              _iconAction(Icons.delete_outline_rounded, AppTheme.red,
                      () => _deleteTeamConfirm(context, t)),
              Icon(Icons.expand_more_rounded, color: AppTheme.textMuted),
            ],
          ),
          children: [
            Divider(color: AppTheme.border, height: 12),
            ...t.players.map((p) => Container(
              margin: EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primary.withOpacity(0.2),
                  child: Text(
                    p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                    style: TextStyle(color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
                title: Text(p.name,
                    style: TextStyle(color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () => Get.to(() => PlayerProfileScreen(player: p)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconAction(Icons.edit_rounded, AppTheme.blue,
                            () => _editPlayerDialog(context, t, p), size: 18),
                    SizedBox(width: 2),
                    _iconAction(Icons.delete_outline_rounded, AppTheme.red,
                            () => _deletePlayerConfirm(context, t, p), size: 18),
                  ],
                ),
              ),
            )),
            // Add Player button
            GestureDetector(
              onTap: () => _addPlayerDialog(context, t),
              child: Container(
                margin: EdgeInsets.only(top: 6),
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.primary.withOpacity(0.3),
                      style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: AppTheme.primaryLight, size: 18),
                    SizedBox(width: 6),
                    Text('Add Player',
                        style: TextStyle(color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconAction(IconData icon, Color color, VoidCallback onTap,
      {double size = 20}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }

  void _addTeamDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Create New Team'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Team Name',
            prefixIcon: Icon(Icons.groups_rounded),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
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
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _addPlayerDialog(BuildContext context, Team team) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Player'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Player Name',
            prefixIcon: Icon(Icons.person_rounded),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
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
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editTeamDialog(BuildContext context, Team team) {
    final nameController = TextEditingController(text: team.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Team'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Team Name'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                team.name = nameController.text.trim();
                controller.refreshData();
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteTeamConfirm(BuildContext context, Team team) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Team'),
        content: RichText(
          text: TextSpan(
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            children: [
              TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(text: team.name,
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
              TextSpan(text: '? This cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () {
              controller.teams.remove(team);
              controller.refreshData();
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editPlayerDialog(BuildContext context, Team team, Player player) {
    final nameController = TextEditingController(text: player.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Player'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Player Name'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                player.name = nameController.text.trim();
                controller.refreshData();
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deletePlayerConfirm(BuildContext context, Team team, Player player) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Remove Player'),
        content: RichText(
          text: TextSpan(
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            children: [
              TextSpan(text: 'Remove '),
              TextSpan(text: player.name,
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
              TextSpan(text: ' from ${team.name}?'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () {
              team.players.remove(player);
              controller.refreshData();
              Navigator.pop(context);
            },
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }
}
