
class StateListData {
  var id;
  var country_id;
  final String name;

  StateListData({required this.id, required this.country_id,required this.name});

  factory StateListData.fromJson(Map<String, dynamic> json) {
    return StateListData(
        id: json['id'], country_id: json['country_id'],name: json['name'] as String);
  }
}