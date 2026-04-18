import 'dart:math';

import 'package:flutter/material.dart';
import 'package:piclicker/data/constants.dart';
import 'package:piclicker/data/storage.dart';
import 'package:piclicker/widgets/DrawerWidget.dart';
import 'package:piclicker/widgets/manager_card_widget.dart';
import 'dart:ui';

class ManagersPage extends StatefulWidget {
  const ManagersPage({super.key});

  @override
  State<ManagersPage> createState() => _ManagersPageState();
}

class _ManagersPageState extends State<ManagersPage> {
  Map<String, dynamic>? _todayManager;
  bool _loaded = false;
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    _initDailyManager();
  }

  Future<void> _initDailyManager() async {
    await userStorage.load();
    final String today = DateTime.now().toIso8601String().split('T').first;

    if (userStorage.todayManager != null &&
        userStorage.todayManagerDate == today) {
      setState(() {
        _todayManager = userStorage.todayManager;
        _loaded = true;
      });
      return;
    }

    final list = Managers.managers;
    if (list.isNotEmpty) {
      final rnd = Random();
      final idx = rnd.nextInt(list.length);
      final selected = Map<String, dynamic>.from(list[idx]);

      userStorage.todayManager = selected;
      userStorage.todayManagerDate = today;
      await userStorage.save();

      setState(() {
        _todayManager = selected;
        _loaded = true;
      });
    } else {
      setState(() {
        _todayManager = null;
        _loaded = true;
      });
    }
  }

  void _onManagerTap() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  Future<void> _hireManager() async {
    if (_todayManager == null) return;

    final managerId = _todayManager!['id']?.toString() ?? '';
    if (userStorage.isManagerHired(managerId)) return;

    await userStorage.addHiredManager(_todayManager!);

    setState(() {
      _isSelected = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_todayManager!['name']} has been hired!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green.withAlpha(100),
        ),
      );
    }
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case "standard":
        return Colors.blueAccent;
      case "super":
        return Colors.redAccent;
      case "epic":
        return Colors.deepPurpleAccent;
      case "legendary":
        return Colors.amberAccent;
      case "master":
        return Colors.white;
      default:
        return Colors.blueAccent;
    }
  }

  Future<void> _removeManager(String managerId, String managerName) async {
    await userStorage.removeHiredManager(managerId);
    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$managerName has been removed!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.withAlpha(100),
        ),
      );
    }
  }

  /// Toggle the selected working manager
  Future<void> _toggleManagerSelection(String managerId) async {
    final currentSelected = userStorage.selectedManagerId;

    if (currentSelected == managerId) {
      // Deselect this manager
      await userStorage.setSelectedManager(null);
    } else {
      // Select this manager
      await userStorage.setSelectedManager(managerId);
    }
    setState(() {});

    if (mounted) {
      final manager = userStorage.hiredManagers.firstWhere(
        (m) => m['id'] == managerId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentSelected == managerId
                ? '${manager['name']} is now off duty'
                : '${manager['name']} is now working!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: currentSelected == managerId
              ? Colors.orange.withAlpha(100)
              : Colors.green.withAlpha(100),
        ),
      );
    }
  }

  /// Check if a manager is currently selected for work
  bool _isManagerSelected(String managerId) {
    return userStorage.selectedManagerId == managerId;
  }

  // Landscape layout - LEFT: offers, RIGHT: hired managers table
  Widget _buildLandscapeLayout(
    bool isHired,
    List<Map<String, dynamic>> hiredManagers,
  ) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.2),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: const Text(
          "MANAGERS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.tealAccent,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) => BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: AlertDialog(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.tealAccent, width: 1),
                  ),
                  title: const Text(
                    'About Managers',
                    style: TextStyle(color: Colors.tealAccent),
                  ),
                  content: const SingleChildScrollView(
                    child: ListBody(
                      children: [
                        Text(
                          "Managers are your assistants at work...",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Okay',
                        style: TextStyle(color: Colors.tealAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Assign work to others",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (_todayManager != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Today's offers:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(
                            height: 130,
                            child: SingleChildScrollView(
                              child: ManagerCard(
                                onTap: _onManagerTap,
                                isSelected: _isSelected,
                                isHired: isHired,
                                name:
                                    _todayManager!['name']?.toString() ??
                                    'Unknown',
                                duration:
                                    _todayManager!['duration']?.toString() ??
                                    '-',
                                price:
                                    double.tryParse(
                                      _todayManager!['price']?.toString() ?? '',
                                    ) ??
                                    0.0,
                                imageSrc:
                                    _todayManager!['imageSrc']?.toString() ??
                                    '',
                                id: _todayManager!['id']?.toString() ?? '-',
                                rarity:
                                    _todayManager!['rarity']?.toString() ??
                                    'standard',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isHired
                                ? "You have a hired manager!"
                                : "Select an offer and hire a manager.",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            margin: EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: (isHired || !_isSelected)
                                    ? null
                                    : _hireManager,
                                child: Text(
                                  isHired ? "MANAGER HIRED" : "HIRE",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isHired ? Colors.grey : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Text('No managers available today.'),
                ],
              ),
            ),
          ),
          // RIGHT SIDE - Hired managers table
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const Text(
                    "Hired managers",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Manage your hired managers",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: hiredManagers.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_off,
                                size: 64,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "You have no managers!",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Transform.scale(
                            scale: 0.70,
                            child: SingleChildScrollView(
                              child: Table(
                                border: TableBorder.all(
                                  color: Colors.grey,
                                  width: 1.5,
                                ),
                                columnWidths: {
                                  0: const FixedColumnWidth(60.0),
                                  1: const FixedColumnWidth(100.0),
                                  2: const FixedColumnWidth(55.0),
                                  3: const FixedColumnWidth(80.0),
                                  4: const FixedColumnWidth(60.0),
                                  5: const FixedColumnWidth(60.0),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.tealAccent.withOpacity(0.2),
                                    ),
                                    children: [
                                      TableCell(child: _tableHeader("Select")),
                                      TableCell(child: _tableHeader("Manager")),
                                      TableCell(child: _tableHeader("Wage")),
                                      TableCell(child: _tableHeader("Rarity")),
                                      TableCell(child: _tableHeader("ID")),
                                      TableCell(child: _tableHeader("Action")),
                                    ],
                                  ),
                                  ...hiredManagers.map((manager) {
                                    final rarity =
                                        manager['rarity']?.toString() ??
                                        'standard';
                                    final rarityColor = _getRarityColor(rarity);
                                    final managerId =
                                        manager['id']?.toString() ?? '';
                                    final managerName =
                                        manager['name']?.toString() ??
                                        'Unknown';
                                    final isSelected = _isManagerSelected(
                                      managerId,
                                    );
                                    return TableRow(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.grey[850],
                                      ),
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Checkbox(
                                              value: isSelected,
                                              onChanged: (value) {
                                                _toggleManagerSelection(
                                                  managerId,
                                                );
                                              },
                                              activeColor: Colors.green,
                                              shape: CircleBorder(),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 4,
                                                  height: 30,
                                                  color: rarityColor,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    managerName,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              manager['price']?.toString() ??
                                                  '-',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  10.0,
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: rarityColor
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                    border: Border.all(
                                                      color: rarityColor,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    rarity.toUpperCase(),
                                                    style: TextStyle(
                                                      color: rarityColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              managerId,
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red[400],
                                              size: 20,
                                            ),
                                            onPressed: () => _removeManager(
                                              managerId,
                                              managerName,
                                            ),
                                            tooltip: 'Remove',
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isHired = userStorage.isManagerHired(
      _todayManager?['id']?.toString() ?? '',
    );
    final List<Map<String, dynamic>> hiredManagers = userStorage.hiredManagers;
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Check orientation
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return _buildLandscapeLayout(isHired, hiredManagers);
    }

    // Portrait layout
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.2),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: const Text(
          "MANAGERS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.tealAccent,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) => BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: AlertDialog(
                  backgroundColor: Colors.black.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  title: const Text(
                    'About Managers',
                    style: TextStyle(color: Colors.black),
                  ),
                  content: const SingleChildScrollView(
                    child: ListBody(
                      children: [
                        Text(
                          "Managers are your assistants at work...",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Okay',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.teal.withValues(alpha: 0.1),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 20.0),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(
                  left: 48.0,
                  right: 48.0,
                  top: 64.0,
                  bottom: 12.0,
                ),
                child: Text(
                  "Assign work to others",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 48.0),
                child: Text(
                  "Hire managers who will look after the robots for you during your absence.",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              if (_todayManager != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 0.0,
                  ),
                  margin: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12.0),
                      Text(
                        "Today's offers:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            ManagerCard(
                              onTap: _onManagerTap,
                              isSelected: _isSelected,
                              isHired: isHired,
                              name:
                                  _todayManager!['name']?.toString() ??
                                  'Unknown',
                              duration:
                                  _todayManager!['duration']?.toString() ?? '-',
                              price:
                                  double.tryParse(
                                    _todayManager!['price']?.toString() ?? '',
                                  ) ??
                                  0.0,
                              imageSrc:
                                  _todayManager!['imageSrc']?.toString() ?? '',
                              id: _todayManager!['id']?.toString() ?? '-',
                              rarity:
                                  _todayManager!['rarity']?.toString() ??
                                  'standard',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 130.0,
                        child: Center(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  top: 20.0,
                                  start: 0.0,
                                  end: 0.0,
                                  bottom: 0.0,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      isHired
                                          ? "You have a hired manager!"
                                          : "Select an offer and hire a manager.",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(16),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black,
                                            minimumSize: const Size(
                                              double.infinity,
                                              50,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                          onPressed: (isHired || !_isSelected)
                                              ? null
                                              : _hireManager,
                                          child: Text(
                                            isHired ? "MANAGER HIRED" : "HIRE",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isHired
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                          ),
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
                      Text("Refreshes everyday.", textAlign: TextAlign.center),
                      const SizedBox(height: 12.0),
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('No managers available today.'),
                ),
              Container(
                margin: EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 48.0, bottom: 12.0),
                      child: Text(
                        "Hired managers",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 48.0),
                      child: Text(
                        "Manage your hired managers",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4.0,
                        right: 4.0,
                        top: 4.0,
                        bottom: 36.0,
                      ),
                      child: hiredManagers.isEmpty
                          ? Column(
                              children: [
                                Icon(
                                  Icons.person_off,
                                  size: 64,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "You have no managers!",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Transform.scale(
                              scale: 0.8,
                              child: Container(
                                color: Colors.grey[700],
                                child: Column(
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Table(
                                        border: TableBorder.all(
                                          color: Colors.grey,
                                          width: 1.5,
                                        ),
                                        defaultColumnWidth:
                                            const FixedColumnWidth(160.0),
                                        columnWidths: {
                                          0: const FixedColumnWidth(75.0),
                                          1: const FixedColumnWidth(180.0),
                                          2: const FixedColumnWidth(120.0),
                                          3: const FixedColumnWidth(110.0),
                                          4: const FixedColumnWidth(120.0),
                                          5: const FixedColumnWidth(80.0),
                                        },
                                        children: [
                                          TableRow(
                                            decoration: BoxDecoration(
                                              color: Colors.teal[700],
                                            ),
                                            children: [
                                              TableCell(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    12.0,
                                                  ),
                                                  child: Text(
                                                    "Duty",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    12.0,
                                                  ),
                                                  child: Text(
                                                    "Name",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    12.0,
                                                  ),
                                                  child: Text(
                                                    "Daily Wage",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    12.0,
                                                  ),
                                                  child: Text(
                                                    "Rarity",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    12.0,
                                                  ),
                                                  child: Text(
                                                    "ID",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    12.0,
                                                  ),
                                                  child: Text(
                                                    "Fire",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          ...hiredManagers.map((manager) {
                                            final rarity =
                                                manager['rarity']?.toString() ??
                                                'standard';
                                            final rarityColor = _getRarityColor(
                                              rarity,
                                            );
                                            final managerId =
                                                manager['id']?.toString() ?? '';
                                            final managerName =
                                                manager['name']?.toString() ??
                                                'Unknown';
                                            final isSelected =
                                                _isManagerSelected(managerId);
                                            return TableRow(
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.green.withOpacity(
                                                        0.2,
                                                      )
                                                    : Colors.grey[850],
                                              ),
                                              children: [
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          6.0,
                                                        ),
                                                    child: Checkbox(
                                                      value: isSelected,
                                                      onChanged: (value) {
                                                        _toggleManagerSelection(
                                                          managerId,
                                                        );
                                                      },
                                                      activeColor: Colors.green,
                                                      shape: CircleBorder(),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          12.0,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 4,
                                                          height: 36,
                                                          color: rarityColor,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            managerName,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 12.0,
                                                          top: 20.0,
                                                        ),
                                                    child: Text(
                                                      manager['price']
                                                              ?.toString() ??
                                                          '-',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 12.0,
                                                          top: 16,
                                                          right: 12.0,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: rarityColor
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        border: Border.all(
                                                          color: rarityColor,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        rarity.toUpperCase(),
                                                        style: TextStyle(
                                                          color: rarityColor,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 12.0,
                                                          top: 20,
                                                        ),
                                                    child: Text(
                                                      managerId,
                                                      style: TextStyle(
                                                        color: Colors.grey[400],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          8.0,
                                                        ),
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red[400],
                                                      ),
                                                      onPressed: () =>
                                                          _removeManager(
                                                            managerId,
                                                            managerName,
                                                          ),
                                                      tooltip: 'Remove manager',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const SizedBox(width: 1.0),
                                        const Icon(
                                          Icons.compare_arrows_sharp,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4.0),
                                        const Text("Drag the horizontal view"),
                                      ],
                                    ),
                                  ],
                                ),
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
    );
  }
}
