class DoctorCategory {
  final String categoryId;
  final String categoryName;
  final String description;

  DoctorCategory({
    required this.categoryId,
    required this.categoryName,
    required this.description,
  });

  factory DoctorCategory.fromMap(Map<String, dynamic> data) {
    return DoctorCategory(
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'description': description,
    };
  }
}
