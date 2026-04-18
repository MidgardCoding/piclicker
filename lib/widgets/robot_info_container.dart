import 'package:flutter/material.dart';
import 'dart:ui';

class RobotInfoContainer extends StatefulWidget {
  const RobotInfoContainer({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.type,
  });

  final String title;
  final String description;
  final double price;
  final String type;

  @override
  State<RobotInfoContainer> createState() => _RobotInfoContainerState();
}

class _RobotInfoContainerState extends State<RobotInfoContainer> {
  @override
  Widget build(BuildContext context) {
    Color cardColor = Colors.tealAccent;
    switch (widget.type) {
      case "Microcomputer":
        cardColor = Colors.tealAccent;
        break;
      case "Microserver":
        cardColor = Colors.cyan;
        break;
      case "Mini PC":
        cardColor = Colors.lightGreenAccent;
        break;
      case "Laptop":
        cardColor = Colors.lightBlue;
        break;
      case "Computer":
        cardColor = Colors.amberAccent;
        break;
      case "Tower Server":
        cardColor = Colors.limeAccent;
        break;
      case "Rack Server":
        cardColor = Colors.grey.shade400;
        break;
      case "Blade Server":
        cardColor = Colors.deepOrangeAccent;
        break;
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cardColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: Colors.tealAccent,
                collapsedIconColor: Colors.tealAccent,
                title: Row(
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: cardColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        widget.type,
                        style: TextStyle(
                          color: cardColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        Divider(color: cardColor, thickness: 0.5),
                        const SizedBox(height: 10),
                        _buildDataRow("Name", widget.title),
                        _buildDataRow("Information", widget.description),
                        _buildDataRow("Price", widget.price.toStringAsFixed(2)),
                        _buildDataRow("Type", widget.type),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    Color cardColor = Colors.tealAccent;
    switch (widget.type) {
      case "Microcomputer":
        cardColor = Colors.tealAccent;
        break;
      case "Microserver":
        cardColor = Colors.cyan;
        break;
      case "Mini PC":
        cardColor = Colors.lightGreenAccent;
        break;
      case "Laptop":
        cardColor = Colors.lightBlue;
        break;
      case "Computer":
        cardColor = Colors.amberAccent;
        break;
      case "Tower Server":
        cardColor = Colors.limeAccent;
        break;
      case "Rack Server":
        cardColor = Colors.grey.shade400;
        break;
      case "Blade Server":
        cardColor = Colors.deepOrangeAccent;
        break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: cardColor,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
