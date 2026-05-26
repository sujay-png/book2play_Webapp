import 'package:flutter/material.dart';

class KpiCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final String subvalue;

  const KpiCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.subvalue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
      
        // Fixed width/height or constraints recommended depending on your grid
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF1A1D1D), 
          border: Border.all(color: Colors.white10), // Subtle border
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Icon and Trending Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF00D9A3).withValues(alpha: 0.1), // Mint background
                  ),
                  child: Icon(icon, color: const Color(0xFF00D9A3), size: 24),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF00D9A3),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subvalue,
                      style: const TextStyle(
                        color: Color(0xFF00D9A3),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Large Value
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}