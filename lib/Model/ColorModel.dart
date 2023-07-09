class ModelColors{
  String id;
  String colorName;
  ModelColors({required this.id, required this.colorName});

  factory ModelColors.fromJson(Map<String, dynamic> json) {
    return ModelColors(
      id: json['id'] as String,
      colorName: json['name'] as String,
    );
  }
}