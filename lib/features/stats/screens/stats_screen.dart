import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_controller.dart';
import '../../../core/models/player.dart';
import '../../../core/models/team.dart';
import 'player_profile_screen.dart';

class StatsScreen extends StatelessWidget {
  final AppController controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Real Leaderboards'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Player Ranking'),
              Tab(text: 'Batting Ranking'),
              Tab(text: 'Bowling Ranking'),
              Tab(text: 'All-Rounder Ranking'),
              Tab(text: 'Team Ranking'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMVPList(),
            _buildBatsmenList(),
            _buildBowlersList(),
            _buildAllRounderList(),
            _buildTeamsList(),
          ],
        ),
      ),
    );
  }

  List<Player> _getActivePlayers() {
    // Only show "real" players by filtering out dummy bench-warmers who never batted or bowled!
    return controller.getAllPlayers().where((p) => p.ballsFaced > 0 || p.oversBowled > 0 || p.wicketsTaken > 0 || p.runsScored > 0).toList();
  }

  Widget _buildMVPList() {
    var players = _getActivePlayers();
    players.sort((a, b) => b.mvpPoints.compareTo(a.mvpPoints));
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        Player p = players[index];
        return ListTile(
          onTap: () => Get.to(() => PlayerProfileScreen(player: p)),
          leading: CircleAvatar(backgroundColor: index == 0 ? Colors.amber : Colors.grey.shade300, child: Text('${index + 1}')),
          title: Text(p.name),
          subtitle: Text('${p.runsScored}R | ${p.wicketsTaken}W | ${p.catches}C'),
          trailing: Text('${p.mvpPoints} pts', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),
        );
      },
    );
  }

  Widget _buildBatsmenList() {
    var players = _getActivePlayers();
    players.sort((a, b) => b.runsScored.compareTo(a.runsScored));
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        Player p = players[index];
        return ListTile(
          onTap: () => Get.to(() => PlayerProfileScreen(player: p)),
          leading: CircleAvatar(backgroundColor: index == 0 ? Colors.orange : Colors.grey.shade300, child: Text('${index + 1}')),
          title: Text(p.name),
          subtitle: Text('SR: ${p.strikeRate.toStringAsFixed(1)}'),
          trailing: Text('${p.runsScored} Runs', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        );
      },
    );
  }

  Widget _buildBowlersList() {
    var players = _getActivePlayers();
    players.sort((a, b) => b.wicketsTaken.compareTo(a.wicketsTaken));
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        Player p = players[index];
        return ListTile(
          onTap: () => Get.to(() => PlayerProfileScreen(player: p)),
          leading: CircleAvatar(backgroundColor: index == 0 ? Colors.purple : Colors.grey.shade300, child: Text('${index + 1}')),
          title: Text(p.name),
          subtitle: Text('Econ: ${p.economy.toStringAsFixed(2)}'),
          trailing: Text('${p.wicketsTaken} Wkts', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        );
      },
    );
  }

  Widget _buildAllRounderList() {
    // Only fetch players who have BOTH Batted (runs > 0/faced balls) and Bowled (wickets > 0/bowled overs)
    var players = _getActivePlayers().where((p) => p.runsScored > 0 && p.wicketsTaken > 0).toList();
    players.sort((a, b) => b.mvpPoints.compareTo(a.mvpPoints));
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        Player p = players[index];
        return ListTile(
          onTap: () => Get.to(() => PlayerProfileScreen(player: p)),
          leading: CircleAvatar(backgroundColor: index == 0 ? Colors.teal : Colors.grey.shade300, child: Text('${index + 1}')),
          title: Text(p.name),
          subtitle: Text('${p.runsScored} Runs | ${p.wicketsTaken} Wickets'),
          trailing: Text('${p.mvpPoints} pts', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        );
      },
    );
  }

  Widget _buildTeamsList() {
    var teams = controller.teams.toList();
    teams.sort((a, b) {
      if (b.points == a.points) {
        return b.netRunRate.compareTo(a.netRunRate);
      }
      return b.points.compareTo(a.points);
    });

    return ListView.builder(
      itemCount: teams.length,
      itemBuilder: (context, index) {
        Team t = teams[index];
        return ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(t.name),
          subtitle: Text('W: ${t.wins} | L: ${t.losses} | NRR: ${t.netRunRate.toStringAsFixed(2)}'),
          trailing: Text('${t.points} Pts', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        );
      },
    );
  }
}
