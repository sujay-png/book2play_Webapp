import 'package:booktoplay_webapp/components/slotlist.dart';
import 'package:booktoplay_webapp/components/slotsbooking.dart';
import 'package:booktoplay_webapp/models/freeslotdiscount.dart';
import 'package:booktoplay_webapp/models/freeslotsmodel.dart';
import 'package:booktoplay_webapp/models/sortdata.dart'; // Make sure SlotData is inside this model file
import 'package:booktoplay_webapp/navigation/primaryscaffold.dart';
import 'package:booktoplay_webapp/pages/freeslots/discountbottomsheet.dart';
import 'package:booktoplay_webapp/service/firebaseservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Freeslots extends StatefulWidget {
  const Freeslots({super.key});

  @override
  State<Freeslots> createState() => _FreeslotsState();
}

class _FreeslotsState extends State<Freeslots> {
 //===================TIE SLOT LIST=================================
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
  List<String> bookedSlotTimes = [];
  @override
  void initState() {
    super.initState();
    fetchBookedSlots();
  }

  DateTime selectedDate = DateTime.now();
  Future<void> fetchBookedSlots() async {
    final startDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final endDate = startDate.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where(
          'bookingDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where('bookingDate', isLessThan: Timestamp.fromDate(endDate))
        .get();

    setState(() {
      bookedSlotTimes = snapshot.docs
          .where((doc) => doc.data().containsKey('slotTime'))
          .map((doc) => doc['slotTime'].toString().trim())
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return sidebar(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //========================Back Button========================
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
                  child: const Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
        
              //========================Heading and KPIs========================
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Free Slots & Promotional Pricing',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ],
              ),
        
              //========================KPIs================================
              const SizedBox(height: 20),
        
              ElevatedButton.icon(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
        
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
        
                    fetchBookedSlots();
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                ),
              ),
              const SizedBox(height: 20),
              Row(
                spacing: 15,
                children: [
                  Expanded(
                    child: Slotsbooking(
                      title: 'Total Free Slots',
                      valueColor: Colors.green,
                      value: _slots.length.toString(),
                    ),
                  ),
                  Expanded(
                    child: Slotsbooking(
                      title: 'Slots With Discounts',
                      valueColor: Colors.red,
                      value: _slots
                          .where((slot) => slot.hasDiscount)
                          .length
                          .toString(),
                    ),
                  ),
                  Expanded(
                    child: Slotsbooking(
                      title: 'Total Booked Slots',
                      valueColor: Colors.blue,
                      value: bookedSlotTimes.length
                          .toString(), // Adjust variable dynamically if needed later
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
        
              //========================Free Slots Grid Layout========================
              SizedBox(
                height: 800,
                child: StreamBuilder<List<SlotDiscountModel>>(
                  stream: FirebaseService().getSlotDiscountsStream(selectedDate),
                  builder: (context, snapshot) {
                    final discounts = snapshot.data ?? [];
        
                    for (final slot in _slots) {
                      slot.discountPercentage = null;
                      slot.fixedDiscountPrice = null;
                    }
        
                    for (final discount in discounts) {
                      final index = _slots.indexWhere(
                        (slot) => slot.time.trim() == discount.slotTime.trim(),
                      );
        
                      if (index != -1) {
                        if (discount.discountType == 'percentage') {
                          _slots[index].discountPercentage =
                              discount.discountValue;
                        } else {
                          _slots[index].fixedDiscountPrice =
                              discount.discountValue;
                        }
                      }
                    }
        
                    return GridView.builder(
                      itemCount: _slots.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.9,
                          ),
                      itemBuilder: (context, index) {
                        return _buildSlotItem(index);
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

  void _showDiscountSheet(BuildContext context, int index) async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DiscountBottomSheet(
          timeSlot: _slots[index].time,
          selectedDate: selectedDate,
        );
      },
    );
    if (result != null) {
      final String? type = result['type'];
      final String? valueStr = result['value'];
      final double? discountValue = double.tryParse(valueStr ?? '');

      if (discountValue != null) {
        setState(() {
          if (type == 'percentage') {
            _slots[index].discountPercentage = discountValue;
            _slots[index].fixedDiscountPrice = null;
          } else if (type == 'fixed') {
            _slots[index].fixedDiscountPrice = discountValue;
            _slots[index].discountPercentage = null;
          }
        });
      }
    }
  }

  Widget _buildSlotItem(int index) {
    final slot = _slots[index];
    final isBooked = bookedSlotTimes.contains(slot.time.trim());

    return Slotlist(
      slot: slot,
      isBooked: isBooked,
      bookedText: isBooked ? 'Slot Booked\n${slot.time}' : null,
      onTap: isBooked
          ? null
          : () {
              _showDiscountSheet(context, index);
            },
      onRemoveDiscount: () {
        setState(() {
          slot.discountPercentage = null;
          slot.fixedDiscountPrice = null;
        });
      },
    );
  }
}
