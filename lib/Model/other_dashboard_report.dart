
// class OtherDahboard {
//   Gender gender;
//   MilkCollected milkCollected;
//
//   OtherDahboard({required this.gender, required this.milkCollected});
//
//   factory OtherDahboard.fromJson(Map<String, dynamic> json) {
//     return OtherDahboard(
//         gender: Gender.fromJson(json['gender']),
//         milkCollected: MilkCollected.fromJson(json['milkCollected']),
//     );
//   }
// }
class Gender {
  String? male;
  String? female;
  int? total;

  Gender({
    required this.male, required this.female, required this.total
  });

  factory Gender.fromJson(Map<String, dynamic> json) {
    return Gender(
      male :json['male'],
      female :json['female'],
      total : json['total'],
    );
  }
}

class MilkCollected {
  int? total;

  MilkCollected({required this.total});

  factory MilkCollected.fromJson(Map<String, dynamic> json) {
    return MilkCollected(
        total: json['total']
    );
  }
}