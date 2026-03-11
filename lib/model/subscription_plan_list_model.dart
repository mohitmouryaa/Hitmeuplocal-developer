class SubscriptionPlanListData {
  final dynamic id;
  final String subscriptionId;
  final String name;
  final dynamic price;
  final dynamic validity;
  final String validityUnit;
  final dynamic planActive;

  SubscriptionPlanListData({
    required this.id,
    required this.subscriptionId,
    required this.name,
    required this.price,
    required this.validity,
    required this.validityUnit,
    required this.planActive,
  });

  factory SubscriptionPlanListData.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanListData(
      id: json['id'],
      subscriptionId: json['subscription_id'] as String,
      name: json['name'] as String,
      price: json['price'],
      validity: json['validity'],
      validityUnit: json['validity_unit'] as String,
      planActive: json['plan_active'],
    );
  }
}