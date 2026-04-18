import 'package:flutter/material.dart';

class ManagerCard extends StatefulWidget {
  const ManagerCard({
    super.key,
    required this.name,
    required this.duration,
    required this.price,
    required this.imageSrc,
    required this.id,
    required this.rarity,
    required this.onTap,
    this.isSelected = false,
    this.isHired = false,
    this.expeditionMode = false,
  });

  final String name;
  final String duration;
  final double price;
  final String imageSrc;
  final String id;
  final String rarity;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isHired;
  final bool expeditionMode;

  @override
  State<ManagerCard> createState() => _ManagerCardState();
}

class _ManagerCardState extends State<ManagerCard> {
  @override
  Widget build(BuildContext context) {
    Color managerRarity = Colors.blueAccent;
    switch (widget.rarity) {
      case "standard":
        managerRarity = Colors.blueAccent;
        break;
      case "super":
        managerRarity = Colors.redAccent;
        break;
      case "epic":
        managerRarity = Colors.deepPurpleAccent;
        break;
      case "legendary":
        managerRarity = Colors.amberAccent;
        break;
      case "master":
        managerRarity = Colors.white;
        break;
    }

    final bool isHired = widget.isHired;
    final bool expeditionMode = widget.expeditionMode;
    final Color cardBackground = isHired
        ? Colors.grey[800]!
        : managerRarity.withValues(alpha: 0.2);
    final Color textColor = isHired ? Colors.grey[300]! : Colors.white;
    final Color secondaryTextColor = isHired ? Colors.grey[500]! : Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      child: InkWell(
        onTap: (isHired && !expeditionMode) ? null : widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shadowColor: Colors.black87,
          surfaceTintColor: isHired ? Colors.grey : managerRarity,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: isHired ? Colors.grey : managerRarity),
              borderRadius: BorderRadius.circular(8),
              color: cardBackground,
            ),
            height: 114,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Opacity(
                        opacity: isHired ? 0.5 : 1.0,
                        child: Image.asset(
                          widget.imageSrc,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,
                              size: 60,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(4.0),
                                    margin: EdgeInsets.only(left: 10),
                                    decoration: BoxDecoration(
                                      color: managerRarity,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                    ),
                                    child: Text(
                                      widget.rarity.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 10.0,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (isHired) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "HIRED",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              if (expeditionMode) ...[
                                Spacer(),
                                Radio(
                                  value: widget.id,
                                  groupValue: widget.isSelected
                                      ? widget.id
                                      : null,
                                  onChanged: (_) => widget.onTap(),
                                  activeColor: Colors.green,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Works for ${widget.duration}",
                            style: TextStyle(fontSize: 10, color: textColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 8.0,
                  color: isHired ? Colors.grey : managerRarity,
                  thickness: 2.0,
                ),
                Container(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Daily Wage (% of your points):",
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              widget.price.toString(),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "ID: ${widget.id}",
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
