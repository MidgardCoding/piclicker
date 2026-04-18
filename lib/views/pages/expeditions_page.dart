import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piclicker/data/seed_handler.dart';
import 'package:piclicker/data/storage.dart';
import 'package:piclicker/widgets/DrawerWidget.dart';

class ExpeditionsPage extends StatefulWidget {
  const ExpeditionsPage({super.key});

  @override
  State<ExpeditionsPage> createState() => _ExpeditionsPageState();
}

class _ExpeditionsPageState extends State<ExpeditionsPage>
    with TickerProviderStateMixin {
  Map<String, dynamic>? seedData;
  String currentSeed = '';
  bool showManagers = false;
  bool _isLoaded = false;
  String? selectedManagerId;
  TextEditingController customSeedController = TextEditingController();

  // List of icons to draw based on seed
  final List<IconData> _seedIcons = [
    Icons.terrain,
    Icons.explore,
    Icons.fort,
    Icons.castle,
    Icons.ac_unit,
    Icons.forest,
    Icons.waves,
    Icons.landscape,
    Icons.compass_calibration,
    Icons.cabin,
    Icons.cloud,
    Icons.dark_mode,
    Icons.egg,
    Icons.fire_hydrant_alt,
    Icons.grass,
    Icons.house,
    Icons.ice_skating,
    Icons.kayaking,
    Icons.local_fire_department,
    Icons.hiking,
    Icons.nature,
    Icons.pest_control,
    Icons.park,
    Icons.radar,
    Icons.sailing,
    Icons.thunderstorm,
    Icons.volcano,
    Icons.water,
    Icons.agriculture,
    Icons.anchor,
    Icons.beach_access,
    Icons.brightness_3,
    Icons.bug_report,
    Icons.camera,
    Icons.diamond,
    Icons.directions_boat,
    Icons.emoji_events,
    Icons.flash_on,
    Icons.gite,
    Icons.handyman,
    Icons.free_breakfast,
    Icons.home_repair_service,
    Icons.layers,
    Icons.map,
    Icons.military_tech,
    Icons.museum,
    Icons.night_shelter,
    Icons.oil_barrel,
    Icons.palette,
    Icons.pets,
  ];

  @override
  void initState() {
    super.initState();
    generateNewSeed();
    _loadData();
  }

  Future<void> _loadData() async {
    await userStorage.load();
    await userStorage.checkAndCompleteAllExpeditions();
    if (mounted) setState(() => _isLoaded = true);
  }

  void generateNewSeed({bool deductPoints = false}) {
    if (deductPoints && userStorage.counter > 0) {
      userStorage.deductPointsPercentage(1.0);
      userStorage.save();
    }
    final newSeed = generateRandomSeed();
    final data = parseUserSeed(newSeed);
    setState(() {
      currentSeed = newSeed;
      seedData = data;
    });
    HapticFeedback.lightImpact();
  }

  // Logic of selecting an icon based on the sum of the digits in the seed
  IconData _getSeedIcon(String seed) {
    int sum = seed.runes
        .where((r) => r >= 48 && r <= 57)
        .fold(0, (prev, element) => prev + (element - 48));
    return _seedIcons[sum % _seedIcons.length];
  }

  Future<void> _showExpeditionProgress() async {
    await userStorage.load();
    await userStorage.checkAndCompleteAllExpeditions();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final activeList = userStorage.activeExpeditionsList;

            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(
                'Active Expeditions (${activeList.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: activeList.isEmpty
                  ? const Text(
                      'No active expeditions',
                      style: TextStyle(color: Colors.white70),
                    )
                  : SizedBox(
                      width: double.maxFinite,
                      height: 350,
                      child: ListView.builder(
                        itemCount: activeList.length,
                        itemBuilder: (context, index) {
                          final exp = activeList[index];
                          final sData =
                              jsonDecode(exp['seedDataJson'])
                                  as Map<String, dynamic>;

                          // Duration generating
                          final DateTime startTime = DateTime.parse(
                            exp['startTime'].toString(),
                          );
                          final String durationStr =
                              sData['expeditionTime'] ?? '1h';
                          final Duration totalDuration = userStorage
                              .parseExpeditionTimeToDuration(durationStr);
                          final DateTime endTime = startTime.add(totalDuration);
                          final Duration elapsed = DateTime.now().difference(
                            startTime,
                          );

                          // Progress calculation (0.0 to 1.0)
                          double progress =
                              (elapsed.inMilliseconds /
                                      totalDuration.inMilliseconds)
                                  .clamp(0.0, 1.0);

                          // Date formatting helper function
                          String formatDate(DateTime dt) {
                            final now = DateTime.now();
                            final difference = dt.difference(now).abs();
                            // If the event is more than 24 hours from now (forward or backward)
                            if (difference.inHours > 24) {
                              return "${dt.day}.${dt.month.toString().padLeft(2, '0')} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                            }
                            // If within 24 hours, the hour itself
                            return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                          }

                          return Card(
                            color: Colors.white.withOpacity(0.05),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        sData['locationName'] ?? 'Unknown',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "${(progress * 100).toStringAsFixed(0)}%",
                                        style: TextStyle(
                                          color: progress >= 1.0
                                              ? Colors.green
                                              : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Progression bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.white10,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        progress >= 1.0
                                            ? Colors.green
                                            : Colors.tealAccent,
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Start and end dates
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildTimeColumn(
                                        "Started",
                                        formatDate(startTime),
                                        CrossAxisAlignment.start,
                                      ),
                                      _buildTimeColumn(
                                        "Ends",
                                        formatDate(endTime),
                                        CrossAxisAlignment.end,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.tealAccent),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper widget for date readability
  Widget _buildTimeColumn(
    String label,
    String time,
    CrossAxisAlignment alignment,
  ) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  void _rerollSeed() {
    HapticFeedback.vibrate();
    setState(() {
      userStorage.deductPointsPercentage(1.0);
      userStorage.save();
      generateNewSeed();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Seed rerolled! Lost 1% of points.',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.black26,
      ),
    );
  }

  Future<void> sendExpedition() async {
    if (selectedManagerId == null || seedData == null) return;
    await userStorage.startExpedition(
      currentSeed,
      seedData!,
      selectedManagerId!,
    );
    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
      final managerName =
          userStorage.hiredManagers.firstWhere(
            (m) => m['id'] == selectedManagerId!,
            orElse: () => {'name': 'Unknown Manager'},
          )['name'] ??
          'Unknown Manager';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Expedition started! Manager $managerName sent to ${seedData!['locationName']}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildManagerSelection(Color primaryColor, Color secondaryColor) {
    final hiredManagers = userStorage.hiredManagers;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: kToolbarHeight + 120),
          const Text(
            "SELECT A MANAGER",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          Expanded(
            child: hiredManagers.isEmpty
                ? const Center(
                    child: Text(
                      "No managers hired!",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: hiredManagers.length,
                    itemBuilder: (context, index) {
                      final manager = hiredManagers[index];
                      final bool isSelected =
                          selectedManagerId == manager['id'];

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? secondaryColor.withOpacity(0.4)
                              : Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? secondaryColor : Colors.white10,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: secondaryColor,
                            child: Text(
                              (manager['name'] ?? "?")[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            manager['name'] ?? "Unknown",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "Efficiency: ${manager['efficiency'] ?? '1.0x'}\nWage: ${manager['price']}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                )
                              : const Icon(
                                  Icons.radio_button_off,
                                  color: Colors.white24,
                                ),
                          onTap: () {
                            final String thisManagerId = manager['id']
                                .toString();
                            final bool isThisWorking =
                                userStorage.selectedManagerId == thisManagerId;
                            final bool isOnExpedition = userStorage
                                .isManagerOnExpedition(thisManagerId);
                            if (!isSelected &&
                                (isThisWorking || isOnExpedition)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Manager is busy (working or on expedition).',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            HapticFeedback.selectionClick();
                            setState(() {
                              selectedManagerId = isSelected
                                  ? null
                                  : manager['id'];
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
          // Bottom action panel
          Container(
            padding: const EdgeInsets.only(bottom: 40, top: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => showManagers = false),
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedManagerId != null
                          ? secondaryColor
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: selectedManagerId != null
                        ? sendExpedition
                        : null,
                    child: Text(
                      "START MISSION",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selectedManagerId != null
                            ? primaryColor
                            : Colors.grey[300],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (seedData == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final primaryColor = hexToColor(seedData!['primaryLocationColor']);
    final secondaryColor = hexToColor(seedData!['secondaryLocationColor']);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black26,
        elevation: 0,
        leading: showManagers
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => showManagers = false),
              )
            : null,
        title: Text(showManagers ? 'Travel' : 'Expeditions'),
        actions: [
          if (!showManagers) ...[
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.orangeAccent),
              tooltip: "Reroll (1%)",
              onPressed: _rerollSeed,
            ),
            IconButton(
              icon: const Icon(Icons.timer),
              onPressed: _showExpeditionProgress,
            ),
          ],
        ],
      ),
      drawer: showManagers ? null : DrawerWidget(),
      body: Stack(
        children: [
          // Dynamic background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, secondaryColor.withOpacity(0.8)],
              ),
            ),
          ),
          // View switcher
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: showManagers
                ? _buildManagerSelection(primaryColor, secondaryColor)
                : _buildLocationView(primaryColor, secondaryColor),
          ),
        ],
      ),
    );
  }

  // Separated location view for code cleanliness
  Widget _buildLocationView(Color primaryColor, Color secondaryColor) {
    return Center(
      key: const ValueKey("location_view"),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12.0,
                  spreadRadius: 6.0,
                  blurStyle: BlurStyle.normal,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  color: Colors.black.withOpacity(0.7),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: secondaryColor,
                        child: Icon(
                          _getSeedIcon(currentSeed),
                          size: 40,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        seedData!['locationName'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 30),
                      _buildStatRow(
                        Icons.auto_awesome,
                        "Loot Multiplier",
                        "1.5x",
                      ),
                      _buildStatRow(
                        Icons.bolt,
                        "Critical Chance",
                        "${seedData!['criticalChanceValue'] ?? 0}x",
                      ),
                      _buildStatRow(
                        Icons.schedule,
                        "Time",
                        "${seedData!['expeditionTime']}",
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () => setState(() => showManagers = true),
                        child: const Text(
                          "PREPARE TRAVEL",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildStatRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.white70)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
