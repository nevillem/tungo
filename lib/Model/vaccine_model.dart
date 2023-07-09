class VaccinationModel{
  String id, period;
  String vaccineNname, repeatVacine, doze,notes;
  VaccinationModel({required this.id, required this.period, required this.repeatVacine, required this.vaccineNname,
  required this.doze, required this.notes,});
  factory VaccinationModel.fromJson(Map<String, dynamic> json) {
    return VaccinationModel(
      id: json['id'] as String,
      period: json['period'] as String,
      vaccineNname: json['name'] as String,
      repeatVacine: json['repeat'] as String,
      notes: json['notes']??"",
      doze: json['dose'] as String,
    );
  }
}