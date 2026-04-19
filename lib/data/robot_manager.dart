import 'dart:async';
import 'package:flutter/material.dart';
import 'package:piclicker/data/storage.dart';
import 'package:piclicker/data/constants.dart';

class RobotManager {
  /// Global callback for each robot tick (add to counter)
  static VoidCallback? _onRobotTick;

  /// Current click value and boost multipliers (updated from main)
  static double _clickValue = 3.14;
  static double _robotBoost = 1.0;

  /// Per-robot timers: id -> Timer
  static final Map<int, Timer?> robotTimers = {};

  /// Initialize with tick callback (called from main.dart)
  static void init({
    required VoidCallback onRobotTick,
    required double clickValue,
    required double robotBoost,
  }) {
    _onRobotTick = onRobotTick;
    _clickValue = clickValue;
    _robotBoost = robotBoost;
  }

  /// Update global multipliers (call when they change)
  static void updateGlobals(double clickValue, double boost) {
    _clickValue = clickValue;
    _robotBoost = boost;
  }

  /// Ensure robot is running if active, stop if not
  static void ensureRobotRunning(int robotId) {
    final robot = Upgrades.robots.firstWhere(
      (r) => r['id'] == robotId,
      orElse: () => throw ArgumentError('Robot $robotId not found'),
    );

    final power = robot['power'] as int;
    final cores = robot['cores'] as int;

    // Stop existing timer
    stopRobot(robotId);

    // Start new if active
    if (userStorage.isRobotActive(robotId)) {
      robotTimers[robotId] = Timer.periodic(Duration(milliseconds: power), (
        timer,
      ) {
        _onRobotTick?.call();
      });
    }
  }

  /// Stop specific robot timer
  static void stopRobot(int robotId) {
    robotTimers[robotId]?.cancel();
    robotTimers.remove(robotId);
  }

  /// Stop all robots
  static void stopAll() {
    robotTimers.values.whereType<Timer>().forEach((timer) => timer.cancel());
    robotTimers.clear();
  }

  /// Toggle robot: stop if active, ensure running if was inactive
  static void toggleRobot(int robotId) {
    // storage.toggle already called from UI
    // Just ensure correct state
    ensureRobotRunning(robotId);
  }

  /// Robot click amount per tick (for offline calc)
  static double getClickAmount(int robotId) {
    final robot = Upgrades.robots.firstWhere((r) => r['id'] == robotId);
    final cores = robot['cores'] as int;
    return _clickValue * cores * _robotBoost;
  }

  /// Check if robot has active timer
  static bool isRobotRunning(int robotId) =>
      robotTimers.containsKey(robotId) && robotTimers[robotId] != null;
}
