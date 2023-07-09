
import 'dart:async';
import 'dart:convert';

import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Helper/Constant.dart';
import 'package:agritungotest/Helper/Session.dart';
import 'package:agritungotest/Helper/SqliteData.dart';
import 'package:agritungotest/Helper/String.dart';
import 'package:agritungotest/Provider/FavoriteProvider.dart';
import 'package:agritungotest/Provider/SettingProvider.dart';
import 'package:agritungotest/Provider/UserProvider.dart';
import 'package:agritungotest/Helper/AppBtn.dart';
import 'package:country_code_picker/country_code.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';

import 'VerifyOtp.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<Login> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  FocusNode? passFocus, monoFocus = FocusNode();
  final Uri toLaunch =
  Uri(scheme: 'https', host: 'app.agritungo.com', path: 'terms');
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool visible = false;
  String? sessionid,
      mobile,
      refreshtoken,
      accesstoken,
      countrycode,
      countryName,
      firstname,
      lastname,
      mobileno,
      status,
      // city,
      // area,
      // pincode,
      // address,
      // latitude,
      // longitude,
      image;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;

  AnimationController? buttonController;
  var db = DatabaseHelper();
  bool isShowPass = true;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));
    // _getSignatureCode();
  }

  /// listen sms
  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    buttonController!.dispose();
    super.dispose();
  }
  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }
  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getLoginUser();
    } else {
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        await buttonController!.reverse();
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
      });
    }
  }
  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }
  setSnackbar(String msg, BuildContext context) {
    ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
      ),
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      elevation: 1.0,
    ));
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.only(top: kToolbarHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            noIntImage(),
            noIntText(context),
            noIntDec(context),
            AppBtn(
              title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();

                Future.delayed(const Duration(seconds: 2)).then(
                      (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                              builder: (BuildContext context) => super.widget));
                    } else {
                      await buttonController!.reverse();
                      if (mounted) {
                        setState(
                              () {},
                        );
                      }
                    }
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

    @override
  Widget build(BuildContext context) {

    return Scaffold(
    resizeToAvoidBottomInset: false,
    backgroundColor: Theme.of(context).colorScheme.white,
      key: _scaffoldKey,
      body: _isNetworkAvail
      ? SingleChildScrollView(
      padding: EdgeInsets.only(
      top: 23,
      left: 23,
      right: 23,
      bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
      key: _formkey,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      getLogo(),
      signInTxt(),
      signInSubTxt(),
      // setPass(),
      setCodeWithMono(),
      // setMobileNo(),
      loginBtn(),
      // setDontHaveAcc(),
        termAndPolicyTxt(),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.10,
        ),
      ],
      ),
      ),
      )
      : noInternet(context)
      );
  }

  Widget getLogo() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 60),
      child: Image.asset(
        'assets/images/logo.png',
        alignment: Alignment.center,
        height: 90,
        width: 90,
        fit: BoxFit.contain,
      ),
    );
  }
  signInTxt() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(
          top: 40.0,
        ),
        child: Text(
          getTranslated(context, 'WELCOME_ESHOP')!,
          style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 0.8),
        ));
  }
  signInSubTxt() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(
          top: 13.0,
        ),
        child: Text(
          getTranslated(context, 'INFO_FOR_LOGIN')!,
          style: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.38),
              fontWeight: FontWeight.bold),
        ));
  }

  Widget setCodeWithMono() {
    return Padding(
      padding: const EdgeInsets.only(top: 45),
      child: Container(
          height: 53,
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.lightWhite,
              borderRadius: BorderRadius.circular(10.0)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: setCountryCode(),
              ),
              Expanded(
                flex: 4,
                child: setMono(),
              )
            ],
          )),
    );
  }

  Widget setCountryCode() {
    double width = deviceWidth!;
    double height = deviceHeight! * 0.9;
    return CountryCodePicker(
        showCountryOnly: false,
        searchStyle: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
        ),
        flagWidth: 15,
        boxDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
        ),
        searchDecoration: InputDecoration(
          hintText: getTranslated(context, 'COUNTRY_CODE_LBL'),
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.fontColor),
          fillColor: Theme.of(context).colorScheme.fontColor,
        ),
        showOnlyCountryWhenClosed: false,
        initialSelection: 'UG',
        dialogSize: Size(width, height),
        alignLeft: true,
        textStyle: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.bold),
        onChanged: (CountryCode countryCode) {
          countrycode = countryCode.toString().replaceFirst('+', '');
          countryName = countryCode.name;
        },
        onInit: (code) {
          countrycode = code.toString().replaceFirst('+', '');
        });
  }
  Widget setMono() {
    return TextFormField(
        keyboardType: TextInputType.number,
        controller: mobileController,
        style: Theme.of(context).textTheme.subtitle2!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) => validateMob(
            val!,
            getTranslated(context, 'MOB_REQUIRED'),
            getTranslated(context, 'VALID_MOB')),
        onSaved: (String? value) {
          mobile = value;
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, 'MOBILEHINT_LBL'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: Theme.of(context).colorScheme.lightWhite),
          // ),
          // focusedBorder: UnderlineInputBorder(
          //   borderSide: const BorderSide(color: colors.primary),
          //   borderRadius: BorderRadius.circular(7.0),
          // ),
          border: InputBorder.none,
          // enabledBorder: UnderlineInputBorder(
          //   borderSide:
          //   BorderSide(color: Theme.of(context).colorScheme.lightWhite),
          // ),
        ));
  }
  loginBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: AppBtn(
          title: getTranslated(context, 'SIGNIN_LBL'),
          btnAnim: buttonSqueezeanimation,
          btnCntrl: buttonController,
          onBtnSelected: () async {
            validateAndSubmit();
          },
        ),
      ),
    );
  }

  Widget termAndPolicyTxt() {
    // return widget.title == getTranslated(context, 'SEND_OTP_TITLE')?
    return SizedBox(
      height: deviceHeight! * 0.18,
      width: double.maxFinite,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(getTranslated(context, 'CONTINUE_AGREE_LBL')!,
              style: Theme.of(context).textTheme.caption!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal)),
          const SizedBox(
            height: 3.0,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                    onTap: () {
                      // Navigator.push(
                      //     context,
                      //     CupertinoPageRoute(
                      //         builder: (context) => PrivacyPolicy(
                      //           title: getTranslated(context, 'TERM'),
                      //         )));
                      _launchInBrowser(toLaunch);
                    },
                    child: Text(
                      getTranslated(context, 'TERMS_SERVICE_LBL')!,
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(
                          color:
                          Theme.of(context).colorScheme.fontColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.normal),
                      overflow: TextOverflow.clip,
                      softWrap: true,
                      maxLines: 1,
                    )),
                const SizedBox(
                  width: 5.0,
                ),
                Text(
                  getTranslated(context, 'AND_LBL')!,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.normal),
                ),
                const SizedBox(
                  width: 5.0,
                ),
                InkWell(
                    onTap: () {
                      // Navigator.push(
                      //     context,
                      //     CupertinoPageRoute(
                      //         builder: (context) => PrivacyPolicy(
                      //           title:
                      //           getTranslated(context, 'PRIVACY'),
                      //         )));
                      _launchInBrowser(toLaunch);
                    },
                    child: Text(
                      getTranslated(context, 'PRIVACY')!,
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(
                          color:
                          Theme.of(context).colorScheme.fontColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.normal),
                      overflow: TextOverflow.clip,
                      softWrap: true,
                      maxLines: 1,
                    )),
              ]),
        ],
      ),
    );
        // : const SizedBox();
  }
  Future<void> getLoginUser() async {
    var data = {USERNAME: "$countrycode$mobile"};
    var phone ="$mobile";
    var finaldata= utf8.encode(jsonEncode(data));
    Response response =
    await post(getUserLoginApi, body: finaldata, headers: headers)
        .timeout(const Duration(seconds: timeOut));

    var getdata = json.decode(response.body);
    bool success = getdata['success'];
    String? msg = getdata['message'];
    await buttonController!.reverse();
    if (success==true) {
      setSnackbar("success", context);
      var i = getdata['data'];
      sessionid = i[SESSION_ID].toString();
      firstname = i[FIRST_NAME];
      lastname = i[LAST_NAME];
      accesstoken = i[ACCESS_TOKEN];
      refreshtoken = i[REFRESH_TOKEN];
      // status = i[STATUS];
      mobile = i[MOBILE];

      image = i[IMAGE];

      CUR_USERID = sessionid;
      // CUR_USERNAME = username;
      UserProvider userProvider =
      Provider.of<UserProvider>(context, listen: false);
      userProvider.setUserId(sessionid ?? '');
      userProvider.setAccessToken(accesstoken ?? '');
      userProvider.setRefreshToken(refreshtoken ?? '');
      userProvider.setStatus(status ?? '');
      userProvider.setMobile(mobile ?? '');
      userProvider.setProfilePic(image ?? '');

      SettingProvider settingProvider =
      Provider.of<SettingProvider>(context, listen: false);
      settingProvider.saveUserDetail(sessionid!, firstname,lastname, accesstoken, refreshtoken, mobile, status,image, context);

      Future.delayed(const Duration(seconds: 1)).then((_) {
        Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
                builder: (context) => VerifyOtp(
                  mobileNumber: phone!,
                  countryCode: countrycode,
                  title: getTranslated(context, 'SEND_OTP_TITLE'),
                )));
      });
    } else {
      await buttonController!.reverse();
      setSnackbar(msg!, context);
    }
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }
}


