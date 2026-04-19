import 'dart:ui'; // Niezbędne do efektu rozmycia (Glassmorphism)
import 'package:flutter/material.dart';
import 'package:piclicker/data/constants.dart';
import 'package:piclicker/data/storage.dart';
import 'package:piclicker/widgets/DrawerWidget.dart';

class BatteriesPage extends StatefulWidget {
  const BatteriesPage({super.key});

  @override
  State<BatteriesPage> createState() => _BatteriesPageState();
}

class _BatteriesPageState extends State<BatteriesPage> {
  int? draggingBatteryId;
  int? activeBatteryId;

  @override
  void initState() {
    super.initState();
    activeBatteryId = userStorage.activeBatteryId;
  }

  void _activateBattery(int batteryId) {
    setState(() {
      activeBatteryId = batteryId;
      userStorage.setActiveBattery(batteryId);
    });
  }

  double get baseXpPerClick => 5.0;

  double get currentXpPerClick {
    double xp = baseXpPerClick;
    if (activeBatteryId != null && activeBatteryId != -1) {
      final battery = Batteries.batteries.firstWhere(
        (b) => b['id'].toString() == activeBatteryId.toString(),
        orElse: () => <String, dynamic>{},
      );
      if (battery.isNotEmpty) {
        final valueType = battery['valueType'] as String;
        final value = (battery['value'] as num).toDouble();
        if (valueType == 'addition') {
          xp += value;
        } else if (valueType == 'multiplier') {
          xp *= value;
        }
      }
    }
    return xp;
  }

