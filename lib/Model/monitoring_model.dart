class MonitoringModel{
  String id;
  String? monitoringcategory;
 MonitoringModel({required this.id, this.monitoringcategory});

  factory MonitoringModel.fromJson(Map<String, dynamic> json) {
    return MonitoringModel(
      id: json['id'] as String,
      monitoringcategory: json['name']as String,
    );
  }
}



