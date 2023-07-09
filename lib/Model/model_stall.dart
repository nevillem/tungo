
import 'dart:convert';


class ModelStall{
  String id;
  String stallName;
  ModelStall({required this.id, required this.stallName});

  factory ModelStall.fromJson(Map<String, dynamic> json) {
    return ModelStall(
      id: json['id'] as String,
      stallName: json['name'] as String,

    );
  }
}

