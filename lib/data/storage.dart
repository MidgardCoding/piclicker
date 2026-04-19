import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'package:piclicker/data/constants.dart';
import 'dart:ui';

class UserStorage {
  // Persistent fields
  double counter = 0;
  int picount = 0;
  double clickValue = 3.14;
  String buttonText = "π";

  int numberLevel = 0;
  int robotLevel = 0;
  int comboLevel = 0;

  // Purchased robots as list of {id: true}
  List<Map<int, bool>> purchasedRobots = [];
  // Active robots
  Set<int> activeRobotIds = {};

  // Purchased boosters as list of ids
  List<int> purchasedBoosters = [];

  // Daily manager selection
  Map<String, dynamic>? todayManager; // selected manager map from constants
  String? todayManagerDate; // stored as YYYY-MM-DD

  // Hired managers (persisted) - list of manager maps
  List<Map<String, dynamic>> hiredManagers = [];

  // Selected working manager (the one currently working)
  String? selectedManagerId;

  // Energy system (deprecated - replaced by XP system)
  // int energy = 0;
  // String? lastEnergyDate; // YYYY-MM-DD when energy was last refilled

  // XP system
  double xp = 0.0; // Total XP accumulated
  int playerLevel = 0; // Player level based on thresholds
  int? _previousLevel;
  double? _previousXp;
  bool _showingLevelUpDialog = false;
  int activeBatteryId = -1; // Currently active battery (-1 = none)
  List<int> purchasedBatteryIds = []; // List of purchased battery IDs

  // Daily robot market offers
  List<int> marketRobotIds = [];

  // Last session timestamp for offline calculation
  DateTime? lastSessionTime;

  // Click tracking
  int playerClicks = 0; // clicks made by player
  int robotClicks = 0; // clicks made by robots

  // Expedition system
  List<String> userEquipment = [];
  String? currentExpeditionSeed;
  String? expeditionSeedDataJson;
  DateTime? expeditionStartTime;
  String? expeditionManagerId;
  List<Map<String, dynamic>> activeExpeditions = [];

  String? lastMarketRefresh;

  // Tutorial completion tracking
  bool _tutorialThresholdsCompleted = false;
  bool _tutorialRobotsCompleted = false;
  bool _tutorialManagersCompleted = false;
  bool _tutorialBatteriesCompleted = false;
  bool _tutorialExpeditionsCompleted = false;
  bool _tutorialSubscriptionCompleted = false;

  // Keys
  static const _kCounter = 'counter';
  static const _kPiCount = 'picount';
  static const _kClickValue = 'clickValue';
  static const _kButtonText = 'buttonText';
  static const _kNumberLevel = 'numberLevel';
  static const _kRobotLevel = 'robotLevel';
  static const _kComboLevel = 'comboLevel';
  static const _kPurchasedRobotIds = 'purchasedRobotIds';
  static const _kPurchasedBoosterIds = 'purchasedBoosterIds';
  static const _kTodayManager = 'todayManager';
  static const _kTodayManagerDate = 'todayManagerDate';
  static const _kHiredManagers = 'hiredManagers';
  static const _kSelectedManagerId = 'selectedManagerId';
  static const _kEnergy = 'energy';
  static const _kLastEnergyDate = 'lastEnergyDate';
  // XP system keys
  static const _kXP = 'xp';
  static const _kPlayerLevel = 'playerLevel';
  static const _kActiveBatteryId = 'activeBatteryId';
  static const _kPurchasedBatteryIds = 'purchasedBatteryIds';
  static const _kLastSessionTime = 'lastSessionTime';
  static const _kPlayerClicks = 'playerClicks';
  static const _kRobotClicks = 'robotClicks';

  // Expedition keys
  static const _kUserEquipment = 'userEquipment';
  static const _kCurrentExpeditionSeed = 'currentExpeditionSeed';
  static const _kExpeditionSeedDataJson = 'expeditionSeedDataJson';
  static const _kExpeditionStartTime = 'expeditionStartTime';
  static const _kExpeditionManagerId = 'expeditionManagerId';
  static const _kActiveExpeditions = 'activeExpeditions';

