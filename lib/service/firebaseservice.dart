import 'package:booktoplay_webapp/models/bookground.dart';
import 'package:booktoplay_webapp/models/bookingmodel.dart';
import 'package:booktoplay_webapp/models/customer_grounddetails.dart';
import 'package:booktoplay_webapp/models/eventmodel.dart';
import 'package:booktoplay_webapp/models/eventpostmodel.dart' hide EventModel;
import 'package:booktoplay_webapp/models/freeslotdiscount.dart';
import 'package:booktoplay_webapp/models/freeslotsmodel.dart';
import 'package:booktoplay_webapp/models/remindermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart' show StreamZip;

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== BOOKING METHODS ====================

 Future<void> addBooking({
  required String name,
  required String phone,
  required String sport,
  required DateTime date,
  required TimeOfDay? inTime,
  required TimeOfDay? outTime,
  required String amountString,
  required String? selectedSlotTime,
  required int? selectedSlotIndex,
}) async {
  try {
    double amount = double.tryParse(amountString) ?? 0.0;

    DateTime? finalInTimestamp;
    DateTime? finalOutTimestamp;

    // If slot is selected, extract time from slot time string
    if (selectedSlotTime != null && selectedSlotTime.isNotEmpty) {
      // Parse slot time like "06:00 AM - 07:00 AM"
      final times = selectedSlotTime.split(' - ');
      if (times.length == 2) {
        final startTimeStr = times[0].trim();
        final endTimeStr = times[1].trim();

        // Parse start time
        final startTime = _parseTimeString(startTimeStr);
        if (startTime != null) {
          finalInTimestamp = DateTime(
            date.year,
            date.month,
            date.day,
            startTime.hour,
            startTime.minute,
          );
        }

        // Parse end time
        final endTime = _parseTimeString(endTimeStr);
        if (endTime != null) {
          finalOutTimestamp = DateTime(
            date.year,
            date.month,
            date.day,
            endTime.hour,
            endTime.minute,
          );
        }
      }
    } else if (inTime != null && outTime != null) {
      // Fallback to manually selected times if no slot selected
      finalInTimestamp = DateTime(
        date.year,
        date.month,
        date.day,
        inTime.hour,
        inTime.minute,
      );

      finalOutTimestamp = DateTime(
        date.year,
        date.month,
        date.day,
        outTime.hour,
        outTime.minute,
      );
    }

    final booking = BookingModel(
      id: '', // Firestore will generate this
      customerName: name,
      phoneNumber: phone,
      sport: sport,
      bookingDate: date,
      inTime: finalInTimestamp,
      outTime: finalOutTimestamp,
      amount: amount,
      createdAt: DateTime.now().toUtc(),
      slotTime: selectedSlotTime,
      slotIndex: selectedSlotIndex,
    );

    await _firestore.collection('bookings').add(booking.toFirestore());
    if (selectedSlotTime != null && selectedSlotTime.isNotEmpty) {
  final freeSlot = FreeSlotModel(
    id: '',
    slotTime: selectedSlotTime,
    amount: amount,
    selectedDate: date,
    createdAt: DateTime.now(),
  );

  await _firestore.collection('freeslots').add(
        freeSlot.toFirestore(),
      );
}
  } catch (e) {
    throw Exception("Firebase Save Failed: $e");
  }
}

/// Helper method to parse time strings like "06:00 AM"
TimeOfDay? _parseTimeString(String timeStr) {
  try {
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;

    int hour = int.parse(parts[0].trim());
    final minuteAndPeriod = parts[1].trim().split(' ');

    if (minuteAndPeriod.length != 2) return null;

    int minute = int.parse(minuteAndPeriod[0]);
    String period = minuteAndPeriod[1].toUpperCase();

    // Convert to 24-hour format
    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  } catch (e) {
    print('Error parsing time: $e');
    return null;
  }
}

 Stream<List<Map<String, dynamic>>> getCombinedBookingsStream() {
  Query bookingsQuery = _firestore.collection('bookings');
  Query groundBookingsQuery = _firestore.collection('groundBookings');
  return bookingsQuery.snapshots().asyncMap((bookingsSnapshot) async {
    
    String globalGroundName = 'Unknown Ground';
    try {
      final groundQuery = await _firestore.collection('custgrounddetails').limit(1).get();
      if (groundQuery.docs.isNotEmpty) {
        globalGroundName = groundQuery.docs.first.data()['groundName'] ?? 'Unknown Ground';
      }
    } catch (e) {
      print("Error fetching ground details: $e");
    }

    List<Map<String, dynamic>> combinedResults = [];
    for (var doc in bookingsSnapshot.docs) {
      final bookingData = doc.data() as Map<String, dynamic>;
      final bookingModel = BookingModel.fromFirestore(bookingData, doc.id);

      combinedResults.add({
        'booking': bookingModel,
        'groundName': globalGroundName,
        'sourceTable': 'bookings',
      });
    }
    try {
      final groundBookingsSnapshot = await groundBookingsQuery.get();
      
      for (var doc in groundBookingsSnapshot.docs) {
        final groundBookingData = doc.data() as Map<String, dynamic>;
        final bookingModel = BookingModel.fromFirestore(groundBookingData, doc.id);

        combinedResults.add({
          'booking': bookingModel,
          'groundName': globalGroundName,
          'sourceTable': 'groundBookings',
        });
      }
    } catch (e) {
      print("Error reading secondary groundBookings table: $e");
    }
    combinedResults.sort((a, b) {
      final DateTime? dateA = (a['booking'] as BookingModel).bookingDate;
      final DateTime? dateB = (b['booking'] as BookingModel).bookingDate;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA); 
    });

    return combinedResults;
  });
}


