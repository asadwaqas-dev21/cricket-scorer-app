import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../app_controller.dart';
import '../../../core/models/completed_match.dart';
import 'match_detail_screen.dart';

class CompletedMatchesScreen extends StatelessWidget {
  final AppController controller = Get.find<AppController>();

  CompletedMatchesScreen({super.key});

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
                gradient: AppTheme.blueGradient,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Match History',
                          style: TextStyle(color: Colors.white, fontSize: 22,
                              fontWeight: FontWeight.w800)),
                      Text('Completed scorecards',
                          style: TextStyle(color: Colors.white60, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: Obx(() {
                if (controller.completedMatches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded, size: 64, color: AppTheme.textMuted),
                        SizedBox(height: 16),
                        Text('No Matches Yet',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary)),
                        SizedBox(height: 8),
                        Text('Completed matches will appear here.',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  );
                }

                var sortedMatches = controller.completedMatches.reversed.toList();

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: sortedMatches.length,
                  itemBuilder: (context, index) {
                    CompletedMatch match = sortedMatches[index];
                    return _MatchCard(match: match);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final CompletedMatch match;

  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => MatchDetailScreen(match: match)),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            // Date bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.textMuted),
                  SizedBox(width: 6),
                  Text(match.date,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _showDeleteConfirmation(context, match);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 16, color: AppTheme.red),
                        SizedBox(width: 4),
                        Text('DELETE', style: TextStyle(
                          color: AppTheme.red, fontSize: 10,
                          fontWeight: FontWeight.w700, letterSpacing: 1,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Teams vs
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(match.team1Name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary),
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: 4),
                        Text(match.team1Score,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                                color: AppTheme.primaryLight)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('VS',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(match.team2Name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end),
                        SizedBox(height: 4),
                        Text(match.team2Score,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                                color: AppTheme.blue)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Result banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF1A6B3C), Color(0xFF0E4526)]),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_events_rounded, color: AppTheme.accent, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(match.result,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CompletedMatch match) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Match', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Are you sure you want to delete this match? All related stats for players and teams will be reversed.', style: TextStyle(color: AppTheme.textSecondary)),
        backgroundColor: AppTheme.surfaceElevated,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            onPressed: () {
              Get.find<AppController>().deleteMatch(match.id);
              Navigator.pop(ctx);
              Get.snackbar('Deleted', 'Match data has been removed successfully',
                  backgroundColor: AppTheme.surfaceElevated, colorText: AppTheme.textPrimary);
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
