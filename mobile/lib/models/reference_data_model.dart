class ReferenceDataModel {
  final List<String> categories;
  final List<String> targetAudiences;

  ReferenceDataModel({
    required this.categories,
    required this.targetAudiences,
  });

  factory ReferenceDataModel.fromJson(Map<String, dynamic> json) {
    return ReferenceDataModel(
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      targetAudiences: (json['targetAudiences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}