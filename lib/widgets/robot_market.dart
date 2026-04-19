import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'package:piclicker/data/constants.dart';
import 'package:piclicker/data/storage.dart';
import 'package:piclicker/data/robot_manager.dart';

class RobotMarket extends StatefulWidget {
  const RobotMarket({super.key});

  @override
  State<RobotMarket> createState() => _RobotMarketState();
}

class _RobotMarketState extends State<RobotMarket> {
  List<int> _marketRobotIds = [];
  bool _isLoading = true;
  List<int> availableIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMarket();
    });
  }

  Future<void> _loadMarket() async {
    setState(() => _isLoading = true);
    await userStorage.load();
    if (userStorage.isNewMarketDay || userStorage.marketRobotIds.isEmpty) {
      availableIds = Upgrades.robots
          .where((r) => !userStorage.hasRobot(r['id'] as int))
          .map((r) => r['id'] as int)
          .toList();
      if (availableIds.length >= 5) {
        _marketRobotIds = (List<int>.from(
          availableIds,
        )..shuffle(Random())).take(6).toList();
        userStorage.marketRobotIds = _marketRobotIds;
        await userStorage.refreshMarket();
      } else {
        _marketRobotIds = availableIds;
        userStorage.marketRobotIds = availableIds;
        await userStorage.refreshMarket();
      }
    } else {
      _marketRobotIds = userStorage.marketRobotIds
          .where((id) => !userStorage.hasRobot(id))
          .toList();
      if (_marketRobotIds.isEmpty && userStorage.marketRobotIds.isNotEmpty) {
        await userStorage.refreshMarket();
        await _loadMarket();
        return;
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _buyRobot(int id) async {
    final robot = Upgrades.robots.firstWhere((r) => r['id'] == id);
    final price = robot['price'] as double;
    if (userStorage.counter < price) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Insufficient funds!'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    userStorage.counter -= price;
    final bool success = await userStorage.purchaseRobot(id);
    if (success) {
      userStorage.marketRobotIds.remove(id);
      await userStorage.save();
      RobotManager.ensureRobotRunning(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${robot['name']} purchased and activated!'),
            backgroundColor: Colors.teal.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _loadMarket();
    } else {
      userStorage.counter += price;
      await userStorage.save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Purchase failed! Robot may already be owned.'),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatNumber(double value) {
    if (value >= 1e12) return '${(value / 1e12).toStringAsFixed(1)}T';
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(1)}B';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
    return value.toStringAsFixed(0);
  }

  Widget _buildMarketCard(int id) {
    final robot = Upgrades.robots.firstWhere((r) => r['id'] == id);
    final price = robot['price'] as double;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: Colors.tealAccent.withValues(alpha: 0.75),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                robot['name'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${robot['type']}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Power: ${robot['power']} | Cores: ${robot['cores']}',
                style: const TextStyle(fontSize: 11, color: Colors.white60),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatNumber(price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amberAccent,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () => _buyRobot(id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent.withValues(
                          alpha: 0.2,
                        ),
                        foregroundColor: Colors.tealAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.tealAccent),
                        ),
                      ),
                      child: const Text(
                        'BUY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'MARKET',
          style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.only(top: kToolbarHeight + 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001214), Color(0xFF002025)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              )
            : Column(
                children: [
                  const SizedBox(height: 20.0),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.tealAccent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Text(
                      'DAILY MARKET OFFERS',
                      style: TextStyle(
                        color: Colors.tealAccent,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _marketRobotIds.isEmpty
                        ? const Center(
                            child: Text(
                              'No offers available today',
                              style: TextStyle(color: Colors.white38),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.9,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: _marketRobotIds.length,
                            itemBuilder: (context, index) =>
                                _buildMarketCard(_marketRobotIds[index]),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
