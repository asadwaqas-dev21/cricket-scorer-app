import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../setup/screens/match_setup_screen.dart';
import '../../setup/screens/manage_teams_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../../stats/screens/completed_matches_screen.dart';
import '../../stats/screens/manage_tournaments_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cricket Scorer Pro'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_cricket, size: 100, color: Colors.indigo.shade700),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              onPressed: () => Get.to(() => MatchSetupScreen()),
              label: const Text('Start New Match'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart),
              onPressed: () => Get.to(() => StatsScreen()),
              label: const Text('Global Leaderboards'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.emoji_events),
              onPressed: () => Get.to(() => ManageTournamentsScreen()),
              label: const Text('Tournaments'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.groups),
              onPressed: () => Get.to(() => ManageTeamsScreen()),
              label: const Text('Manage Teams & Players'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              onPressed: () => Get.to(() => CompletedMatchesScreen()),
              label: const Text('Match History'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
