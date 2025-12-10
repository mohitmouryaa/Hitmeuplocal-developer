class NotificationListData {
  var id;
  var read;
  String title;
  String created_at;


  NotificationListData({required this.id,required this.read,required this.title,required this.created_at});

  factory NotificationListData.fromJson(Map<String, dynamic> json) {
    return NotificationListData(
        id: json['id'] , read: json['read'], title: json['title'] as String, created_at: json['created_at'] as String);
  }
}