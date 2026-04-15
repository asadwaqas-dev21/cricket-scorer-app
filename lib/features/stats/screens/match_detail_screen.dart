import 'package:flutter/material.dart';
import '../../../core/models/completed_match.dart';

class MatchDetailScreen extends StatelessWidget {
  final CompletedMatch match;

  const MatchDetailScreen({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Scorecard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMatchSummary(),
            const SizedBox(height: 20),
            _buildManOfTheMatch(),
            const SizedBox(height: 20),
            _buildSectionHeader('Batting Performances', Icons.sports_cricket),
            _buildBattingTable(),
            const SizedBox(height: 20),
            _buildSectionHeader('Bowling Performances', Icons.sports_baseball),
            _buildBowlingTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchSummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(match.date, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _teamScoreBox(match.team1Name, match.team1Score),
                const Text('VS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                _teamScoreBox(match.team2Name, match.team2Score),
              ],
            ),
            const Divider(height: 30),
            Text(match.result, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _teamScoreBox(String name, String score) {
    return Column(
      children: [
        Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(score, style: const TextStyle(fontSize: 22, color: Colors.indigo, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildManOfTheMatch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.amber.shade200, Colors.amber.shade700]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 30, color: Colors.white),
          const SizedBox(width: 10),
          Column(
            children: [
              const Text('MAN OF THE MATCH', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(match.manOfTheMatch, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
      ],
    );
  }

  Widget _buildBattingTable() {
    return Card(
      child: DataTable(
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Batsman')),
          DataColumn(label: Text('R')),
          DataColumn(label: Text('B')),
          DataColumn(label: Text('SR')),
        ],
        rows: match.battingPerformances.map((b) {
          double sr = b['balls'] > 0 ? (b['runs'] / b['balls']) * 100 : 0.0;
          return DataRow(cells: [
            DataCell(Text('${b['name']}\n(${b['team']})', style: const TextStyle(fontSize: 12))),
            DataCell(Text('${b['runs']}')),
            DataCell(Text('${b['balls']}')),
            DataCell(Text(sr.toStringAsFixed(1))),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildBowlingTable() {
    return Card(
      child: DataTable(
        columnSpacing: 15,
        columns: const [
          DataColumn(label: Text('Bowler')),
          DataColumn(label: Text('O')),
          DataColumn(label: Text('W')),
          DataColumn(label: Text('R')),
        ],
        rows: match.bowlingPerformances.map((b) {
          return DataRow(cells: [
            DataCell(Text('${b['name']}\n(${b['team']})', style: const TextStyle(fontSize: 12))),
            DataCell(Text('${b['overs']}')),
            DataCell(Text('${b['wickets']}')),
            DataCell(Text('${b['runs']}')),
          ]);
        }).toList(),
      ),
    );
  }
}
