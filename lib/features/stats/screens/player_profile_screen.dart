import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/player.dart';

class PlayerProfileScreen extends StatelessWidget {
  final Player player;

  const PlayerProfileScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 20, right: 20, bottom: 28,
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
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
                    ],
                  ),
                  SizedBox(height: 20),
                  // Avatar
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                      style: TextStyle(color: Colors.white, fontSize: 36,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(player.name,
                      style: TextStyle(color: Colors.white, fontSize: 24,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withOpacity(0.3),
                          blurRadius: 8, offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '${player.mvpPoints} MVP Points',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800,
                              fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Quick stats row
                  Row(
                    children: [
                      Expanded(child: _quickStat('${player.runsScored}', 'Runs',
                          AppTheme.primaryLight, Icons.sports_cricket_rounded)),
                      SizedBox(width: 10),
                      Expanded(child: _quickStat('${player.wicketsTaken}', 'Wickets',
                          AppTheme.red, Icons.sports_baseball_rounded)),
                      SizedBox(width: 10),
                      Expanded(child: _quickStat('${player.catches}', 'Catches',
                          AppTheme.accent, Icons.pan_tool_rounded)),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Batting stats
                  _buildStatSection(
                    title: 'Batting',
                    icon: Icons.sports_cricket_rounded,
                    iconColor: AppTheme.primaryLight,
                    stats: [
                      ('Runs Scored', '${player.runsScored}'),
                      ('Balls Faced', '${player.ballsFaced}'),
                      ('Strike Rate', player.strikeRate.toStringAsFixed(2)),
                      ('Boundaries (4s)', '${player.fours}'),
                      ('Sixes (6s)', '${player.sixes}'),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Bowling & Fielding stats
                  _buildStatSection(
                    title: 'Bowling & Fielding',
                    icon: Icons.sports_baseball_rounded,
                    iconColor: AppTheme.blue,
                    stats: [
                      ('Wickets Taken', '${player.wicketsTaken}'),
                      ('Overs Bowled', '${player.oversBowled}'),
                      ('Runs Conceded', '${player.runsConceded}'),
                      ('Economy Rate', player.economy.toStringAsFixed(2)),
                      ('Catches', '${player.catches}'),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickStat(String value, String label, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          SizedBox(height: 6),
          Text(value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          Text(label,
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<(String, String)> stats,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // section header
          Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                SizedBox(width: 10),
                Text(title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
              ],
            ),
          ),
          Divider(color: AppTheme.border, height: 1),
          // stat rows
          ...stats.asMap().entries.map((entry) {
            final isLast = entry.key == stats.length - 1;
            final stat = entry.value;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(stat.$1,
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                      Text(stat.$2,
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                if (!isLast) Divider(color: AppTheme.border, height: 1, indent: 16),
              ],
            );
          }),
        ],
      ),
    );
  }
}
