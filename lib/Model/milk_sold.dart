class MilkSold {
  final String id;
  final String transactionid,date;
  final double litres;
  final double price,paid;
  Customerdata customerdata;

  MilkSold({
    required this.id,
    required this.transactionid,
    required this.date,
    required this.litres,
    required this.price,
    required this.paid,
    required this.customerdata,
    // required this.notes,
  });

  factory MilkSold.fromJson(Map<String, dynamic> json) {
    return MilkSold(
      id: json['id'],
      transactionid: json['transactionid'],
      date: json['date'] as String,
      litres: double.parse(json['litres'].toString()),
      price: double.parse(json['unitprice'].toString()),
      paid: double.parse(json['paid'].toString()),
      customerdata: Customerdata.fromJson(json['customerdata']),
    );
  }
}
class Customerdata {
  String name;
  String contact;
  String email;

  Customerdata({
    required this.name, required this.contact, required this.email
  });

  factory Customerdata.fromJson(Map<String, dynamic> json) {
    return Customerdata(
      name :json['name'],
      contact :json['contact'],
      email : json['email'],
    );
  }
}



