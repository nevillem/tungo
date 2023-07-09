import 'dart:async';

import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Helper/Session.dart';
import 'package:agritungotest/Helper/String.dart';
import 'package:agritungotest/Provider/SettingProvider.dart';
import 'package:agritungotest/Screen/Login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    super.initState();
    startTime();
  }
  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: back(),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/splashlogo.svg',
                width: 150,
                height: 150,
              ),
            ),
          ),
          Image.asset(
            'assets/images/doodle.png',
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
        ],
      ),
    );
  }
  startTime() async {
    var duration = const Duration(seconds: 2);
    return Timer(duration, navigationPage);
  }
  Future<void> navigationPage() async {
    SettingProvider settingsProvider =
    Provider.of<SettingProvider>(context, listen: false);
    String? isAccessToken = await settingsProvider.getPrefrence(ACCESS_TOKEN);
    String? isStatus = await settingsProvider.getPrefrence(STATUS);
    String? fname = await settingsProvider.getPrefrence(FIRST_NAME);
    print(isAccessToken);
    if ((isAccessToken !=null) && (isStatus !='')&& (isStatus !=null)&& (isStatus != 'inactive')) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => const Login(),
          ));
    }
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.black),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ));
  }

  @override
  void dispose() {
    //  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }
}
