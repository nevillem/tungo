import 'dart:convert';
import 'package:http/http.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';

class AnimalTag {
  final String id;
  final String tagNumber;

  const AnimalTag({
    required this.id, required this.tagNumber,
  });

  static AnimalTag fromJson(Map<String, dynamic> json) => AnimalTag(
    tagNumber: json['tagNumber'],
    id: json["id"],
  );
}

class AnimalApi{
  static Future<List<AnimalTag>> getAnimalSuggestions(String query) async {
    var response = await get(saveanimalsApi, headers: headers);
    if (response.statusCode == 200) {
      final List animals = json.decode(response.body)['data']['animals'];
      return animals.map((json) => AnimalTag.fromJson(json)).where((animals) {
        final nameLower = animals.tagNumber.toLowerCase();
        final queryLower = query.toLowerCase();
        return nameLower.contains(queryLower);
      }).toList();
    }
    else {
      // print(storage.getItem('access_token'));
      throw "try again";
    }
  }
}