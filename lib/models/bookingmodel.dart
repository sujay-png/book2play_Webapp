import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String customerName;
  final String phoneNumber;
  final String sport;
  final DateTime bookingDate;
  final DateTime? inTime;
  final DateTime? outTime;
  final double amount;
  final DateTime createdAt;
  final String? slotTime;
  final int? slotIndex;

  BookingModel({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.sport,
    required this.bookingDate,
    this.inTime,
    this.outTime,
    required this.amount,
    required this.createdAt,
    this.slotTime,
    this.slotIndex,
  });

  /// Convert BookingModel to Firestore JSON
  Map<String, dynamic> toFirestore() {
    return {
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'sport': sport,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'inTime': inTime != null ? Timestamp.fromDate(inTime!) : null,
      'outTime': outTime != null ? Timestamp.fromDate(outTime!) : null,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
      'slotTime': slotTime,
      'slotIndex': slotIndex,
    };
  }

  /// Helper to safely convert both Timestamp and String to DateTime
  static DateTime? _safeDateTimeConversion(dynamic value) {
    if (value == null) return null;

    // If it's already a Timestamp
    if (value is Timestamp) {
      return value.toDate();
    }

    // If it's a String (ISO format from old data)
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing date string: $e');
        return null;
      }
    }

    return null;
  }

  /// Convert Firestore document to BookingModel
  /// Handles both old (String) and new (Timestamp) date formats
  factory BookingModel.fromFirestore(
    Map<String, dynamic> firestoreMap,
    String docId,
  ) {
    return BookingModel(
      id: docId,
      customerName: firestoreMap['customerName'] as String? ?? '',
      phoneNumber: firestoreMap['phoneNumber'] as String? ?? '',
      sport: firestoreMap['sport'] as String? ?? '',
      // Handle both Timestamp and String formats
      bookingDate: _safeDateTimeConversion(firestoreMap['bookingDate']) ??
          DateTime.now(),
      inTime: _safeDateTimeConversion(firestoreMap['inTime']),
      outTime: _safeDateTimeConversion(firestoreMap['outTime']),
      amount: (firestoreMap['amount'] as num?)?.toDouble() ?? 0.0,
      // Handle both Timestamp and String formats
      createdAt: _safeDateTimeConversion(firestoreMap['createdAt']) ??
          DateTime.now(),
      slotTime: firestoreMap['slotTime'] as String?,
      slotIndex: firestoreMap['slotIndex'] as int?,
    );
  }

  /// Create a copy of BookingModel with modified fields
  BookingModel copyWith({
    String? id,
    String? customerName,
    String? phoneNumber,
    String? sport,
    DateTime? bookingDate,
    DateTime? inTime,
    DateTime? outTime,
    double? amount,
    DateTime? createdAt,
    String? slotTime,
    int? slotIndex,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      sport: sport ?? this.sport,
      bookingDate: bookingDate ?? this.bookingDate,
      inTime: inTime ?? this.inTime,
      outTime: outTime ?? this.outTime,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      slotTime: slotTime ?? this.slotTime,
      slotIndex: slotIndex ?? this.slotIndex,
    );
  }

  @override
  String toString() {
    return 'BookingModel(id: $id, customerName: $customerName, phoneNumber: $phoneNumber, sport: $sport, bookingDate: $bookingDate, inTime: $inTime, outTime: $outTime, amount: $amount, createdAt: $createdAt, slotTime: $slotTime, slotIndex: $slotIndex)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customerName == other.customerName &&
          phoneNumber == other.phoneNumber &&
          sport == other.sport &&
          bookingDate == other.bookingDate &&
          inTime == other.inTime &&
          outTime == other.outTime &&
          amount == other.amount &&
          createdAt == other.createdAt &&
          slotTime == other.slotTime &&
          slotIndex == other.slotIndex;

  @override
  int get hashCode =>
      id.hashCode ^
      customerName.hashCode ^
      phoneNumber.hashCode ^
      sport.hashCode ^
      bookingDate.hashCode ^
      inTime.hashCode ^
      outTime.hashCode ^
      amount.hashCode ^
      createdAt.hashCode ^
      slotTime.hashCode ^
      slotIndex.hashCode;
}