/// Fetch bookings as typed models
Stream<List<BookingModel>> getBookingsStream({
  DateTime? startDate,
  DateTime? endDate,
}) {
  Query query = _firestore.collection('bookings');

  if (startDate != null) {
    query = query.where(
      'bookingDate',
      isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
    );
  }

  if (endDate != null) {
    query = query.where(
      'bookingDate',
      isLessThanOrEqualTo: Timestamp.fromDate(endDate),
    );
  }

  return query.orderBy('bookingDate', descending: true).snapshots().map(
    (snapshot) {
      return snapshot.docs.map((doc) {
        return BookingModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    },
  );
}
  /// Delete booking by document ID
  Future<void> deleteBooking(String docId) async {
    try {
      await _firestore.collection('bookings').doc(docId).delete();
    } catch (e) {
      throw Exception("Firebase Delete Failed: $e");
    }
  }

  // ==================== REMINDER METHODS ====================

  Future<void> addReminder({
    required String name,
    required String description,
    required String priority,
    required DateTime date,
    required String amount,
  }) async {
    try {
      final reminder = ReminderModel(
        id: '', // Firestore will generate this
        customerName: name,
        description: description,
        priority: priority,
        bookingDate: date,
        createdAt: DateTime.now().toUtc(),
        isDone: false,
        amount: amount,
      );

      await _firestore.collection('reminders').add(reminder.toFirestore());
    } catch (e) {
      throw Exception("Firebase Save Failed: $e");
    }
  }

  //================== Update reminder's done status============================
  Future<void> markReminderAsDone(String id) async {
    await FirebaseFirestore.instance.collection('reminders').doc(id).update({
      'isDone': true,
    });
  }

  /// Fetch reminders as typed models
  Stream<List<ReminderModel>> getRemindersStream() {
    return FirebaseFirestore.instance.collection('reminders').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return ReminderModel.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  /// Delete reminder by document ID
  Future<void> deleteReminder(String docId) async {
    try {
      await _firestore.collection('reminders').doc(docId).delete();
    } catch (e) {
      throw Exception("Firebase Delete Failed: $e");
    }
  }
  //=============================Fetch Expenses from reminders=============================

  Stream<List<Map<String, dynamic>>> getReminderAmountStream() {
    return FirebaseFirestore.instance.collection('reminders').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'title': data['customerName'] ?? '',
          'amount': data['amount'] ?? 0,
        };
      }).toList();
    });
  }

  Stream<List<Map<String, String>>> getReminderTitlesStream() {
    return FirebaseFirestore.instance.collection('reminders').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'title': (data['customerName'] ?? '').toString(),
          'amount': (data['amount'] ?? '').toString(),
        };
      }).toList();
    });
  }
  // ==================== EVENT METHODS ====================

  /// Add a new event to Firestore
  Future<void> addEvent({
    required String title,
    required String sport,
    required String description,
    required String status,
    required String maxParticipants,
    required double entryFee,
    required DateTime date,
    required TimeOfDay? inTime,
    required TimeOfDay? outTime,
  }) async {
    try {
      DateTime? finalInTimestamp;
      DateTime? finalOutTimestamp;

      if (inTime != null) {
        finalInTimestamp = DateTime(
          date.year,
          date.month,
          date.day,
          inTime.hour,
          inTime.minute,
        );
      }

      if (outTime != null) {
        finalOutTimestamp = DateTime(
          date.year,
          date.month,
          date.day,
          outTime.hour,
          outTime.minute,
        );
      }

      final event = EventModel(
        id: '', // Firestore will generate this
        title: title,
        sport: sport,
        status: status,
        description: description,
        dateTime: date,
        inTime: finalInTimestamp,
        outTime: finalOutTimestamp,
        currentParticipants: 0, // Start with 0 participants
        maxParticipants:
            int.tryParse(maxParticipants) ??
            20, // Default to 20 if parsing fails
        entryFee: entryFee,
        paidCount: 0, // No paid participants initially
        pendingCount: 0, // No pending participants initially
        createdAt: DateTime.now().toUtc(),
      );

      await _firestore.collection('events').add(event.toFirestore());
    } catch (e) {
      throw Exception("Firebase Save Failed: $e");
    }
  }

  /// Fetch events as typed models
  Stream<List<EventModel>> getEventsStream() {
    return _firestore
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => EventModel.fromFirestore(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList();
        });
  }

  // ==================== EVENT POST METHODS ====================

  Future<void> saveEventPost({
    required String title,
    required String description,
    required String sport,
    required int maxParticipants, // Changed from String to int
    required double entryFee, // Changed from String to double
    required String prizes,
    required DateTime date,
    required TimeOfDay? inTime,
  }) async {
    try {
      DateTime? finalInTimestamp;

      if (inTime != null) {
        finalInTimestamp = DateTime(
          date.year,
          date.month,
          date.day,
          inTime.hour,
          inTime.minute,
        );
      }

      final eventPost = EventPostModel(
        id: '', // Firestore will generate this
        eventTitle: title,
        description: description,
        sport: sport,
        maxParticipants: maxParticipants, // Now properly typed as int
        entryFee: entryFee, // Now properly typed as double
        prizes: prizes,
        bookingDate: date,
        inTime: finalInTimestamp,
        createdAt: DateTime.now().toUtc(),
      );

      await _firestore.collection('eventpost').add(eventPost.toFirestore());
    } catch (e) {
      throw Exception("Firebase Save Failed: $e");
    }
  }

  /// Fetch all event posts as typed models
  Stream<List<EventPostModel>> getEventPostsStream() {
    return _firestore
        .collection('eventpost')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => EventPostModel.fromFirestore(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList();
        });
  }

  // ==================== FREE SLOT METHODS ====================

  Future<void> addFreeSlot({
    required String amount,
    required TimeOfDay? inTime,
    required TimeOfDay? outTime,
  }) async {
    try {
      DateTime? finalInTimestamp;
      DateTime? finalOutTimestamp;

      if (inTime != null) {
        finalInTimestamp = DateTime.now().toUtc().add(
          Duration(hours: inTime.hour, minutes: inTime.minute),
        );
      }

      if (outTime != null) {
        finalOutTimestamp = DateTime.now().toUtc().add(
          Duration(hours: outTime.hour, minutes: outTime.minute),
        );
      }

      final freeSlot = FreeSlotModel(
        id: '', // Firestore will generate this
        amount: double.tryParse(amount) ?? 0.0,
        inTime: finalInTimestamp,
        outTime: finalOutTimestamp,
        createdAt: DateTime.now().toUtc(),
      );

      await _firestore.collection('freeslots').add(freeSlot.toFirestore());
    } catch (e) {
      throw Exception("Firebase Save Failed: $e");
    }
  }

  /// Fetch free slots as typed models
  Stream<List<FreeSlotModel>> getFreeSlotsStream() {
    return _firestore
        .collection('freeslots')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => FreeSlotModel.fromFirestore(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList();
        });
  }

  /// Delete free slot by document ID
  Future<void> deleteFreeSlot(String docId) async {
    try {
      await _firestore.collection('freeslots').doc(docId).delete();
    } catch (e) {
      throw Exception("Firebase Delete Failed: $e");
    }
  }
  //=======================Add New Ground========================
