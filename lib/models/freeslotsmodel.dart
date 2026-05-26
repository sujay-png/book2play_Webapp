import 'package:cloud_firestore/cloud_firestore.dart';

class FreeSlotModel {
  final String id;
  final String? slotTime;
  final double amount;
  final DateTime? selectedDate;
  final DateTime? inTime;
  final DateTime? outTime;
  final DateTime createdAt;

  FreeSlotModel({
    required this.id,
    required this.amount,
    this.inTime,
    this.outTime,
    required this.createdAt, this.slotTime, this.selectedDate,
  });

  /// Convert Firestore document data to FreeSlotModel
  factory FreeSlotModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return FreeSlotModel(
      id: docId,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
        slotTime: data['slotTime'] ?? '',
      inTime: _parseDateTime(data['inTime']),
      outTime: _parseDateTime(data['outTime']),
         selectedDate: data['selectedDate'] is Timestamp
          ? (data['selectedDate'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now().toUtc(),
    );
  }

  /// Convert FreeSlotModel to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
       'slotTime': slotTime,
      'inTime': inTime?.toUtc().toIso8601String(),
      'outTime': outTime?.toUtc().toIso8601String(),
      'selectedDate': Timestamp.fromDate(selectedDate!),
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  /// Helper method to safely parse DateTime strings (nullable version)
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      try {
        return DateTime.parse(value).toUtc();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Get slot duration in minutes
  int? getSlotDurationInMinutes() {
    if (inTime != null && outTime != null) {
      return outTime!.difference(inTime!).inMinutes;
    }
    return null;
  }

  /// Check if current time is within this slot
  bool isCurrentTimeInSlot() {
    final now = DateTime.now().toUtc();
    if (inTime != null && outTime != null) {
      return now.isAfter(inTime!) && now.isBefore(outTime!);
    }
    return false;
  }

  @override
  String toString() =>
      'FreeSlotModel(id: $id, amount: $amount, duration: ${getSlotDurationInMinutes()} minutes)';
}