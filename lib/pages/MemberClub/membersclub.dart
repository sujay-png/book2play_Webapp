import 'package:booktoplay_webapp/components/membersclub_kpiboxes.dart';
import 'package:booktoplay_webapp/navigation/primaryscaffold.dart';
import 'package:booktoplay_webapp/service/firebaseservice.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Membersclub extends StatefulWidget {
  const Membersclub({super.key});

  @override
  State<Membersclub> createState() => _MembersclubState();
}

class _MembersclubState extends State<Membersclub> {
  final FirebaseService bookingService = FirebaseService();
  @override
  Widget build(BuildContext context) {
    return sidebar(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                SizedBox(
                  width: 180,
                  height: 50,

                  //=============================== Back Button ===============================
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

            //=============================== Page Title ===============================
            Text(
              'Members Club',
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
            //=============================== KPI Boxes Row ===============================
            SizedBox(height: 15),
            Row(
              spacing: 25,
              children: [
                Expanded(
                  child: MembersclubKpiboxes(
                    value: '3',
                    label: 'Total Members',
                    iconColor: Colors.blue,
                    icons: Icon(Icons.people_alt_outlined),
                    valueColor: Colors.blue,
                  ),
                ),
                Expanded(
                  child: MembersclubKpiboxes(
                    value: '3',
                    label: 'Total Member Revenue',
                    iconColor: Colors.green,
                    icons: Icon(Icons.attach_money_outlined),
                    valueColor: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            //============================Create Event  container=========================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Members Only Events',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _showaddevent(context); // Show the add event dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.white),
                          SizedBox(width: 10),
                          Text('Create Event'),
                        ],
                      ),
                    ),
                  ),
                 
                 
                ],
              ),
            ),
            SizedBox(height: 15,),
            Expanded(
              child: StreamBuilder(
                stream: bookingService.getEventsStream(),
                builder: (context, snapshot) {
                  if(snapshot.hasError) {
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
                      final docs = snapshot.data ?? [];
                  
                   if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No events found.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }
                     return ListView.builder(
                      itemCount: docs.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final data = docs[index] as Map<String, dynamic>;
                        final docId = docs[index].id;
              
                       return _buildEventCard({
                          'customerName': data['customerName'] ?? 'Untitled Event',
                          'description': data['description'] ?? 'No description available.',
                          'Maxparticipants': data['Maxparticipants'] ?? '0',
                          'bookingDate': data['bookingDate'] ?? '',
                                     });
                      },
                    );
                },
              ),
            )
            
            
          ],
        ),
      ),
    );
  }
Widget _buildEventCard(Map<String, dynamic> data) {
 
  final String title = data['customerName'] ?? 'Untitled Event';
  final String description = data['description'] ?? 'No description available.';
  final String priorityValue = data['priority'] ?? '0'; 
  final String bookingDate = data['bookingDate'] ?? ''; 
  const String currentRegistered = "0"; 

  return Container(
 margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),

    child: Row(
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
                  color: Colors.white, 
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                bookingDate.isNotEmpty ? bookingDate : 'No Date Set',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),

       
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFA832FF), 
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$currentRegistered/$priorityValue registered',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
  //
}

void _showaddevent(BuildContext context) {
  // Text editing controllers to grab the form data later
  final FirebaseService bookingService = FirebaseService();

  final eventController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final inTimeController = TextEditingController();
  final outTimeController = TextEditingController();
  final maxparticipantsController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedInTime;
  TimeOfDay? selectedOutTime;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Reusable text style for field labels
      const labelStyle = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF374151), // Dark slate grey
      );

      // Reusable decoration to keep the text fields uniform
      InputDecoration customInputDecoration({
        String? hintText,
        Widget? suffixIcon,
      }) {
        return InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1.5,
            ), // Light gray border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF00C853),
              width: 2,
            ), // Green focus border
          ),
        );
      }

      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: SizedBox(
          width:
              MediaQuery.of(context).size.width *
              0.35, // Adjust width constraints
          height:
              MediaQuery.of(context).size.height *
              0.8, // Prevent vertical overflow
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row with Close Icon and Title
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.black),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Add Bookings Manual Page',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Customer Name Field
                const Text('Event Title', style: labelStyle),
                const SizedBox(height: 8),
                TextFormField(
                  controller: eventController,
                  decoration: customInputDecoration(),
                ),
                const SizedBox(height: 16),

                // Phone Number Field
                const Text('Description', style: labelStyle),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  decoration: customInputDecoration(),
                ),

                const SizedBox(height: 16),

                // Date Field
                const Text('Date', style: labelStyle),
                const SizedBox(height: 8),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: customInputDecoration(
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      selectedDate  = pickedDate; 
                      dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Row for In Time and Out Time fields
                Row(
                  children: [
                    // In Time Field
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('In Time', style: labelStyle),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: inTimeController,
                            readOnly: true,
                            decoration: customInputDecoration(
                              suffixIcon: const Icon(
                                Icons.access_time,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                            onTap: () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                 selectedInTime = pickedTime; 
                                inTimeController.text = pickedTime.format(context);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Out Time Field
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Out Time', style: labelStyle),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: outTimeController,
                            readOnly: true,
                            decoration: customInputDecoration(
                              suffixIcon: const Icon(
                                Icons.access_time,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                            onTap: () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                selectedOutTime = pickedTime;
                                outTimeController.text = pickedTime.format(
                                  context,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount Field
                const Text('Max Participants', style: labelStyle),
                const SizedBox(height: 8),
                TextFormField(
                  controller: maxparticipantsController,
                  keyboardType: TextInputType.number,
                  decoration: customInputDecoration(),
                ),
                const SizedBox(height: 24),

                // Vibrant Green "Add Booking" Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.purpleAccent, // The vibrant green color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (eventController.text.trim().isEmpty ||
                          descriptionController.text.trim().isEmpty ||
                          maxparticipantsController.text.trim().isEmpty ||
                          selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please fill all mandatory fields (Title, Description, Max Participants, Date)',
                            ),
                          ),
                        );
                        return;
                      }

                      final int? parsedMaxParticipants = int.tryParse(
                        maxparticipantsController.text.trim(),
                      );
                      if (parsedMaxParticipants == null ||
                          parsedMaxParticipants <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter a valid number for Max Participants',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF00C853),
                            ),
                          ),
                        ),
                      );

                      try {
                        await bookingService.addEvent(
                          title: eventController.text.trim(),
                          description: descriptionController.text.trim(),
                          maxParticipants: maxparticipantsController.text.trim(),
                          date: selectedDate!,
                          inTime: selectedInTime,
                          outTime: selectedOutTime, sport: '', status: '', entryFee:0,
                        );

                        if (!context.mounted) return;
                        Navigator.pop(context);
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Event added successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (error) {
                        if (!context.mounted) return;
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${error.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Create Event',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  //Helper Function

  
}
