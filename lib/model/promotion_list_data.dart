class PromotionListData {
  final dynamic promotionId;
  final dynamic id;
  final dynamic businessId;
  final String title;
  final String description;
  final dynamic categoryId;
  final dynamic distance;
  final dynamic businessDetail;
  final dynamic status;

  const PromotionListData({
    required this.promotionId,
    required this.id,
    required this.businessId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.distance,
    required this.businessDetail,
    required this.status,
  });

  factory PromotionListData.fromJson(Map<String, dynamic> json) {
    return PromotionListData(
      promotionId: json['promotion_id'],
      id: json['id'],
      businessId: json['business_id'],
      title: json['title'] as String,
      description: json['description'] as String,
      categoryId: json['category_id'],
      distance: json['distance'],
      businessDetail: json['business_detail'],
      status: json['status'],
    );
  }
}