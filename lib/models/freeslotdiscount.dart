import 'package:cloud_firestore/cloud_firestore.dart';

class SlotDiscountModel {
  final String id;
  final String slotTime;
  final String discountType;
  final double discountValue;
  final DateTime? selectedDate;
  final DateTime? updatedAt;

  SlotDiscountModel({
    required this.id,
    required this.slotTime,
    required this.discountType,
    required this.discountValue,
    this.selectedDate,
    this.updatedAt,
  });

  factory SlotDiscountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SlotDiscountModel(
      id: doc.id,
      slotTime: data['slotTime'] ?? '',
      discountType: data['discountType'] ?? '',
      discountValue:
          (data['discountValue'] as num?)?.toDouble() ?? 0,
      selectedDate: data['selectedDate'] != null
          ? (data['selectedDate'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slotTime': slotTime,
      'discountType': discountType,
      'discountValue': discountValue,
      'selectedDate': selectedDate != null
          ? Timestamp.fromDate(selectedDate!)
          : null,
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}