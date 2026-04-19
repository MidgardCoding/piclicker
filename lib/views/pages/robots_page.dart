import 'dart:ui'; // Potrzebne do ImageFilter
import 'package:flutter/material.dart';
import 'package:piclicker/widgets/DrawerWidget.dart';
import 'package:piclicker/widgets/robot_info_container.dart';
import 'package:piclicker/data/constants.dart';
import 'package:piclicker/data/storage.dart';
import 'package:piclicker/data/robot_manager.dart';
import 'package:piclicker/widgets/robot_market.dart';

class RobotsPage extends StatefulWidget {
  const RobotsPage({super.key});

  @override
  State<RobotsPage> createState() => _RobotsPageState();
}

class _RobotsPageState extends State<RobotsPage> {
  String _sortBy = 'ID';

  List<Map<String, dynamic>> _sortedPurchasedRobots() {
    final robots = userStorage.purchasedRobots.map((entry) {
      final int id = entry.keys.first;
      final robot = Upgrades.robots.firstWhere(
        (r) => r['id'] == id,
        orElse: () => {
          'id': id,
          'name': 'Unknown Robot',
          'price': 0.0,
          'power': 0,
          'cores': 0,
          'type': '',
        },
      );
      robot['isActive'] = userStorage.isRobotActive(id);
      robot['robotId'] = id;
      return robot;
    }).toList();

    int toInt(dynamic v) => v is int ? v : (v as num).toInt();
    double toDouble(dynamic v) => v is double ? v : (v as num).toDouble();

    switch (_sortBy) {
      case 'Power':
        robots.sort((a, b) => toInt(a['power']).compareTo(toInt(b['power'])));
        break;
      case 'Cores':
        robots.sort((a, b) => toInt(a['cores']).compareTo(toInt(b['cores'])));
        break;
      case 'Price':
        robots.sort(
          (a, b) => toDouble(a['price']).compareTo(toDouble(b['price'])),
        );
        break;
      case 'ID':
      default:
        robots.sort((a, b) => toInt(a['id']).compareTo(toInt(b['id'])));
        break;
    }
    return robots;
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      extendBodyBehindAppBar: true, // Pozwala tłu wejść pod AppBar
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: const Text(
          "ROBOTS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.tealAccent,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showAboutDialog(context),
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Colors.tealAccent,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => RobotMarket())),
            child: Text("Robot Market"),
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF002025), Color(0xFF004D40), Color(0xFF001214)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 100.0 : 20.0,
              vertical: 20.0,
            ),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSortDropdown(),
                const SizedBox(height: 20),
                ..._sortedPurchasedRobots().map((robot) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: RobotInfoContainer(
                      robotId: robot['robotId'],
                      isActive: robot['isActive'],
                      title: robot['name'] as String,
                      description:
                          'Power: ${robot['power']} • Cores: ${robot['cores']}',
                      price: (robot['price'] as num).toDouble(),
                      type: robot['type'],
                      onToggle: () async {
                        await userStorage.toggleRobotActive(robot['robotId']);
                        RobotManager.toggleRobot(robot['robotId']);
                        if (mounted) setState(() {});
                      },
                      onDelete: () =>
                          _showDeleteConfirmationDialog(robot['robotId']),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Text(
            "Purchased Robots",
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check which robots you own and what their properties are.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.tealAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sort by: ', style: TextStyle(color: Colors.tealAccent)),
          DropdownButton<String>(
            value: _sortBy,
            dropdownColor: const Color(0xFF002025),
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.tealAccent),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            items: const [
              DropdownMenuItem(value: 'ID', child: Text('ID')),
              DropdownMenuItem(value: 'Power', child: Text('Power')),
              DropdownMenuItem(value: 'Cores', child: Text('Cores')),
              DropdownMenuItem(value: 'Price', child: Text('Price')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _sortBy = value);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.tealAccent, width: 1),
          ),
          title: const Text(
            'About Robots',
            style: TextStyle(color: Colors.tealAccent),
          ),
          content: const Text(
            "Robots are your assistants at work. They help you click by doing it for you...\n\nRemember to purchase managers so that the robots can work while you are away!",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Okay',
                style: TextStyle(color: Colors.tealAccent),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(int robotId) {
    double sliderValue = 0.0;
    bool isDeleteEnabled = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) =>
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                backgroundColor: Colors.black.withValues(alpha: 0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.redAccent, width: 1),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text(
                      'Confirm Deletion',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'The selected Robot will be permanently removed from your list of owned robots.\n\nYou can purchase a new robot using the Robot Market.',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Slide to proceed:',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: sliderValue,
                      min: 0.0,
                      max: 1.0,
                      activeColor: Colors.redAccent,
                      inactiveColor: Colors.grey,
                      thumbColor: Colors.redAccent,
                      onChanged: (value) {
                        setDialogState(() {
                          sliderValue = value;
                          isDeleteEnabled = value >= 0.99;
                        });
                      },
                      onChangeEnd: (value) {
                        if (value < 0.99) {
                          setDialogState(() {
                            sliderValue = 0.0;
                            isDeleteEnabled = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDeleteEnabled
                          ? Colors.redAccent
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isDeleteEnabled
                        ? () async {
                            Navigator.of(dialogContext).pop();
                            await userStorage.removeRobot(robotId);
                            RobotManager.stopRobot(robotId);
                            if (mounted) setState(() {});
                          }
                        : null,
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
