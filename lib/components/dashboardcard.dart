import 'package:flutter/material.dart';

class Dashboardcard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color themeColor; 
  final void Function() onTap ;

  const Dashboardcard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20), // Increased padding for better look
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF0D1515), // Correct dark background color
          border: Border.all(
            color: themeColor.withValues(alpha: 0.2), // Subtle colored border
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: themeColor, size: 24), // Uses the passed theme color
            const SizedBox(height: 16), // Spacing between icon and text
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}