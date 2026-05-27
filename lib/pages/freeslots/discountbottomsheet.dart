import 'package:booktoplay_webapp/models/freeslotdiscount.dart';
import 'package:booktoplay_webapp/service/firebaseservice.dart';
import 'package:flutter/material.dart';

class DiscountBottomSheet extends StatefulWidget {
  final String timeSlot;
  final DateTime selectedDate;

  const DiscountBottomSheet({
    super.key,
    required this.timeSlot,
    required this.selectedDate,
  });
  @override
  _DiscountBottomSheetState createState() => _DiscountBottomSheetState();
}

class _DiscountBottomSheetState extends State<DiscountBottomSheet> {
  bool isPercentageSelected = true; 
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      //=============== Handles keyboard avoiding when input is focused========================
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title displaying dynamic time slot
          Text(
            'Set Discount for ${widget.timeSlot}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          //=============== Toggle Tabs (Percentage vs Fixed Price)===========================
          Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  title: '% Percentage',
                  isSelected: isPercentageSelected,
                  onTap: () => setState(() => isPercentageSelected = true),
                ),
              ),
              Expanded(
                child: _buildTabButton(
                  title: r'$ Fixed Price',
                  isSelected: !isPercentageSelected,
                  onTap: () => setState(() => isPercentageSelected = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          //============== Input field and Action buttons==========================
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: isPercentageSelected ? 'Enter %' : 'Enter Amount',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              //==================APPLY BUTTON LOGIC==============================
              ElevatedButton(
                onPressed: () async {
                  if (_inputController.text.trim().isEmpty) return;

                  final value = double.tryParse(_inputController.text.trim());

                  if (value == null) return;

                  final discountModel = SlotDiscountModel(
                    id: '',
                    slotTime: widget.timeSlot,
                    discountType: isPercentageSelected ? 'percentage' : 'fixed',
                    discountValue: value,
                    selectedDate: widget.selectedDate,
                  );

                  await FirebaseService().saveSlotDiscount(discountModel);

                  Navigator.pop(context, {
                    'type': discountModel.discountType,
                    'value': value.toString(),
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                child: const Text('Apply'),
              ),
              //======================== CANCEL BUTTON LOGIC===========================
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ====================== helper widget to build the segmented toggle buttons==============================
  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
