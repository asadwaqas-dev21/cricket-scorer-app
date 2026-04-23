import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cricket_score/core/theme/app_theme.dart';
import 'package:cricket_score/features/app_controller.dart';
import 'package:cricket_score/features/setup/screens/match_setup_screen.dart';
import 'package:cricket_score/features/setup/screens/manage_teams_screen.dart';
import 'package:cricket_score/features/stats/screens/stats_screen.dart';
import 'package:cricket_score/features/stats/screens/completed_matches_screen.dart';
import 'package:cricket_score/features/stats/screens/manage_tournaments_screen.dart';
import 'package:cricket_score/features/scoring/screens/scoring_screen.dart';
import 'package:cricket_score/features/scoring/controllers/scoring_controller.dart';
import 'package:cricket_score/core/models/match_settings.dart';
import 'package:cricket_score/core/models/ball_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  final AppController controller = Get.find<AppController>();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.darkGradient),
        child: FadeTransition(
          opacity: _fadeIn,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Branded header ──
              SliverToBoxAdapter(child: _buildBrandHeader(context)),
              // ── Quick stats row ──
              SliverToBoxAdapter(child: _buildQuickStats()),
              // ── Hero CTA ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _buildHeroCTA(),
                ),
              ),
              // ── Navigation menu ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _buildMenuSection(),
                ),
              ),
              // ── Recent form / last match ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 20 + bottom),
                  child: _buildRecentMatchCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  BRAND HEADER
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildBrandHeader(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(24, top + 20, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A6B3C), Color(0xFF145230), Color(0xFF0E3E22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E4526).withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo mark
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Center(child: Text('🏏', style: TextStyle(fontSize: 24))),
          ),
          SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cricket Scorer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'PRO',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (Get.isDarkMode) {
                Get.changeThemeMode(ThemeMode.light);
              } else {
                Get.changeThemeMode(ThemeMode.dark);
              }
              // Force rebuild for custom static theme colors
              Future.delayed(const Duration(milliseconds: 100), () {
                Get.forceAppUpdate();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Get.isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          SizedBox(width: 12),
          // Mini badge — total matches
          Obx(() {
            final count = controller.completedMatches.length;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.scoreboard_outlined,
                    size: 14,
                    color: Colors.white54,
                  ),
                  SizedBox(width: 5),
                  Text(
                    '$count',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  QUICK STATS ROW
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildQuickStats() {
    return Obx(() {
      final orange = controller.getOrangeCap();
      final purple = controller.getPurpleCap();
      final teamsCount = controller.teams.length;

      return Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          children: [
            _StatChip(
              label: 'Teams',
              value: '$teamsCount',
              color: AppTheme.blue,
            ),
            SizedBox(width: 10),
            _StatChip(
              label: 'Top Run Scorer',
              value: orange != null ? '${orange.runsScored}' : '–',
              color: const Color(0xFFE8A838),
            ),
            SizedBox(width: 10),
            _StatChip(
              label: 'Top Wicket Taker',
              value: purple != null ? '${purple.wicketsTaken}' : '–',
              color: const Color(0xFF7B5EA7),
            ),
          ],
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  HERO CTA — START NEW MATCH
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildHeroCTA() {
    final ongoing = controller.getOngoingMatch();
    final bool hasOngoing = ongoing != null;

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (hasOngoing) {
                final settings = MatchSettings.fromJson(ongoing['settings']);
                final List<BallEvent> events = (ongoing['events'] as List)
                    .map((e) => BallEvent.fromJson(e))
                    .toList();

                Get.delete<ScoringController>();
                final scoringCtrl = Get.put(ScoringController());
                scoringCtrl.resumeMatch(settings, events, ongoing);
                Get.to(() => ScoringScreen());
              } else {
                Get.delete<ScoringController>();
                Get.to(() => const MatchSetupScreen());
              }
            },
            child: Ink(
              decoration: BoxDecoration(
                gradient: hasOngoing
                    ? LinearGradient(
                        colors: [Color(0xFFE8A838), Color(0xFFC68B25)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : LinearGradient(
                        colors: [Color(0xFF1A6B3C), Color(0xFF21854D)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryLight.withOpacity(0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (hasOngoing ? AppTheme.accent : AppTheme.primary)
                        .withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        hasOngoing
                            ? Icons.history_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasOngoing ? 'Resume Match' : 'Start New Match',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            hasOngoing
                                ? 'Continue your paused match'
                                : 'Set up teams, overs & toss',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white38,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasOngoing) ...[
            SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: Text('Start New Match?'),
                    content: Text(
                      'This will delete the current ongoing match progress.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.clearOngoingMatch();
                          Get.back();
                          Get.to(() => const MatchSetupScreen());
                        },
                        child: Text(
                          'Start New',
                          style: TextStyle(color: AppTheme.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white70, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Start New Match Instead',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  MENU SECTION
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXPLORE',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        SizedBox(height: 14),
        // 2×2 grid
        Row(
          children: [
            Expanded(
              child: _MenuTile(
                title: 'Match\nHistory',
                accent: AppTheme.blue,
                icon: Icons.history_rounded,
                onTap: () => Get.to(() => CompletedMatchesScreen()),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MenuTile(
                title: 'Tour-\nnaments',
                accent: const Color(0xFF7B5EA7),
                icon: Icons.emoji_events_rounded,
                onTap: () => Get.to(() => ManageTournamentsScreen()),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MenuTile(
                title: 'Leader-\nboards',
                accent: AppTheme.accent,
                icon: Icons.leaderboard_rounded,
                onTap: () => Get.to(() => StatsScreen()),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MenuTile(
                title: 'Teams &\nPlayers',
                accent: AppTheme.primaryLight,
                icon: Icons.groups_rounded,
                onTap: () => Get.to(() => ManageTeamsScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  RECENT MATCH CARD
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildRecentMatchCard() {
    return Obx(() {
      if (controller.completedMatches.isEmpty) {
        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              Icon(
                Icons.sports_cricket_rounded,
                color: AppTheme.textMuted,
                size: 32,
              ),
              SizedBox(height: 10),
              Text(
                'No matches played yet',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Start a match and your stats will appear here.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      final lastMatch = controller.completedMatches.last;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LAST MATCH',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teams
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lastMatch.team1Name,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'vs',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        lastMatch.team2Name,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Result
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    lastMatch.result,
                    style: TextStyle(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                // Date
                Text(
                  lastMatch.date,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  PRIVATE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuTile({
    required this.title,
    required this.accent,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
