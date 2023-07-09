import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import 'package:intl/intl.dart';

import '../Helper/update_access_token.dart';

class RegisterAnimals extends StatefulWidget {
  // final Function() notifyParent;

  const RegisterAnimals({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return RegisterAnimalsState();
  }
}

class RegisterAnimalsState extends State<RegisterAnimals> with TickerProviderStateMixin {
  bool isLoading=false;
  int currentIndex = 0;

  final _completePformKey = GlobalKey<FormState>();
  final _bDate = TextEditingController();
  // final _gender = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _colorName = TextEditingController();
  final _previousVaccineDate = TextEditingController();
  final boughtDate = TextEditingController();
  final _dateNextPregnance = TextEditingController();
  final _ltrsdaily = TextEditingController();
  final _boughtFrom = TextEditingController();
  final _buyingP = TextEditingController();
  final _tag = TextEditingController();
  final _notes = TextEditingController();
  bool _isNetworkAvail = true;
  int totalStallRows=0;
  int totalColorRows=0;
  int totalBreedRows=0;
  int totalVaccineRows=0;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? dob,_myGender,weight, height,_myColors,_myStall,_myBreed,
      _bornorbought,
      tag,_myVaccine,previousVaccineDate,notes;
  String? dailyLitres='';
  String? boughtFrom='';
  String? buyingP='';
  String? _pregnacyStatus;
  String? dateNextPregnance='';
  String? datebought='';
  FocusNode? addgenderFocus,
      monoFocus,monodFocus,addFocus,dobFocus,ldobFocus,dailyLtrsFocus,dobBoughtFocus,
      previousVaccineDateFocus,_previousVaccineDateFinFocus,
      almonoFocus,addColorsFocus,addBreedFocus,addWeightFocus,addHeightFocus, weightFocus,heightFocus,
      monodBoughtFocus,boughtfromFocus,pregnancyStatDateFocus,pregnancyStatFocus,bronOrBoughtFocus,
      addBuyingpFocus,addBuyingMonoFocus,addvaccineFocus,fnotesFocus,notesFocus,dateboughtFocus,ldateBoughtFocus;

  CroppedFile? _croppedFile;
  bool _inProcess = false;
  final picker = ImagePicker();

  Widget _getImageWidget() {
    if (_croppedFile != null) {
      return Image.file(File(_croppedFile!.path),);
    } else {
      return Image.asset(
          "assets/images/cow.png");
    }
  }
  List<Map> _selectGender = [{"gender":"Male"}, {"gender":"Female"}];
  bool _disablebuyingprice=false;
  List<Map> listBornOrBought = [{"options":"Yes"}, {"options":"No"}];
  List<Map> listPregnancy=[{"option":"Yes"}, {"option":"No"}];


