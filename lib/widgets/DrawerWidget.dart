import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piclicker/data/storage.dart';
import 'package:piclicker/views/pages/batteries_page.dart';
import 'package:piclicker/views/pages/expeditions_page.dart';
import 'package:piclicker/views/pages/managers_page.dart';
import 'package:piclicker/views/pages/robots_page.dart';
import 'package:piclicker/views/pages/subscription_page.dart';
import 'package:piclicker/views/pages/thresholds.dart';
import 'package:piclicker/views/pages/tutorial/tutorial.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  void initState() {
    super.initState();
  }

  void _navigateTo(
    BuildContext context,
    Widget page,
    List<Map<String, String>> screens,
    String pageKey,
  ) {
    userStorage.save();
    Navigator.of(context).pop(); // Zamknij drawer
    Navigator.of(context).popUntil((route) => route.isFirst); // Wróć do bazy
    if (userStorage.isTutorialCompleted(pageKey)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TutorialPage(
            screens: screens,
            onFinishPage: page,
            pageKey: pageKey,
          ),
        ),
      );
    }
  }

  VoidCallback _createLockedOnTap(int requiredLevel) {
    return () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                'Reach level $requiredLevel to unblock this content',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF37474F),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final progressData = userStorage.getLevelProgress();
    final xp = userStorage.xp;
    final progress = progressData['progress'] as double;
    final level = userStorage.playerLevel;
    final nextThreshold = progressData['nextThreshold'] as double;

    final bool unlockedRobots = level >= 3;
    final bool unlockedBatteries = level >= 6;
    final bool unlockedManagers = level >= 9;
    final bool unlockedExpeditions = level >= 15;

    return Drawer(
      backgroundColor: const Color(0xFF001214), // Głęboka czerń/morski
      child: Column(
        children: [
          // --- NAGŁÓWEK DRAWERA ---
          _buildHeader(xp, progress, level, nextThreshold),

          // --- LISTA OPCJI ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildMenuItem(
                  Icons.play_arrow_rounded,
                  "Play",
                  Colors.tealAccent,
                  onTap: () {
                    userStorage.save();
                    Navigator.of(context).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                const SizedBox(height: 8),
                _buildPremiumItem(context), // Specjalny przycisk Infinity
                const SizedBox(height: 8),
                const Divider(color: Colors.white10),
                _buildMenuItem(
                  Icons.work_outline,
                  "Thresholds",
                  Colors.tealAccent,
                  onTap: () =>
                      _navigateTo(context, const ThresholdsPage(), const [
                        {'image': '', 'title': ''},
                      ], 'thresholds'),
                  isUnlocked: true,
                ),
                _buildMenuItem(
                  Icons.computer_sharp,
                  "Robots",
                  Colors.blueAccent,
                  onTap: unlockedRobots
                      ? () => _navigateTo(context, const RobotsPage(), [
                          {
                            'type': 'lottie',
                            'name': 'teal-click',
                            'title': 'Tired of clicking?',
                            'text':
                                'Hire robots to do all the clicking for you!',
                          },
                          {
                            'type': 'lottie',
                            'name': 'teal-robot',
                            'title': 'The architecture',
                            'text':
                                'Robots have Power, which determines the speed at which a click is executed, and Cores, which determines the number of clicks per action.',
                          },
                          {
                            'type': 'lottie',
                            'name': 'teal-hearts',
                            'title': 'Health and safety at work',
                            'text':
                                'Robots have health points - if these drop to zero, the robot will stop working. You can buy new ones at the Robot Market!',
                          },
                        ], 'robots')
                      : _createLockedOnTap(3),
                  isUnlocked: unlockedRobots,
                ),
                _buildMenuItem(
                  Icons.battery_charging_full_sharp,
                  "Batteries",
                  Colors.orangeAccent,
                  onTap: unlockedBatteries
                      ? () => _navigateTo(
                          context,
                          const BatteriesPage(),
                          const [],
                          'batteries',
                        )
                      : _createLockedOnTap(6),
                  isUnlocked: unlockedBatteries,
                ),
                _buildMenuItem(
                  Icons.work_outline,
                  "Managers",
                  Colors.purpleAccent,
                  onTap: unlockedManagers
                      ? () => _navigateTo(
                          context,
                          const ManagersPage(),
                          const [],
                          'managers',
                        )
                      : _createLockedOnTap(9),
                  isUnlocked: unlockedManagers,
                ),
                _buildMenuItem(
                  Icons.travel_explore,
                  "Expeditions",
                  Colors.greenAccent,
                  onTap: unlockedExpeditions
                      ? () => _navigateTo(
                          context,
                          const ExpeditionsPage(),
                          const [],
                          'expeditions',
                        )
                      : _createLockedOnTap(15),
                  isUnlocked: unlockedExpeditions,
                ),
                const Divider(color: Colors.white10),
                _buildMenuItem(
                  Icons.pie_chart_outline,
                  "Statistics",
                  Colors.white70,
                  isUnlocked: true,
                ),
                _buildMenuItem(
                  Icons.settings_outlined,
                  "Preferences",
                  Colors.white70,
                  isUnlocked: true,
                ),
                _buildMenuItem(
                  Icons.exit_to_app_rounded,
                  "Quit Game",
                  Colors.redAccent,
                  onTap: () {
                    userStorage.save();
                    SystemNavigator.pop();
                  },
                ),
              ],
            ),
          ),

          // --- STOPKA ---
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(
    double xp,
    double progress,
    int level,
    double nextThreshold,
  ) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF003D33), Color(0xFF001214)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PI CLICKER",
            style: TextStyle(
              color: Colors.tealAccent,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "LEVEL PROGRESS",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(color: Colors.tealAccent, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white10,
              color: Colors.tealAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "LVL $level | ${xp.toInt()} / ${nextThreshold.toInt()} XP needed for next level",
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
    bool isUnlocked = true,
  }) {
    return Container(
      margin: isUnlocked ? null : EdgeInsets.all(2.0),
      child: ListTile(
        leading: isUnlocked ? Icon(icon, color: color, size: 22) : null,
        title: isUnlocked
            ? Text(
                title,
                style: TextStyle(
                  color: isUnlocked ? Colors.white : Colors.blueGrey[300],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Icon(Icons.lock, color: Colors.white60),
        tileColor: isUnlocked ? null : Colors.grey[850],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
        dense: true,
        hoverColor: isUnlocked ? color.withOpacity(0.1) : Colors.transparent,
      ),
    );
  }

  Widget _buildPremiumItem(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[900]!, Colors.blue[900]!],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 8),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.rocket_launch, color: Colors.amberAccent),
        title: const Text(
          "INFINITY PREMIUM",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        onTap: () => _navigateTo(
          context,
          const SubscriptionPage(),
          const [],
          'subscription',
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      color: Colors.black26,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PiClicker Alpha v1.2",
            style: TextStyle(
              color: Colors.white24,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "CORE: BNE EPYC 8413",
            style: TextStyle(color: Colors.white10, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
