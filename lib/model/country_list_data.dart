class CountryListData {
  var id;
  final String shortname;
  final String name;

  CountryListData({required this.id,required this.shortname, required this.name});

  factory CountryListData.fromJson(Map<String, dynamic> json) {
    return CountryListData(
        id: json['id'], shortname: json['shortname'] as String, name: json['name'] as String);
  }
}