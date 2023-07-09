
import 'dart:async';
import 'dart:convert';

import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Screen/Add_Address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Provider/SettingProvider.dart';
import '../Provider/UserProvider.dart';
import 'Dashboard.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateUserProfile();
  }
}

class StateUserProfile extends State<UserProfile> with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _firstname = TextEditingController();
  final _lastname = TextEditingController();
  final _telphone = TextEditingController();
  final _nin = TextEditingController();
  final _dob = TextEditingController();
  final _landsize = TextEditingController();
  final _familypop = TextEditingController();
  final _village = TextEditingController();
  bool checkedDefault = false;
  FocusNode? fnameFocus,lnameFocus,lVillageFocus,villageFocus,
      monoFocus,fmonoFocus,addFocus,dobFocus,ldobFocus,
      almonoFocus,addNinFocus,NinFocus,addLSizeFocus, lSizeFocus,
      familyPopFocus, familyPFocus,addCountryFocus,addRegionFocus,addDistrictFocus;
  int currentIndex = 0;
  String? userphone,fname,lname,mobile,ninNumber,landsize,familypopulation;
  String? _myGender,_countrySelection,_myRegions,_mydistrict,_myCounties,dob,
      _mysubCounties,_myParish,village;
  bool _isProgress = false;
  final List<Map> _selectGender = [{"gender":"Male"}, {"gender":"Female"}];
  List<Map> _myCountry = [{"id":1,"name":"Uganda"}];
  String? userfirstname,userlastname,usermobile,status,refresh, image, accesstoken,sessionid;
  @override
  void initState() {
    // TODO: implement initState
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
  }
  @override
  void dispose() {
    buttonController!.dispose();
    _firstname?.dispose();
    _lastname?.dispose();
    _nin?.dispose();
    _dob?.dispose();
    _landsize?.dispose();
    _familypop?.dispose();
    _village!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();
              Future.delayed(const Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                          builder: (BuildContext context) => super.widget));
                } else {
                  await buttonController!.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      // backgroundColor: const Color(0xFFF2F2F2),
      appBar: getSimpleAppBar(getTranslated(context, 'PROFILE_LBL')!, context),
      body: _isNetworkAvail ? _showContent() : noInternet(context),
    );
  }

  void backPress() async {
      setState(() {
        currentIndex=0;
      });
  }
  void validateAndCompleteForm() async {
    if (validateAndContinue()) {
     setState(() {
       currentIndex=1;
     });
    }
  }
  bool validateAndContinue() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      if (currentIndex == 0) {
        if (_myGender == null || _myGender!.isEmpty) {
          setSnackbar(getTranslated(context, 'FIELD_REQUIRED')!);
        } else {
          return true;
        }
      }
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate() && currentIndex==1) {
      if (_countrySelection == null || _countrySelection!.isEmpty) {
        setSnackbar(getTranslated(context, 'FIELD_REQUIRED')!);
      }
      else if (_myRegions == null || _myRegions!.isEmpty) {
        setSnackbar(getTranslated(context, 'FIELD_REQUIRED')!);
      }
      else if (_mydistrict == null || _mydistrict!.isEmpty) {
        setSnackbar(getTranslated(context, 'FIELD_REQUIRED')!);
      }
      else if (_myCounties == null || _myCounties!.isEmpty) {
        setSnackbar(getTranslated(context, 'FIELD_REQUIRED')!);
      }
            else if (_mysubCounties == null || _mysubCounties!.isEmpty) {
        setSnackbar(getTranslated(context, 'FIELD_REQUIRED')!);
      }
       else if (_myParish == null || _myParish!.isEmpty) {
        setSnackbar(getTranslated(context, 'FIELD_REQUIRED')!);
      }

      else {
        return true;
      }
    }
    return false;
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      completeProfile();
      // _getStateList();
      // _getDistrict();
      // _getCounties();
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
            (_) async {
          if (mounted) {
            setState(
                  () {
                _isNetworkAvail = false;
              },
            );
          }
          await buttonController!.reverse();
        },
      );
    }
  }


  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(color: colors.primary),
        ),
        backgroundColor: Theme.of(context).colorScheme.white,
        elevation: 1.0,
      ),
    );
  }
  defaultAdd() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: SwitchListTile(
        value: checkedDefault,
        activeColor: Theme.of(context).colorScheme.secondary,
        dense: true,
        onChanged: (newValue) {
          if (mounted) {
            setState(
                  () {
                checkedDefault = newValue;
              },
            );
          }
        },
        title: Text(
          getTranslated(context, 'DEFAULT_ADD')!,
          style: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.lightBlack,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  _showContent() {
    return Form(
        key: _formkey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: <Widget>[
                      currentIndex == 0 ?setUserName():Container(),
                      currentIndex == 0 ?setLastName():Container(),
                      // currentIndex == 0 ?setMobileNo():Container(),
                      currentIndex == 0 ?setNationIdentityNumber():Container(),
                      currentIndex == 0 ?setGender():Container(),
                      currentIndex == 0 ?setDOB():Container(),
                      currentIndex == 0 ?setLandSize():Container(),
                      currentIndex == 0 ?setFamilyPopullation():Container(),
                      currentIndex == 1 ?setCountry():Container(),
                      currentIndex == 1 ?setRegion():Container(),
                      currentIndex == 1 ?setDistrict():Container(),
                      currentIndex == 1 ?setCounties():Container(),
                      currentIndex == 1 ?setSubCounty():Container(),
                      currentIndex == 1 ?setParish():Container(),
                      currentIndex == 1 ?setVillage():Container(),
                      // setStateField(),
                      // setCountry(),
                      // typeOfAddress(),
                      // defaultAdd(),
                      // addBtn(),
                    ],
                  ),
                ),
              ),
            ),
            currentIndex == 1 ? Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  currentIndex == 1 ?Expanded(
                    flex: 5,
                    child: backButton(getTranslated(context, 'BACK_LBL')!, () {
                      backPress();
                    }),
                  ):Container(),
                  SizedBox(width: 10,),
                  currentIndex == 1 ?Expanded(
                    flex: 5,
                    child: AppBtn(
                      title: getTranslated(context, 'SAVE_LBL'),
                      btnAnim: buttonSqueezeanimation,
                      btnCntrl: buttonController,
                      onBtnSelected: () async {
                        validateAndSubmit();
                      },
                    ),
                  ):Container()
                ],
              ),
            ):Container(),

            currentIndex == 0 ?nextButton(getTranslated(context, 'NEXT_LBL')!, () {
              validateAndCompleteForm();
            }):Container(),
          ],
        ));
  }
  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
  setUserName() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            focusNode: fnameFocus,
            controller: _firstname,
            textCapitalization: TextCapitalization.words,
            validator: (val) => validateUserName(
                val!,
                getTranslated(context, 'FNAME_REQUIRED'),
                getTranslated(context, 'FNAME_LENGTH')),
            onSaved: (String? value) {
              fname = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, fnameFocus!, monoFocus);
            },
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'FNAME_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'FNAME_LBL'),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
  setLastName() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            focusNode: lnameFocus,
            controller: _lastname,
            textCapitalization: TextCapitalization.words,
            validator: (val) => validateUserName(
                val!,
                getTranslated(context, 'LNAME_REQUIRED'),
                getTranslated(context, 'LNAME_LENGTH')),
            onSaved: (String? value) {
              lname = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, lnameFocus!, fmonoFocus);
            },
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'LNAME_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'LNAME_LBL'),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  setMobileNo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: _telphone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            focusNode: addFocus,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            validator: (val) => validateMob(
                val!,
                getTranslated(context, 'MOB_REQUIRED'),
                getTranslated(context, 'VALID_MOB')),
            onSaved: (String? value) {
              mobile = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, addFocus!, almonoFocus);
            },
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'MOBILEHINT_LBL')!),
                fillColor: Theme.of(context).colorScheme.white,
                isDense: true,
                hintText: getTranslated(context, 'MOBILEHINT_LBL'),
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }

  setNationIdentityNumber() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z 0-9]')),
            ],
            maxLength: 14,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            focusNode: addNinFocus,
            controller: _nin,
            validator: (val) => validateNin(
              val!,
              getTranslated(context, 'NIN_REQUIRED'),
              getTranslated(context, 'NIN_LENGTH'),
            ),
            onSaved: (String? value) {
              ninNumber = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, addNinFocus!, NinFocus);
            },
            decoration: InputDecoration(
              counterText: '',
              label: Text(getTranslated(context, 'NIN_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'NIN_LBL'),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
 setGender() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: DropdownButtonFormField<String>(
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            focusNode: addNinFocus,
            validator: (value) {
              if (value ==null) {
                return getTranslated(context, 'GENDER_REQUIRED');
              } else
                return null;
            },
            // getTranslated(context, 'GENDER_REQUIRED')
            value: _myGender,
            onChanged: (String? newValue) {
              setState(() {
                _myGender = newValue;
              });
              // print (_countrySelection);
            },
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'GENDER_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'GENDER_LBL'),
              border: InputBorder.none,
            ),
            items: _selectGender.map((Map map) {
              return DropdownMenuItem<String>(
                value: map["gender"].toString(),
                child: new Text(
                  map["gender"],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  setDOB() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            focusNode: dobFocus,
            controller: _dob,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context, initialDate: DateTime(2010),
                  firstDate: DateTime(1945), //DateTime.now() - not to allow to choose before today.
                  lastDate: DateTime(2010),
           builder:(context, child) {
             return Theme(
                 data: ThemeData.dark().copyWith(
                 colorScheme: const ColorScheme.dark(
                 onPrimary: Colors.black, // selected text color
                 onSurface: Colors.amberAccent, // default text color
                 primary: Colors.amberAccent // circle color
             ),
                     dialogBackgroundColor: Colors.black54,
                     textButtonTheme: TextButtonThemeData(
                         style: TextButton.styleFrom(
                             textStyle: const TextStyle(
                                 color: Colors.amber,
                                 fontWeight: FontWeight.normal,
                                 fontSize: 12,
                                 fontFamily: 'Quicksand'),
                             primary: Colors.amber, // color of button's letters
                             backgroundColor: Colors.black54, // Background color
                             shape: RoundedRectangleBorder(
                                 side: const BorderSide(
                                     color: Colors.transparent,
                                     width: 1,
                                     style: BorderStyle.solid),
                                 borderRadius: BorderRadius.circular(50))))
             ),

           child: child!,);
           },
              );

              if(pickedDate != null ){
                print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
                String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                print(formattedDate); //formatted date output using intl package =>  2021-03-16
                //you can implement different kind of Date Format here according to your requirement

                setState(() {
                  _dob.text = formattedDate; //set output date to TextField value.
                });
              }else{
                print("Date is not selected");
              }
            },
            validator: (val) => validateUserName(
                val!,
                getTranslated(context, 'DOB_REQUIRED'),
                getTranslated(context, 'DOB_LENGTH')),
            onSaved: (String? value) {
              dob = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, dobFocus!, ldobFocus);
            },
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'DOB_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'DOB_LBL'),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  setLandSize() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: _landsize,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            focusNode: addLSizeFocus,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            validator: (val) => validateFqmilyPop(
                val!,
                getTranslated(context, 'LANDSIZE_REQUIRED'),
            ),
            onSaved: (String? value) {
              landsize = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, addLSizeFocus!, lSizeFocus);
            },
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'LANDSIZE_LBL')!),
                fillColor: Theme.of(context).colorScheme.white,
                isDense: true,
                hintText: getTranslated(context, 'LANDSIZE_LBL'),
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }
  setFamilyPopullation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: _familypop,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            focusNode: familyPopFocus,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            validator: (val) => validateFqmilyPop(
                val!,
                getTranslated(context, 'FAMILY_POPULATION_REQUIRED'),
            ),
            onSaved: (String? value) {
              familypopulation = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, familyPopFocus!, familyPFocus);
            },
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'FAMILY_POPULATION_LBL')!),
                fillColor: Theme.of(context).colorScheme.white,
                isDense: true,
                hintText: getTranslated(context, 'FAMILY_POPULATION_LBL'),
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }
  setCountry() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: DropdownButtonFormField<String>(
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            focusNode: addCountryFocus,
            validator: (value) {
              if (value ==null) {
                return getTranslated(context, 'FIELD_REQUIRED');
              } else
                return null;
            },
            value: _countrySelection,
            onChanged: (String? newValue) {
              setState(() {
                _countrySelection = newValue;
                _myRegions=null;
                _getStateList();
              });

              // print (_countrySelection);
            },
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'COUNTRIES_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'COUNTRIES_LBL'),
              border: InputBorder.none,
            ),
            items: _myCountry.map((Map map) {
              return new DropdownMenuItem<String>(
                value: map["id"].toString(),
                child: new Text(
                  map["name"],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  setRegion() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: DropdownButtonFormField<String>(
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            focusNode: addRegionFocus,
            validator: (value) {
              if (value ==null) {
                return getTranslated(context, 'FIELD_REQUIRED');
              } else
                return null;
            },
            value: _myRegions,
            onChanged: (String? newValue) {
              setState(() {
                _myRegions = newValue;
                _mydistrict=null;
                _getDistrict();
              });
            },
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'REGION_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'REGION_LBL'),
              border: InputBorder.none,
            ),
            items: regionsList?.map((item) {
              return new DropdownMenuItem(
                child: new Text(item['name']),
                value: item['id'].toString(),
              );
            })?.toList() ??
                [],

          ),
        ),
      ),
    );
  }
  setDistrict() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: DropdownButtonFormField<String>(
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            focusNode: addDistrictFocus,
            validator: (value) {
              if (value ==null) {
                return getTranslated(context, 'FIELD_REQUIRED');
              } else
                return null;
            },
            value: _mydistrict,
            onChanged: (String? newValue) {
              setState(() {
                _mydistrict = newValue;
                _myCounties=null;
                _getCounties();
              });
            },
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'DISTRICT_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'DISTRICT_LBL'),
              border: InputBorder.none,
            ),
            items: districtList?.map((item) {
              return new DropdownMenuItem(
                child: new Text(item['name']),
                value: item['id'].toString(),
              );
            })?.toList() ??
                [],
          ),
        ),
      ),
    );
  }

  setCounties() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: DropdownButtonFormField<String>(
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            focusNode: addDistrictFocus,
            validator: (value) {
              if (value ==null) {
                return getTranslated(context, 'FIELD_REQUIRED');
              } else
                return null;
            },
            value: _myCounties,
            onChanged: (String? newValue) {
              setState(() {
                _myCounties = newValue;
                _mysubCounties=null;
                _getSubcounites();
                // print(_myCounties);
              });
            },
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'COUNTY_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'COUNTY_LBL'),
              border: InputBorder.none,
            ),
            items: countiesList?.map((item) {
              return new DropdownMenuItem(
                child: new Text(item['name']),
                value: item['id'].toString(),
              );
            })?.toList() ??
                [],
          ),
        ),
      ),
    );
  }

  setSubCounty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: DropdownButtonFormField<String>(
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            focusNode: addDistrictFocus,
            validator: (value) {
              if (value ==null) {
                return getTranslated(context, 'FIELD_REQUIRED');
              } else
                return null;
            },
            value: _mysubCounties,
            onChanged: (String? newValue) {
              setState(() {
                _mysubCounties = newValue;
                _myParish=null;
                _getParishes();
              });
            },
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'SUBCOUNTY_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'SUBCOUNTY_LBL'),
              border: InputBorder.none,
            ),
            items: subcountiesList?.map((item) {
              return new DropdownMenuItem(
                child: new Text(item['name']),
                value: item['id'].toString(),
              );
            })?.toList() ??
                [],
          ),
        ),
      ),
    );
  }
  setParish() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: DropdownButtonFormField<String>(
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            focusNode: addDistrictFocus,
            validator: (value) {
              if (value ==null) {
                return getTranslated(context, 'FIELD_REQUIRED');
              } else
                return null;
            },
            value: _myParish,
            onChanged: (String? newValue) {
              setState(() {
                _myParish = newValue;
              });
            },
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'PARISH_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'PARISH_LBL'),
              border: InputBorder.none,
            ),
            items: parishList?.map((item) {
              return new DropdownMenuItem(
                child: new Text(item['name']),
                value: item['id'].toString(),
              );
            })?.toList() ??
                [],
          ),
        ),
      ),
    );
  }
  setVillage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            focusNode: lVillageFocus,
            controller: _village,
            textCapitalization: TextCapitalization.words,
            validator: (val) => validateUserName(
                val!,
                getTranslated(context, 'VILLAGE_REQUIRED'),
                getTranslated(context, 'VILLAGE_LENGTH')),
            onSaved: (String? value) {
              village = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, lVillageFocus!, villageFocus);
            },
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'VILLAGE_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'VILLAGE_LBL'),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
  Widget backButton(String title,  VoidCallback? onBtnSelected) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: MaterialButton(
        height: 45.0,
        textColor: Theme.of(context).colorScheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        onPressed: onBtnSelected,
        color: colors.primary,
        child: Text(
          title,
          style: const TextStyle(
            color: colors.whiteTemp,
            fontSize: textFontSize16,
          ),
        ),
      ),
    );
  }
  Widget saveButton(String title,  VoidCallback? onBtnSelected) {
    return MaterialButton(
      height: 45.0,
      textColor: Theme.of(context).colorScheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      onPressed: onBtnSelected,
      color: colors.primary,
      child: Text(
        title,
        style: const TextStyle(
          color: colors.whiteTemp,
          fontSize: textFontSize16,
        ),
      ),
    );
  }

  Widget nextButton(String title, VoidCallback? onBtnSelected) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: MaterialButton(
              height: 45.0,
              textColor: Theme.of(context).colorScheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              onPressed: onBtnSelected,
              color: colors.primary,
              child: Text(
                title,
                style: const TextStyle(
                  color: colors.whiteTemp,
                  fontSize: textFontSize16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List? regionsList;
  _getStateList() async {
    await get(Uri.parse('$region/$_countrySelection')).then((response) {
      var data = json.decode(response.body);
      // print(data);
      setState(() {
        regionsList = data['data']['regions'];
      });
    });
  }
  List? districtList;
  _getDistrict() async {
    await get(Uri.parse('$getdistricts/$_myRegions')).then((response) {
      var data = json.decode(response.body);
      setState(() {
        districtList = data['data']['districts'];
      });
    });
  }
  List? countiesList;
  _getCounties() async {
    await get(Uri.parse('$getcounties/$_mydistrict')).then((response) {
      var data = json.decode(response.body);
      // print(data);
      setState(() {
        countiesList = data['data']['counties'];
      });
    });
  }
  List? subcountiesList;
  _getSubcounites() async {
    // String countryInfoUrl = '$url/subcounties/$_myCounties';
    await get(Uri.parse("$subCounties/$_myCounties")).then((response) {
      var data = json.decode(response.body);

      setState(() {
        subcountiesList = data['data']['subcounty'];
      });
    });
  }
  List? parishList;
  _getParishes() async {
    await get(Uri.parse("$parishes/$_myCounties")).then((response) {
      var data = json.decode(response.body);
      //  print(data);
      setState(() {
        parishList = data['data']['parish'];
      });
    });
  }

  Future<void> completeProfile() async {
    try {
      var data = {
        FIRST_NAME: fname,
        LAST_NAME: lname,
        GENDER: _myGender,
        NIN: ninNumber,
        DOB: dob,
        LANDSIZE: landsize,
        POPULATION: familypopulation,
        VILLAGE: village,
        PARISH: _myParish,
      };
      var updateProfile = utf8.encode(jsonEncode(data));
      Response response = await patch(users, headers: headers, body: updateProfile)
          .timeout(const Duration(seconds: timeOut));
      var getdata = json.decode(response.body);
      bool success = getdata['success'];
      String? msg = getdata['message'];
      print(getdata);
      await buttonController!.reverse();
      if (response.statusCode == 201) {
      if (success == true) {
        var data = getdata['data'];
        userfirstname=data['firstname'];
        userlastname=data['lastname'];
        print(userlastname);
        status = CUR_STATUS;
        usermobile = CUR_MOBILE;
        var settingProvider =
        Provider.of<SettingProvider>(context, listen: false);
        settingProvider.setPrefrence(FIRST_NAME, userfirstname!);
        settingProvider.setPrefrence(LAST_NAME, userlastname!);
        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setFirstName(userfirstname!);
        userProvider.setLastName(userlastname!);
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (BuildContext context) => const Dashboard(),
          ),
        );
        // Future.delayed(const Duration(seconds: 1)).then((_) {
        //   Navigator.pushReplacement(
        //       context,
        //       CupertinoPageRoute(
        //           builder: (context) => Dashboard()));
        // });
        // Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);

      } else {
        setSnackbar(msg!);
      }
    }
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);
    }

  }


}