Future<void> saveGroundBooking({ 
  required String groundName,
  required String place,
  required double amount,
  required String address,

 
}) async {
  try {
    final booking = Bookground(
      id: '',    
      groundName: groundName,
      place: place,

  
      amount: amount.toInt(),
      createdAt: DateTime.now().toUtc(), 
      address:address,
    );

    await _firestore.collection('groundBookings').add(
      booking.toMap(),
    );
  } catch (e) {
    throw Exception("Ground Booking Save Failed: $e");
  }
}

Stream<List<Bookground>> getGroundBookingsStream() {
  return _firestore
      .collection('groundBookings')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Bookground.fromMap(
            doc.data(),
            doc.id,
          );
        }).toList();
      });
}

//=======================Dashboard details=====================
Stream<Map<String, dynamic>> getDashboardMetricsStream() {
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final startOfTomorrow = startOfToday.add(const Duration(days: 1));

  return StreamZip([
    _firestore.collection('bookings').snapshots(),
    _firestore.collection('groundBookings').snapshots(),
    _firestore.collection('custgrounddetails').snapshots(),
    _firestore.collection('freeslots').snapshots(),
  ]).map((List<QuerySnapshot> snapshots) {
    final bookingsSnap = snapshots[0];
    final groundSnap = snapshots[1];
    final customerGroundSnap = snapshots[2];
    final slotsSnap = snapshots[3];

    int todaysBookingsCount = 0;
    double totalRevenue = 0.0;

    bool isToday(dynamic value) {
      if (value == null || value is! Timestamp) return false;

      final date = value.toDate();

      return date.isAtSameMomentAs(startOfToday) ||
          date.isAfter(startOfToday) && date.isBefore(startOfTomorrow);
    }

    for (var doc in bookingsSnap.docs) {
      final data = doc.data() as Map<String, dynamic>;

      if (isToday(data['bookingDate'])) {
        todaysBookingsCount++;
      }

      totalRevenue += (data['amount'] as num?)?.toDouble() ?? 0.0;
    }

    for (var doc in groundSnap.docs) {
      final data = doc.data() as Map<String, dynamic>;

      if (isToday(data['date'])) {
        todaysBookingsCount++;
      }

      totalRevenue += (data['amount'] as num?)?.toDouble() ?? 0.0;
    }

    for (var doc in customerGroundSnap.docs) {
      final data = doc.data() as Map<String, dynamic>;

      if (isToday(data['bookingDate'])) {
        todaysBookingsCount++;
      }

      totalRevenue += (data['amount'] as num?)?.toDouble() ?? 0.0;
    }

    int totalSlots = slotsSnap.docs.length;

    int todayBookedSlots = 0;
    int totalBookingsCount =bookingsSnap.docs.length ;

    for (var doc in bookingsSnap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (isToday(data['bookingDate'])) {
        todayBookedSlots++;
      }
    }

    for (var doc in customerGroundSnap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (isToday(data['bookingDate'])) {
        todayBookedSlots++;
      }
    }

    int availableSlots = totalSlots - todayBookedSlots;

    if (availableSlots < 0) {
      availableSlots = 0;
    }

    return {
      'todaysBookings': todaysBookingsCount.toString(),
      'totalRevenue': '₹${totalRevenue.toStringAsFixed(0)}',
      'availableSlots': availableSlots.toString(),
        'totalBookings': totalBookingsCount.toString(),
    };
  });
}

