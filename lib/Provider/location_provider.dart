
import 'package:agritungotest/Api_services/location_service.dart';
import 'package:agritungotest/model/location_model.dart';
import 'package:flutter/cupertino.dart';

class WeatherProvider extends ChangeNotifier {
  LocationModel? post;
  bool loading = false;

  getPostData() async {
    loading = true;
    post = (await getLocationData())!;
    loading = false;

    notifyListeners();
  }
}