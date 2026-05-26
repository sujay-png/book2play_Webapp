import 'package:cloud_firestore/cloud_firestore.dart';

class Bookground {
  final String? id;
  final String groundName;
  final String place;
  final String address;


  final int amount;

  final DateTime? createdAt;

  Bookground({
    this.id,
    required this.groundName,
    required this.place,
  
    required this.amount,
    this.createdAt, required this.address,
  });

  /// Convert model → Firestore map
  Map<String, dynamic> toMap() {
    return {
      'groundName': groundName,
      'place': place,
      'Address':address,
      'amount': amount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert Firestore → model
  factory Bookground.fromMap(Map<String, dynamic> map, String id) {
    return Bookground(
      id: id,
      groundName: map['groundName'] ?? '',
      place: map['place'] ?? '',
      address: map['place'] ?? '',      
      amount: map['amount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}