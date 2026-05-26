import 'package:flutter/material.dart';

class BreakdownKpiboxes extends StatelessWidget {
  final String title;
  final String subtitle1;
  final String? subtitle2;
  final String? subtitle3;
  final String value1;
  final String? value2;
  final String? value3;
  final Color? valuecolor3;
  final Color valueColor1;
  final Color? valueColor2;

  const BreakdownKpiboxes({
    super.key,
    required this.title,
    required this.subtitle1,
    this.subtitle2,
    this.subtitle3,
    this.valuecolor3,
    required this.valueColor1,
     this.valueColor2,
    required this.value1,
     this.value2,
    this.value3,
  });

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
          Text(title, style: TextStyle(fontSize: 18, color: Colors.white)),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle1,
                style: TextStyle(fontSize: 15, color: Colors.white70),
              ),
              Text(value1, style: TextStyle(fontSize: 16, color: valueColor1)),
            ],
          ),

          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle2 ?? '',
                style: TextStyle(fontSize: 15, color: Colors.white70),
              ),
              Text(value2 ?? '', style: TextStyle(fontSize: 16, color: valueColor2)),
            ],
          ),

          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle3 ?? '',
                style: TextStyle(fontSize: 15, color: Colors.white70),
              ),
              Text(
                value3 ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: valuecolor3 ?? Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
