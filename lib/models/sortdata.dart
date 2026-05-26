class SlotData {
  final String time;
  final double? basePrice;
  double? discountPercentage;
  double? fixedDiscountPrice;

  SlotData({required this.time,  this.basePrice});
  bool get hasDiscount => discountPercentage != null || fixedDiscountPrice != null;

  double get finalPrice {
    if (discountPercentage != null) {
      return basePrice! * (1 - (discountPercentage! / 100));
    }
    if (fixedDiscountPrice != null) {
      return fixedDiscountPrice!;
    }
    return basePrice!;
  }
}