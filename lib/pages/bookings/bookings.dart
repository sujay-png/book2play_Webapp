import 'package:booktoplay_webapp/models/bookingmodel.dart';
import 'package:booktoplay_webapp/models/sortdata.dart';
import 'package:booktoplay_webapp/navigation/primaryscaffold.dart';
import 'package:booktoplay_webapp/pages/bookings/bookingfilter.dart';
import 'package:booktoplay_webapp/service/firebaseservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Bookings extends StatefulWidget {
  const Bookings({super.key});

  @override
  State<Bookings> createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  final ScrollController slotScrollController = ScrollController();
  String selectedFilter = 'Today';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();

    final result = BookingFilterHelper.calculateRange('Today');

    startDate = result.startDate;
    endDate = result.endDate;
  }

  @override
  void dispose() {
    slotScrollController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  final List<SlotData> _slots = [
    SlotData(time: '06:00 AM - 07:00 AM', basePrice: 1000),
    SlotData(time: '07:00 AM - 08:00 AM', basePrice: 1000),
    SlotData(time: '08:00 AM - 09:00 AM', basePrice: 1000),
    SlotData(time: '09:00 AM - 10:00 AM', basePrice: 1000),
    SlotData(time: '10:00 AM - 11:00 AM', basePrice: 1000),
    SlotData(time: '11:00 AM - 12:00 PM', basePrice: 1000),
    SlotData(time: '12:00 PM - 01:00 PM', basePrice: 1000),
    SlotData(time: '01:00 PM - 02:00 PM', basePrice: 1000),
    SlotData(time: '02:00 PM - 03:00 PM', basePrice: 1000),
    SlotData(time: '03:00 PM - 04:00 PM', basePrice: 1000),
    SlotData(time: '04:00 PM - 05:00 PM', basePrice: 1000),
    SlotData(time: '05:00 PM - 06:00 PM', basePrice: 1000),
    SlotData(time: '06:00 PM - 07:00 PM', basePrice: 1000),
    SlotData(time: '07:00 PM - 08:00 PM', basePrice: 1000),
    SlotData(time: '08:00 PM - 09:00 PM', basePrice: 1000),
    SlotData(time: '10:00 PM - 11:00 PM', basePrice: 1000),
    SlotData(time: '11:00 PM - 12:00 AM', basePrice: 1000),
  ];
  final FirebaseService _bookingService = FirebaseService();
  @override
  Widget build(BuildContext context) {
    return sidebar(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  'Update bookings Manually',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _showAddBookingDialog(context);
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
                          'Add New Booking',
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
            SizedBox(height: 25),
            Expanded(
              child: Expanded(
  child: StreamBuilder<List<Map<String, dynamic>>>(
    // 🔥 Cleaned: Removed arguments to fetch everything
    stream: _bookingService.getCombinedBookingsStream(), 
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text('Error loading bookings: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)),
        );
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
      }

      // 🔥 Cleaned: No more client-side date filtering! We show the entire list.
      final docs = snapshot.data ?? [];

      if (docs.isEmpty) {
        return const Center(
          child: Text('No bookings found.', style: TextStyle(color: Colors.grey, fontSize: 16)),
        );
      }

      return ListView.builder(
        itemCount: docs.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final currentItem = docs[index];
          final BookingModel booking = currentItem['booking'];
          final String groundName = currentItem['groundName'] ?? 'Unknown Ground';

          String formattedTime = '--:-- - --:--';
          if (booking.inTime != null && booking.outTime != null) {
            formattedTime = '${_formatTime(booking.inTime!)} - ${_formatTime(booking.outTime!)}';
          } else if (booking.slotTime != null) {
            formattedTime = booking.slotTime!;
          }

          String formattedDate = booking.bookingDate != null ? _formatDate(booking.bookingDate) : '--/--/----';

          return _buildBookingCard(
            docId: booking.id,
            name: booking.customerName.isEmpty ? 'Unknown Customer' : booking.customerName,
            phone: booking.phoneNumber.isEmpty ? 'No Phone' : booking.phoneNumber,
            sport: booking.sport.isEmpty ? groundName : '${booking.sport} ($groundName)',
            date: formattedDate,
            time: formattedTime,
            amount: booking.amount.toString(),
          );
        },
      );
    },
  ),
)
            ),
          ],
        ),
      ),
    );
  }

  //Delete Bookings

  Future<void> _handleDelete(String id) async {
    try {
      // FIX: Triggers decoupled external logic instead of parsing native firebase parameters here
      await _bookingService.deleteBooking(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking removed successfully.')),
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

  Widget _buildBookingCard({
    required String docId,
    required String name,
    required String phone,
    required String sport,
    required String date,
    required String time,
    required String amount,
  }) {
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
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                phone,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  double itemWidth = constraints.maxWidth / 4;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricColumn('Sport:', sport, itemWidth),
                      _buildMetricColumn('Date:', date, itemWidth),
                      _buildMetricColumn('Time:', time, itemWidth),
                      _buildMetricColumn('Amount:', '₹$amount', itemWidth),
                    ],
                  );
                },
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: () {
                _handleDelete(docId);
              },
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.close, color: Colors.redAccent, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, double width) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 230, 232, 235),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBookingDialog(BuildContext context) {
    final FirebaseService bookingService = FirebaseService();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final sportController = TextEditingController();
    final dateController = TextEditingController();
    final inTimeController = TextEditingController();
    final outTimeController = TextEditingController();
    final amountController = TextEditingController();

    DateTime? selectedDate;
    TimeOfDay? selectedInTime;
    TimeOfDay? selectedOutTime;
    int? selectedSlotIndex;
    String? selectedSlotTime;
    List<String> bookedSlotTimes = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        const labelStyle = TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
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
            fillColor: Colors.black87,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
            ),
          );
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.height * 0.8,
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
                            'Add Bookings Manual Page',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('Customer Name', style: labelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nameController,
                        decoration: customInputDecoration(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Phone Number', style: labelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: customInputDecoration(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Sport', style: labelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: sportController,
                        decoration: customInputDecoration(),
                      ),
                      const SizedBox(height: 16),
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
                            setDialogState(() {
                              selectedDate = pickedDate;
                              dateController.text = "${pickedDate.toLocal()}"
                                  .split(' ')[0];

                              selectedSlotIndex = null;
                              selectedSlotTime = null;
                              amountController.clear();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select Time Slot', style: labelStyle),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 75,
                            child: StreamBuilder<List<String>>(
                              stream: selectedDate == null
                                  ? null
                                  : bookingService.getBookedSlotsByDate(
                                      selectedDate!,
                                    ),
                              builder: (context, snapshot) {
                                final bookedSlotTimes = snapshot.data ?? [];

                                return RawScrollbar(
                                  controller: slotScrollController,
                                  thumbVisibility: true,
                                  thickness: 5,
                                  radius: const Radius.circular(10),
                                  child: ListView.builder(
                                    controller: slotScrollController,
                                    primary: false,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _slots.length,
                                    itemBuilder: (context, index) {
                                      final slot = _slots[index];
                                      final isSelected =
                                          selectedSlotIndex == index;
                                      final isBooked = bookedSlotTimes.contains(
                                        slot.time.trim(),
                                      );

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: InkWell(
                                          onTap:
                                              selectedDate == null || isBooked
                                              ? null
                                              : () {
                                                  setDialogState(() {
                                                    selectedSlotIndex = index;
                                                    selectedSlotTime =
                                                        slot.time;
                                                    amountController.text = slot
                                                        .basePrice!
                                                        .toStringAsFixed(0);
                                                  });
                                                },
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: selectedDate == null
                                                  ? Colors.grey.shade800
                                                  : isBooked
                                                  ? Colors.grey.shade700
                                                  : isSelected
                                                  ? Colors.green
                                                  : Colors.black87,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: isBooked
                                                    ? Colors.red
                                                    : isSelected
                                                    ? Colors.green
                                                    : Colors.grey.withOpacity(
                                                        0.3,
                                                      ),
                                                width: 2,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  slot.time,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  selectedDate == null
                                                      ? "SELECT DATE"
                                                      : isBooked
                                                      ? "BOOKED"
                                                      : "FREE",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: isBooked
                                                        ? Colors.redAccent
                                                        : Colors.greenAccent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Amount (₹)', style: labelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: customInputDecoration(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            // Validation
                            if (nameController.text.trim().isEmpty ||
                                amountController.text.trim().isEmpty ||
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
                              // UPDATED: Pass slot data to addBooking
                              await bookingService.addBooking(
                                name: nameController.text.trim(),
                                phone: phoneController.text.trim(),
                                sport: sportController.text.trim(),
                                date: selectedDate!,
                                inTime: selectedInTime,
                                outTime: selectedOutTime,
                                amountString: amountController.text.trim(),
                                selectedSlotTime: selectedSlotTime,
                                selectedSlotIndex: selectedSlotIndex,
                              );
                              setState(() {
                                startDate = DateTime(
                                  selectedDate!.year,
                                  selectedDate!.month,
                                  selectedDate!.day,
                                );
                                endDate = startDate!
                                    .add(const Duration(days: 1))
                                    .subtract(const Duration(microseconds: 1));
                              });

                              if (context.mounted) Navigator.pop(context);
                              if (context.mounted) Navigator.pop(context);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Booking added successfully!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (error) {
                              if (context.mounted) Navigator.pop(context);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${error.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Add Booking',
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
      },
    ).then((_) {
      // Memory cleanup
      nameController.dispose();
      phoneController.dispose();
      sportController.dispose();
      dateController.dispose();
      inTimeController.dispose();
      outTimeController.dispose();
      amountController.dispose();
    });
  }
}