//Get customer ground bookings details
Stream<List<BookingModel>> getBookings() {
  return FirebaseFirestore.instance
      .collection('custgrounddetails')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => BookingModel.fromFirestore(  doc.data(),doc.id))
        .toList();
  });
}
Stream<List<CustomergroundDetails>> getAllCustomerBookings() {
  final now = DateTime.now();

  return FirebaseFirestore.instance
      .collection('custgrounddetails')
      .where(
        'bookingDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(now),
      )
      .orderBy('bookingDate')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => CustomergroundDetails.fromFirestore(doc))
        .toList();
  });
}

//sort time according to the date
Stream<List<String>> getBookedSlotsByDate(DateTime selectedDate) {
  final startDate = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );

  final endDate = startDate.add(const Duration(days: 1));

  return FirebaseFirestore.instance
      .collection('bookings')
      .where(
        'bookingDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      )
      .where(
        'bookingDate',
        isLessThan: Timestamp.fromDate(endDate),
      )
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          return data['slotTime']?.toString().trim() ?? '';
        })
        .where((slot) => slot.isNotEmpty)
        .toList();
  });
}

//save slotdiscount

Future<void> saveSlotDiscount(
  SlotDiscountModel discount,
) async {
  final startDate = DateTime(
    discount.selectedDate!.year,
    discount.selectedDate!.month,
    discount.selectedDate!.day,
  );

  await FirebaseFirestore.instance
      .collection('freeslots')
      .doc("${discount.slotTime}_${startDate.toIso8601String()}")
      .set(
        discount.toMap(),
        SetOptions(merge: true),
      );
}
//read saved discount slots
Stream<List<SlotDiscountModel>> getSlotDiscountsStream(
  DateTime selectedDate,
) {
  final startDate = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
  );

  final endDate = startDate.add(const Duration(days: 1));

  return FirebaseFirestore.instance
      .collection('freeslots')
      .where(
        'selectedDate',
        isGreaterThanOrEqualTo:
            Timestamp.fromDate(startDate),
      )
      .where(
        'selectedDate',
        isLessThan: Timestamp.fromDate(endDate),
      )
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => SlotDiscountModel.fromFirestore(doc))
        .toList();
  });
}

//Get All Bookings

Stream<List<BookingModel>> getAllBookings() {
  return FirebaseFirestore.instance
      .collection('bookings')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc.data(),doc.id ))
            .toList();
      });
}

}
