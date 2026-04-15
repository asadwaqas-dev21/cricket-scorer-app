import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_controller.dart';
import '../../../core/models/tournament.dart';
import '../../../core/models/completed_match.dart';
import '../../../core/models/team.dart';

class TournamentDetailScreen extends StatelessWidget {
  final Tournament tournament;
  final AppController controller = Get.find<AppController>();

  TournamentDetailScreen({Key? key, required this.tournament}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tournament.name),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Standings'),
              Tab(text: 'Matches'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            _buildStandings(),
            _buildMatches(),
          ],
        ),
      ),
    );
  }

  Widget _buildStandings() {
    return Obx(() {
      // Filter matches for this tournament
      var tMatches = controller.completedMatches.where((m) => m.tournamentId == tournament.id).toList();
      
      // Calculate standings for teams in this tournament
      Map<String, Map<String, dynamic>> standings = {};
      for (var tid in tournament.teamIds) {
        standings[tid] = {
          'pts': 0, 'w': 0, 'l': 0, 'p': 0, 'nrr': 0.0,
          'runsScored': 0, 'oversFaced': 0, 'runsConceded': 0, 'oversBowled': 0
        };
      }

      for (var match in tMatches) {
        // Logic to extract who won and scores from match.result and match scores
        // For simplicity, we use the match result text check
        String t1Id = controller.teams.firstWhereOrNull((t) => t.name == match.team1Name)?.id ?? "";
        String t2Id = controller.teams.firstWhereOrNull((t) => t.name == match.team2Name)?.id ?? "";

        if (standings.containsKey(t1Id)) standings[t1Id]!['p'] += 1;
        if (standings.containsKey(t2Id)) standings[t2Id]!['p'] += 1;

        if (match.result.contains(match.team1Name)) {
           if (standings.containsKey(t1Id)) { standings[t1Id]!['w'] += 1; standings[t1Id]!['pts'] += 2; }
           if (standings.containsKey(t2Id)) standings[t2Id]!['l'] += 1;
        } else if (match.result.contains(match.team2Name)) {
           if (standings.containsKey(t2Id)) { standings[t2Id]!['w'] += 1; standings[t2Id]!['pts'] += 2; }
           if (standings.containsKey(t1Id)) standings[t1Id]!['l'] += 1;
        } else {
           // Tied
           if (standings.containsKey(t1Id)) standings[t1Id]!['pts'] += 1;
           if (standings.containsKey(t2Id)) standings[t2Id]!['pts'] += 1;
        }
      }

      var sortedIds = tournament.teamIds.toList();
      sortedIds.sort((a, b) => standings[b]!['pts'].compareTo(standings[a]!['pts']));

      return SingleChildScrollView(
        child: DataTable(
          columnSpacing: 12,
          columns: const [
            DataColumn(label: Text('Team')),
            DataColumn(label: Text('P')),
            DataColumn(label: Text('W')),
            DataColumn(label: Text('L')),
            DataColumn(label: Text('Pts')),
          ],
          rows: sortedIds.map((tid) {
            String name = controller.teams.firstWhere((t) => t.id == tid).name;
            var data = standings[tid]!;
            return DataRow(cells: [
              DataCell(Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text('${data['p']}')),
              DataCell(Text('${data['w']}')),
              DataCell(Text('${data['l']}')),
              DataCell(Text('${data['pts']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
            ]);
          }).toList(),
        ),
      );
    });
  }

  Widget _buildMatches() {
    return Obx(() {
      var tMatches = controller.completedMatches.where((m) => m.tournamentId == tournament.id).toList().reversed.toList();
      if (tMatches.isEmpty) return const Center(child: Text('No matches played yet.'));
      
      return ListView.builder(
        itemCount: tMatches.length,
        itemBuilder: (context, index) {
          var match = tMatches[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text('${match.team1Name} vs ${match.team2Name}'),
              subtitle: Text(match.result),
              trailing: Text(match.date),
            ),
          );
        },
      );
    });
  }
}
