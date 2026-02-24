class SubscriptionPlanListData {
  var id;
  String subscriptionId;
  final String name;
  var price;
  var validity;
  final String validity_unit;
  var planActive;


  SubscriptionPlanListData({required this.id,required this.subscriptionId,required this.name
    , required this.price, required this.validity, required this.validity_unit , required this.planActive,});

  factory SubscriptionPlanListData.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanListData(
        id: json['id'],subscriptionId : json['subscription_id'] as String ,name: json['name'] as String
        , price: json['price'],
        validity: json['validity'], validity_unit: json['validity_unit'] as String , planActive: json['plan_active'],);
  }
}