  // Tutorial keys
  static const _kTutorialThresholds = 'tutorial_thresholds_completed';
  static const _kTutorialRobots = 'tutorial_robots_completed';
  static const _kTutorialManagers = 'tutorial_managers_completed';
  static const _kTutorialBatteries = 'tutorial_batteries_completed';
  static const _kTutorialExpeditions = 'tutorial_expeditions_completed';
  static const _kTutorialSubscription = 'tutorial_subscription_completed';
  static const _kActiveRobotIds = 'activeRobotIds';
  static const _kMarketRobotIds = 'marketRobotIds';
  static const _kLastMarketRefresh = 'lastMarketRefresh';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    counter = prefs.getDouble(_kCounter) ?? 0.0;
    picount = prefs.getInt(_kPiCount) ?? 0;
    clickValue = prefs.getDouble(_kClickValue) ?? 3.14;
    buttonText = prefs.getString(_kButtonText) ?? "π";

    numberLevel = prefs.getInt(_kNumberLevel) ?? 0;
    robotLevel = prefs.getInt(_kRobotLevel) ?? 0;
    comboLevel = prefs.getInt(_kComboLevel) ?? 0;

    final ids = prefs.getStringList(_kPurchasedRobotIds) ?? <String>[];
    purchasedRobots = ids
        .map((s) => int.tryParse(s))
        .where((id) => id != null)
        .map((id) => {id!: true})
        .toList();

    final boosterIds = prefs.getStringList(_kPurchasedBoosterIds) ?? <String>[];
    purchasedBoosters = boosterIds
        .map((s) => int.tryParse(s))
        .whereType<int>()
        .toList();

    // Load today's manager
    todayManagerDate = prefs.getString(_kTodayManagerDate);
    final tm = prefs.getStringList(_kTodayManager);
    if (tm != null && tm.length >= 6) {
      // expect order: name,duration,price,imageSrc,id,rarity
      todayManager = {
        'name': tm[0],
        'duration': tm[1],
        'price': tm[2],
        'imageSrc': tm[3],
        'id': tm[4],
        'rarity': tm[5],
      };
    }

    // Load hired managers (list)
    hiredManagers = [];
    final hiredManagersData = prefs.getStringList(_kHiredManagers) ?? [];
    // Data is stored as multiple concatenated lists
    // Each manager has 6 fields: name, duration, price, imageSrc, id, rarity
    final managerCount = hiredManagersData.length ~/ 6;
    for (int i = 0; i < managerCount; i++) {
      final baseIndex = i * 6;
      if (baseIndex + 5 < hiredManagersData.length) {
        hiredManagers.add({
          'name': hiredManagersData[baseIndex],
          'duration': hiredManagersData[baseIndex + 1],
          'price': hiredManagersData[baseIndex + 2],
          'imageSrc': hiredManagersData[baseIndex + 3],
          'id': hiredManagersData[baseIndex + 4],
          'rarity': hiredManagersData[baseIndex + 5],
        });
      }
    }

    // Load selected working manager
    selectedManagerId = prefs.getString(_kSelectedManagerId);

    // Load XP system
    xp = prefs.getDouble(_kXP) ?? 0.0;
    playerLevel = prefs.getInt(_kPlayerLevel) ?? 3;
    activeBatteryId = prefs.getInt(_kActiveBatteryId) ?? -1;
    final batteryIds = prefs.getStringList(_kPurchasedBatteryIds) ?? <String>[];
    purchasedBatteryIds = batteryIds
        .map((s) => int.tryParse(s))
        .whereType<int>()
        .toList();

    // Auto-compute level from XP if needed
    _updatePlayerLevelFromXP();

    _previousLevel = playerLevel;
    _previousXp = xp;
    _showingLevelUpDialog = false;

    // Load last session time
    final lastSessionStr = prefs.getString(_kLastSessionTime);
    if (lastSessionStr != null) {
      lastSessionTime = DateTime.tryParse(lastSessionStr);
    }

    // Load click tracking
    playerClicks = prefs.getInt(_kPlayerClicks) ?? 0;
    robotClicks = prefs.getInt(_kRobotClicks) ?? 0;

