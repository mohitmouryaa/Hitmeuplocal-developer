class OfferListData {
  var discount_type;
  var discount;


  OfferListData({required this.discount_type,required this.discount});

  factory OfferListData.fromJson(Map<String, dynamic> json) {
    return OfferListData(
        discount_type: json['discount_type'] , discount: json['discount']);
  }
}