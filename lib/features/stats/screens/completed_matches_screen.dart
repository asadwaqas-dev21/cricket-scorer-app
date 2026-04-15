import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_controller.dart';
import '../../../core/models/completed_match.dart';
import 'match_detail_screen.dart';

class CompletedMatchesScreen extends StatelessWidget {
  final AppController controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Matches'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.completedMatches.isEmpty) {
          return const Center(
            child: Text(
              'No matches have been completed yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // List newest first
        var sortedMatches = controller.completedMatches.reversed.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: sortedMatches.length,
          itemBuilder: (context, index) {
            CompletedMatch match = sortedMatches[index];
            return InkWell(
              onTap: () => Get.to(() => MatchDetailScreen(match: match)),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          match.date,
                          style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.sports_cricket, color: Colors.indigo),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(match.team1Name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(match.team1Score, style: const TextStyle(fontSize: 20, color: Colors.indigo, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const Text('vs', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(match.team2Name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(match.team2Score, style: const TextStyle(fontSize: 20, color: Colors.indigo, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        match.result,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        );
      }),
    );
  }
}
