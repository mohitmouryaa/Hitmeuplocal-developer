class NotificationListData {
  dynamic id;
  dynamic read;
  String title;
  String createdAt;

  NotificationListData({
    required this.id,
    required this.read,
    required this.title,
    required this.createdAt,
  });

  factory NotificationListData.fromJson(Map<String, dynamic> json) {
    return NotificationListData(
      id: json['id'],
      read: json['read'],
      title: json['title'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}
