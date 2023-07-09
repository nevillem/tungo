
import 'dart:async';
import 'dart:convert';

import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Helper/Constant.dart';
import 'package:agritungotest/Provider/UserProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';

import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Provider/SettingProvider.dart';
import '../Helper/AppBtn.dart';

class VerifyOtp extends StatefulWidget {
  final String? mobileNumber, countryCode, title;

  const VerifyOtp(
      {Key? key,
        required String this.mobileNumber,
        this.countryCode,
        this.title})
      : super(key: key);

  @override
  _MobileOTPState createState() => _MobileOTPState();
}
class _MobileOTPState extends State<VerifyOtp> with TickerProviderStateMixin {
  final dataKey = GlobalKey();
  String? password;
  String? otp;
  late Timer timer;
  bool enableResend = false;
  bool isCodeSent = false;
  FocusNode focusNode = FocusNode();
  late String _verificationId;
  String signature = '';
  bool _isNetworkAvail = true;
  final intRegex = RegExp(r'\d+', multiLine: true);
  String _otpCode = "";
  // bool isLoading=false;
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _textEditingController = new TextEditingController(text: "");
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool userPhoneNumber = false;

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
    _getSignatureCode();
    _startListeningSms();
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

    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (SECONDS_REMAINING != 0) {
        setState(() {
          SECONDS_REMAINING--;
        });
      }
      else {
        setState(() {
          enableResend = true;
        });
      }
    });
  }
  void _resendCode() {
    setState((){
      SECONDS_REMAINING = 60;
      enableResend = false;
      _startListeningSms();
    });
  }

  @override
  dispose(){
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    timer.cancel();
    _textEditingController.dispose();
    focusNode.dispose();
    buttonController!.dispose();
    super.dispose();
    SmsVerification.stopListening();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }


  /// get signature code
  _getSignatureCode() async {
    String? signature = await SmsVerification.getAppSignature();
    print("signature $signature");
  }
  /// listen sms
  _startListeningSms()  {
    SmsVerification.startListeningSms().then((message) {
      setState(() {
        _otpCode = SmsVerification.getCode(message, intRegex);
        _textEditingController.text = _otpCode;
        _onOtpCallBack(_otpCode, true);
      });
    });
  }
  _onOtpCallBack(String otpCode, bool isAutofill){
    setState(() {
      this._otpCode = otpCode;
      if (otpCode.length == CODE_LENGTH && isAutofill) {
        // _enableButton = false;
        otpVerification(otpCode);
        _playAnimation();
        checkNetwork();
      } else if (otpCode.length == CODE_LENGTH && !isAutofill) {
        // _enableButton = true;
      } else {
        // _enableButton = false;
      }
    });
  }

  void validateAndSubmit() async {
    _playAnimation();
      checkNetwork();
  }
  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      otpVerification(_textEditingController.text);
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

  Widget verifyBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: AppBtn(
            title: getTranslated(context, 'VERIFY_AND_PROCEED'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              validateAndSubmit();
            }),
      ),
    );
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
      ),
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      elevation: 1.0,
    ));
  }


  getImage() {
    return Expanded(
      flex: 4,
      child: Center(
        child: Image.asset('assets/images/logo.png'),
      ),
    );
  }


  monoVarifyText() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(
          top: 60.0,
        ),
        child: Text(getTranslated(context, 'MOBILE_NUMBER_VARIFICATION')!,
            style: Theme.of(context).textTheme.headline6!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
                fontSize: 23,
                letterSpacing: 0.8)));
  }

  otpText() {
    return Padding(
        padding: const EdgeInsetsDirectional.only(
          top: 13.0,
        ),
        child: Text(
          getTranslated(context, 'SENT_VERIFY_CODE_TO_NO_LBL')!,
          style: Theme.of(context).textTheme.subtitle2!.copyWith(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
            fontWeight: FontWeight.bold,
          ),
        ));
  }

  mobText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 5.0),
      child: Text(
        '+${widget.countryCode}-${widget.mobileNumber}',
        style: Theme.of(context).textTheme.subtitle2!.copyWith(
          color: Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget otpLayout() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 30),
      child: TextFieldPin(
          autoFocus: true,
          textController: _textEditingController,
          codeLength: CODE_LENGTH,
          alignment: MainAxisAlignment.center,
          defaultBoxSize: 45.0,
          margin: 10,
          selectedBoxSize: 45.0,
          defaultDecoration:_pinPutDecoration,
          textStyle: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 20, color:Theme.of(context).colorScheme.fontColor),
          selectedDecoration: _pinPutDecoration,
          onChange: (code) {
            _onOtpCallBack(code,false);
          }
      ),
    );
  }

  Widget resendText() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if(SECONDS_REMAINING !=0)
            Text(getTimeCounter("$SECONDS_REMAINING",
                getTranslated(context,'TIME_RESEND_OTP')!
                , getTranslated(context,'SECONDS')!).toString(),
              textAlign: TextAlign.right,
              // style: TextStyle(color: Colors.black, fontSize: 10),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold, fontSize: 10,)
            ),
          SizedBox(height: 10.0),
          Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                getTranslated(context, 'DIDNT_GET_THE_CODE')!,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor.withOpacity(0.5),
                    fontWeight: FontWeight.bold),
              ),
              InkWell(
                  onTap: enableResend ? _resendCode : null,
                  //     () async {
                  //   await buttonController!.reverse();
                  //   checkNetworkOtp();
                  // },
                  child: Text(
                    getTranslated(context, 'RESEND_OTP')!,
                    style:enableResend ?  Theme.of(context).textTheme.caption!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        // decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold):Theme.of(context).textTheme.caption!.copyWith(
                        color: Theme.of(context).colorScheme.black26,
                        // decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold),
                  ))
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.lightWhite.withOpacity(0.4),
      border: Border.all(color: Theme.of(context).primaryColor),
      borderRadius: BorderRadius.circular(8.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.white,
        body: Center(
          child: SingleChildScrollView(
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
                  monoVarifyText(),
                  otpText(),
                  mobText(),
                  otpLayout(),
                  resendText(),
                  verifyBtn(),
                  /* SizedBox(
                          height: deviceHeight! * 0.1,
                        ),
                        termAndPolicyTxt(),*/
                ],
              ),
            ),
          ),
        ));
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

  Future<void>  otpVerification(String otp)async {
  if (otp.length == 4) {
  SettingProvider settingsProvider =
  Provider.of<SettingProvider>(context, listen: false);
  String? isAccessToken = await settingsProvider.getPrefrence(ACCESS_TOKEN);
  sessionid = await settingsProvider.getPrefrence(SESSION_ID);
  refreshtoken = await settingsProvider.getPrefrence(REFRESH_TOKEN);
    // print(json);
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-type": "application/json",
      'Authorization': '$isAccessToken',
    };
  var data = {OTP: "$otp"};
  var finaldata= utf8.encode(jsonEncode(data));
  Response response =
  await post(verifyOtpApi, body: finaldata, headers: headers)
      .timeout(const Duration(seconds: timeOut));

  var getdata = json.decode(response.body);
  bool success = getdata['success'];
  String? msg = getdata['message'];
  await buttonController!.reverse();
  if (success==true) {
      var i = getdata['data'];
      firstname = i[FIRST_NAME];
      lastname = i[LAST_NAME];
      status = i[STATUS];
      mobile = i[MOBILENO];
      UserProvider userProvider =
      Provider.of<UserProvider>(context, listen: false);
      userProvider.setFirstName(firstname ?? '');
      userProvider.setLastName(lastname ?? '');
      userProvider.setStatus(status ?? '');
      SettingProvider settingProvider =
      Provider.of<SettingProvider>(context, listen: false);
      settingProvider.saveUserDetail(sessionid!, firstname,lastname, isAccessToken, refreshtoken, mobile, status,image, context);

      setSnackbar(getTranslated(context, 'OTPMSG')!);
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);

    }
    else{
      setSnackbar(getTranslated(context, 'OTPERROR')!);
    }

  } else {
  setSnackbar(getTranslated(context, 'ENTEROTP')!);
  }
  }

}