import 'package:booktoplay_webapp/components/allbookings_kpibox.dart';
import 'package:booktoplay_webapp/models/bookingmodel.dart';
import 'package:booktoplay_webapp/navigation/primaryscaffold.dart';
import 'package:booktoplay_webapp/pages/bookings/bookingfilter.dart';
import 'package:booktoplay_webapp/service/firebaseservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Allbookings extends StatefulWidget {
  const Allbookings({super.key});

  @override
  State<Allbookings> createState() => _AllbookingsState();
}

class _AllbookingsState extends State<Allbookings> {
  String selectedTimeFilter = 'Today';
  DateTime? startDate;
  DateTime? endDate;
  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period = hour >= 12 ? 'PM' : 'AM';

    //=================== Convert to 12-hour format============================
    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  //===================== Helper method to format DateTime to date string (DD/MM/YYYY)=================================
  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  final FirebaseService _bookingService = FirebaseService();
  @override
  Widget build(BuildContext context) {
    //===================FILTER LIST================================
    final List<String> tabs = [
      'Today',
      'Tomorrow',
      'This Week',
      'This Month',
      'Quarter',
      'Year',
      'Custom',
    ];

    @override
    void initState() {
      super.initState();

      final initialRange = BookingFilterHelper.calculateRange('Today');
      startDate = initialRange.startDate;
      endDate = initialRange.endDate;
    }

    void updateTimeRange(String filterType) async {
      if (filterType == 'Custom') {
        final result = await BookingFilterHelper.showCustomRangePicker(
          context: context,
          initialStart: startDate,
          initialEnd: endDate,
        );

        if (result != null) {
          setState(() {
            selectedTimeFilter = filterType;
            startDate = result.startDate;
            endDate = result.endDate;
          });
        }
      } else {
        final result = BookingFilterHelper.calculateRange(filterType);

        setState(() {
          selectedTimeFilter = filterType;
          startDate = result.startDate;
          endDate = result.endDate;
        });
      }
    }
    return sidebar(
      child: SingleChildScrollView(
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
        
                    //=============================== Back Button ===============================
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/'); 
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
        
              Text(
                'Check bookings',
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
        
              //=============================== Filter and Tabs Section ===============================
              DefaultTabController(
                length: tabs.length,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.grey[800]!,
                    ), // Subtle border for definition
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.filter_alt_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          Text(
                            'Filter ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.green,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        
                        unselectedLabelColor: const Color(0xFF1A237E),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        onTap: (index) => updateTimeRange(tabs[index]),
                        tabs: tabs.map((tabText) {
                          return Tab(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(tabText),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
        
              //=============================== KPI Boxes Row& UPDATE DASBORD FROM BACKEND  ===============================
              SizedBox(height: 15),
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
                        'totalBookings': '0',
                        'totalRevenue': '\$0',
                        'availableSlots': '0',
                      };

                  final bool isLoading =
                      snapshot.connectionState == ConnectionState.waiting;
                      return  Row(
                  spacing: 15,
                  children: [
                    Expanded(
                      child: AllbookingsKpibox(
                    value: isLoading ? '...' : data['totalBookings']!,

                        label: 'Total Bookings',
                        valueColor: Colors.blueAccent,
                      ),
                    ),
                    Expanded(
                      child: AllbookingsKpibox(
                       value: isLoading ? '...' : data['totalRevenue']!,
                        label: 'Total Revenue',
                        valueColor: Colors.green,
                      ),
                    ),
                  ],
                );
                }
              ),
            
              //=============================== Bookings List Section ===============================
              SizedBox(height: 25),
              SizedBox(
                height: 500,
                child: StreamBuilder<List<BookingModel>>(
                  stream: _bookingService.getBookingsStream(),
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
                        child: CircularProgressIndicator(
                          color: Colors.greenAccent,
                        ),
                      );
                    }
        
                    final docs = (snapshot.data ?? []).where((booking) {
                      if (startDate == null ||
                          endDate == null) {
                        return false;
                      }
        
                      return booking.bookingDate.isAfter(
                            startDate!.subtract(const Duration(microseconds: 1)),
                          ) &&
                          booking.bookingDate.isBefore(
                            endDate!.add(const Duration(microseconds: 1)),
                          );
                    }).toList();
        
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No bookings found.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }
        
                    return ListView.builder(
                      itemCount: docs.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final booking = docs[index];
                        String formattedTime = '--:-- - --:--';
                        if (booking.inTime != null && booking.outTime != null) {
                          final inTimeStr = _formatTime(booking.inTime!);
                          final outTimeStr = _formatTime(booking.outTime!);
                          formattedTime = '$inTimeStr - $outTimeStr';
                        } else if (booking.slotTime != null) {
                          formattedTime = booking.slotTime!;
                        }
                        String formattedDate = '--/--/----';
                        formattedDate = _formatDate(booking.bookingDate);
        
                        return _buildBookingCard(
                          docId: booking.id,
                          name: booking.customerName.isEmpty
                              ? 'Unknown Customer'
                              : booking.customerName,
                          phone: booking.phoneNumber.isEmpty
                              ? 'No Phone'
                              : booking.phoneNumber,
                          sport: booking.sport.isEmpty ? 'N/A' : booking.sport,
                          date: formattedDate,
                          time: formattedTime,
                          amount: booking.amount.toString(),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //=========================Helper method to build each booking card==========================
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
}
