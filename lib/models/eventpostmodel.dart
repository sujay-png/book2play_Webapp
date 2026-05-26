class EventPostModel {
  final String id;
  final String eventTitle;
  final String description;
  final String sport;
  final int maxParticipants; // Changed from String to int
  final double entryFee; // Changed from String to double
  final String prizes;
  final DateTime bookingDate;
  final DateTime? inTime;
  final DateTime createdAt;

  EventPostModel({
    required this.id,
    required this.eventTitle,
    required this.description,
    required this.sport,
    required this.maxParticipants,
    required this.entryFee,
    required this.prizes,
    required this.bookingDate,
    this.inTime,
    required this.createdAt,
  });

  /// Convert entry fee as double (already stored as double)
  double getEntryFeeAsDouble() {
    return entryFee;
  }

  /// Get max participants as int (already stored as int)
  int getMaxParticipantsAsInt() {
    return maxParticipants;
  }

  /// Check if event is upcoming (booking date is in future)
  bool get isUpcoming => bookingDate.isAfter(DateTime.now());

  /// Check if event is happening today
  bool get isToday {
    final now = DateTime.now();
    return bookingDate.year == now.year &&
        bookingDate.month == now.month &&
        bookingDate.day == now.day;
  }

  /// Get formatted date and time string
  String get formattedDateTime {
    return '${bookingDate.month}/${bookingDate.day}/${bookingDate.year} at ${bookingDate.hour.toString().padLeft(2, '0')}:${bookingDate.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted time only
  String get formattedTime {
    if (inTime == null) return 'No time set';
    return '${inTime!.hour.toString().padLeft(2, '0')}:${inTime!.minute.toString().padLeft(2, '0')}';
  }

  /// Convert Firestore document data to EventPostModel
  factory EventPostModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return EventPostModel(
      id: docId,
      eventTitle: data['eventtitle'] as String? ?? 'Unnamed Event',
      description: data['description'] as String? ?? '',
      sport: data['sportname'] as String? ?? 'Unknown Sport',
      maxParticipants: int.tryParse(data['Maxparticipants']?.toString() ?? '0') ?? 0,
      entryFee: double.tryParse(data['entryfee']?.toString() ?? '0.0') ?? 0.0,
      prizes: data['prizes'] as String? ?? '',
      bookingDate: _parseDateTime(data['bookingDate']) ?? DateTime.now().toUtc(),
      inTime: _parseDateTime(data['inTime']),
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now().toUtc(),
    );
  }

  /// Convert EventPostModel to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'eventtitle': eventTitle,
      'description': description,
      'sportname': sport,
      'Maxparticipants': maxParticipants,
      'entryfee': entryFee,
      'prizes': prizes,
      'bookingDate': bookingDate.toUtc().toIso8601String(),
      'inTime': inTime?.toUtc().toIso8601String(),
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

  @override
  String toString() =>
      'EventPostModel(id: $id, eventTitle: $eventTitle, sport: $sport, entryFee: $entryFee)';
}