  _getPregnancyOption(){
    if(_myGender=="Female"){
      setState(() {
        listPregnancy=[{"option":"Yes"}, {"option":"No"}];
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getBreeds();
    _getColors();
    _getStalls();
    _getVaccines();
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
    ScaffoldMessenger.of(context).clearSnackBars();
    _tag.dispose();
    _height.dispose();
    _weight.dispose();
    _bDate.dispose();
    _boughtFrom.dispose();
    _buyingP.dispose();
    super.dispose();
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
                  if (mounted) {
                    setState(() {
                      _isNetworkAvail = true;
                    });
                  }
                  // callApi();
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
  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getSimpleAppBar(getTranslated(context, 'REGISTER_ANIMALS_LBL')!, context),
      body: _isNetworkAvail ? _showContent() : noInternet(context),
    );
  }
  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
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
                      currentIndex == 0 ?setDOB():Container(),
                      currentIndex == 0 ?setGender():Container(),
                      currentIndex == 0 ?setWeight():Container(),
                      currentIndex == 0 ?setHeight():Container(),
                      currentIndex == 0 ?setColors():Container(),
                      currentIndex == 0 ?setBreed():Container(),
                      currentIndex == 0 ?setPregStatus():Container(),
                      currentIndex == 0 ?setNextPregDate():Container(),
                      currentIndex == 0 ?setDailyLitres():Container(),
                      currentIndex == 0 ?setBornOrBought():Container(),
                      currentIndex == 1 ?setBoughtFrom():Container(),
                      currentIndex == 1 ?setBuyingPrice():Container(),
                      currentIndex == 1 ?setDateBought():Container(),
                      currentIndex == 1 ?setMyStall():Container(),
                      currentIndex == 1 ?setAnimalTag():Container(),
                      currentIndex == 1 ?setVaccine():Container(),
                      currentIndex == 1 ?setPreviousVaccineDate():Container(),
                      currentIndex == 1 ?setOtherNotes():Container(),
                      currentIndex == 1 ?setProfilePic():Container(),
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
            currentIndex == 0 ? nextButton(getTranslated(context, 'NEXT_LBL')!, () {
        validateAndCompleteForm();
            }):Container(),
          ],
        ));
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
            controller: _bDate,
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
                  _bDate.text = formattedDate; //set output date to TextField value.
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
            focusNode: addgenderFocus,
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
                print("gender: $_myGender");
                if(_myGender =="Female"){
                  _getPregnancyOption();
                }
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
  setWeight() {
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
            controller: _weight,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            focusNode: weightFocus,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            validator: (val) => validateFqmilyPop(
              val!,
              getTranslated(context, 'WEIGHT_REQUIRED'),
            ),
            onSaved: (String? value) {
              weight = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, weightFocus!, addWeightFocus);
            },
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'WEIGHT_LBL')!),
                fillColor: Theme.of(context).colorScheme.white,
                isDense: true,
                hintText: getTranslated(context, 'WEIGHT_LBL'),
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }
  setHeight() {
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
            controller: _height,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            focusNode: heightFocus,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            validator: (val) => validateFqmilyPop(
              val!,
              getTranslated(context, 'HEIGHT_REQUIRED'),
            ),
            onSaved: (String? value) {
              height = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, heightFocus!, addHeightFocus);
            },
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'HEIGHT_LBL')!),
                fillColor: Theme.of(context).colorScheme.white,
                isDense: true,
                hintText: getTranslated(context, 'HEIGHT_LBL'),
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }

  setColors() {
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
            focusNode: addColorsFocus,
            validator: (value) {
              if (value ==null) {
                return getTranslated(context, 'COLOR_REQUIRED');
              } else
                return null;
            },
            value: _myColors,
            onChanged: (String? newValue) {
              setState(() {
                _myColors = newValue;
              });
            },
            decoration: InputDecoration(
              label: Text(totalColorRows!=0?getTranslated(context, 'COLOR_LBL')!:getTranslated(context, "CATALOG_COLOR_SET")!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText:totalColorRows!=0?getTranslated(context, 'COLOR_LBL'):getTranslated(context, "CATALOG_COLOR_SET"),
              border: InputBorder.none,
            ),
            items: colorsList?.map((item) {
              return DropdownMenuItem(
                child: Text(item['name']),
                value: item['id'].toString(),
              );
            })?.toList() ??
                [],
          ),
        ),
      ),
    );
  }
  setBreed() {
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
            focusNode: addBreedFocus,
            validator: (value) {
              if (value ==null) {
                return getTranslated(context, 'BREED_REQUIRED');
              } else
                return null;
            },
            value: _myBreed,
            onChanged: (String? newValue) {
              setState(() {
                _myBreed = newValue;
              });
            },
            decoration: InputDecoration(
              label: Text(totalBreedRows!=0?getTranslated(context, 'BREED_LBL')!:getTranslated(context, "CATALOG_BREED_SET")!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText:totalBreedRows!=0?getTranslated(context, 'BREED_LBL'):getTranslated(context, "CATALOG_BREED_SET"),
              border: InputBorder.none,
            ),
            items: breedList?.map((item) {
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
  setPregStatus() {
    return _myGender=="Female"?Padding(
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
            focusNode: pregnancyStatFocus,
            validator: (value) {
              if (value ==null) {
                return getTranslated(context, 'PREGNANCYSTATUS_REQUIRED');
              } else
                return null;
            },
            value: _pregnacyStatus,
            onChanged: (String? newValue) {
              setState(() {
                _pregnacyStatus = newValue;
              });
            },
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'PREGNANCE_STATUS_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText:getTranslated(context, 'PREGNANCE_STATUS_LBL'),
              border: InputBorder.none,
            ),
            items:listPregnancy?.map((item) {
              return new DropdownMenuItem(
                child: new Text(item['option']),
                value: item['option'].toString(),
              );
            })?.toList() ??
                [],
          ),
        ),
      ),
    ):Container();
  }
  setNextPregDate() {
    return (_myGender=="Female" && _pregnacyStatus=="No")?Padding(
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
            focusNode: pregnancyStatDateFocus,
            controller: _dateNextPregnance,
            textCapitalization: TextCapitalization.words,
            validator: (val) => validateFqmilyPop(
              val!,
              getTranslated(context, 'NEXT_PREGNANCY_DATE_REQUIRED'),
            ),
            onSaved: (String? value) {
              dateNextPregnance = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, pregnancyStatDateFocus!, monoFocus);
            },
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'PREGNANCE_STATUS_DATE_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'PREGNANCE_STATUS_DATE_LBL'),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    ):Container();
  }
  setDailyLitres() {
    return _myGender=="Female"?Padding(
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
            focusNode: dailyLtrsFocus,
            controller: _ltrsdaily,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            validator: (val) => validateFqmilyPop(
              val!,
              getTranslated(context, 'FIELD_REQUIRED'),
            ),
            onSaved: (String? value) {
              dailyLitres = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, dailyLtrsFocus!, monodFocus);
            },
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'LITRES_DAILY_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'LITRES_DAILY_LBL'),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    ):Container();
  }

  setBornOrBought() {
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
            focusNode: bronOrBoughtFocus,
            validator: (value) {
              if (value ==null) {
                return getTranslated(context, 'BOUGHT_OR_BORN_ON_FARM_REQUIRED');
              } else
                return null;
            },
            value: _bornorbought,
            onChanged: (String? newValue) {
              setState(() {
                _bornorbought = newValue;
              });
            },
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'BORN_ON_FARM_STATUS_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText:getTranslated(context, 'BORN_ON_FARM_STATUS_LBL'),
              border: InputBorder.none,
            ),
            items:listBornOrBought?.map((item) {
              return new DropdownMenuItem(
                child: new Text(item['options']),
                value: item['options'].toString(),
              );
            })?.toList() ??
                [],
          ),
        ),
      ),
    );
  }

  setBoughtFrom() {
    // print("hhhh$_bornorbought");
    return _bornorbought=="No"?Padding(
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
            focusNode: boughtfromFocus,
            controller: _boughtFrom,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            validator: (val) => validateFqmilyPop(
              val!,
              getTranslated(context, 'FIELD_REQUIRED'),
            ),
            onSaved: (String? value) {
              boughtFrom = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, boughtfromFocus!, monodBoughtFocus);
            },
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'BOUGHT_FROM_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'BOUGHT_FROM_LBL'),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    ):Container();
  }
  setBuyingPrice() {
    return _bornorbought=="No"?Padding(
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
            controller: _buyingP,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            focusNode: addBuyingpFocus,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            validator: (val) =>validateFqmilyPop(
            val!,
            getTranslated(context, 'FIELD_REQUIRED'),
          ),
            onSaved: (String? value) {
              buyingP = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, addBuyingpFocus!, addBuyingMonoFocus);
            },
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'BUYING_PRICE')!),
                fillColor: Theme.of(context).colorScheme.white,
                isDense: true,
                hintText: getTranslated(context, 'BUYING_PRICE'),
                border: InputBorder.none),
          ),
        ),
      ),
    ):Container();
  }

  setDateBought() {
    return _bornorbought=="No"?Padding(
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
            focusNode: dateboughtFocus,
            controller: boughtDate,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context, initialDate: DateTime.now(),
                firstDate: DateTime(1945), //DateTime.now() - not to allow to choose before today.
                lastDate: DateTime.now(),
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
                String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                setState(() {
                  boughtDate.text = formattedDate;
                });
              }else{
              }
            },
            validator: (val) => validateFqmilyPop(
                val!,
                getTranslated(context, 'BOUGHT_DATE_REQUIRED')),
            onSaved: (String? value) {
              datebought = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, dateboughtFocus!, ldateBoughtFocus);
            },
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'DATE_BOUGHT_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'DATE_BOUGHT_LBL'),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    ):Container();
  }
  setMyStall() {
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
            focusNode: addBreedFocus,
            validator: (value) {
              if (value ==null) {
                return getTranslated(context, 'BREED_REQUIRED');
              } else
                return null;
            },
            value: _myStall,
            onChanged: (String? newValue) {
              setState(() {
                _myStall = newValue;
              });
            },
            decoration: InputDecoration(
              label: Text(totalStallRows!=0?getTranslated(context, 'STALL_LBL')!:getTranslated(context, "CATALOG_STALL_SET")!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText:totalStallRows!=0?getTranslated(context, 'STALL_LBL'):getTranslated(context, "CATALOG_STALL_SET"),
              border: InputBorder.none,
            ),
            items: stallList?.map((item) {
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
  setAnimalTag() {
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
            textCapitalization: TextCapitalization.sentences,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            focusNode: addFocus,
            controller: _tag,
            validator: (val) => validateField(
              val!,
              getTranslated(context, 'TAG_REQUIRED'),
            ),
            onSaved: (String? value) {
              tag = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, addFocus!, monoFocus);
            },
            decoration: InputDecoration(
              counterText: '',
              label: Text(getTranslated(context, 'TAG_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'TAG_LBL'),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
  setVaccine() {
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
            focusNode: addvaccineFocus,
            validator: (value) {
              if (value ==null) {
                return getTranslated(context, 'VACCINE_REQUIRED');
              } else
                return null;
            },
            value: _myVaccine,
            onChanged: (String? newValue) {
              setState(() {
                _myVaccine = newValue;
              });
            },
            decoration: InputDecoration(
              label: Text(totalVaccineRows!=0?getTranslated(context, 'VACCINE_LBL')!:getTranslated(context, "CATALOG_VACCINE_SET")!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText:totalVaccineRows!=0?getTranslated(context, 'VACCINE_LBL'):getTranslated(context, "CATALOG_VACCINE_SET"),
              border: InputBorder.none,
            ),
            items: vaccinelList?.map((item) {
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
  setPreviousVaccineDate() {
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
            focusNode: previousVaccineDateFocus,
            controller: _previousVaccineDate,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context, initialDate: DateTime.now(),
                firstDate: DateTime(1945), //DateTime.now() - not to allow to choose before today.
                lastDate: DateTime.now(),
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
                String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                //you can implement different kind of Date Format here according to your requirement

                setState(() {
                  _previousVaccineDate.text = formattedDate; //set output date to TextField value.
                });
              }else{
                print("Date is not selected");
              }
            },
            validator: (val) => validateField(
                val!,
                getTranslated(context, 'VACCINE_DATE_REQUIRED'),
            ),
            onSaved: (String? value) {
              previousVaccineDate = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, previousVaccineDateFocus!, _previousVaccineDateFinFocus);
            },
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'PREVIOUS_VACCINE_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'PREVIOUS_VACCINE_LBL'),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  setOtherNotes() {
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
            focusNode: notesFocus,
            controller: _notes,
            textCapitalization: TextCapitalization.words,
            onSaved: (String? value) {
              notes = value;
            },
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'NOTES_LBL')!),
              fillColor: Theme.of(context).colorScheme.white,
              isDense: true,
              hintText: getTranslated(context, 'NOTES_LBL'),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
  setProfilePic() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          // SizedBox(height:10),
          Text(getTranslated(context, 'PHOTO_ANIMAL_LBL')!),
          Container(
              height: 120,
              width: 120,
              margin: EdgeInsets.only(left:40, right:40, top: 0),
              child: MaterialButton(
                onPressed: ()=>_bottomSheet(),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color:Colors.black45),
                    borderRadius: BorderRadius.circular(8), //<-- SEE HERE
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _getImageWidget(),
                  ),
                ),
              )
          ),
        ],
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

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      uploadCow();
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
        if (_myColors == null || _myColors!.isEmpty) {
          setSnackbar(getTranslated(context, 'FIELD_REQUIRED')!);
        } else {
          return true;
        }
      }

    }
    return false;
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    print(form);
    if (form.validate()) {
        return true;
      }
    return false;
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
  _bottomSheet(){
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  getImage(ImageSource.gallery);

                },
              ),
              // ListTile(
              //   leading: new Icon(Icons.videocam),
              //   title: new Text('Video'),
              //   onTap: () {
              //     Navigator.pop(context);
              //   },
              // ),
              // ListTile(
              //   leading: new Icon(Icons.share),
              //   title: new Text('Share'),
              //   onTap: () {
              //     Navigator.pop(context);
              //   },
              // ),
            ],
          );
        });
  }

  Future<void> getImage(ImageSource source) async {
    this.setState((){
      _inProcess = true;
    });
    final pickedFile  = await  ImagePicker().pickImage(source: source);
    if(pickedFile != null){
      final  cropped = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(
            ratioX: 1, ratioY: 1),
        compressQuality: 50,
        // maxWidth: 700,
        // maxHeight: 700,
        compressFormat: ImageCompressFormat.jpg,
      );

      this.setState((){
        _croppedFile = cropped;
        _inProcess = false;
      });
    } else {
      this.setState((){
        _inProcess = false;
      });
    }
  }
  List? colorsList;

  _getColors() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      await get(getColorsApi, headers: headers).then((response) {
        var dataColor = json.decode(response.body);
        totalColorRows=(dataColor['data']['rows_returned']);
        if (response.statusCode == 401) {
          setState(() {
            getNewToken(context, _getColors);
          });
        } else {
          setState(() {
            colorsList = dataColor['data']['colors'];
          });
        }
      });
    }
    else{
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }
  List? breedList;
    _getBreeds() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      await get(getBreeds, headers:headers ).then((response) {
        var dataBreed= json.decode(response.body);
        totalBreedRows=(dataBreed['data']['rows_returned']);
        setState(() {
          breedList = dataBreed['data']['breed'];
        });
      });
    }
    else{
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  List? stallList;
  _getStalls() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      await get(getStalls, headers:headers ).then((response) {
        var dataStall = json.decode(response.body);
         totalStallRows=(dataStall['data']['rows_returned']);
        setState(() {
          stallList = dataStall['data']['stalls'];
        });
      });
    }
    else{
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }
  List? vaccinelList;
  _getVaccines() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      await get(getVaccines, headers:headers ).then((response) {
        var dataVaccine = json.decode(response.body);
        totalVaccineRows=(dataVaccine['data']['rows_returned']);
        setState(() {
          if(mounted) {
            vaccinelList = dataVaccine['data']['vaccines'];
          }
        });
      });
    }
    else{
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }
  Future<void> uploadCow() async {
    var fpregnanceStatus;
    if(_pregnacyStatus==null){
      fpregnanceStatus='';
    }
    else{
      fpregnanceStatus=_pregnacyStatus;
    }
    Map<String,dynamic> postdata1 = {
      WEIGHT: weight,
      DATEOFBIRTH: dob,
      HEIGHT : height,
      GENDER : _myGender,
      LITRES : dailyLitres,
      PRICE : buyingP,
      NOTES : notes,
      PREGNANCY_STATUS: fpregnanceStatus,
      NEXT_PREGNANCY_APPROXIMET_TIME :dateNextPregnance,
      BOUGHTFROM : boughtFrom,
      DATEBOUGHT : datebought,
      TAGNO : tag,
      MYSTALL : _myStall,
      BREED : _myBreed,
      VACCINE : _myVaccine,
      VACCINEDONEDATE : _myVaccine,
      COLOR: _myColors
    };
    if(_croppedFile!.path !=null && _croppedFile!.path !=''){
      var request = http.MultipartRequest('POST', addAnimal)
        ..fields.addAll({'animal_data':jsonEncode(postdata1)})
        ..files.add(await http.MultipartFile.fromPath(
            'imagefile', _croppedFile!.path,
            contentType: MediaType('image', 'jpeg')))
        ..headers.addAll(headers);
      var response = await request.send().timeout(const Duration(seconds: timeOut));
      var responseString=(await http.Response.fromStream(response));
      var getdata=json.decode(responseString.body);
      await buttonController!.reverse();
      String?  msg=getdata['message'];
      if(response.statusCode==201){
        _clearValues();
        setSnackbar("Animal details uploaded");
        // widget.notifyParent();
        Future.delayed(const Duration(seconds: 1)).then((_) {
          Navigator.of(context, rootNavigator: true).pop();
        });
      }
      else if(response.statusCode==401){
        getNewToken(context, uploadCow());
      }
      else if(response.statusCode==400){
        setSnackbar("Check form data, try again later");
      }
      else{
        await buttonController!.reverse();

        setSnackbar(msg!);
      }
    }
    else{
      setSnackbar("Please attach animal photo");
    }


  }
  _clearValues() {
    _bDate.text = '';
    _weight.text = '';
    _height.text = '';
    _dateNextPregnance.text = '';
    _ltrsdaily.text = '';
    _boughtFrom.text = '';
    boughtDate.text = '';
    _tag.text = '';
    _notes.text = '';
    // _myGender = '';
    _myStall = '';
  }
}