    // Load expedition data
    userEquipment = prefs.getStringList(_kUserEquipment) ?? [];
    currentExpeditionSeed = prefs.getString(_kCurrentExpeditionSeed);
    expeditionSeedDataJson = prefs.getString(_kExpeditionSeedDataJson);
    final startTimeStr = prefs.getString(_kExpeditionStartTime);
    if (startTimeStr != null) {
      expeditionStartTime = DateTime.tryParse(startTimeStr);
    }
    expeditionManagerId = prefs.getString(_kExpeditionManagerId);

    // Load active expeditions
    final activeJson = prefs.getStringList(_kActiveExpeditions) ?? [];
    activeExpeditions = [];
    for (final jsonStr in activeJson) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        map['startTime'] = DateTime.parse(map['startTime']);
        activeExpeditions.add(map);
      } catch (e) {
        print('Invalid expedition data: $e');
      }
    }

    // Load tutorial completions
    _tutorialThresholdsCompleted = prefs.getBool(_kTutorialThresholds) ?? false;
    _tutorialRobotsCompleted = prefs.getBool(_kTutorialRobots) ?? false;
    _tutorialManagersCompleted = prefs.getBool(_kTutorialManagers) ?? false;
    _tutorialBatteriesCompleted = prefs.getBool(_kTutorialBatteries) ?? false;
    _tutorialExpeditionsCompleted =
        prefs.getBool(_kTutorialExpeditions) ?? false;
    _tutorialSubscriptionCompleted =
        prefs.getBool(_kTutorialSubscription) ?? false;

    // Load active robot IDs
    final activeIdsStr = prefs.getStringList(_kActiveRobotIds) ?? [];
    activeRobotIds = activeIdsStr
        .map((s) => int.tryParse(s) ?? 0)
        .where((id) => id > 0)
        .toSet();

    // Load market robot IDs
    final marketIdsStr = prefs.getStringList(_kMarketRobotIds) ?? <String>[];
    marketRobotIds = marketIdsStr
        .map((s) => int.tryParse(s))
        .whereType<int>()
        .toList();

    // Migrate: if no active robots but purchased exist, activate all
    if (activeRobotIds.isEmpty && purchasedRobots.isNotEmpty) {
      activeRobotIds = purchasedRobots.map((e) => e.keys.first).toSet();
    }

    lastMarketRefresh = prefs.getString(_kLastMarketRefresh);
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kCounter, counter);
    await prefs.setInt(_kPiCount, picount);
    await prefs.setDouble(_kClickValue, clickValue);
    await prefs.setString(_kButtonText, buttonText);

    await prefs.setInt(_kNumberLevel, numberLevel);
    await prefs.setInt(_kRobotLevel, robotLevel);
    await prefs.setInt(_kComboLevel, comboLevel);

    final ids = purchasedRobots.map((e) => e.keys.first.toString()).toList();
    await prefs.setStringList(_kPurchasedRobotIds, ids);

    final boosterIds = purchasedBoosters.map((e) => e.toString()).toList();
    await prefs.setStringList(_kPurchasedBoosterIds, boosterIds);

    // Save today's manager
    if (todayManager != null) {
      await prefs.setStringList(_kTodayManager, [
        todayManager!['name']?.toString() ?? '',
        todayManager!['duration']?.toString() ?? '',
        todayManager!['price']?.toString() ?? '',
        todayManager!['imageSrc']?.toString() ?? '',
        todayManager!['id']?.toString() ?? '',
        todayManager!['rarity']?.toString() ?? '',
      ]);
    }
    if (todayManagerDate != null) {
      await prefs.setString(_kTodayManagerDate, todayManagerDate!);
    }

    // Save hired managers (list)
    final hiredManagersData = <String>[];
    for (final manager in hiredManagers) {
      hiredManagersData.add(manager['name']?.toString() ?? '');
      hiredManagersData.add(manager['duration']?.toString() ?? '');
      hiredManagersData.add(manager['price']?.toString() ?? '');
      hiredManagersData.add(manager['imageSrc']?.toString() ?? '');
      hiredManagersData.add(manager['id']?.toString() ?? '');
      hiredManagersData.add(manager['rarity']?.toString() ?? '');
    }
    await prefs.setStringList(_kHiredManagers, hiredManagersData);

    // Save selected working manager
    if (selectedManagerId != null) {
      await prefs.setString(_kSelectedManagerId, selectedManagerId!);
    } else {
      await prefs.remove(_kSelectedManagerId);
    }

    // Save XP system
    await prefs.setDouble(_kXP, xp);
    await prefs.setInt(_kPlayerLevel, playerLevel);
    await prefs.setInt(_kActiveBatteryId, activeBatteryId);
    final batteryIds = purchasedBatteryIds.map((e) => e.toString()).toList();
    await prefs.setStringList(_kPurchasedBatteryIds, batteryIds);

    // Save last session time
    if (lastSessionTime != null) {
      await prefs.setString(
        _kLastSessionTime,
        lastSessionTime!.toIso8601String(),
      );
    }

    // Save click tracking
    await prefs.setInt(_kPlayerClicks, playerClicks);
    await prefs.setInt(_kRobotClicks, robotClicks);

    // Save expedition data
    await prefs.setStringList(_kUserEquipment, userEquipment);
    if (currentExpeditionSeed != null) {
      await prefs.setString(_kCurrentExpeditionSeed, currentExpeditionSeed!);
    } else {
      await prefs.remove(_kCurrentExpeditionSeed);
    }
    if (expeditionSeedDataJson != null) {
      await prefs.setString(_kExpeditionSeedDataJson, expeditionSeedDataJson!);
    } else {
      await prefs.remove(_kExpeditionSeedDataJson);
    }
    if (expeditionStartTime != null) {
      await prefs.setString(
        _kExpeditionStartTime,
        expeditionStartTime!.toIso8601String(),
      );
    } else {
      await prefs.remove(_kExpeditionStartTime);
    }
    if (expeditionManagerId != null) {
      await prefs.setString(_kExpeditionManagerId, expeditionManagerId!);
    } else {
      await prefs.remove(_kExpeditionManagerId);
    }

    // Save active expeditions
    final activeJson = activeExpeditions.map((e) {
      final map = Map<String, dynamic>.from(e);
      map['startTime'] = map['startTime'].toIso8601String();
      return jsonEncode(map);
    }).toList();
    await prefs.setStringList(_kActiveExpeditions, activeJson);

    // Save tutorial completions
    await prefs.setBool(_kTutorialThresholds, _tutorialThresholdsCompleted);
    await prefs.setBool(_kTutorialRobots, _tutorialRobotsCompleted);
    await prefs.setBool(_kTutorialManagers, _tutorialManagersCompleted);
    await prefs.setBool(_kTutorialBatteries, _tutorialBatteriesCompleted);
    await prefs.setBool(_kTutorialExpeditions, _tutorialExpeditionsCompleted);
    await prefs.setBool(_kTutorialSubscription, _tutorialSubscriptionCompleted);

    // Save active robot IDs
    await prefs.setStringList(
      _kActiveRobotIds,
      activeRobotIds.map((id) => id.toString()).toList(),
    );

    // Save market robot IDs
    final marketIds = marketRobotIds.map((id) => id.toString()).toList();
    await prefs.setStringList(_kMarketRobotIds, marketIds);

    if (lastMarketRefresh != null) {
      await prefs.setString(_kLastMarketRefresh, lastMarketRefresh!);
    } else {
      await prefs.remove(_kLastMarketRefresh);
    }
  }

  /// Check if tutorial for given page is completed
  bool isTutorialCompleted(String pageKey) {
    switch (pageKey) {
      case 'thresholds':
        return _tutorialThresholdsCompleted;
      case 'robots':
        return _tutorialRobotsCompleted;
      case 'managers':
        return _tutorialManagersCompleted;
      case 'batteries':
        return _tutorialBatteriesCompleted;
      case 'expeditions':
        return _tutorialExpeditionsCompleted;
      case 'subscription':
        return _tutorialSubscriptionCompleted;
      default:
        return true;
    }
  }

  /// Mark tutorial for page as completed
  Future<void> markTutorialCompleted(String pageKey) async {
    switch (pageKey) {
      case 'thresholds':
        _tutorialThresholdsCompleted = true;
        break;
      case 'robots':
        _tutorialRobotsCompleted = true;
        break;
      case 'managers':
        _tutorialManagersCompleted = true;
        break;
      case 'batteries':
        _tutorialBatteriesCompleted = true;
        break;
      case 'expeditions':
        _tutorialExpeditionsCompleted = true;
        break;
      case 'subscription':
        _tutorialSubscriptionCompleted = true;
        break;
    }
    await save();
  }

  // Helper method to add a hired manager
  Future<void> addHiredManager(Map<String, dynamic> manager) async {
    // Check if manager already exists
    final existingIndex = hiredManagers.indexWhere(
      (m) => m['id'] == manager['id'],
    );
    if (existingIndex == -1) {
      hiredManagers.add(manager);
      await save();
    }
  }

  // Helper method to remove a hired manager
  Future<void> removeHiredManager(String managerId) async {
    hiredManagers.removeWhere((m) => m['id'] == managerId);
    // If the removed manager was the selected one, clear selection
    if (selectedManagerId == managerId) {
      selectedManagerId = null;
    }
    await save();
  }

  // Check if a manager is already hired
  bool isManagerHired(String managerId) {
    return hiredManagers.any((m) => m['id'] == managerId);
  }

  // Set the selected working manager
  Future<void> setSelectedManager(String? managerId) async {
    selectedManagerId = managerId;
    await save();
  }

  // Get the currently selected manager details
  Map<String, dynamic>? get selectedManager {
    if (selectedManagerId == null) return null;
    try {
      return hiredManagers.firstWhere((m) => m['id'] == selectedManagerId);
    } catch (_) {
      return null;
    }
  }

  // Calculate XP per click based on active battery
  int get xpPerClick {
    int baseXp = 5; // Base XP per player click

    if (activeBatteryId == -1) {
      return baseXp;
    }

    // Find the active battery
    try {
      final battery = Batteries.batteries.firstWhere(
        (b) => b['id'] == activeBatteryId.toString(),
      );

      final valueType = battery['valueType'] as String;
      final value = battery['value'] as int;

      if (valueType == 'addition') {
        return baseXp + value;
      } else if (valueType == 'multiplier') {
        return baseXp * value;
      }
    } catch (_) {
      // Battery not found, return base
    }

    return baseXp;
  }

  // Get the active battery details
  Map<String, dynamic>? get activeBattery {
    if (activeBatteryId == -1) return null;
    try {
      return Batteries.batteries.firstWhere(
        (b) => b['id'] == activeBatteryId.toString(),
      );
    } catch (_) {
      return null;
    }
  }

  // Expedition helpers
  void deductPointsPercentage(double percentage) {
    counter -= counter * (percentage / 100.0);
  }

  Future<void> addEquipment(String itemId) async {
    if (!userEquipment.contains(itemId)) {
      userEquipment.add(itemId);
      await save();
    }
  }

  Duration parseExpeditionTimeToDuration(String timeStr) {
    final regExp = RegExp(r'(\d+)\s*(minutes?|hours?|days?|weeks?)');
    final match = regExp.firstMatch(timeStr.toLowerCase());
    if (match == null) return const Duration(hours: 1); // default

    final numStr = match.group(1)!;
    final unit = match.group(2)!.toLowerCase();

    final num = int.parse(numStr);
    switch (unit) {
      case 'minute':
      case 'minutes':
        return Duration(minutes: num);
      case 'hour':
      case 'hours':
        return Duration(hours: num);
      case 'day':
      case 'days':
        return Duration(days: num);
      case 'week':
      case 'weeks':
        return Duration(days: num * 7);
      default:
        return const Duration(hours: 1);
    }
  }

  Future<void> checkAndCompleteAllExpeditions() async {
    final now = DateTime.now();
    final expiredIndices = <int>[];

    for (int i = 0; i < activeExpeditions.length; i++) {
      final exp = activeExpeditions[i];
      final elapsed = now.difference(exp['startTime'] as DateTime);
      final seedData =
          jsonDecode(exp['seedDataJson'] as String) as Map<String, dynamic>;
      final timeStr = seedData['expeditionTime'] as String;
      final lootPoolStr = seedData['lootPool'] as String;
      final requiredDuration = parseExpeditionTimeToDuration(timeStr);

      if (elapsed >= requiredDuration) {
        try {
          final poolId = int.parse(lootPoolStr);
          final pool = Expeditions.expeditionsLootPool[poolId];
          final List<dynamic> itemsIdList = pool['itemsId'] as List<dynamic>;
          final itemsId = itemsIdList.cast<String>();

          if (itemsId.isNotEmpty) {
            final random = Random();
            final numRewards = 1 + random.nextInt(itemsId.length);
            final rewards = <String>[];
            for (int j = 0; j < numRewards; j++) {
              final reward = itemsId[random.nextInt(itemsId.length)];
              await addEquipment(reward);
              rewards.add(reward);
            }
            print('Expedition $i complete! Rewards: ${rewards.join(', ')}');
          }
          expiredIndices.add(i);
        } catch (e) {
          print('Expedition completion error: $e');
        }
      }
    }

    // Remove completed expeditions (reverse order to preserve indices)
    for (final i in expiredIndices.reversed) {
      activeExpeditions.removeAt(i);
    }
    await save();
  }

  bool isManagerOnExpedition(String managerId) {
    return activeExpeditions.any((e) => e['managerId'] == managerId);
  }

  bool isExpeditionCompleted(Map<String, dynamic> exp) {
    if (!exp.containsKey('startTime') || !exp.containsKey('seedDataJson'))
      return true;
    final now = DateTime.now();
    final elapsed = now.difference(exp['startTime'] as DateTime);
    final seedData =
        jsonDecode(exp['seedDataJson'] as String) as Map<String, dynamic>;
    final timeStr = seedData['expeditionTime'] as String?;
    if (timeStr == null) return true;
    final requiredDuration = parseExpeditionTimeToDuration(timeStr);
    return elapsed >= requiredDuration;
  }

  List<Map<String, dynamic>> get activeExpeditionsFiltered {
    return activeExpeditions.where((e) => !isExpeditionCompleted(e)).toList();
  }

  Future<void> startExpedition(
    String seed,
    Map<String, dynamic> seedData,
    String managerId,
  ) async {
    if (activeExpeditions.length >= 5) {
      print('Max 5 expeditions');
      return;
    }
    if (isManagerOnExpedition(managerId)) {
      print('Manager already on expedition');
      return;
    }
    final exp = {
      'seed': seed,
      'seedDataJson': jsonEncode(seedData),
      'startTime': DateTime.now(),
      'managerId': managerId,
    };
    activeExpeditions.add(exp);
    await save();
  }

  bool get hasActiveExpeditions => activeExpeditionsFiltered.isNotEmpty;

  List<Map<String, dynamic>> get activeExpeditionsList =>
      activeExpeditionsFiltered;
  int get activeExpeditionsCount => activeExpeditions.length;

  static const List<String> levelUpMessages = [
    "Congratulations! You've completed level {level}! You've earned {xpGained} XP so far! 🚀",
    "Level {level} completed! {xpGained} XP earned so far! 🎉",
    "Great job! New level {level} and {xpGained} XP gained so far! ⭐",
    "Level up! {level} completed with {xpGained} XP earned! ⚡",
    "Bravo! Level {level} unlocked with {xpGained} XP earned! 🏆",
    "Fantastic! Level {level} in your pocket, with {xpGained} XP earned so far! 🌟",
    "{level} completed! {xpGained} XP gained so far! 💎",
    "Mastery! Level {level} + {xpGained} XP earned so far! 🔥",
  ];

  Future<void> cancelExpedition(int index) async {
    if (index >= 0 && index < activeExpeditions.length) {
      activeExpeditions.removeAt(index);
      await save();
    }
  }

  // Set active battery
  Future<void> setActiveBattery(int batteryId) async {
    activeBatteryId = batteryId;
    await save();
  }

  // Add a purchased battery
  Future<void> addPurchasedBattery(int batteryId) async {
    if (!purchasedBatteryIds.contains(batteryId)) {
      purchasedBatteryIds.add(batteryId);
      await save();
    }
  }

  /// Active robot status
  bool isRobotActive(int id) => activeRobotIds.contains(id);

  /// Toggle robot active status
  Future<void> toggleRobotActive(int id) async {
    if (activeRobotIds.contains(id)) {
      activeRobotIds.remove(id);
    } else {
      activeRobotIds.add(id);
    }
    await save();
  }

  /// Remove robot from purchased and active
  Future<void> removeRobot(int id) async {
    activeRobotIds.remove(id);
    purchasedRobots.removeWhere((e) => e.keys.first == id);
    await save();
  }

  /// Number of active robots (working)
  int get activeRobotCount => activeRobotIds.length;

  // Get the number of active robots

  Future<void> addXp(double amount, {BuildContext? context}) async {
    _previousXp ??= xp;
    _previousLevel ??= playerLevel;
    final prevLevel = _previousLevel!;
    final prevXp = _previousXp!;

    xp += amount;
    _updatePlayerLevelFromXP();

    if (playerLevel > prevLevel && context != null && !_showingLevelUpDialog) {
      final xpGained = xp - prevXp;
      showLevelUpDialog(context, playerLevel, xpGained);
    }

    _previousXp = xp;
    _previousLevel = playerLevel;

    await save();
  }

  void showLevelUpDialog(BuildContext context, int newLevel, double xpGained) {
    if (_showingLevelUpDialog) return;

    _showingLevelUpDialog = true;

    final random = Random();
    final message = levelUpMessages[random.nextInt(levelUpMessages.length)]
        .replaceAll('{level}', newLevel.toString())
        .replaceAll('{xpGained}', xp.toStringAsFixed(0));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.tealAccent, width: 1),
          ),
          title: const Text(
            'Level Up!',
            style: TextStyle(
              color: Colors.tealAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '$message\n\n${Thresholds.blocks[playerLevel - 1]["prize"]}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.tealAccent),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _showingLevelUpDialog = false;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Computes player level progress based on Thresholds.blocks
  Map<String, dynamic> getLevelProgress() {
    final blocks = Thresholds.blocks;
    if (blocks.isEmpty) {
      return {
        'level': 1,
        'currentThreshold': 0.0,
        'nextThreshold': 500.0,
        'progress': 0.0,
      };
    }

    int level = 1;
    double prevThreshold = 0.0;
    for (int i = 0; i < blocks.length; i++) {
      final blockXp = (blocks[i]['xp'] as num).toDouble();
      if (xp >= blockXp) {
        level = i + 1;
        prevThreshold = i > 0 ? (blocks[i - 1]['xp'] as num).toDouble() : 0.0;
      } else {
        break;
      }
    }

    double currentThreshold = 0.0;
    double nextThreshold = blocks[0]['xp'].toDouble();

    for (int i = 0; i < blocks.length; i++) {
      final blockXp = blocks[i]['xp'].toDouble();
      if (xp < blockXp) {
        nextThreshold = blockXp;
        if (i > 0) {
          currentThreshold = blocks[i - 1]['xp'].toDouble();
        }
        break;
      }
      currentThreshold = blockXp;
    }

    var progress = (xp - currentThreshold) / (nextThreshold - currentThreshold);
    if (progress.isNaN || progress.isInfinite) {
      progress = 0.0;
    }
    return {
      'level': level,
      'currentThreshold': currentThreshold,
      'nextThreshold': nextThreshold,
      'progress': progress.clamp(0.0, 1.0),
    };
  }

  /// Internal: Update playerLevel based on current xp
  void _updatePlayerLevelFromXP() {
    final blocks = Thresholds.blocks;
    if (blocks.isEmpty) return;

    int newLevel = 1;
    for (int i = 0; i < blocks.length; i++) {
      if (xp >= (blocks[i]['xp'] as num).toDouble()) {
        newLevel = i + 1;
      } else {
        break;
      }
    }
    playerLevel = newLevel;
  }

  int get robotCount => purchasedRobots.length;

  bool hasRobot(int id) => purchasedRobots.any((m) => m.keys.first == id);

  Future<bool> purchaseRobot(int id) async {
    bool success = false;
    if (!hasRobot(id)) {
      purchasedRobots.add({id: true});
      activeRobotIds.add(id);
      await save();
      success = true;
    }
    return success;
  }

  bool get isNewMarketDay {
    if (lastMarketRefresh == null || marketRobotIds.isEmpty) return true;
    final today = DateTime.now().toIso8601String().split('T')[0];
    return today != lastMarketRefresh;
  }

  Future<void> refreshMarket() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    lastMarketRefresh = today;
    await save();
  }
}

final UserStorage userStorage = UserStorage();
