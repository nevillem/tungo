import 'dart:convert';

List<IncomeModel> incomeModelFromJson(String str) => List<IncomeModel>.from(
    json.decode(str).map((x) => IncomeModel.fromJson(x)));

String incomeModelToJson(List<IncomeModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
class IncomeModel {
  int income;
  String month;

  IncomeModel({required this.income, required this.month});

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
    income:json['income'],
    month:json['month']
    );
  }

  Map<String, dynamic> toJson() =>
      {
        "income": this.income,
        "month": this.month,

  };
}

// class IncomeModel{
//   String month;
//   int count;
//   IncomeModel({
//     required this.month,
//     required this.count,
//   });
//   factory IncomeModel.fromJson(Map<String, dynamic> json) => IncomeModel(
//       month: json['month'],
//       count:double.parse(json['income']).toInt(),
//   );
//   Map<String, dynamic> toJson() =>
//       {
//         "name": month,
//         "count": count.toString(),
//
//       };
// }
// class IncomeModel{
//   String month;
//   int count;
//   List<Incomes>? incomes;
//   List<String> incomeMonths;
//   // List<Null> expenses;
//   // List<Null> expenseMonths;
//   Gender gender;
//   MilkCollected milkCollected;
//   IncomeModel({
//     required this.month,
//     required this.count,
//     // required this.incomes,
//     required this.incomeMonths,
//     // required this.expenses,
//     // required this.expenseMonths,
//     required this.gender,
//     required this.milkCollected
//   });
//   factory IncomeModel.fromJson(Map<String, dynamic> json) => IncomeModel(
//       month: json['month'],
//       count: json['income'],
//       // incomes: json['incomes'].forEach((v) {
//       //   incomes!.add(Incomes.fromJson(v));
//       // }),
//       incomeMonths: [],
//       // expenses: [],
//       // expenseMonths: [],
//       gender: Gender.fromJson(json['gender']),
//       milkCollected: MilkCollected.fromJson(json['gender']),
//   );
//   Map<String, dynamic> toJson() =>
//       {
//         "name": month,
//         "count": count,
//
//       };
// }
