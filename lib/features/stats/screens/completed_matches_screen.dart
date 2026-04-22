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
        decoration: const BoxDecoration(color: AppTheme.surface),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16, right: 16, bottom: 20,
              ),
              decoration: const BoxDecoration(
                gradient: AppTheme.blueGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
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
                  return const Center(
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
                  padding: const EdgeInsets.all(16),
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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            // Date bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Text(match.date,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  const Icon(Icons.sports_cricket_rounded, size: 14, color: AppTheme.primaryLight),
                  const SizedBox(width: 4),
                  const Text('CRICKET', style: TextStyle(
                    color: AppTheme.primaryLight, fontSize: 10,
                    fontWeight: FontWeight.w700, letterSpacing: 1,
                  )),
                ],
              ),
            ),
            // Teams vs
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(match.team1Name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary),
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(match.team1Score,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                                color: AppTheme.primaryLight)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('VS',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(match.team2Name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end),
                        const SizedBox(height: 4),
                        Text(match.team2Score,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1A6B3C), Color(0xFF0E4526)]),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: AppTheme.accent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(match.result,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
