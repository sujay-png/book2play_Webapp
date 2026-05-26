import 'package:booktoplay_webapp/models/sortdata.dart';
import 'package:flutter/material.dart';

class Slotlist extends StatelessWidget {
  final SlotData slot;
  final void Function()? onTap;
  final void Function() onRemoveDiscount;

  // ADD THESE
  final bool isBooked;
  final String? bookedText;

  const Slotlist({
    super.key,
    required this.slot,
    required this.onTap,
    required this.onRemoveDiscount,

    // ADD THESE
    this.isBooked = false,
    this.bookedText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isBooked ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isBooked
              ? Colors.red.shade300
              : slot.hasDiscount
                  ? Colors.green.shade200
                  : Colors.black87,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isBooked
                ? Colors.red
                : slot.hasDiscount
                    ? Colors.orange.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  slot.time,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: slot.hasDiscount || isBooked
                        ? Colors.black87
                        : Colors.white,
                  ),
                ),

                // REMOVE BUTTON ONLY IF NOT BOOKED
                if (slot.hasDiscount && !isBooked)
                  GestureDetector(
                    onTap: onRemoveDiscount,
                    child: const Text(
                      'Remove',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // BOOKED UI
            if (isBooked) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  bookedText ?? "Slot Booked",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ] else ...[
              // NORMAL PRICE UI
              Row(
                children: [
                  if (slot.hasDiscount) ...[
                    Text(
                      "₹${slot.basePrice!.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  Text(
                    "₹${slot.finalPrice.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          slot.hasDiscount ? Colors.teal : Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (slot.hasDiscount)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    slot.discountPercentage != null
                        ? "${slot.discountPercentage!.toStringAsFixed(0)}% OFF"
                        : "SPECIAL OFF",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}