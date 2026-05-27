import 'package:booktoplay_webapp/components/dashboardcard.dart';
import 'package:booktoplay_webapp/components/kpiboxes.dart';
import 'package:booktoplay_webapp/models/bookingmodel.dart';
import 'package:booktoplay_webapp/models/customer_grounddetails.dart';
import 'package:booktoplay_webapp/models/sortdata.dart';
import 'package:booktoplay_webapp/navigation/primaryscaffold.dart';
import 'package:booktoplay_webapp/service/firebaseservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ScrollController slotScrollController = ScrollController();
  //==================TIME SLOT LIST====================================
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
  @override
  void dispose() {
    slotScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return sidebar(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  //=========================ADD NEW GROUND BUTTON==================================
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _showGroundDialog(context);
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
                            'Add New Ground',
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
              Text(
                'ABC Sports Arena',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              SizedBox(height: 12),
              //=============================== KPI Boxes Row UPADATD ===============================
              StreamBuilder<Map<String, dynamic>>(
                stream: FirebaseService().getDashboardMetricsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading metrics: ${snapshot.error}'),
                    );
                  }

                  // Fallback values while loading or if data is empty
                  final data =
                      snapshot.data ??
                      {
                        'todaysBookings': '0',
                        'totalRevenue': '\$0',
                        'availableSlots': '0',
                      };

                  final bool isLoading =
                      snapshot.connectionState == ConnectionState.waiting;

                  return Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: KpiCard(
                          value: isLoading ? '...' : data['todaysBookings']!,
                          label: 'Todays bookings',
                          icon: Icons.calendar_today_rounded,
                          subvalue:
                              '+2.5', // You can calculate percentage changes later if needed
                        ),
                      ),
                      Expanded(
                        child: KpiCard(
                          value: isLoading ? '...' : data['totalRevenue']!,
                          label: 'Total Revenue',
                          icon: Icons.attach_money_rounded,
                          subvalue: '+12.3%',
                        ),
                      ),
                      Expanded(
                        child: KpiCard(
                          value: isLoading ? '...' : data['availableSlots']!,
                          label: 'Available Slot',
                          icon: Icons.event_seat_rounded,
                          subvalue: 'Live',
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),
              //=========================Booking details===========================
              Row(
                children: [
                  Expanded(
                    child: Dashboardcard(
                      title: 'Add Manual Booking',
                      subtitle: 'Record offline bookings',
                      icon: Icons.calendar_today_outlined,
                      themeColor: const Color(0xFF00D9A3),
                      onTap: () {
                        context.go('/allbookings');
                      }, // Mint Green
                    ),
                  ),
                  const SizedBox(width: 15), // Spacing between cards
                  Expanded(
                    child: Dashboardcard(
                      title: 'Promote Dull Hours',
                      subtitle: 'Set discounts for free slots',
                      icon: Icons.trending_up_rounded,
                      themeColor: const Color(0xFF7C4DFF),
                      onTap: () {
                        context.go('/freeslots');
                      }, // Purple
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
              SizedBox(height: 15),
              //=============================== Recent Bookings List ===============================
              Container(
                padding: const EdgeInsets.all(
                  20,
                ), // Slightly more padding for a premium look
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF1A1D1D),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // Align "Recent Bookings" to the left
                  children: [
                    const Text(
                      'Recent Bookings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    //===========================GET CUSTOMER BOOKINGS LIST=========================
                    StreamBuilder<List<CustomergroundDetails>>(
                      stream: FirebaseService().getAllCustomerBookings(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              "No Upcoming Bookings",
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }

                        final bookings = snapshot.data!;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final booking = bookings[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.sports_soccer,
                                          color: Colors.green,
                                        ),
                                      ),

                                      const SizedBox(width: 15),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              booking.groundName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            const SizedBox(height: 5),

                                            Text(
                                              booking.slotTime,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),

                                            const SizedBox(height: 4),

                                            Text(
                                              booking.bookingDate != null
                                                  ? "${booking.bookingDate!.day}/${booking.bookingDate!.month}/${booking.bookingDate!.year}"
                                                  : "",
                                              style: const TextStyle(
                                                color: Colors.greenAccent,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Text(
                                        "₹${booking.amount.toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  const Text(
                                    "Players",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  if (booking.players.isEmpty)
                                    const Text(
                                      "No player details",
                                      style: TextStyle(color: Colors.white54),
                                    )
                                  else
                                    Column(
                                      children: booking.players.map((player) {
                                        final name = player['name'] ?? '';
                                        final phone = player['phone'] ?? '';
                                        final splitAmount =
                                            (player['splitAmount'] as num?)
                                                ?.toDouble() ??
                                            0.0;

                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.25,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.withValues(
                                                alpha: 0.3,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                color: Colors.greenAccent,
                                                size: 20,
                                              ),

                                              const SizedBox(width: 10),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      name.toString(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    Text(
                                                      phone.toString(),
                                                      style: const TextStyle(
                                                        color: Colors.white60,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Text(
                                                "₹${splitAmount.toStringAsFixed(0)}",
                                                style: const TextStyle(
                                                  color: Colors.greenAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),

                    SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  //=========================ADD GROUND  popup form====================================

  void _showGroundDialog(BuildContext context) {
    final FirebaseService bookingService = FirebaseService();

    // Controllers
    final playerNameController = TextEditingController();
    final phoneController = TextEditingController();
    final sportController = TextEditingController();
    final groundNameController = TextEditingController();
    final placeController = TextEditingController();
    final dateController = TextEditingController();
    final hoursController = TextEditingController();
    final amountController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        const labelStyle = TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        );
//======================TEXTBOX DESIGN=================================
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
                width: MediaQuery.of(context).size.width * 0.45,
                height: MediaQuery.of(context).size.height * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
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
                            'Add Ground Booking',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      //==================== Ground & Location Section=====================================
                      _buildSectionHeader('Ground & Location'),
                      const SizedBox(height: 12),
                  //=======================GROUND NAME FIED==================================
                      const Text('Ground Name', style: labelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: groundNameController,
                        decoration: customInputDecoration(
                          hintText: 'e.g., City Sports Complex',
                        ),
                      ),
                      const SizedBox(height: 16),
                      //===================PLACE AND LOCATION=============================
                      const Text('Place/Location', style: labelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: placeController,
                        decoration: customInputDecoration(
                          hintText: 'e.g., Whitefield, Bangalore',
                        ),
                      ),
                    //======================ADDRESS====================================
                      const SizedBox(height: 16),
                      const Text('Address', style: labelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        maxLines: 2,
                        controller: addressController,
                        decoration: customInputDecoration(hintText: ''),
                      ),

                      const SizedBox(height: 16),

                      //=======================Duration & Amount Section=============================
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Amount (₹)', style: labelStyle),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: amountController,
                                  keyboardType: TextInputType.number,
                                  decoration: customInputDecoration(
                                    hintText: '0',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
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
                          //======================ADD GROUND LOGIC======================================
                          onPressed: () async {
                            // Validation
                            if (groundNameController.text.trim().isEmpty ||
                                placeController.text.trim().isEmpty ||
                                amountController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please fill all mandatory fields',
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
                            //===================SAVE GROUND DETAILS===========================
                            try {
                              await bookingService.saveGroundBooking(
                                groundName: groundNameController.text.trim(),
                                place: placeController.text.trim(),
                               address: addressController.text.trim(),
                                amount: double.parse(
                                  amountController.text.trim(),
                                ),
                              );
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
      playerNameController.dispose();
      phoneController.dispose();
      sportController.dispose();
      groundNameController.dispose();
      placeController.dispose();
      dateController.dispose();
      hoursController.dispose();
      amountController.dispose();
    });
  }

  // ================Helper widget for section headers==================
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF00C853),
        letterSpacing: 0.5,
      ),
    );
  }
}
