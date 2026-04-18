// DEPRECATED !!!
//
// import 'package:flutter/material.dart';

// class PurchaseOptionInformationWidget extends StatefulWidget {
//   const PurchaseOptionInformationWidget({super.key});

//   @override
//   State<PurchaseOptionInformationWidget> createState() =>
//       _PurchaseOptionInformationWidgetState();
// }

// class _PurchaseOptionInformationWidgetState
//     extends State<PurchaseOptionInformationWidget> {
//   @override
//   Future<void> _showPurchaseOptionInformation({
//     required String name,
//     required String description,
//     required double price,
//     required bool isPurchased,
//   }) async {
//     await showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(name),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text(description),
//                 Text(
//                   'Price: \$${price.toStringAsFixed(2)}',
//                   style: TextStyle(
//                     fontSize: 32.0,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.tealAccent,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Purchase'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ElevatedButton(
//         onPressed: () {
//           _showPurchaseOptionInformation(
//             name: 'Product Name',
//             description: 'Product Description',
//             price: 99.99,
//             isPurchased: false,
//           );
//         },
//         child: const Text('Show Purchase Option'),
//       ),
//     );
//   }
// }
