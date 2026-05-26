import 'package:intl/intl.dart';

class EventModel {
  final String id;
  final String title;
  final String sport;
  final String status;
  final DateTime dateTime;
  final DateTime? inTime;
  final DateTime? outTime;
  final int currentParticipants;
  final int maxParticipants;
  final double entryFee;
  final int paidCount;
  final int pendingCount;
  final String description;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.sport,
    required this.status,
    required this.dateTime,
    this.inTime,
    this.outTime,
    required this.currentParticipants,
    required this.maxParticipants,
    required this.entryFee,
    required this.paidCount,
    required this.pendingCount,
    required this.description,
    required this.createdAt,
  });

  /// Calculate revenue from paid participants (70% commission)
  double get calculatedRevenue => (paidCount * entryFee) * 0.70;

  /// Format date and time for display
  String get formattedDateTime => DateFormat('M/d/yyyy "at" HH:mm').format(dateTime);

  /// Get available slots remaining
  int get availableSlots => maxParticipants - currentParticipants;

  /// Check if event is fully booked
  bool get isFullyBooked => currentParticipants >= maxParticipants;

  /// Check if event is upcoming (date is in future)
  bool get isUpcoming => dateTime.isAfter(DateTime.now());

  /// Convert EventModel to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'eventtitle': title,
      'sportsname': sport,
      'status': status,
      'bookingDate': dateTime.toUtc().toIso8601String(),
      'inTime': inTime?.toUtc().toIso8601String(),
      'outTime': outTime?.toUtc().toIso8601String(),
      'currentParticipants': currentParticipants,
      'Maxparticipants': maxParticipants,
      'entryfee': entryFee,
      'paidCount': paidCount,
      'pendingCount': pendingCount,
      'description': description,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  /// Map Firebase Firestore document to EventModel safely
  factory EventModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return EventModel(
      id: docId,
      title: json['eventtitle'] as String? ?? 'Unnamed Event',
      sport: json['sportsname'] as String? ?? 'Unknown Sport',
      status: json['status'] as String? ?? 'upcoming',
      dateTime: _parseDateTime(json['bookingDate']) ?? DateTime.now(),
      inTime: _parseDateTime(json['inTime']),
      outTime: _parseDateTime(json['outTime']),
      currentParticipants: int.tryParse(json['currentParticipants']?.toString() ?? '0') ?? 0,
      maxParticipants: int.tryParse(json['Maxparticipants']?.toString() ?? '20') ?? 20,
      entryFee: double.tryParse(json['entryfee']?.toString() ?? '0.0') ?? 0.0,
      paidCount: int.tryParse(json['paidCount']?.toString() ?? '0') ?? 0,
      pendingCount: int.tryParse(json['pendingCount']?.toString() ?? '0') ?? 0,
      description: json['description'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }

  /// Safe DateTime parser
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

  @override
  String toString() =>
      'EventModel(id: $id, title: $title, sport: $sport, participants: $currentParticipants/$maxParticipants)';
}