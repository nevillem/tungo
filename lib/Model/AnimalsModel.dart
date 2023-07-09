
class AnimalsModel {
  String id;
  String weight;
  String dateOfBirth;
  String height;
  String gender;
  String litres;
  String price;
  String notes;
  String pregancyStatus;
  String pregancyApproxPregancyTime;
  String broughtFrom;
  String broughtFromTime;
  String tagNumber;
  String stallno;
  String breed;
  String vaccine;
  String color;
  String vaccineDoneDate;
  String timestamp;
  String images;

  AnimalsModel({required this.id,
    required this.weight,
    required this.dateOfBirth,
    required this.height,
    required this.gender,
    required this.litres,
    required this.price,
    required this.notes,
    required this.pregancyStatus,
    required this.pregancyApproxPregancyTime,
    required this.broughtFrom,
    required this.broughtFromTime,
    required this.tagNumber,
    required this.stallno,
    required this.breed,
    required this.vaccine,
    required this.color,
    required this.vaccineDoneDate,
    required this.timestamp,
    required this.images});

  factory AnimalsModel.fromJson(Map<String, dynamic> json) {
    return AnimalsModel(
        id: json['id'],
        weight: json['weight'],
        dateOfBirth: json['dateOfBirth'],
        height: json['height'],
        gender: json['gender'],
        litres: json['litres'],
        price: json['price'],
        notes: json['notes'],
        pregancyStatus: json['pregancyStatus'],
        pregancyApproxPregancyTime: json['pregancyApproxPregancyTime'],
        broughtFrom: json['broughtFrom'],
        broughtFromTime: json['broughtFromTime'],
        tagNumber: json['tagNumber'],
        stallno: json['stallno'],
        breed: json['breed'],
        vaccine: json['vaccine'],
        color: json['color'],
        vaccineDoneDate: json['vaccineDoneDate'],
        timestamp: json['timestamp'],
        images: json['images']
    );
  }
}
