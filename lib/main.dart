import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:piclicker/data/constants.dart';
import 'package:piclicker/data/storage.dart';
import 'package:piclicker/widgets/DrawerWidget.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PiClicker Alpha',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      home: const MyHomePage(title: "PiClicker"),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _counter = 0.0;
  int _picount = 0;
  double clickValue = 3.14;
  String buttonText = "π";

  String _formatNumber(double value) {
    // Extended units for very large numbers
    const units = [
      {'t': 'S', 'v': 1e63}, // Sexvigintillion
      {'t': 'Q', 'v': 1e60}, // Quinvigintillion
      {'t': 'Tt', 'v': 1e57}, // Quattuorvigintillion
      {'t': 'Td', 'v': 1e54}, // Trevigintillion
      {'t': 'Dd', 'v': 1e51}, // Duovigintillion
      {'t': 'D', 'v': 1e33}, // Decillion
      {'t': 'N', 'v': 1e30}, // Nonillion
      {'t': 'O', 'v': 1e27}, // Octillion
      {'t': 'Sp', 'v': 1e24}, // Septillion
      {'t': 'Sx', 'v': 1e21}, // Sextillion
      {'t': 'Qi', 'v': 1e18}, // Quintillion
      {'t': 'Qa', 'v': 1e15}, // Quadrillion
      {'t': 'T', 'v': 1e12}, // Trillion
      {'t': 'B', 'v': 1e9}, // Billion
      {'t': 'M', 'v': 1e6}, // Million
    ];
    for (final u in units) {
      final threshold = u['v'] as double;
      if (value >= threshold) {
        final short = value / threshold;
        if (short >= 100) {
          return short.toStringAsFixed(0) + (u['t'] as String);
        } else if (short >= 10) {
          return short.toStringAsFixed(1) + (u['t'] as String);
        } else {
          return short.toStringAsFixed(2) + (u['t'] as String);
        }
      }
    }
    return value.toStringAsFixed(2);
  }

  int robotLevel = 0;
  int numberLevel = 0;
  int comboLevel = 0;

  // Separate click tracking
  int playerClicks = 0;
  int robotClicks = 0;

  final List<Timer> _robotTimers = [];

  bool _loaded = false;

  final bool _forceShowBottomBar = false;

  final robots = Upgrades.robots;
  final numbers = Upgrades.numbers;

  // Get combos from constants
  List<Map<String, dynamic>> get combos => Combos.combos;

  // Get current combo multiplier (1.0 if no combo purchased)
  double get currentComboMultiplier {
    if (comboLevel > 0 && comboLevel <= combos.length) {
      return (combos[comboLevel - 1]['multiplier'] as double?) ?? 1.0;
    }
    return 1.0;
  }

  // Parse combo price string to double
  double _parseComboPrice(String priceStr) {
    final numericValue = double.tryParse(priceStr);
    if (numericValue != null) return numericValue;

    final lowerStr = priceStr.toLowerCase().trim();
    if (lowerStr.contains('milliard')) {
      return 1e9;
    } else if (lowerStr.contains('billion')) {
      return 1e12;
    } else if (lowerStr.contains('trillion')) {
      return 1e15;
    } else if (lowerStr.contains('quadrillion')) {
      return 1e18;
    } else if (lowerStr.contains('quintillion')) {
      return 1e21;
    } else if (lowerStr.contains('sextillion')) {
      return 1e24;
    } else if (lowerStr.contains('septillion')) {
      return 1e27;
    }
    return 0;
  }

  // Booster multipliers
  double _clickMultiplier = 1.0;
  double _robotIncomeMultiplier = 1.0;
  double _batteryMultiplier = 1.0;

  double get _totalRobotBoost => _robotIncomeMultiplier;

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  Future<void> _initLoad() async {
    await userStorage.load();
    setState(() {
      _counter = userStorage.counter;
      _picount = userStorage.picount;
      clickValue = userStorage.clickValue;
      buttonText = userStorage.buttonText;

      numberLevel = userStorage.numberLevel;
      robotLevel = userStorage.robotLevel;
      comboLevel = userStorage.comboLevel;

      // Load separate click tracking
      playerClicks = userStorage.playerClicks;
      robotClicks = userStorage.robotClicks;

      _loaded = true;
    });

    // Check for completed expeditions after load
    await userStorage.checkAndCompleteAllExpeditions();

    // XP system - no energy consumption, deprecated

    await _calculateOfflineEarnings();

    for (final entry in userStorage.purchasedRobots) {
      final id = entry.keys.first;
      final robot = robots.firstWhere((r) => r['id'] == id, orElse: () => {});
      if (robot.isNotEmpty) {
        final int power = robot['power'] as int;
        final int cores = robot['cores'] as int;
        final timer = Timer.periodic(Duration(milliseconds: power), (t) {
          setState(() {
            _counter += clickValue * cores * _totalRobotBoost;
            robotClicks++;
          });
          _persistState();
        });
        _robotTimers.add(timer);
      }
    }

    userStorage.lastSessionTime = DateTime.now();
    await userStorage.save();
  }

  Future<void> _calculateOfflineEarnings() async {
    final selectedManager = userStorage.selectedManager;
    if (selectedManager == null) return;

    final lastSession = userStorage.lastSessionTime;
    if (lastSession == null) return;

    final now = DateTime.now();
    final offlineDuration = now.difference(lastSession);
    final offlineHours = offlineDuration.inHours;

    if (offlineHours < 1) return;

    final managerDurationStr = selectedManager['duration']?.toString() ?? '10h';
    final managerMaxHours = Managers.parseDurationToHours(managerDurationStr);

    final effectiveHours = offlineHours > managerMaxHours
        ? managerMaxHours
        : offlineHours;
    final robotCount = userStorage.purchasedRobots.length;
    if (robotCount == 0) return;

    // XP system - no energy consumption

    double totalOfflineClicks = 0.0;
    for (final entry in userStorage.purchasedRobots) {
      final robotId = entry.keys.first;
      final robot = robots.firstWhere(
        (r) => r['id'] == robotId,
        orElse: () => {},
      );
      if (robot.isEmpty) continue;

      final int power = robot['power'] as int;
      final int cores = robot['cores'] as int;
      final millisecondsPerHour = 3600 * 1000;
      final clicksPerRobot =
          (effectiveHours * millisecondsPerHour / power) * cores;
      totalOfflineClicks += clicksPerRobot;
    }

    final offlineEarnings = totalOfflineClicks * clickValue * _totalRobotBoost;
    setState(() {
      _counter += offlineEarnings;
    });

    final wageStr = selectedManager['price']?.toString() ?? '0%';
    final wagePercent = double.tryParse(wageStr.replaceAll('%', '')) ?? 0;
    if (wagePercent > 0) {
      final wageDeduction = _counter * (wagePercent / 100);
      setState(() {
        _counter -= wageDeduction;
      });
    }

    await userStorage.save();
  }

  @override
  void dispose() {
    for (var timer in _robotTimers) {
      timer.cancel();
    }
    super.dispose();
  }

  void _incrementCounter() {
    HapticFeedback.mediumImpact();
    final comboMultiplier = currentComboMultiplier;
    setState(() {
      _counter += clickValue * _clickMultiplier * comboMultiplier;
      playerClicks++;
      userStorage.xp += 10000;
    });
    userStorage.addXp(userStorage.xpPerClick.toDouble(), context: context);
    _persistState();
  }

  void _buyRobot() {
    if (robotLevel < robots.length && _counter >= robots[robotLevel]['price']) {
      HapticFeedback.lightImpact();
      setState(() {
        _counter -= robots[robotLevel]['price'];
        robotLevel++;
      });
      final int purchasedId = robots[robotLevel - 1]['id'] as int;
      if (!userStorage.purchasedRobots.any(
        (e) => e.keys.first == purchasedId,
      )) {
        userStorage.purchasedRobots.add({purchasedId: true});
      }

      final int power = robots[robotLevel - 1]['power'] as int;
      final int cores = robots[robotLevel - 1]['cores'] as int;
      Timer newTimer = Timer.periodic(Duration(milliseconds: power), (timer) {
        setState(() {
          _counter += clickValue * cores * _totalRobotBoost;
          robotClicks++;
        });
        _persistState();
      });
      _robotTimers.add(newTimer);
      _persistState();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  void _buyNumber() {
    if (numberLevel < numbers.length &&
        _counter >= numbers[numberLevel]['price']) {
      HapticFeedback.heavyImpact();
      setState(() {
        _counter -= numbers[numberLevel]['price'];
        clickValue = numbers[numberLevel]['value'];
        buttonText = numbers[numberLevel]['name'];
        numberLevel++;
      });
      _persistState();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  void _buyCombo() {
    if (comboLevel < combos.length) {
      final price = _parseComboPrice(combos[comboLevel]['price'].toString());
      if (_counter >= price) {
        HapticFeedback.heavyImpact();
        setState(() {
          _counter -= price;
          comboLevel++;
        });
        _persistState();
        return;
      }
    }
    HapticFeedback.selectionClick();
  }

  String _getRobotButtonText() {
    if (robotLevel < robots.length) {
      final price = robots[robotLevel]['price'] as double;
      return '${robots[robotLevel]['name']}\n${_formatNumber(price)}';
    } else {
      return 'Max Robots';
    }
  }

  String _getNumberButtonText() {
    if (numberLevel < numbers.length) {
      final price = numbers[numberLevel]['price'] as double;
      return '${numbers[numberLevel]['name']}\n${_formatNumber(price)}';
    } else {
      return 'Max Numbers';
    }
  }

  String _getComboButtonText() {
    if (comboLevel < combos.length) {
      final multiplier = combos[comboLevel]['multiplier'];
      final priceValue = combos[comboLevel]['price'];
      String priceStr;
      if (priceValue is String) {
        priceStr = priceValue;
      } else {
        priceStr = _formatNumber(priceValue as double);
      }
      return 'x$multiplier\n$priceStr';
    } else {
      return 'Max Combos';
    }
  }

  String _getClicksDisplay() {
    return '🫵 $playerClicks | 🤖 $robotClicks';
  }

  void _syncToUserStorage() {
    userStorage.counter = _counter;
    userStorage.picount = _picount;
    userStorage.clickValue = clickValue;
    userStorage.buttonText = buttonText;
    userStorage.numberLevel = numberLevel;
    userStorage.robotLevel = robotLevel;
    userStorage.comboLevel = comboLevel;
    userStorage.playerClicks = playerClicks;
    userStorage.robotClicks = robotClicks;
  }

  Future<void> _persistState() async {
    _syncToUserStorage();
    await userStorage.save();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    bool showBottomBar = !isLandscape || _forceShowBottomBar;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.01),
        title: const Text(
          "PiClicker",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.tealAccent,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: [
          InkWell(
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: AlertDialog(
                  backgroundColor: Colors.black.withValues(alpha: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.tealAccent, width: 1),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Okay'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                  content: SizedBox(
                    height: 175.0,
                    child: Column(
                      children: [
                        Text(
                          "Current XP:",
                          style: const TextStyle(fontSize: 24.0),
                        ),
                        Text(
                          "\n${userStorage.xp}",
                          style: TextStyle(fontSize: 36.0, fontWeight: .bold),
                        ),
                        Row(
                          mainAxisAlignment: .center,
                          crossAxisAlignment: .center,
                          children: [
                            Text(
                              "XP per click:",
                              style: const TextStyle(fontSize: 20.0),
                            ),
                            SizedBox(width: 20.0),
                            Text(
                              "+${userStorage.xpPerClick}",
                              style: const TextStyle(
                                fontWeight: .bold,
                                color: Colors.teal,
                                fontSize: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.tealAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.tealAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    "${userStorage.xp}",
                    style: const TextStyle(
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text("XP"),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: showBottomBar
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(1, 1, 118, 1),
                    Color.fromARGB(45, 14, 221, 169),
                    Color.fromARGB(65, 14, 221, 169),
                    Color.fromARGB(75, 14, 221, 169),
                    Color.fromARGB(75, 14, 221, 169),
                    Color.fromARGB(75, 14, 221, 169),
                    Color.fromARGB(65, 14, 221, 169),
                    Color.fromARGB(45, 14, 221, 169),
                    Color.fromARGB(1, 1, 118, 1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          children: [
                            Text(
                              _formatNumber(_counter),
                              style: TextStyle(
                                color: Colors.teal[100],
                                fontSize: 48.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Clicks:\n${_getClicksDisplay()}",
                              style: TextStyle(
                                color: Colors.teal[100],
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 50.0),
                            SizedBox(
                              height: 225.0,
                              width: 225.0,
                              child: MaterialButton(
                                onLongPress: () => HapticFeedback.vibrate(),
                                onPressed: _incrementCounter,
                                color: Colors.tealAccent[700],
                                splashColor: const Color.fromARGB(
                                  115,
                                  70,
                                  100,
                                  100,
                                ),
                                shape: const CircleBorder(),
                                child: Image.asset(
                                  numbers[numberLevel]['source'],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(1, 1, 118, 1),
                    Color.fromARGB(45, 14, 221, 169),
                    Color.fromARGB(65, 14, 221, 169),
                    Color.fromARGB(75, 14, 221, 169),
                    Color.fromARGB(75, 14, 221, 169),
                    Color.fromARGB(75, 14, 221, 169),
                    Color.fromARGB(65, 14, 221, 169),
                    Color.fromARGB(45, 14, 221, 169),
                    Color.fromARGB(1, 1, 118, 1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              height: double.infinity,
              child: Center(
                child: SingleChildScrollView(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth / 2,
                        child: Column(
                          children: [
                            Text(
                              _formatNumber(_counter),
                              style: TextStyle(
                                color: Colors.teal[100],
                                fontSize: 48.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Clicks:\n${_getClicksDisplay()}",
                              style: TextStyle(
                                color: Colors.teal[100],
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: screenWidth / 2,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 175.0,
                              width: 175.0,
                              child: MaterialButton(
                                onLongPress: () => HapticFeedback.vibrate(),
                                onPressed: _incrementCounter,
                                color: Colors.tealAccent[700],
                                splashColor: const Color.fromARGB(
                                  115,
                                  70,
                                  100,
                                  100,
                                ),
                                shape: const CircleBorder(),
                                child: Image.asset(
                                  numbers[numberLevel]['source'],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: showBottomBar
          ? Container(
              height: 250.0,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        children: [
                          Text(
                            "Points Per Click (now $clickValue)",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white70,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 370.0,
                            height: 65.0,
                            child: ElevatedButton(
                              onPressed: _buyNumber,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal[900]?.withValues(
                                  alpha: 0.8,
                                ),
                                foregroundColor: Colors.tealAccent,
                                elevation: 8,
                                shadowColor: Colors.tealAccent.withValues(
                                  alpha: 0.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(
                                    color: Colors.tealAccent,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              child: Text(
                                _getNumberButtonText(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 20.0,
                            left: 10.0,
                            right: 20.0,
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Robots ($robotLevel)",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 175.0,
                                height: 65.0,
                                child: ElevatedButton(
                                  onPressed: _buyRobot,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal[900]
                                        ?.withValues(alpha: 0.8),
                                    foregroundColor: Colors.tealAccent,
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: const BorderSide(
                                        color: Colors.tealAccent,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _getRobotButtonText(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 20.0,
                            right: 10.0,
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Combos",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 175.0,
                                height: 65.0,
                                child: ElevatedButton(
                                  onPressed: _buyCombo,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal[900]
                                        ?.withValues(alpha: 0.8),
                                    foregroundColor: Colors.tealAccent,
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: const BorderSide(
                                        color: Colors.tealAccent,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _getComboButtonText(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : Container(
              height: 125.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                border: const Border(
                  top: BorderSide(color: Colors.tealAccent, width: 0.5),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLandscapeButton(
                      "Points ($clickValue)",
                      _buyNumber,
                      _getNumberButtonText(),
                      screenWidth / 2.5,
                    ),
                    _buildLandscapeButton(
                      "Robots ($robotLevel)",
                      _buyRobot,
                      _getRobotButtonText(),
                      screenWidth / 5,
                    ),
                    _buildLandscapeButton(
                      "Combos ($comboLevel)",
                      _buyCombo,
                      _getComboButtonText(),
                      screenWidth / 5,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLandscapeButton(
    String label,
    VoidCallback onPressed,
    String buttonText,
    double width,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: width,
            height: 55.0,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[900]?.withValues(alpha: 0.7),
                foregroundColor: Colors.tealAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.tealAccent, width: 1),
                ),
              ),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
