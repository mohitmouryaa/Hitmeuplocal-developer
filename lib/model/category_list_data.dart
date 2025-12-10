class CategoryListData {
  var id;
  final String category_name;
  var parent_id;


  CategoryListData({required this.id,required this.category_name
    ,required this.parent_id});

  factory CategoryListData.fromJson(Map<String, dynamic> json) {
    return CategoryListData(
        id: json['id'],category_name: json['category_name'] as String
        , parent_id: json['parent_id']);
  }
}