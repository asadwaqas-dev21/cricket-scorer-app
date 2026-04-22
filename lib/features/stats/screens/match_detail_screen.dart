import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/completed_match.dart';

class MatchDetailScreen extends StatelessWidget {
  final CompletedMatch match;

  const MatchDetailScreen({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppTheme.surface,
        child: Column(
          children: [
            // Gradient header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16, right: 16, bottom: 20,
              ),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
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
                          Text('Match Scorecard',
                              style: TextStyle(color: Colors.white, fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                          Text('Full match details',
                              style: TextStyle(color: Colors.white60, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Score summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(match.team1Name,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(match.team1Score,
                                  style: const TextStyle(color: Colors.white, fontSize: 26,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('VS',
                              style: TextStyle(color: Colors.white, fontSize: 12,
                                  fontWeight: FontWeight.w900)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(match.team2Name,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(match.team2Score,
                                  style: const TextStyle(color: Colors.white, fontSize: 26,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Result
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF1A6B3C), Color(0xFF0E4526)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events_rounded,
                              color: AppTheme.accent, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(match.result,
                                style: const TextStyle(color: Colors.white,
                                    fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Man of the match
                    _buildManOfTheMatch(),
                    const SizedBox(height: 20),
                    // Date
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 6),
                        Text(match.date,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Team 1 Stats
                    _buildTeamStats(match.team1Name),
                    // Team 2 Stats
                    _buildTeamStats(match.team2Name),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManOfTheMatch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MAN OF THE MATCH',
                  style: TextStyle(color: Colors.white70, fontSize: 10,
                      fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(match.manOfTheMatch,
                  style: const TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStats(String teamName) {
    final teamBatting = match.battingPerformances.where((b) => b['team']?.toString().trim() == teamName.trim()).toList();
    final teamBowling = match.bowlingPerformances.where((b) => b['team']?.toString().trim() == teamName.trim()).toList();

    if (teamBatting.isEmpty && teamBowling.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(teamName, Icons.shield_rounded),
        const SizedBox(height: 12),
        if (teamBatting.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Batting', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          _buildBattingTable(teamBatting),
          const SizedBox(height: 16),
        ],
        if (teamBowling.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Bowling', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          _buildBowlingTable(teamBowling),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryLight, size: 16),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildBattingTable(List<Map<String, dynamic>> performances) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Batsman',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11,
                        fontWeight: FontWeight.w700, letterSpacing: 1))),
                SizedBox(width: 40, child: Center(child: Text('R',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700)))),
                SizedBox(width: 40, child: Center(child: Text('B',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700)))),
                SizedBox(width: 50, child: Center(child: Text('SR',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700)))),
              ],
            ),
          ),
          // Data rows
          ...performances.asMap().entries.map((entry) {
            final b = entry.value;
            final isLast = entry.key == performances.length - 1;
            double sr = b['balls'] > 0 ? (b['runs'] / b['balls']) * 100 : 0.0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: isLast ? null : const Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${b['name']}',
                            style: const TextStyle(color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('${b['team']}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                  SizedBox(width: 40, child: Center(child: Text('${b['runs']}',
                      style: const TextStyle(color: AppTheme.primaryLight,
                          fontWeight: FontWeight.w800, fontSize: 14)))),
                  SizedBox(width: 40, child: Center(child: Text('${b['balls']}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)))),
                  SizedBox(width: 50, child: Center(child: Text(sr.toStringAsFixed(1),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBowlingTable(List<Map<String, dynamic>> performances) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Bowler',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11,
                        fontWeight: FontWeight.w700, letterSpacing: 1))),
                SizedBox(width: 40, child: Center(child: Text('O',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700)))),
                SizedBox(width: 40, child: Center(child: Text('W',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700)))),
                SizedBox(width: 40, child: Center(child: Text('R',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w700)))),
              ],
            ),
          ),
          ...performances.asMap().entries.map((entry) {
            final b = entry.value;
            final isLast = entry.key == performances.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: isLast ? null : const Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${b['name']}',
                            style: const TextStyle(color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('${b['team']}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                  SizedBox(width: 40, child: Center(child: Text('${b['overs']}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)))),
                  SizedBox(width: 40, child: Center(child: Text('${b['wickets']}',
                      style: const TextStyle(color: AppTheme.red,
                          fontWeight: FontWeight.w800, fontSize: 14)))),
                  SizedBox(width: 40, child: Center(child: Text('${b['runs']}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
