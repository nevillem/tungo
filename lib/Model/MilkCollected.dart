class MilkCollected {
  final String id;
  final String date;
  final double litres;
  final double price,totalprice;
  final String notes, tagno, transid;

  const MilkCollected({
    required this.id,
    required this.transid,
    required this.date,
    required this.litres,
    required this.price,
    required this.tagno,
    required this.totalprice,
    required this.notes,
  });

  factory MilkCollected.fromJson(Map<String, dynamic> json) {
    return MilkCollected(
      id: json['id'].toString(),
      transid: json['collect_transaction_id'].toString(),
      tagno:json['animal_tag'],
      date: json['collect_date'] as String,
      litres: double.parse(json['collect_litres'].toString()),
      price: double.parse(json['collect_price_litre'].toString()),
      totalprice: double.parse(json['collect_milk_total'].toString()),
      notes: json['collect_notes'],
    );
  }
}