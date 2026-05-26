import 'package:booktoplay_webapp/components/reminders_kpibox.dart';
import 'package:booktoplay_webapp/models/remindermodel.dart';
import 'package:booktoplay_webapp/navigation/primaryscaffold.dart';
import 'package:booktoplay_webapp/service/firebaseservice.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Reminder extends StatefulWidget {
  const Reminder({super.key});

  @override
  State<Reminder> createState() => _ReminderState();
}

class _ReminderState extends State<Reminder> {
  final FirebaseService _bookingService = FirebaseService();

  final FirebaseService bookingService = FirebaseService();
  @override
  Widget build(BuildContext context) {
    return sidebar(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: StreamBuilder<List<ReminderModel>>(
          stream: bookingService.getRemindersStream(),
          builder: (context, snapshot) {
            int pendingCount = 0;
            int overdueCount = 0;
            List<ReminderModel> documents = [];

            if (snapshot.hasData) {
              documents = snapshot.data ?? [];

              // STEP 3: Loop through all records and calculate live counts
              for (var doc in documents) {
                final DateTime bookingDate = doc.bookingDate;

                if (!doc.isDone) {
                  if (_checkIsOverdue(bookingDate)) {
                    overdueCount++;
                  } else {
                    pendingCount++;
                  }
                }
              }
            }

            return Column(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Important Reminders',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _addreminderform(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),

                        child: Row(
                          children: [
                            Icon(Icons.add, color: Colors.black),
                            SizedBox(width: 10),
                            Text(
                              'Add Reminder',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  spacing: 15,
                  children: [
                    Expanded(
                      child: Reminders(
                        title: 'Pending Reminders',
                        icon: Icons.notifications_none_outlined,
                        value:
                            snapshot.connectionState == ConnectionState.waiting
                            ? '...'
                            : pendingCount.toString(),
                        valueColor: Colors.red,
                        iconColor: Colors.redAccent,
                      ),
                    ),
                    Expanded(
                      child: Reminders(
                        title: 'OverDue',
                        icon: Icons.notifications_none_outlined,
                        value:
                            snapshot.connectionState == ConnectionState.waiting
                            ? '...'
                            : overdueCount.toString(),
                        valueColor: Colors.red,
                        iconColor: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Expanded(
                  child: StreamBuilder<List<ReminderModel>>(
                    stream: bookingService.getRemindersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading records: ${snapshot.error}',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 15,
                            ),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF00C853),
                            ),
                          ),
                        );
                      }

                      final documents = snapshot.data ?? [];

                      if (documents.isEmpty) {
                        return const Center(
                          child: Text(
                            'No active reminders.',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: documents.length,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 16.0),
                        itemBuilder: (context, index) {
                          final doc = documents[index];

                          final String docId = doc.id;
                          final String title = doc.customerName.isEmpty
                              ? 'Untitled Reminder'
                              : doc.customerName;
                          final String description = doc.description;
                          final String priority = doc.priority;
                          final DateTime bookingDate = doc.bookingDate;
                          final bool isDone = doc.isDone;

                          final bool isOverdue = _checkIsOverdue(bookingDate);

                          return Opacity(
                            opacity: isDone ? 0.5 : 1.0,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? Colors.grey.shade800
                                    : Colors.black87,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          _buildStatusBadge(label: priority),
                                          if (isOverdue) ...[
                                            const SizedBox(width: 8.0),
                                            _buildStatusBadge(label: 'Overdue'),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (description.isNotEmpty) ...[
                                    const SizedBox(height: 12.0),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6.0),
                                      child: Text(
                                        description,
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 16.0),
                                  Row(
                                    children: [
                                      if (!isDone)
                                        TextButton(
                                          onPressed: () async {
                                            await bookingService.markReminderAsDone(docId);
                                          },
                                          child: const Text(
                                            'Done',
                                            style: TextStyle(
                                              color: Colors.greenAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                      const SizedBox(width: 10),

                                      TextButton(
                                        onPressed: () async {
                                          _handleDelete(docId);
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  //Delete
  Future<void> _handleDelete(String id) async {
    try {
      // FIX: Triggers decoupled external logic instead of parsing native firebase parameters here
      await _bookingService.deleteReminder(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder removed successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatusBadge({required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: _getBadgeBackgroundColor(label),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey)
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _getBadgeTextColor(label),
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  //Popupform for model

  void _addreminderform(BuildContext context) {
    final FirebaseService bookingService = FirebaseService();
    final titlecontroller = TextEditingController();
    final descriptioncontroller = TextEditingController();
    final prioritycontroller = TextEditingController();
    final dateController = TextEditingController();
    final amountcontroller = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        const labelStyle = TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color:Colors.white70,
        );

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
            fillColor: Colors.black12,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
            ),
          );
        }

        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
           
          ),
          
          
          contentPadding: const EdgeInsets.all(24),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            height: MediaQuery.of(context).size.height * 0.7,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Add New Reminder',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text('Title', style: labelStyle),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: titlecontroller,
                    decoration: customInputDecoration(),
                  ),
                  const SizedBox(height: 16),

                  const Text('Description', style: labelStyle),
                  const SizedBox(height: 8),
                  TextFormField(
                      keyboardType: TextInputType.multiline,
                  maxLines: 3,
                    controller: descriptioncontroller,
                    decoration: customInputDecoration( ),
                  ),
                  const SizedBox(height: 16),

                  const Text('Priority', style: labelStyle),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: prioritycontroller,
                    decoration: customInputDecoration(),
                  ),
                  const SizedBox(height: 16),
                    const Text('Amount', style: labelStyle),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: amountcontroller,
                    decoration: customInputDecoration(),
                  ),

                  const Text('Date', style: labelStyle),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: dateController,
                    readOnly: true,
                    decoration: customInputDecoration(
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white,
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
                        selectedDate = pickedDate;
                        dateController.text = "${pickedDate.toLocal()}".split(
                          ' ',
                        )[0];
                      }
                    },
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        // CRITICAL FIX: Explicitly check selectedDate for null before execution
                        if (titlecontroller.text.trim().isEmpty ||
                            prioritycontroller.text.trim().isEmpty ||
                            selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please fill all mandatory fields (Name, Date, Amount)',
                              ),
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
                          await bookingService.addReminder(
                            name: titlecontroller.text.trim(),
                            description: descriptioncontroller.text.trim(),
                            priority: prioritycontroller.text.trim(),
                            date: selectedDate!, // Guaranteed safe now
                            amount: amountcontroller.text.trim(),
                          );
                          if (context.mounted) Navigator.pop(context);

                          if (context.mounted) Navigator.pop(context);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reminder added successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (error) {
                          if (context.mounted) Navigator.pop(context);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to save: ${error.toString()}',
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Add Reminder',
                        style: TextStyle(
                          color: Colors.black,
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
    ).then((_) {
      // Memory cleanup
      titlecontroller.dispose();
      descriptioncontroller.dispose();
      prioritycontroller.dispose();
      dateController.dispose();
    });
  }

  //Helper Method

 

  bool _checkIsOverdue(DateTime bookingDate) {
    final now = DateTime.now();

    final targetDate = DateTime(
      bookingDate.year,
      bookingDate.month,
      bookingDate.day,
    );

    final todayMidnight = DateTime(now.year, now.month, now.day);

    return targetDate.isBefore(todayMidnight);
  }

  Color _getBadgeBackgroundColor(String label) {
    switch (label.toLowerCase()) {
      case 'high':
      case 'overdue':
        return const Color(0xFFFFEAEA); // Soft Red
      case 'medium':
        return const Color(0xFFFFF3E0); // Soft Orange
      case 'low':
      default:
        return const Color(0xFFE8F5E9); // Soft Green
    }
  }

  Color _getBadgeTextColor(String label) {
    switch (label.toLowerCase()) {
      case 'high':
      case 'overdue':
        return const Color(0xFFE53935); // Crimson Red
      case 'medium':
        return const Color(0xFFEF6C00); // Dark Amber Orange
      case 'low':
      default:
        return const Color(0xFF2E7D32); // Deep Forest Green
    }
  }
}
