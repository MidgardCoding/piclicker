import 'package:flutter/material.dart';
import 'dart:ui';

class ProTipWidget extends StatelessWidget {
  const ProTipWidget({
    super.key,
    required this.boxIcon,
    required this.title,
    required this.description,
    this.button,
  });

  final Icon boxIcon;
  final String title;
  final String description;
  final Widget? button;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.1),
        border: Border.all(color: Colors.tealAccent.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.teal.shade900,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade800,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Icon(
                          boxIcon.icon,
                          color: Colors.tealAccent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                    height: 1.4,
                  ),
                ),
                if (button != null) ...[const SizedBox(height: 16), button!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
