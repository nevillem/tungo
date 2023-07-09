class BreedModel{
  String id;
  String breedName;
  BreedModel({required this.id, required this.breedName});

  factory BreedModel.fromJson(Map<String, dynamic> json) {
    return BreedModel(
      id: json['id'] as String,
      breedName: json['name']as String,
    );
  }
}