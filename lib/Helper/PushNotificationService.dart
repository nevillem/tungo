// import 'dart:convert';
// import 'dart:io';
//
// import 'package:agritungotest/Provider/SettingProvider.dart';
// import 'package:agritungotest/Screen/Chat.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/http.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../Screen/Splash.dart';
// import '../Widgets/ProductDetail1.dart';
// import '../main.dart';
// import '../model/Section_Model.dart';
// import 'Constant.dart';
// import 'Session.dart';
// import 'String.dart';
//
// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
// FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//
//
// class PushNotificationService {
//   late BuildContext context;
//   final TabController tabController;
//
//   PushNotificationService({required this.context, required this.tabController});
//
//   Future initialise() async {
//     iOSPermission();
//     messaging.getToken().then((token) async {
//       print('token is $token');
//
//
//       SettingProvider settingsProvider =
//       Provider.of<SettingProvider>(context, listen: false);
//       if (settingsProvider.userId != null && settingsProvider.userId != '') {
//         _registerToken(token);
//       }
//     });
//
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('ic_launcher');
//     const IOSInitializationSettings initializationSettingsIOS =
//     IOSInitializationSettings();
//     const MacOSInitializationSettings initializationSettingsMacOS =
//     MacOSInitializationSettings();
//     const InitializationSettings initializationSettings =
//     InitializationSettings(
//         android: initializationSettingsAndroid,
//         iOS: initializationSettingsIOS,
//         macOS: initializationSettingsMacOS);
//
//     flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onSelectNotification: (String? payload) async {
//           if (payload != null) {
//             List<String> pay = payload.split(',');
//             if (pay[0] == 'products') {
//               getProduct(pay[1], 0, 0, true);
//             } else if (pay[0] == 'categories') {
//               Future.delayed(Duration.zero, () {
//                 tabController.animateTo(1);
//               });
//             } else if (pay[0] == 'wallet') {
//               // Navigator.push(context,
//               //     (CupertinoPageRoute(builder: (context) => const MyWallet())));
//             } else if (pay[0] == 'order') {
//               // Navigator.push(context,
//               //     (CupertinoPageRoute(builder: (context) => const MyOrder())));
//             } else if (pay[0] == 'ticket_message') {
//               // Navigator.push(
//               //   context,
//               //   CupertinoPageRoute(
//               //       builder: (context) => Chat(
//               //         id: pay[1],
//               //         status: '',
//               //       )),
//               // );
//             } else if (pay[0] == 'ticket_status') {
//               // Navigator.push(
//               //   context,
//               //   CupertinoPageRoute(
//               //     builder: (context) => const CustomerSupport(),
//               //   ),
//               // );
//             } else {
//               Navigator.push(
//                 context,
//                 CupertinoPageRoute(builder: (context) => const Splash()),
//               );
//             }
//           } else {
//             SharedPreferences prefs = await SharedPreferences.getInstance();
//             Navigator.push(
//               context,
//               CupertinoPageRoute(
//                   builder: (context) => MyApp(sharedPreferences: prefs)),
//             );
//           }
//         });
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//
//       print(message.data);
//       SettingProvider settingsProvider =
//       Provider.of<SettingProvider>(context, listen: false);
//
//       var data = message.notification!;
//
//       var title = data.title.toString();
//       var body = data.body.toString();
//       var image = message.data['image'] ?? '';
//
//       var type = message.data['type'] ?? '';
//       var id = '';
//       id = message.data['type_id'] ?? '';
//
//       if (type == 'ticket_status') {
//         // Navigator.push(context,
//         //     CupertinoPageRoute(builder: (context) => const CustomerSupport()));
//       } else if (type == 'ticket_message') {
//         if (CUR_TICK_ID == id) {
//           if (chatstreamdata != null) {
//             var parsedJson = json.decode(message.data['chat']);
//             parsedJson = parsedJson[0];
//
//             Map<String, dynamic> sendata = {
//               'id': parsedJson[ID],
//               'title': parsedJson[TITLE],
//               'message': parsedJson[MESSAGE],
//               'user_id': parsedJson[USER_ID],
//               'name': parsedJson[NAME],
//               'date_created': parsedJson[DATE_CREATED],
//               'attachments': parsedJson['attachments']
//             };
//             var chat = {};
//
//             chat['data'] = sendata;
//             if (parsedJson[USER_ID] != settingsProvider.userId) {
//               chatstreamdata!.sink.add(jsonEncode(chat));
//             }
//           }
//         } else {
//           if (image != null && image != 'null' && image != '') {
//             generateImageNotication(title, body, image, type, id);
//           } else {
//             generateSimpleNotication(title, body, type, id);
//           }
//         }
//       } else if (image != null && image != 'null' && image != '') {
//         generateImageNotication(title, body, image, type, id);
//       } else {
//         generateSimpleNotication(title, body, type, id);
//       }
//     });
//
//     messaging.getInitialMessage().then((RemoteMessage? message) async {
//
//       // bool back = await getPrefrenceBool(ISFROMBACK);
//       bool back = await Provider.of<SettingProvider>(context, listen: false)
//           .getPrefrenceBool(ISFROMBACK);
//
//
//       if (message != null && back) {
//         var type = message.data['type'] ?? '';
//         var id = '';
//         id = message.data['type_id'] ?? '';
//
//         if (type == 'products') {
//           getProduct(id, 0, 0, true);
//         } else if (type == 'categories') {
//           Future.delayed(Duration.zero, () {
//             tabController.animateTo(1);
//           });
//         } else if (type == 'wallet') {
//           // Navigator.push(context,
//           //     (CupertinoPageRoute(builder: (context) => const MyWallet())));
//         } else if (type == 'order') {
//           // Navigator.push(context,
//           //     (CupertinoPageRoute(builder: (context) => const MyOrder())));
//         } else if (type == 'ticket_message') {
//           // Navigator.push(
//           //   context,
//           //   CupertinoPageRoute(
//           //       builder: (context) => Chat(
//           //         id: id,
//           //         status: '',
//           //       )),
//           // );
//         } else if (type == 'ticket_status') {
//           // Navigator.push(
//           //     context,
//           //     CupertinoPageRoute(
//           //         builder: (context) => const CustomerSupport()));
//         } else {
//           Navigator.push(context,
//               (CupertinoPageRoute(builder: (context) => const Splash())));
//         }
//         Provider.of<SettingProvider>(context, listen: false)
//             .setPrefrenceBool(ISFROMBACK, false);
//       }
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       var type = message.data['type'] ?? '';
//       var id = '';
//
//       id = message.data['type_id'] ?? '';
//
//       if (type == 'products') {
//         getProduct(id, 0, 0, true);
//       } else if (type == 'categories') {
//         Future.delayed(Duration.zero, () {
//           tabController.animateTo(1);
//         });
//       } else if (type == 'wallet') {
//         // Navigator.push(context,
//         //     (CupertinoPageRoute(builder: (context) => const MyWallet())));
//       } else if (type == 'order') {
//         // Navigator.push(context,
//         //     (CupertinoPageRoute(builder: (context) => const MyOrder())));
//       } else if (type == 'ticket_message') {
//         // Navigator.push(
//         //   context,
//         //   CupertinoPageRoute(
//         //       builder: (context) => Chat(
//         //         id: id,
//         //         status: '',
//         //       )),
//         // );
//       } else if (type == 'ticket_status') {
//         // Navigator.push(
//         //     context,
//         //     CupertinoPageRoute(
//         //         builder: (context) => const CustomerSupport()));
//       } else {
//         Navigator.push(
//           context,
//           CupertinoPageRoute(
//               builder: (context) => MyApp(
//                 sharedPreferences: prefs,
//               )),
//         );
//       }
//       Provider.of<SettingProvider>(context, listen: false)
//           .setPrefrenceBool(ISFROMBACK, false);
//     });
//   }
//
//   void iOSPermission() async {
//     await messaging.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }
//
//   void _registerToken(String? token) async {
//     SettingProvider settingsProvider =
//     Provider.of<SettingProvider>(context, listen: false);
//     var parameter = {USER_ID: settingsProvider.userId, FCM_ID: token};
//
//     Response response =
//     await post(updateFcmApi, body: parameter, headers: headers)
//         .timeout(const Duration(seconds: timeOut));
//
//     var getdata = json.decode(response.body);
//   }
//
//   Future<void> getProduct(String id, int index, int secPos, bool list) async {
//     try {
//       var parameter = {
//         ID: id,
//       };
//
//       Response response =
//       await post(getProductApi, headers: headers, body: parameter)
//           .timeout(const Duration(seconds: timeOut));
//       var getdata = json.decode(response.body);
//       bool error = getdata['error'];
//       if (!error) {
//         var data = getdata['data'];
//
//         List<Product> items = [];
//
//         items = (data as List).map((data) => Product.fromJson(data)).toList();
//
//         Navigator.of(context).push(CupertinoPageRoute(
//             builder: (context) => ProductDetail1(
//               index: int.parse(id),
//               model: items[0],
//               secPos: secPos,
//               list: list,
//             )));
//       } else {}
//     } on Exception {}
//   }
// }
//
// Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
//
//   print(message.data);
//   setPrefrenceBool(ISFROMBACK, true);
//
//   return Future<void>.value();
// }
//
// Future<String> _downloadAndSaveImage(String url, String fileName) async {
//   var directory = await getApplicationDocumentsDirectory();
//   var filePath = '${directory.path}/$fileName';
//   var response = await http.get(Uri.parse(url));
//
//   var file = File(filePath);
//   await file.writeAsBytes(response.bodyBytes);
//   return filePath;
// }
//
// Future<void> generateImageNotication(
//     String title, String msg, String image, String type, String id) async {
//   var largeIconPath = await _downloadAndSaveImage(image, 'largeIcon');
//   var bigPicturePath = await _downloadAndSaveImage(image, 'bigPicture');
//   var bigPictureStyleInformation = BigPictureStyleInformation(
//       FilePathAndroidBitmap(bigPicturePath),
//       hideExpandedLargeIcon: true,
//       contentTitle: title,
//       htmlFormatContentTitle: true,
//       summaryText: msg,
//       htmlFormatSummaryText: true);
//   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'big text channel id', 'big text channel name',
//       channelDescription: 'big text channel description',
//       largeIcon: FilePathAndroidBitmap(largeIconPath),
//       styleInformation: bigPictureStyleInformation,
//       playSound: true);
//   var platformChannelSpecifics =
//   NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin
//       .show(0, title, msg, platformChannelSpecifics, payload: '$type,$id');
// }
//
// Future<void> generateSimpleNotication(
//     String title, String msg, String type, String id) async {
//   var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
//       'your channel id', 'your channel name',
//       channelDescription: 'your channel description',
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: 'ticker',
//       playSound: true);
//   var iosDetail = const IOSNotificationDetails();
//
//   var platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics, iOS: iosDetail);
//   await flutterLocalNotificationsPlugin
//       .show(0, title, msg, platformChannelSpecifics, payload: '$type,$id');
// }
