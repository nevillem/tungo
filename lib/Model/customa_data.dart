import 'dart:convert';
import 'package:http/http.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';

class Customer {
  final String id;
  final String customername;

  const Customer({
    required this.id, required this.customername,
  });

  static Customer fromJson(Map<String, dynamic> json) => Customer(
    customername: json['name'],
    id: json["id"],
  );
}

class CustomerApi{
  static Future<List<Customer>> getAnimalSuggestions(String query) async {
    var response = await get(getCustomers, headers: headers);
    if (response.statusCode == 200) {
      final List customers = json.decode(response.body)['data']['customers'];
      return customers.map((json) => Customer.fromJson(json)).where((customers) {
        final name = customers.customername.toLowerCase();
        final queryLower = query.toLowerCase();
        return name.contains(queryLower);
      }).toList();
    }
    else {
      // print(storage.getItem('access_token'));
      throw "failed, try again";
    }
  }
}