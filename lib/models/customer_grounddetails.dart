import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomergroundDetails {
  final String id;
   final String userId;
  final String customerName;
  final String phoneNumber;
  final String groundName;
  final String place;
  final String sport;
  final String slotTime;
  final double amount;
  final DateTime? bookingDate;
  final DateTime? createdAt;
  final List<Map<String, dynamic>> players;

  CustomergroundDetails({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.groundName,
    required this.place,
    required this.sport,
    required this.slotTime,
    required this.amount,
    this.bookingDate,
    required this.players,
    this.createdAt, required this.userId,
  });

  factory CustomergroundDetails.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final user = FirebaseAuth.instance.currentUser;


    return CustomergroundDetails(
      id: doc.id,
       userId: user!.uid,
      customerName: data['customerName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      groundName: data['groundName'] ?? '',
      place: data['place'] ?? '',
      sport: data['sport'] ?? '',
      slotTime: data['slotTime'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      bookingDate: data['bookingDate'] != null
          ? (data['bookingDate'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
          players: data['players'] != null
          ? List<Map<String, dynamic>>.from(data['players'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'groundName': groundName,
      'place': place,
      'sport': sport,
      'slotTime': slotTime,
      'amount': amount,
      'bookingDate': bookingDate != null
          ? Timestamp.fromDate(bookingDate!)
          : null,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
         'players': players,
    };
  }
}