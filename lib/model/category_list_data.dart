class CategoryListData {
  final dynamic id;
  final String categoryName;
  final dynamic parentId;

  CategoryListData({
    required this.id,
    required this.categoryName,
    required this.parentId,
  });

  factory CategoryListData.fromJson(Map<String, dynamic> json) {
    return CategoryListData(
      id: json['id'],
      categoryName: json['category_name'] as String,
      parentId: json['parent_id'],
    );
  }
}