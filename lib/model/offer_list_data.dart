class OfferListData {
  final dynamic discountType;
  final dynamic discount;

  OfferListData({required this.discountType, required this.discount});

  factory OfferListData.fromJson(Map<String, dynamic> json) {
    return OfferListData(
      discountType: json['discount_type'],
      discount: json['discount'],
    );
  }
}