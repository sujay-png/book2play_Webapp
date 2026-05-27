import 'package:booktoplay_webapp/components/accounts_kpiboxes.dart';
import 'package:booktoplay_webapp/components/breakdown_kpiboxes.dart';
import 'package:booktoplay_webapp/models/bookingmodel.dart';
import 'package:booktoplay_webapp/navigation/primaryscaffold.dart';
import 'package:booktoplay_webapp/service/firebaseservice.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//==============FILTER LIST=============================
const List<String> filterList = [
  'This Week',
  'Last Week',
  'This Quarter',
  'This Year',
];

class Accounts extends StatefulWidget {
  const Accounts({super.key});

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  final ScrollController _pageScrollController = ScrollController();
  final ScrollController _expenseScrollController = ScrollController();
  final ScrollController _transactionScrollController = ScrollController();

  String selectedFilter = 'This Week';
  int selectedType = 0; 

  @override
  void dispose() {
    _pageScrollController.dispose();
    _expenseScrollController.dispose();
    _transactionScrollController.dispose();
    super.dispose();
  }
//============================FILTER METHOD===========================
  DateTimeRange _getDateRange(String filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case 'Last Week':
        final startThisWeek = today.subtract(Duration(days: now.weekday - 1));
        final startLastWeek = startThisWeek.subtract(const Duration(days: 7));
        return DateTimeRange(
          start: startLastWeek,
          end: startThisWeek.subtract(const Duration(microseconds: 1)),
        );

      case 'This Quarter':
        final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        final start = DateTime(now.year, quarterStartMonth, 1);
        final end = DateTime(now.year, quarterStartMonth + 3, 1)
            .subtract(const Duration(microseconds: 1));
        return DateTimeRange(start: start, end: end);

      case 'This Year':
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year + 1, 1, 1)
              .subtract(const Duration(microseconds: 1)),
        );

      case 'This Week':
      default:
        final start = today.subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 7))
            .subtract(const Duration(microseconds: 1));
        return DateTimeRange(start: start, end: end);
    }
  }

  bool _isBookingInRange(BookingModel booking) {
    final range = _getDateRange(selectedFilter);
    final date = booking.bookingDate;

    return date.isAfter(range.start.subtract(const Duration(microseconds: 1))) &&
        date.isBefore(range.end.add(const Duration(microseconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return sidebar(
      child: Scrollbar(
        controller: _pageScrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _pageScrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //========================== BACK TO DASHBOARD BUTTON=======================
              SizedBox(
                width: 180,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => context.go('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Back to Dashboard',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Accounts & Expenses',
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),

              const SizedBox(height: 15),
              //========================GET BOOKINGS LIST=============================
              StreamBuilder<List<BookingModel>>(
                stream: FirebaseService().getBookings(),
                builder: (context, bookingSnapshot) {
                  final allBookings = bookingSnapshot.data ?? [];
                  final filteredBookings =
                      allBookings.where(_isBookingInRange).toList();

                  final totalRevenue = filteredBookings.fold<double>(
                    0,
                    (sum, item) => sum + item.amount,
                  );
                //===========================GET EXPENSES FROM REMIDER & KPI BOX UPDATE=============================
                  return StreamBuilder<List<Map<String, String>>>(
                    stream: FirebaseService().getReminderTitlesStream(),
                    builder: (context, expenseSnapshot) {
                      final expenses = expenseSnapshot.data ?? [];

                      final totalExpenses = expenses.fold<double>(0, (
                        sum,
                        item,
                      ) {
                        return sum + (double.tryParse(item['amount'] ?? '0') ?? 0);
                      });

                      final netProfit = totalRevenue - totalExpenses;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AccountsKpibox(
                                  value: '₹${totalRevenue.toStringAsFixed(0)}',
                                  label: 'Total Revenue',
                                  iconColor: Colors.red,
                                  icons: const Icon(Icons.trending_up),
                                  valueColor: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: AccountsKpibox(
                                  value: '₹${totalExpenses.toStringAsFixed(0)}',
                                  label: 'Total Expenses',
                                  iconColor: Colors.blue,
                                  icons: const Icon(Icons.trending_down),
                                  valueColor: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: AccountsKpibox(
                                  value: '₹${netProfit.toStringAsFixed(0)}',
                                  label: 'Net Profit',
                                  iconColor: Colors.blue,
                                  icons: const Icon(Icons.attach_money_sharp),
                                  valueColor: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                //=======================FILTER DATA METHOD======================
                                SizedBox(
                                  width: 220,
                                  child: DropdownButtonFormField<String>(
                                    initialValue: selectedFilter,
                                    dropdownColor: Colors.black87,
                                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00C853)),
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
                                      ),
                                    ),
                                    onChanged: (value) {
                                     
                                    },
                                    items: filterList.map((value) {
                                      return DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),

                                const SizedBox(width: 20),

                                Wrap(
                                  spacing: 12,
                                  children: ['All', 'Revenue', 'Expenses']
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final label = entry.value;
                                    final selected = selectedType == index;

                                    return ChoiceChip(
                                      label: Text(label),
                                      selected: selected,
                                      selectedColor: const Color(0xFF00C853),
                                      backgroundColor: const Color(0xffF1F3F5),
                                      showCheckmark: false,
                                      labelStyle: TextStyle(
                                        color: selected ? Colors.white : const Color(0xFF1E293B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      onSelected: (_) {
                                        setState(() {
                                          selectedType = index;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedType == 0 || selectedType == 1)
                                Expanded(
                                  child: BreakdownKpiboxes(
                                    title: 'Revenue Breakdown',
                                    subtitle1: 'Bookings',
                                    value1: '₹${totalRevenue.toStringAsFixed(0)}',
                                    valueColor1: Colors.green,
                                    valueColor2: Colors.red,
                                  ),
                                ),

                              if (selectedType == 0) const SizedBox(width: 15),

                              if (selectedType == 0 || selectedType == 2)
                                Expanded(
                                  child: Container(
                                    height: 300,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Expense Breakdown',
                                          style: TextStyle(fontSize: 18, color: Colors.white),
                                        ),
                                        const SizedBox(height: 15),
                                        Expanded(
                                          child: Scrollbar(
                                            controller: _expenseScrollController,
                                            thumbVisibility: true,
                                            child: ListView.builder(
                                              controller: _expenseScrollController,
                                              itemCount: expenses.length,
                                              itemBuilder: (context, index) {
                                                final item = expenses[index];

                                                return Padding(
                                                  padding: const EdgeInsets.only(bottom: 12),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          item['title'] ?? '-',
                                                          style: const TextStyle(color: Colors.white70),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Text(
                                                        '₹${item['amount'] ?? '0'}',
                                                        style: const TextStyle(
                                                          color: Colors.blueAccent,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 15),
                          //==============================RECENT TRANSACTION TABLE==============================

                          if (selectedType == 0 || selectedType == 1)
                            Container(
                              height: 420,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Recent Transactions',
                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                  const SizedBox(height: 15),

                                  Expanded(
                                    child: Scrollbar(
                                      controller: _transactionScrollController,
                                      thumbVisibility: true,
                                      child: ListView.builder(
                                        controller: _transactionScrollController,
                                        itemCount: filteredBookings.length,
                                        itemBuilder: (context, index) {
                                          final item = filteredBookings[index];

                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 12),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1E1E1E),
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: const Color(0xFF2D2D3A),
                                                  child: Text(
                                                    item.customerName.isNotEmpty
                                                        ? item.customerName[0].toUpperCase()
                                                        : "?",
                                                    style: const TextStyle(color: Color(0xFF9CCAFF)),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    item.customerName,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "₹${item.amount.toStringAsFixed(0)}",
                                                      style: const TextStyle(
                                                        color: Color(0xFF00C853),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    const Text(
                                                      "confirmed",
                                                      style: TextStyle(
                                                        color: Color(0xFF00C853),
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}