import 'package:booktoplay_webapp/navigation/primaryscaffold.dart';
import 'package:booktoplay_webapp/service/firebaseservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  double totalPotentialRevenue = 0.0;
  double organizerShare = 0.0;
  double appCommission = 0.0;
  double eventPostingFee = 500.0; // Fixed flat fee

  @override
  void initState() {
    super.initState();
    // Attach update listeners to both text controllers
    _feeController.addListener(_calculateRevenue);
    _maxParticipantsController.addListener(_calculateRevenue);
  }

  void _calculateRevenue() {
    // Safe parsing fallback to 0 if text is empty or invalid
    final double entryFee = double.tryParse(_feeController.text.trim()) ?? 0.0;
    final int maxParticipants =
        int.tryParse(_maxParticipantsController.text.trim()) ?? 0;

    setState(() {
      totalPotentialRevenue = entryFee * maxParticipants;
      organizerShare = totalPotentialRevenue * 0.70; // 70% share
      appCommission = totalPotentialRevenue * 0.30; // 30% commission
    });
  }

  final _formKey = GlobalKey<FormState>();

  // Explicit form controllers for handling user input
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _sportController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _maxParticipantsController =
      TextEditingController();
  final TextEditingController _prizesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _sportController.dispose();
    _statusController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _feeController.dispose();
    _maxParticipantsController.dispose();
    _prizesController.dispose();
    _feeController.removeListener(_calculateRevenue);
    _maxParticipantsController.removeListener(_calculateRevenue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime? selectedDate;
    TimeOfDay? selectedInTime;
    TimeOfDay? selectedOutTime;
    final FirebaseService bookingService = FirebaseService();

    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
    );
    return sidebar(
      child: SingleChildScrollView(
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
                    'Create Event and Post',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 700,
                  padding: const EdgeInsets.all(28.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Event Title'),
                        TextFormField(
                          style: TextStyle(color: Colors.black87),
                          controller: _titleController,
                          decoration: InputDecoration(
                            border: inputBorder,
                            enabledBorder: inputBorder,
                            focusedBorder: focusedBorder,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildFieldLabel('Description'),
                        TextFormField(
                          style: TextStyle(color: Colors.black87),
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            border: inputBorder,
                            enabledBorder: inputBorder,
                            focusedBorder: focusedBorder,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildFieldLabel('Sport'),
                        TextFormField(
                          style: TextStyle(color: Colors.black87),
                          controller: _sportController,
                          decoration: InputDecoration(
                            border: inputBorder,
                            enabledBorder: inputBorder,
                            focusedBorder: focusedBorder,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Two Column Grid for Date and Time
                        Row(
                          spacing: 20,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('Event Date'),
                                  TextFormField(
                                    style: TextStyle(color: Colors.black87),

                                    controller: _dateController,
                                    readOnly: true,
                                    onTap: () => _selectDate(context),
                                    decoration: InputDecoration(
                                      suffixIcon: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 18,
                                        color: Colors.black87,
                                      ),
                                      border: inputBorder,
                                      enabledBorder: inputBorder,
                                      focusedBorder: focusedBorder,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('Start Time'),
                                  TextFormField(
                                    style: TextStyle(color: Colors.black87),
                                    controller: _timeController,
                                    readOnly: true,
                                    onTap: () => _selectTime(context),
                                    decoration: InputDecoration(
                                      suffixIcon: const Icon(
                                        Icons.access_time_outlined,
                                        size: 18,
                                        color: Colors.black87,
                                      ),
                                      border: inputBorder,
                                      enabledBorder: inputBorder,
                                      focusedBorder: focusedBorder,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Two Column Grid for Entry Fee and Participants
                        Row(
                          spacing: 20,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel(
                                    'Entry Fee per Participant (₹)',
                                  ),
                                  TextFormField(
                                    style: TextStyle(color: Colors.black87),
                                    controller: _feeController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: inputBorder,
                                      enabledBorder: inputBorder,
                                      focusedBorder: focusedBorder,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('Max Participants'),
                                  TextFormField(
                                    style: TextStyle(color: Colors.black87),
                                    controller: _maxParticipantsController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: inputBorder,
                                      enabledBorder: inputBorder,
                                      focusedBorder: focusedBorder,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        _buildFieldLabel('Prizes (Optional)'),
                        TextFormField(
                          style: TextStyle(color: Colors.black87),
                          controller: _prizesController,
                          decoration: InputDecoration(
                            border: inputBorder,
                            enabledBorder: inputBorder,
                            focusedBorder: focusedBorder,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Revenue Breakdown Segment Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFF8FAFC,
                            ), // Off-white canvas background tint
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Revenue Breakdown',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Row 1: Total Potential Entry Fees
                              _buildRevenueRow(
                                label: 'Total Potential Entry Fees:',
                                value:
                                    '₹${totalPotentialRevenue.toStringAsFixed(0)}',
                                isBold: true,
                              ),
                              const SizedBox(height: 10),

                              // Row 2: Your Share (70%)
                              _buildRevenueRow(
                                label: 'Your Share (70%):',
                                value: '₹${organizerShare.toStringAsFixed(0)}',
                                valueColor: Colors.green[700],
                              ),
                              const SizedBox(height: 10),

                              // Row 3: App Commission (30%)
                              _buildRevenueRow(
                                label: 'App Commission (30%):',
                                value: '₹${appCommission.toStringAsFixed(0)}',
                                valueColor: Colors.amber[800],
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(
                                  color: Color(0xFFCBD5E1),
                                  height: 1,
                                ),
                              ),

                              // Row 4: Event Posting Fee
                              _buildRevenueRow(
                                label: 'Event Posting Fee:',
                                value: '₹${eventPostingFee.toStringAsFixed(0)}',
                                valueColor: Colors.blue[700],
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Solid Green Action Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // 1. Validate all text fields are filled
                                if (_titleController.text.trim().isEmpty ||
                                    _descriptionController.text
                                        .trim()
                                        .isEmpty ||
                                    _dateController.text.trim().isEmpty ||
                                    _feeController.text.trim().isEmpty ||
                                    _sportController.text.trim().isEmpty ||
                                    _maxParticipantsController.text
                                        .trim()
                                        .isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please fill all mandatory fields',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                // 2. Safe Date Parsing Check BEFORE showing the loading dialog
                                DateTime? parsedDate;
                                String dateStr = _dateController.text.trim();

                                try {
                                  // If the date uses forward slashes (MM/DD/YYYY), convert it to YYYY-MM-DD for standard parsing
                                  if (dateStr.contains('/')) {
                                    List<String> parts = dateStr.split('/');
                                    if (parts.length == 3) {
                                      // Assumes input is MM/DD/YYYY -> transforms to YYYY-MM-DD
                                      dateStr =
                                          "${parts[2]}-${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}";
                                    }
                                  }
                                  parsedDate = DateTime.parse(dateStr);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Invalid date format ($dateStr). Please use YYYY-MM-DD or MM/DD/YYYY',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return; // Stop right here if the date format is completely broken
                                }

                                // ✅ 3. Now show the loading overlay dialog safely
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
                                  // 4. Save to Database
                                  await bookingService.addEvent(
                                    title: _titleController.text.trim(),
                                    description: _descriptionController.text
                                        .trim(),
                                    sport: _sportController.text.trim(),
                                  status: _statusController.text.trim(),
                                    maxParticipants: _maxParticipantsController.text.trim(),
                                    entryFee: double.tryParse(_feeController.text.trim()) ?? 0.0,
                                    date: parsedDate,
                                    inTime: selectedInTime,
                                    outTime: selectedOutTime,
                                  );
                                        
                                    

                                  print('✅ Event saved successfully!');

                                  if (!context.mounted) return;

                                  // Dismiss the loading spinner dialog explicitly using its raw root navigator instance
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pop();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Event created successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  // 5. Navigate to Home/Dashboard cleanly without breaking navigation stack layers
                                  await Future.delayed(
                                    const Duration(milliseconds: 500),
                                  );
                                  if (context.mounted) {
                                    context.go('/');
                                  }
                                } on FirebaseException catch (firebaseError) {
                                  print(
                                    '❌ Firebase Error: ${firebaseError.message}',
                                  );
                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pop(); // Dismiss spinner safely
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Database Error: ${firebaseError.message}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (error) {
                                  print('❌ General Error: ${error.toString()}');
                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pop(); // Dismiss spinner safely
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Execution Error: ${error.toString()}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C853),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.attach_money, size: 20),
                            label: const Text(
                              'Create Event & Pay ₹500',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build calculate revenue breakdown section
  Widget _buildRevenueRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF475569),
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF1E293B),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String labelText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        labelText,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Pure picker triggers instead of generic mocks
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }
}
