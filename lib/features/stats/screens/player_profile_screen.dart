import 'package:flutter/material.dart';
import '../../../core/models/player.dart';

class PlayerProfileScreen extends StatelessWidget {
  final Player player;

  const PlayerProfileScreen({Key? key, required this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${player.name} Profile'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo.shade100,
                    child: const Icon(Icons.person, size: 60, color: Colors.indigo),
                  ),
                ),
                const SizedBox(height: 16),
                Text(player.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'MVP Points: ${player.mvpPoints}', 
                    textAlign: TextAlign.center, 
                    style: TextStyle(fontSize: 16, color: Colors.orange.shade900, fontWeight: FontWeight.bold)
                  ),
                ),
                const SizedBox(height: 32),
                _buildSectionHeader('Batting Statistics', Icons.sports_cricket),
                _buildStatRow('Runs Scored', '${player.runsScored}'),
                _buildStatRow('Balls Faced', '${player.ballsFaced}'),
                _buildStatRow('Strike Rate', player.strikeRate.toStringAsFixed(2)),
                _buildStatRow('Boundary 4s', '${player.fours}'),
                _buildStatRow('Boundary 6s', '${player.sixes}'),
                const Divider(height: 40, thickness: 1),
                _buildSectionHeader('Bowling & Fielding', Icons.sports_baseball),
                _buildStatRow('Wickets Taken', '${player.wicketsTaken}'),
                _buildStatRow('Overs Bowled', '${player.oversBowled}'),
                _buildStatRow('Runs Conceded', '${player.runsConceded}'),
                _buildStatRow('Economy Rate', player.economy.toStringAsFixed(2)),
                _buildStatRow('Catches', '${player.catches}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
