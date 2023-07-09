import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:agritungotest/Helper/String.dart';
import 'package:agritungotest/model/location_model.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// Future<Position> _getGeoLocationPosition() async {
//   bool serviceEnabled;
//   LocationPermission permission;
//
//   // Test if location services are enabled.
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     // Location services are not enabled don't continue
//     // accessing the position and request users of the
//     // App to enable the location services.
//     await Geolocator.openLocationSettings();
//     return Future.error('Location services are disabled.');
//   }
//
//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       // Permissions are denied, next time you could try
//       // requesting permissions again (this is also where
//       // Android's shouldShowRequestPermissionRationale
//       // returned true. According to Android guidelines
//       // your App should show an explanatory UI now.
//       return Future.error('Location permissions are denied');
//     }
//   }
//
//   if (permission == LocationPermission.deniedForever) {
//     // Permissions are denied forever, handle appropriately.
//     return Future.error(
//         'Location permissions are permanently denied, we cannot request permissions.');
//   }
//
//   // When we reach here, permissions are granted and we can
//   // continue accessing the position of the device.
//   return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
// }
Future _getLocation() async {
  var location = Location();

  if (!await location.serviceEnabled()) {
  if (!await location.requestService()) {
  return Future.error('Location services are disabled.');
  }
  }

  var permission = await location.hasPermission();
  if (permission == PermissionStatus.denied) {
  permission = await location.requestPermission();
  if (permission != PermissionStatus.granted) {
  return Future.error('Location permissions are denied');
  }
  }

  return await location.getLocation();
}

Future<LocationModel?> getLocationData() async {
  LocationModel? result;
  // Position position = await _getGeoLocationPosition();
  // List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
  /// Placemark place = placemarks[0];
  // print("latitude:${position.latitude}");
  // Placemark place = placemarks.first;
  // var Address= place.locality?.toLowerCase();
   var loc= await _getLocation();
  Map postdata = {
    LATITUDE: loc.longitude.toString(),
    LONGITUDE: loc.latitude.toString(),
  };
  print(postdata);
  var _json= utf8.encode(jsonEncode(postdata));
  try {
    final response = await http.post(weatherApi,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      },body:_json);
    print(response.body);
    if (response.statusCode == 201) {
      final item = json.decode(response.body);
      result = LocationModel.fromJson(item);
    } else {
      print("error");
    }
  } catch (e) {
    // log(e.toString());
    log("connection error!");
  }
  return result;
}