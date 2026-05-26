import 'package:flutter/material.dart';

class AccountsKpibox extends StatelessWidget {
  final String value;
  final String label;
  final Color iconColor;
  final Icon icons;
  final Color valueColor;

  const AccountsKpibox({
    super.key, 
    required this.value, 
  required this.label, 
  required this.iconColor, 
  required this.icons, 
  required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
            Icon( icons.icon, color: iconColor, size: 30 ),
              SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,           
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            value,
            style: TextStyle(
              fontSize: 25,
              color: valueColor,
            ),
          ),
          SizedBox(height: 15),
        
        ],
      ),
    );
  }
}