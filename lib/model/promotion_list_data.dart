class PromotionListData {
  var promotion_id;
  var id;
  var business_id;
  final String title;
  final String description;
  var category_id;
  var distance;
  var business_detail;
  var status;


  PromotionListData({required this.promotion_id,required this.id,required this.business_id,
    required this.title, required this.description, required this.category_id, required this.distance, required this.business_detail, required this.status});

  factory PromotionListData.fromJson(Map<String, dynamic> json) {
    return PromotionListData(
        promotion_id: json['promotion_id'],
        id: json['id'],
        business_id: json['business_id']
        , title: json['title'] as String,
        description: json['description'] as String,
      category_id: json['category_id'],
      distance: json['distance'],
      business_detail: json['business_detail'],
      status: json['status'],
    );
  }
}