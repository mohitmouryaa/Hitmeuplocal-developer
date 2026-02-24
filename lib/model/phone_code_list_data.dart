class PhoneCodeListData {
  final int id;
  final String name;
  final String phonecode;

  PhoneCodeListData({required this.id, required this.name, required this.phonecode});

  factory PhoneCodeListData.fromJson(Map<String, dynamic> json) {
    return PhoneCodeListData(
      id: json['id'] as int,
      name: json['name'] as String,
      phonecode: json['phonecode'].toString(),
    );
  }
}