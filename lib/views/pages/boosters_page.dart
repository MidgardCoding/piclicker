// DEPRECATED !!!
//
// import 'package:flutter/material.dart';
// import 'package:piclicker/data/constants.dart';
// import 'package:piclicker/data/storage.dart';
// import 'package:piclicker/widgets/DrawerWidget.dart';

// class BoostersPage extends StatefulWidget {
//   const BoostersPage({super.key});

//   @override
//   State<BoostersPage> createState() => _BoostersPageState();
// }

// class _BoostersPageState extends State<BoostersPage> {
//   bool _loaded = false;
//   int _picount = 0; // clicks available for purchases
//   List<int> _purchasedBoosterIds = [];

//   @override
//   void initState() {
//     super.initState();
//     _initLoad();
//   }

//   Future<void> _initLoad() async {
//     // Ensure latest storage is loaded
//     await userStorage.load();
//     setState(() {
//       _picount = userStorage.picount;
//       _purchasedBoosterIds = List<int>.from(userStorage.purchasedBoosters);
//       _loaded = true;
//     });
//   }

//   Future<void> _persist() async {
//     userStorage.picount = _picount;
//     userStorage.purchasedBoosters = List<int>.from(_purchasedBoosterIds);
//     await userStorage.save();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_loaded) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.teal[800],
//         title: const Text('Boosters'),
//         centerTitle: true,
//         elevation: 4,
//         leading: Builder(
//           builder: (context) {
//             return IconButton(
//               icon: const Icon(Icons.menu),
//               onPressed: () {
//                 Scaffold.of(context).openDrawer();
//               },
//             );
//           },
//         ),
//       ),
//       drawer: DrawerWidget(),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(36.0),
//                     child: Column(
//                       children: const [
//                         Text(
//                           'Enhance your gameplay',
//                           style: TextStyle(
//                             fontSize: 28.0,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           'Purchase new boosters for a specified\namount of time and become the click master!',
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Click Boosters
//             _buildBoosterSection(
//               title: 'Click Boosters:',
//               description:
//                   'Click boosters provide a click multiplier for a given period of time.',
//               icon: Icons.touch_app,
//               category: 'click',
//             ),
//             const SizedBox(height: 24),

//             // Income Boosters
//             _buildBoosterSection(
//               title: 'Income Boosters:',
//               description:
//                   'Your managers on expeditions can earn more if you purchase the following boosters.',
//               icon: Icons.attach_money,
//               category: 'income',
//             ),
//             const SizedBox(height: 24),

//             // Experience Boosters
//             _buildBoosterSection(
//               title: 'Experience Boosters:',
//               description:
//                   'Let your achievements shine brighter with the following boosters.',
//               icon: Icons.emoji_events,
//               category: 'xp',
//             ),
//             const SizedBox(height: 24),

//             // Batteries
//             _buildBoosterSection(
//               title: 'Batteries:',
//               description:
//                   'Double the power of your robots for a specific amount of time with the following batteries.',
//               icon: Icons.battery_charging_full,
//               category: 'battery',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Buduje pojedyńczą sekcję z nagłówkiem, opisem i poziomą listą kart.
//   Widget _buildBoosterSection({
//     required String title,
//     required String description,
//     required IconData icon,
//     required String category,
//   }) {
//     final items = Upgrades.boosters
//         .where((b) => b['category'] == category)
//         .toList(growable: false);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Nagłówek (pogrubiony, duży)
//         Text(
//           title,
//           style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 4),
//         // Opis (pogrubiony)
//         Text(
//           description,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey,
//           ),
//         ),
//         const SizedBox(height: 12),
//         // Pozioma lista kart
//         SizedBox(
//           height: 130, // stała wysokość dla listy (karta + odstępy)
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: items.length,
//             itemBuilder: (context, index) {
//               final booster = items[index];
//               return _buildBoosterCard(icon: icon, booster: booster);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   /// Pojedyncza kwadratowa karta z ikoną i tekstem i logiką zakupu.
//   Widget _buildBoosterCard({
//     required IconData icon,
//     required Map<String, dynamic> booster,
//   }) {
//     final String label = booster['title'] as String;
//     final int id = booster['id'] as int;
//     final bool purchased = _purchasedBoosterIds.contains(id);

//     return Padding(
//       padding: const EdgeInsets.only(right: 12.0),
//       child: SizedBox(
//         width: 140,
//         height: 140,
//         child: Card(
//           elevation: 3,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: InkWell(
//             borderRadius: BorderRadius.circular(12),
//             onTap: () => _onBoosterTap(booster),
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     purchased ? Colors.grey.shade600 : Colors.teal,
//                     purchased ? Colors.grey.shade700 : Colors.teal.shade700,
//                   ],
//                 ),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     icon,
//                     size: 40,
//                     color: purchased ? Colors.white70 : Colors.tealAccent,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     label,
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: purchased ? Colors.white70 : null,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 6),
//                   if (!purchased)
//                     Text(
//                       '${booster['priceClicks']} clicks',
//                       style: const TextStyle(
//                         fontSize: 11,
//                         color: Colors.white70,
//                       ),
//                       textAlign: TextAlign.center,
//                     )
//                   else
//                     const Text(
//                       'Purchased',
//                       style: TextStyle(fontSize: 11, color: Colors.white70),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _onBoosterTap(Map<String, dynamic> booster) async {
//     final int id = booster['id'] as int;
//     final String title = booster['title'] as String;
//     final String description =
//         booster['description'] as String? ?? 'Placeholder description.';
//     final int priceClicks = booster['priceClicks'] as int? ?? 0;
//     final bool alreadyPurchased = _purchasedBoosterIds.contains(id);

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Colors.teal[900],
//           title: Text(title),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(description, style: TextStyle(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 12),
//               if (!alreadyPurchased)
//                 Column(
//                   crossAxisAlignment: .start,
//                   children: [
//                     Text('Price:'),
//                     Text(
//                       '$priceClicks clicks',
//                       style: TextStyle(
//                         color: Colors.tealAccent,
//                         fontSize: 24.0,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 )
//               else
//                 const Text(
//                   'Already purchased',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Color.fromARGB(255, 239, 181, 215),
//                   ),
//                 ),
//               const SizedBox(height: 12),
//               Text('Your clicks:'),
//               Text('$_picount', style: TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Close'),
//             ),
//             if (!alreadyPurchased)
//               TextButton(
//                 onPressed: (_picount >= priceClicks)
//                     ? () {
//                         // Perform purchase: deduct clicks, add to purchased, persist
//                         setState(() {
//                           userStorage.picount -= priceClicks;
//                           _purchasedBoosterIds.add(id);
//                         });
//                         _persist();
//                         Navigator.of(context).pop();
//                       }
//                     : null,
//                 child: const Text('Buy'),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }
