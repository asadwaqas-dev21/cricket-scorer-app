import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../app_controller.dart';
import '../../../core/models/player.dart';
import '../../../core/models/team.dart';
import 'player_profile_screen.dart';

class StatsScreen extends StatelessWidget {
  final AppController controller = Get.find<AppController>();

  StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
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
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leaderboards',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Global rankings & stats',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  const TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(text: '⭐  MVP'),
                      Tab(text: '🏏  Batting'),
                      Tab(text: '⚾  Bowling'),
                      Tab(text: '🎭  All-Round'),
                      Tab(text: '🏆  Teams'),
                    ],
                    tabAlignment: TabAlignment.start,
                  ),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  _buildMVPList(),
                  _buildBatsmenList(),
                  _buildBowlersList(),
                  _buildAllRounderList(),
                  _buildTeamsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Player> _getActivePlayers() {
    return controller
        .getAllPlayers()
        .where(
          (p) =>
              p.ballsFaced > 0 ||
              p.oversBowled > 0 ||
              p.wicketsTaken > 0 ||
              p.runsScored > 0,
        )
        .toList();
  }

  Widget _buildTableHeader(String type) {
    String col3 = 'Score';
    String col4 = 'Strike rate';
    String col5 = 'Average';

    if (type == 'MVP' || type == 'All-Round') {
      col3 = 'Points';
      col4 = 'Runs';
      col5 = 'Wickets';
    } else if (type == 'Batting') {
      col3 = 'Runs';
      col4 = 'Strike rate';
      col5 = 'Average';
    } else if (type == 'Bowling') {
      col3 = 'Wickets';
      col4 = 'Econ';
      col5 = 'Average';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              'No',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Name',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 45,
            child: Center(
              child: Text(
                'Matches',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 45,
            child: Center(
              child: Text(
                col3,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 45,
            child: Center(
              child: Text(
                col4,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
            width: 45,
            child: Center(
              child: Text(
                col5,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerTableRow(Player p, int index, String type) {
    String score = '';
    String sr = '';
    String avg = '';

    if (type == 'MVP' || type == 'All-Round') {
      score = p.mvpPoints.toString();
      sr = p.runsScored.toString();
      avg = p.wicketsTaken.toString();
    } else if (type == 'Batting') {
      score = p.runsScored.toString();
      sr = p.strikeRate.toStringAsFixed(1);
      avg = p.battingAverage.toStringAsFixed(1);
    } else if (type == 'Bowling') {
      score = p.wicketsTaken.toString();
      sr = p.economy.toStringAsFixed(2);
      avg = p.bowlingAverage.toStringAsFixed(1);
    }

    return GestureDetector(
      onTap: () => Get.to(() => PlayerProfileScreen(player: p)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                p.name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 45,
              child: Center(
                child: Text(
                  '${p.matchesPlayed}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 45,
              child: Center(
                child: Text(
                  score,
                  style: TextStyle(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 45,
              child: Center(
                child: Text(
                  sr,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 45,
              child: Center(
                child: Text(
                  avg,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMVPList() {
    var players = _getActivePlayers();
    players.sort((a, b) => b.mvpPoints.compareTo(a.mvpPoints));
    if (players.isEmpty) return _emptyState('No player data yet');
    return Column(
      children: [
        _buildTableHeader('MVP'),
        Expanded(
          child: ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              return _buildPlayerTableRow(players[index], index, 'MVP');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBatsmenList() {
    var players = _getActivePlayers();
    players.sort((a, b) => b.runsScored.compareTo(a.runsScored));
    if (players.isEmpty) return _emptyState('No batting data yet');
    return Column(
      children: [
        _buildTableHeader('Batting'),
        Expanded(
          child: ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              return _buildPlayerTableRow(players[index], index, 'Batting');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBowlersList() {
    var players = _getActivePlayers();
    players.sort((a, b) => b.wicketsTaken.compareTo(a.wicketsTaken));
    if (players.isEmpty) return _emptyState('No bowling data yet');
    return Column(
      children: [
        _buildTableHeader('Bowling'),
        Expanded(
          child: ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              return _buildPlayerTableRow(players[index], index, 'Bowling');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllRounderList() {
    var players = _getActivePlayers()
        .where((p) => p.runsScored > 0 && p.wicketsTaken > 0)
        .toList();
    players.sort((a, b) => b.mvpPoints.compareTo(a.mvpPoints));
    if (players.isEmpty) return _emptyState('No all-rounder data yet');
    return Column(
      children: [
        _buildTableHeader('All-Round'),
        Expanded(
          child: ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              return _buildPlayerTableRow(players[index], index, 'All-Round');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTeamTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              'No',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Team',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Center(
              child: Text(
                'M',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 32,
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
            width: 32,
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
            width: 36,
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
          SizedBox(
            width: 45,
            child: Center(
              child: Text(
                'NRR',
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
    );
  }

  Widget _buildTeamTableRow(Team t, int index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppTheme.primary.withOpacity(0.2),
                  child: Text(
                    t.name.isNotEmpty ? t.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 32,
            child: Center(
              child: Text(
                '${t.matchesPlayed}',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Center(
              child: Text(
                '${t.wins}',
                style: TextStyle(
                  color: AppTheme.primaryLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Center(
              child: Text(
                '${t.losses}',
                style: TextStyle(color: AppTheme.red, fontSize: 13),
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Center(
              child: Text(
                '${t.points}',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 45,
            child: Center(
              child: Text(
                t.netRunRate.toStringAsFixed(2),
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsList() {
    var teams = controller.teams.toList();
    teams.sort((a, b) {
      if (b.points == a.points) return b.netRunRate.compareTo(a.netRunRate);
      return b.points.compareTo(a.points);
    });
    if (teams.isEmpty) return _emptyState('No team data yet');

    return Column(
      children: [
        _buildTeamTableHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              return _buildTeamTableRow(teams[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 56,
            color: AppTheme.textMuted,
          ),
          SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