  @override
  Widget build(BuildContext context) {
    final purchasedIds = userStorage.purchasedBatteryIds;
    final allBatteries = Batteries.batteries;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'BATTERIES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.tealAccent,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [_buildClicksIndicator()],
      ),
      drawer: const DrawerWidget(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001A1E), Color(0xFF003D33), Color(0xFF000F11)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildActiveSlotSection(purchasedIds),
              _buildPurchasedSection(purchasedIds, allBatteries),
              const Divider(color: Colors.white10),
              _buildShopSection(allBatteries, purchasedIds),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClicksIndicator() {
    return InkWell(
      onTap: () => _showClicksDialog(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.tealAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Text(
              "${userStorage.playerClicks}",
              style: const TextStyle(
                color: Colors.tealAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.touch_app, color: Colors.tealAccent, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSlotSection(List<int> purchasedIds) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Text(
            'ACTIVE BATTERY SLOT',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          DragTarget<int>(
            onWillAcceptWithDetails: (details) =>
                purchasedIds.contains(details.data),
            onAcceptWithDetails: (details) => _activateBattery(details.data),
            builder: (context, candidateData, rejectedData) {
              final isHovering = candidateData.isNotEmpty;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isHovering
                      ? Colors.tealAccent.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isHovering
                        ? Colors.tealAccent
                        : Colors.teal.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: isHovering
                      ? [
                          BoxShadow(
                            color: Colors.tealAccent.withValues(alpha: 0.2),
                            blurRadius: 15,
                          ),
                        ]
                      : [],
                ),
                child: _buildActiveBatteryDisplay(),
              );
            },
          ),
          if (activeBatteryId != null && activeBatteryId != -1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getActiveBatteryEffectText(),
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => activeBatteryId = null),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Text(
              "No active effect",
              style: TextStyle(color: Colors.white24),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPurchasedSection(
    List<int> purchasedIds,
    List<dynamic> allBatteries,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'YOUR STORAGE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'XP/click: ${currentXpPerClick.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: purchasedIds.isEmpty
              ? const Center(
                  child: Text(
                    'No batteries',
                    style: TextStyle(color: Colors.white24),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: purchasedIds.length,
                  itemBuilder: (context, index) {
                    final batteryId = purchasedIds[index];
                    final battery = allBatteries.firstWhere(
                      (b) => b['id'].toString() == batteryId.toString(),
                    );
                    return _buildPurchasedBatteryCard(battery);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildShopSection(List<dynamic> allBatteries, List<int> purchasedIds) {
    return Expanded(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.tealAccent,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'BATTERY SHOP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: allBatteries.length,
              itemBuilder: (context, index) {
                final battery = allBatteries[index];
                final isPurchased = purchasedIds.contains(
                  int.tryParse(battery['id'].toString()) ?? -1,
                );
                return _buildShopBatteryCard(battery, isPurchased);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- ELEMENTY LISTY ---

  Widget _buildPurchasedBatteryCard(Map<String, dynamic> battery) {
    final batteryId = int.tryParse(battery['id'].toString()) ?? -1;
    final isActive = activeBatteryId == batteryId;

    return Draggable<int>(
      data: batteryId,
      feedback: Opacity(opacity: 0.8, child: _buildBatteryImage(battery, 60)),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildBatteryImage(battery, 50),
      ),
      child: GestureDetector(
        onTap: () => _activateBattery(batteryId),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 85,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.tealAccent.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isActive ? Colors.tealAccent : Colors.white10,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBatteryImage(battery, 45),
              const SizedBox(height: 4),
              Text(
                battery['name'],
                style: const TextStyle(color: Colors.white70, fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopBatteryCard(Map<String, dynamic> battery, bool isPurchased) {
    final price = (battery['price'] as num).toInt();
    final value = battery['value'];
    final valueType = battery['valueType'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isPurchased
              ? Colors.greenAccent.withValues(alpha: 0.5)
              : Colors.white10,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBatteryImage(battery, 40),
          const SizedBox(height: 8),
          Text(
            battery['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            valueType == 'addition' ? '+$value XP' : 'x$value',
            style: TextStyle(
              color: valueType == 'addition'
                  ? Colors.greenAccent
                  : Colors.blueAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (isPurchased)
            const Icon(Icons.check_circle, color: Colors.greenAccent)
          else
            ElevatedButton(
              onPressed: userStorage.playerClicks >= price
                  ? () => _buyBattery(
                      int.parse(battery['id'].toString()),
                      price.toDouble(),
                    )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent.withValues(alpha: 0.2),
                foregroundColor: Colors.tealAccent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                '$price 🫵',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBatteryImage(Map<String, dynamic> battery, double size) {
    return Image.asset(
      'assets/images${battery['src']}',
      height: size,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.battery_charging_full,
        color: Colors.tealAccent,
        size: size,
      ),
    );
  }

  Widget _buildActiveBatteryDisplay() {
    if (activeBatteryId == null || activeBatteryId == -1) {
      return const Center(
        child: Text(
          'DRAG BATTERY HERE',
          style: TextStyle(
            color: Colors.white12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      );
    }
    final battery = Batteries.batteries.firstWhere(
      (b) => b['id'].toString() == activeBatteryId.toString(),
      orElse: () => {},
    );
    return Center(child: _buildBatteryImage(battery, 60));
  }

  String _getActiveBatteryEffectText() {
    final battery = Batteries.batteries.firstWhere(
      (b) => b['id'].toString() == activeBatteryId.toString(),
      orElse: () => {},
    );
    if (battery.isEmpty) return '';
    return "${battery['name']}: ${battery['valueType'] == 'addition' ? '+' : 'x'}${battery['value']} XP";
  }

  void _showClicksDialog() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.tealAccent),
          ),
          title: const Text(
            'Statistics',
            style: TextStyle(color: Colors.tealAccent),
          ),
          content: Text(
            "Current clicks: ${userStorage.playerClicks}",
            style: const TextStyle(color: Colors.white70),
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
        ),
      ),
    );
  }

  void _buyBattery(int batteryId, double price) {
    if (userStorage.playerClicks >= price) {
      setState(() {
        userStorage.playerClicks -= price.toInt();
        userStorage.addPurchasedBattery(batteryId);
        userStorage.save();
      });
    }
  }
}
