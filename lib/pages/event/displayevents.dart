import 'package:booktoplay_webapp/models/eventmodel.dart';
import 'package:booktoplay_webapp/navigation/primaryscaffold.dart';
import 'package:booktoplay_webapp/service/firebaseservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Displayevents extends StatefulWidget {
  final EventModel? event;
  const Displayevents({super.key, this.event});

  @override
  State<Displayevents> createState() => _DisplayeventsState();
}

class _DisplayeventsState extends State<Displayevents> {
  final FirebaseService _bookingService = FirebaseService();



  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController dateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // Form custom non-generic input decorations
   
    return sidebar(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              SizedBox(
                width: 180,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/'); // Navigate back to dashboard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  child: Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Upcoming Event Details',
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 20),
         Expanded(
          child: StreamBuilder<List<EventModel>>(
            stream: _bookingService.getEventsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading bookings: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.greenAccent),
                );
              }

              final events = snapshot.data ?? [];

              if (events.isEmpty) {
                return const Center(
                  child: Text(
                    'No bookings found.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                itemCount: events.length,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemBuilder: (context, index) {
                  final EventModel event = events[index];
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: _buildEventCard(event),
                  );
                },
              );
            },
          ),
        ),
        ],
      ),
    );
  }

 Widget _buildEventCard(EventModel eventData) {
  // Extracting Firestore map data with default fallbacks matching your design
  final String title = eventData.title ?? 'No title available';
  final String sport = eventData.sport ?? 'Cricket';
  final String status = (eventData.status ?? 'upcoming').toString().toLowerCase();

  final int paidCount = eventData.paidCount ?? 2;
  final int pendingCount = eventData.pendingCount ?? 1;
  final int maxParticipants = eventData.maxParticipants ?? 20;
  final int totalParticipants = paidCount + pendingCount;

  final double entryFee = (eventData.entryFee ?? 200).toDouble();
 // final double totalRevenue = (eventData.totalRevenue ?? (paidCount * entryFee * 0.7)).toDouble();

  // Safely processing date formatting
  String dateTimeStr = '4/27/2026\n17:00'; 
  try {
    DateTime parsedDate;
    if (eventData.dateTime is Timestamp) {
      parsedDate = (eventData.dateTime as Timestamp).toDate();
    } else {
      parsedDate = DateTime.parse(eventData.dateTime.toString());
    }
    final String localTime = parsedDate.toLocal().toString();
    if (localTime.length >= 16) {
      dateTimeStr = localTime.substring(0, 16).replaceAll(' ', '\n');
    }
  } catch (_) {}

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24.0),
    decoration: BoxDecoration(
      color: Colors.white, // Modern light mode background matching image layout
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Layout: Title, Sport, and Status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sport,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),

        // Grid Content Rows
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetaColumn('Date & Time:', dateTimeStr, const Color(0xFF1E293B)),
            _buildMetaColumn('Participants:', '$totalParticipants/$maxParticipants', const Color(0xFF2563EB)),
            _buildMetaColumn('Entry Fee:', '₹${entryFee.toStringAsFixed(0)}', const Color(0xFF2563EB)),
            //('Your Revenue:', '₹${totalRevenue.toStringAsFixed(0)}', const Color(0xFF2563EB)),
          ],
        ),
        
        const SizedBox(height: 24),

        // Status Indicators 
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$paidCount paid',
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$pendingCount pending',
                style: const TextStyle(
                  color: Color(0xFFEA580C),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Sub-helper method for metadata columns
Widget _buildMetaColumn(String title, String value, Color valueColor) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
            height: 1.2,
          ),
        ),
      ],
    ),
  );
}
}
