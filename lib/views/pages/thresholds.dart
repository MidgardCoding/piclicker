import 'package:flutter/material.dart';
import 'package:piclicker/data/constants.dart';
import 'dart:ui';
import 'package:piclicker/data/storage.dart';
import 'package:piclicker/data/constants.dart';
import 'package:piclicker/widgets/pro_tip_widget.dart';

class ThresholdsPage extends StatelessWidget {
  const ThresholdsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> blocks = Thresholds.blocks;
    final double currentXp = userStorage.xp;
    final progressData = userStorage.getLevelProgress();
    final progress = progressData['progress'] as double;
    final level = progressData['level'] as int;
    final nextThreshold = progressData['nextThreshold'] as double;

    return Scaffold(
      backgroundColor: const Color(0xFF001214),
      appBar: AppBar(
        title: const Text(
          "PROGRESS THRESHOLDS",
          style: TextStyle(letterSpacing: 2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ProTipWidget(
                    boxIcon: Icon(Icons.stacked_line_chart_sharp),
                    title: "Rise to the top with Thresholds!",
                    description:
                        "Thresholds are special types of levels that grant rewards. You unlock them with XP. Every third Threshold (marked with a different color) has a special reward that unlocks new content. Ready for the challenge?",
                    button: null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30.0,
                    left: 60.0,
                    right: 60.0,
                    bottom: 130,
                  ),
                  child: Column(
                    children: List.generate(blocks.length, (index) {
                      final blockData = blocks[index];
                      final bool isAvailable =
                          currentXp >= (blockData['xp'] as num);
                      final bool isSpecial = (index + 1) % 3 == 0;

                      int step = index % 6;
                      double paddingFactor = step <= 3
                          ? step.toDouble()
                          : (6 - step).toDouble();

                      return Padding(
                        padding: EdgeInsets.only(
                          left: paddingFactor * 40.0,
                          right: (3 - paddingFactor).clamp(0, 3) * 40.0,
                          bottom: 20.0,
                        ),
                        child: ThresholdBlock(
                          data: blockData,
                          available: isAvailable,
                          isSpecial: isSpecial,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildProgressBox(progress, level, currentXp, nextThreshold),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBox(
    double progress,
    int level,
    double xp,
    double nextThreshold,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF003D33), Color(0xFF001214)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
}

class ThresholdBlock extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool available;
  final bool isSpecial;

  const ThresholdBlock({
    super.key,
    required this.data,
    required this.available,
    required this.isSpecial,
  });

  @override
  Widget build(BuildContext context) {
    Color mainColor = available
        ? (isSpecial ? Colors.purpleAccent : Colors.tealAccent)
        : Colors.grey;

    return Container(
      width: 220,
      padding: isSpecial ? const EdgeInsets.all(4) : const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: available
            ? [
                BoxShadow(
                  color: mainColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [],
        gradient: LinearGradient(
          colors: [mainColor, mainColor.withOpacity(0.35)],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSpecial
              ? const Color.fromARGB(255, 67, 13, 87)
              : const Color(0xFF001A1D),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                available ? (data['icon']) : Icons.lock_outline_rounded,
                color: mainColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    available ? data['name'] : "BLOCKED",
                    style: TextStyle(
                      color: available ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    available ? data['prize'] : "Reach ${data['xp']} XP",
                    style: TextStyle(color: mainColor, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
