import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../app_controller.dart';
import '../../../core/models/tournament.dart';
import 'match_detail_screen.dart';

class TournamentDetailScreen extends StatelessWidget {
  final Tournament tournament;
  final AppController controller = Get.find<AppController>();

  TournamentDetailScreen({Key? key, required this.tournament})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 0,
              ),
              decoration: const BoxDecoration(
                gradient: AppTheme.purpleGradient,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tournament.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${tournament.teamIds.length} Teams · ${tournament.startDate}',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const TabBar(
                    tabs: [
                      Tab(text: '🏆  Standings'),
                      Tab(text: '📋  Matches'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(children: [_buildStandings(), _buildMatches()]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandings() {
    return Obx(() {
      var tMatches = controller.completedMatches
          .where((m) => m.tournamentId == tournament.id)
          .toList();

      Map<String, Map<String, dynamic>> standings = {};
      for (var tid in tournament.teamIds) {
        standings[tid] = {'pts': 0, 'w': 0, 'l': 0, 'p': 0};
      }

      for (var match in tMatches) {
        String t1Id =
            controller.teams
                .firstWhereOrNull((t) => t.name == match.team1Name)
                ?.id ??
            '';
        String t2Id =
            controller.teams
                .firstWhereOrNull((t) => t.name == match.team2Name)
                ?.id ??
            '';

        if (standings.containsKey(t1Id)) standings[t1Id]!['p'] += 1;
        if (standings.containsKey(t2Id)) standings[t2Id]!['p'] += 1;

        if (match.result.contains(match.team1Name)) {
          if (standings.containsKey(t1Id)) {
            standings[t1Id]!['w'] += 1;
            standings[t1Id]!['pts'] += 2;
          }
          if (standings.containsKey(t2Id)) standings[t2Id]!['l'] += 1;
        } else if (match.result.contains(match.team2Name)) {
          if (standings.containsKey(t2Id)) {
            standings[t2Id]!['w'] += 1;
            standings[t2Id]!['pts'] += 2;
          }
          if (standings.containsKey(t1Id)) standings[t1Id]!['l'] += 1;
        } else {
          if (standings.containsKey(t1Id)) standings[t1Id]!['pts'] += 1;
          if (standings.containsKey(t2Id)) standings[t2Id]!['pts'] += 1;
        }
      }

      var sortedIds = tournament.teamIds.toList();
      sortedIds.sort(
        (a, b) => standings[b]!['pts'].compareTo(standings[a]!['pts']),
      );

      if (sortedIds.isEmpty) {
        return const Center(
          child: Text(
            'No standings yet.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(width: 32),
                Expanded(
                  child: Text(
                    'TEAM',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      'W',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      'L',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      'PTS',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(14),
              ),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: sortedIds.asMap().entries.map((entry) {
                final index = entry.key;
                final tid = entry.value;
                final teamName = controller.teams
                    .firstWhere(
                      (t) => t.id == tid,
                      orElse: () => controller.teams.first,
                    )
                    .name;
                final data = standings[tid]!;
                final isLast = index == sortedIds.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Rank
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: index == 0
                                  ? AppTheme.accent.withOpacity(0.2)
                                  : AppTheme.surfaceElevated,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: index == 0
                                    ? AppTheme.accent
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              teamName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: index == 0
                                    ? AppTheme.textPrimary
                                    : AppTheme.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 36,
                            child: Center(
                              child: Text(
                                '${data['p']}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 36,
                            child: Center(
                              child: Text(
                                '${data['w']}',
                                style: const TextStyle(
                                  color: AppTheme.primaryLight,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 36,
                            child: Center(
                              child: Text(
                                '${data['l']}',
                                style: const TextStyle(
                                  color: AppTheme.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Center(
                              child: Text(
                                '${data['pts']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: index == 0
                                      ? AppTheme.accent
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                        color: AppTheme.border,
                        height: 1,
                        indent: 16,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMatches() {
    return Obx(() {
      var tMatches = controller.completedMatches
          .where((m) => m.tournamentId == tournament.id)
          .toList()
          .reversed
          .toList();

      if (tMatches.isEmpty) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_cricket_rounded,
                size: 48,
                color: AppTheme.textMuted,
              ),
              SizedBox(height: 12),
              Text(
                'No matches played yet.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tMatches.length,
        itemBuilder: (context, index) {
          var match = tMatches[index];
          return GestureDetector(
            onTap: () => Get.to(() => MatchDetailScreen(match: match)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        match.date,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppTheme.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          match.team1Name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'vs',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          match.team2Name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      match.result,
                      style: const TextStyle(
                        color: AppTheme.primaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
