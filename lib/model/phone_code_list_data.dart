class PhoneCodeListData {
  var id;
  final String name;
  var phonecode;

  PhoneCodeListData({required this.id,required this.name, required this.phonecode});

  factory PhoneCodeListData.fromJson(Map<String, dynamic> json) {
    return PhoneCodeListData(
        id: json['id'], name: json['name'] as String, phonecode: json['phonecode']);
  }
}