import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../app_controller.dart';
import '../../../core/models/tournament.dart';
import 'tournament_detail_screen.dart';

class ManageTournamentsScreen extends StatelessWidget {
  final AppController controller = Get.find<AppController>();

  ManageTournamentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppTheme.surface,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16, right: 16, bottom: 20,
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.purpleGradient,
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
                        Text('Tournaments',
                            style: TextStyle(color: Colors.white, fontSize: 22,
                                fontWeight: FontWeight.w800)),
                        Text('Leagues & competitions',
                            style: TextStyle(color: Colors.white60, fontSize: 13)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _addTournamentDialog(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text('New',
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
                if (controller.tournaments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events_rounded, size: 64, color: AppTheme.textMuted),
                        SizedBox(height: 16),
                        Text('No Tournaments Yet',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary)),
                        SizedBox(height: 8),
                        Text('Create a new tournament to get started.',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: controller.tournaments.length,
                  itemBuilder: (context, index) {
                    Tournament t = controller.tournaments[index];
                    return _TournamentCard(tournament: t);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _addTournamentDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    List<String> selectedTeamIds = [];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: Color(0xFF7B5EA7)),
                SizedBox(width: 10),
                Text('New Tournament'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tournament Name',
                      prefixIcon: Icon(Icons.edit_rounded),
                    ),
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  SizedBox(height: 20),
                  Text('Participating Teams',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11,
                          fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  SizedBox(height: 8),
                  ...controller.teams.map((team) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(team.name,
                        style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                    value: selectedTeamIds.contains(team.id),
                    onChanged: (val) {
                      setModalState(() {
                        if (val == true) {
                          selectedTeamIds.add(team.id);
                        } else {
                          selectedTeamIds.remove(team.id);
                        }
                      });
                    },
                  )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) {
                    Get.snackbar('Error', 'Please enter tournament name',
                        snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  if (selectedTeamIds.length < 2) {
                    Get.snackbar('Error', 'Select at least 2 teams',
                        snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  controller.tournaments.add(Tournament(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameCtrl.text.trim(),
                    teamIds: selectedTeamIds,
                    startDate: DateTime.now().toString().substring(0, 10),
                  ));
                  controller.saveData();
                  Navigator.pop(ctx);
                },
                child: Text('Create'),
              ),
            ],
          );
        });
      },
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final Tournament tournament;

  const _TournamentCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => TournamentDetailScreen(tournament: tournament)),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: AppTheme.purpleGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.emoji_events_rounded, color: AppTheme.accent, size: 26),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tournament.name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      _chip('${tournament.teamIds.length} Teams', Icons.groups_rounded),
                      SizedBox(width: 8),
                      _chip(tournament.startDate, Icons.calendar_today_rounded),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textMuted, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppTheme.textMuted),
          SizedBox(width: 4),
          Text(label,
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
