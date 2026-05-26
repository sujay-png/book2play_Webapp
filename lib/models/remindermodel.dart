import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String customerName;
  final String description;
  final String priority;
  final DateTime bookingDate;
  final DateTime createdAt;
  final bool isDone;
  final String amount;

  ReminderModel({
    required this.id,
    required this.customerName,
    required this.description,
    required this.priority,
    required this.bookingDate,
    required this.createdAt, required this.isDone,
     required this.amount,
  });

  /// Convert Firestore document data to ReminderModel
  factory ReminderModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return ReminderModel(
      id: docId,
      customerName: data['customerName'] as String? ?? '',
      description: data['description'] as String? ?? '',
      priority: data['priority'] as String? ?? 'medium',
      bookingDate: _parseDateTime(data['bookingDate']),
      createdAt: _parseDateTime(data['createdAt']),
       isDone: data['isDone'] ?? false,
       amount: data['amount'] as String? ?? '',
    );
  }

  /// Convert ReminderModel to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'customerName': customerName,
      'description': description,
      'priority': priority,
      'bookingDate': bookingDate.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'isDone': isDone,
      'amount': amount,
    };
  }

  /// Helper method to safely parse DateTime strings
  static DateTime _parseDateTime(dynamic value) {
  if (value == null) {
    return DateTime.now().toUtc();
  }

  if (value is Timestamp) {
    return value.toDate().toUtc();
  }

  if (value is String) {
    return DateTime.parse(value).toUtc();
  }

  if (value is DateTime) {
    return value.toUtc();
  }

  return DateTime.now().toUtc();
}

  /// Get priority level as color indicator (useful for UI)
  String getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'red';
      case 'medium':
        return 'orange';
      case 'low':
        return 'green';
      default:
        return 'grey';
    }
  }

  @override
  String toString() =>
      'ReminderModel(id: $id, customerName: $customerName, priority: $priority, isDone: $isDone, amount: $amount)';
}