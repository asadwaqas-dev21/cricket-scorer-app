import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/completed_match.dart';

class MatchDetailScreen extends StatelessWidget {
  final CompletedMatch match;

  const MatchDetailScreen({super.key, required this.match});

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
              decoration: BoxDecoration(
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
                          Text('Match Scorecard',
                              style: TextStyle(color: Colors.white, fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                          Text('Full match details',
                              style: TextStyle(color: Colors.white60, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Score summary
                  Container(
                    padding: EdgeInsets.all(16),
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
                                  style: TextStyle(color: Colors.white70, fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 4),
                              Text(match.team1Score,
                                  style: TextStyle(color: Colors.white, fontSize: 26,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Text('VS',
                              style: TextStyle(color: Colors.white, fontSize: 12,
                                  fontWeight: FontWeight.w900)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(match.team2Name,
                                  style: TextStyle(color: Colors.white70, fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 4),
                              Text(match.team2Score,
                                  style: TextStyle(color: Colors.white, fontSize: 26,
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
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Result
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xFF1A6B3C), Color(0xFF0E4526)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.emoji_events_rounded,
                              color: AppTheme.accent, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(match.result,
                                style: TextStyle(color: Colors.white,
                                    fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    // Man of the match
                    _buildManOfTheMatch(),
                    SizedBox(height: 20),
                    // Date
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 14, color: AppTheme.textMuted),
                        SizedBox(width: 6),
                        Text(match.date,
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Team 1 Stats
                    _buildTeamStats(match.team1Name),
                    // Team 2 Stats
                    _buildTeamStats(match.team2Name),
                    SizedBox(height: 10),
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
      padding: EdgeInsets.all(16),
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
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.star_rounded, color: Colors.white, size: 22),
          ),
          SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MAN OF THE MATCH',
                  style: TextStyle(color: Colors.white70, fontSize: 10,
                      fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              SizedBox(height: 4),
              Text(match.manOfTheMatch,
                  style: TextStyle(color: Colors.white, fontSize: 20,
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

    if (teamBatting.isEmpty && teamBowling.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(teamName, Icons.shield_rounded),
        SizedBox(height: 12),
        if (teamBatting.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Batting', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          _buildBattingTable(teamBatting),
          SizedBox(height: 16),
        ],
        if (teamBowling.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Bowling', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          _buildBowlingTable(teamBowling),
          SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryLight, size: 16),
        ),
        SizedBox(width: 10),
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
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
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
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
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: isLast ? null : Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${b['name']}',
                            style: TextStyle(color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('${b['team']}',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                  SizedBox(width: 40, child: Center(child: Text('${b['runs']}',
                      style: TextStyle(color: AppTheme.primaryLight,
                          fontWeight: FontWeight.w800, fontSize: 14)))),
                  SizedBox(width: 40, child: Center(child: Text('${b['balls']}',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)))),
                  SizedBox(width: 50, child: Center(child: Text(sr.toStringAsFixed(1),
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)))),
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
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
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
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: isLast ? null : Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${b['name']}',
                            style: TextStyle(color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('${b['team']}',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                  SizedBox(width: 40, child: Center(child: Text('${b['overs']}',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)))),
                  SizedBox(width: 40, child: Center(child: Text('${b['wickets']}',
                      style: TextStyle(color: AppTheme.red,
                          fontWeight: FontWeight.w800, fontSize: 14)))),
                  SizedBox(width: 40, child: Center(child: Text('${b['runs']}',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
