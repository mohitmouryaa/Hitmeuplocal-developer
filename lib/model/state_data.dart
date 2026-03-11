class StateListData {
  dynamic id;
  dynamic countryId;
  final String name;

  StateListData(
      {required this.id, required this.countryId, required this.name,});

  factory StateListData.fromJson(Map<String, dynamic> json) {
    return StateListData(
      id: json['id'],
      countryId: json['country_id'],
      name: json['name'] as String,
    );
  }
}
