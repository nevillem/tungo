import 'dart:convert';
import 'dart:io';
import 'package:agritungotest/Screen/Cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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
import '../Model/customa_data.dart';

class MilkSoldScreen extends StatefulWidget {
  const MilkSoldScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return MilkSoldScreenState();
  }
}

class MilkSoldScreenState extends State<MilkSoldScreen> with TickerProviderStateMixin {
  bool isLoading = false;
  int currentIndex = 0;
  final _datesold = TextEditingController();
  final _customer = TextEditingController();
  final boughtDate = TextEditingController();
  final _totalAmoubtBePaid = TextEditingController()..text = '0';
  final _litres = TextEditingController();
  final _price = TextEditingController();
  final _tag = TextEditingController();
  final _notes = TextEditingController();

  //customer details
  final _customername = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _bal = TextEditingController()..text = '';
  final _amount_paid = TextEditingController();

  bool _isNetworkAvail = true;
  int totalStallRows = 0;
  int totalColorRows = 0;
  int totalBreedRows = 0;
  int totalVaccineRows = 0;
  Animation? buttonSqueezeanimation, buttonSqueezeanimationAddCustomer;
  AnimationController? buttonController, buttonAddCustomerController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormFieldState> _customernameKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _emailKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _locationKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _phoneKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormState> _addMilkSoldKey = GlobalKey<FormState>();
  String? datesold, customerdata, phone, location, customerNames,
      email, litres, price, totalAmoubtBePaid, balance, amount_paid;

  FocusNode? dateSoldLFocus, dateSoldFocus,
      monoFocus, monodFocus, addFocus, priceFocus, priceLFocus,
      addEmailLFocus, customerNameFocus, customerNameLFocus, phoneFocus,
      phoneLFocus,
      locationFocus, locationLFocus, addEmailFocus, litresFocus, litresLFocus,
      totalAmountBePaidFocus,
      totalAmountBePaidLFocus, balanceFocus, balanceLFocus, amountPaidFocus,
      amountPaidLFocus;

  double milklitres = 0;
  double milkpriceeachltr = 0;
  double totalpaid = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // CustomerApi.getAnimalSuggestions("");
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    buttonAddCustomerController=AnimationController(duration:const Duration(milliseconds: 2000), vsync: this);
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
    buttonSqueezeanimationAddCustomer = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonAddCustomerController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));

  }

  @override
  void dispose() {
    buttonController!.dispose();
    buttonAddCustomerController!.dispose();
    ScaffoldMessenger.of(context).clearSnackBars();
    _email.dispose();
    _location.dispose();
    _customername.dispose();
    _email.dispose();

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
  Future<void> _playCustomerAnimation() async {
    try {
      await buttonAddCustomerController!.forward();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: getSimpleAppBar(
          getTranslated(context, 'REGISTER_MILKSALES_LBL')!, context),
      body: _isNetworkAvail ? _showContent() : noInternet(context),
    );
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus,
      FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  _showContent() {
    return Form(
        key: _addMilkSoldKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: <Widget>[
                      setDateSold(),
                      setCustomer(),
                      setLitres(),
                      setPricePerLitre(),
                      setAmountToBePaid(),
                      setAmountPaid(),
                      setBalance()

                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4),
              child: AppBtn(
                title: getTranslated(context, 'SAVE_LBL'),
                btnAnim: buttonSqueezeanimation,
                btnCntrl: buttonController,
                onBtnSelected: () async {
                  validateAndSubmit();
                },
              ),
            ),
          ],
        ));
  }

  setDateSold() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .colorScheme
              .white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            focusNode: dateSoldFocus,
            controller: _datesold,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1945),
                //DateTime.now() - not to allow to choose before today.
                lastDate: DateTime.now(),
                builder: (context, child) {
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
                                primary: Colors.amber,
                                // color of button's letters
                                backgroundColor: Colors.black54,
                                // Background color
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

              if (pickedDate != null) {
                String formattedDate = DateFormat('yyyy-MM-dd').format(
                    pickedDate);

                setState(() {
                  _datesold.text =
                      formattedDate; //set output date to TextField value.
                });
              } else {}
            },
            validator: (val) =>
                validateField(
                  val!,
                  getTranslated(context, 'DATE_REQUIRED'),),
            onSaved: (String? value) {
              datesold = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, dateSoldFocus!, dateSoldLFocus);
            },
            style: Theme
                .of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme
                .of(context)
                .colorScheme
                .fontColor),
            decoration: InputDecoration(
              label: Text(getTranslated(context, 'DATE_LBL')!),
              fillColor: Theme
                  .of(context)
                  .colorScheme
                  .white,
              isDense: true,
              hintText: getTranslated(context, 'DATE_LBL'),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  setCustomer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .colorScheme
              .white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: Column(
            children: [
              TypeAheadFormField<Customer?>(
                debounceDuration: Duration(milliseconds: 500,),
                hideSuggestionsOnKeyboardHide: false,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _customer,
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Theme
                      .of(context)
                      .colorScheme
                      .fontColor),
                  decoration: InputDecoration(
                    label: Text(getTranslated(context, 'CUSTOMER_LBL')!),
                    fillColor: Theme
                        .of(context)
                        .colorScheme
                        .white,
                    isDense: true,
                    hintText: getTranslated(context, 'CUSTOMER_LBL'),
                    border: InputBorder.none,
                  ),
                ),
                suggestionsCallback: CustomerApi.getAnimalSuggestions,
                itemBuilder: (context, Customer? suggestion) {
                  final customer = suggestion!;
                  return ListTile(
                    title: Text(customer.customername),
                  );
                },
                validator: (val) =>
                    validateFqmilyPop(
                      val!,
                      getTranslated(context, 'CUSTOMER_REQUIRED'),
                    ),
                noItemsFoundBuilder: (context) =>
                    Container(
                      height: 100,
                      child: Center(
                        child: Text(
                            'Please add clients first.',
                            style: Theme
                                .of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: Theme
                                .of(context)
                                .colorScheme
                                .fontColor, fontSize: textFontSize14)),
                      ),
                    ),
                onSuggestionSelected: (Customer? suggestion) {
                  final customer = suggestion!;
                  this._customer.text = customer.customername;
                  customerdata = (customer.id);
                },
              ),
              GestureDetector(
                onTap: () {
                  _addCustomerDialog();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 7),
                  child: Row(
                    children: const [
                      Icon(Icons.add, color: colors.primary,),
                      Text("Customer", textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 12, color: colors.primary,)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  setLitres() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .colorScheme
              .white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: _litres,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            focusNode: litresFocus,
            style: Theme
                .of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme
                .of(context)
                .colorScheme
                .fontColor),
            validator: (val) =>
                validateFqmilyPop(
                  val!,
                  getTranslated(context, 'LITRES_REQUIRED'),
                ),
            onChanged: (value) {
              if (value.isEmpty) {
                setState(() => milklitres = 0);
              }
              else {
                setState(() {
                  milklitres = double.parse(value);
                });
              }
            },
            onSaved: (String? value) {
              litres = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, litresFocus!, litresLFocus);
            },
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'LITRES_LBL')!),
                fillColor: Theme
                    .of(context)
                    .colorScheme
                    .white,
                isDense: true,
                hintText: getTranslated(context, 'LITRES_LBL'),
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }

  setPricePerLitre() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .colorScheme
              .white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: _price,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              FilteringTextInputFormatter.digitsOnly
            ],
            textInputAction: TextInputAction.next,
            focusNode: priceFocus,
            style: Theme
                .of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme
                .of(context)
                .colorScheme
                .fontColor),
            validator: (val) =>
                validateFqmilyPop(
                  val!,
                  getTranslated(context, 'PRICE_REQUIRED'),
                ),
            onChanged: (value) {
              if (value.isEmpty) {
                setState(() => milkpriceeachltr = 0);
              }
              else {
                setState(() {
                  milkpriceeachltr = double.parse(value) * milklitres;
                  _totalAmoubtBePaid.text = milkpriceeachltr.toString();
                });
              }
            },
            onSaved: (String? value) {
              price = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, priceFocus!, priceLFocus);
            },
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'PRICE_LBL')!),
                fillColor: Theme
                    .of(context)
                    .colorScheme
                    .white,
                isDense: true,
                hintText: getTranslated(context, 'PRICE_LBL'),
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }

  setAmountToBePaid() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .colorScheme
              .white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: _totalAmoubtBePaid,
            readOnly: true,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              FilteringTextInputFormatter.digitsOnly
            ],
            textInputAction: TextInputAction.next,
            focusNode: totalAmountBePaidFocus,
            style: Theme
                .of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme
                .of(context)
                .colorScheme
                .fontColor),
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'AMOUNT_TOBE_PAID_LBL')!),
                fillColor: Theme
                    .of(context)
                    .colorScheme
                    .white,
                isDense: true,
                hintText: getTranslated(context, 'AMOUNT_TOBE_PAID_LBL'),
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }

  setAmountPaid() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .colorScheme
              .white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: _amount_paid,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              FilteringTextInputFormatter.digitsOnly
            ],
            textInputAction: TextInputAction.next,
            focusNode: amountPaidFocus,
            style: Theme
                .of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme
                .of(context)
                .colorScheme
                .fontColor),
            validator: (val) =>
                validateFqmilyPop(
                  val!,
                  getTranslated(context, 'Amount_PAID_REQUIRED'),
                ),
            onChanged: (value){
              if(value.isEmpty) {
                setState(() => totalpaid = 0);
              }
              else{
                setState((){
                  totalpaid = milkpriceeachltr-double.parse(value);
                  _bal.text=totalpaid.toString();

                });
              }
            },
            onSaved: (String? value) {
              amount_paid = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, amountPaidFocus!, amountPaidLFocus);
            },
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'AMOUNT_PAID_LBL')!),
                fillColor: Theme
                    .of(context)
                    .colorScheme
                    .white,
                isDense: true,
                hintText: getTranslated(context, 'AMOUNT_PAID_LBL'),
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }

  setBalance() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .colorScheme
              .white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: TextFormField(
            keyboardType: TextInputType.number,
            controller: _bal,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              FilteringTextInputFormatter.digitsOnly
            ],
            textInputAction: TextInputAction.next,
            focusNode: balanceFocus,
            style: Theme
                .of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme
                .of(context)
                .colorScheme
                .fontColor),
            validator: (val) =>
                validateFqmilyPop(
                  val!,
                  getTranslated(context, 'BALANCE_REQUIRED'),
                ),
            onChanged: (value) {
              if (value.isEmpty) {
                setState(() => totalpaid = 0);
              }
              else {
                setState(() {
                  totalpaid = milkpriceeachltr - double.parse(value);
                  _bal.text = totalpaid.toString();
                });
              }
            },
            onSaved: (String? value) {
              price = value;
            },
            onFieldSubmitted: (v) {
              _fieldFocusChange(context, priceFocus!, priceLFocus);
            },
            decoration: InputDecoration(
                label: Text(getTranslated(context, 'TOTAL_BAL')!),
                fillColor: Theme
                    .of(context)
                    .colorScheme
                    .white,
                isDense: true,
                hintText: getTranslated(context, 'TOTAL_BAL'),
                border: InputBorder.none),
          ),
        ),
      ),
    );
  }

  Widget backButton(String title, VoidCallback? onBtnSelected) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: MaterialButton(
        height: 45.0,
        textColor: Theme
            .of(context)
            .colorScheme
            .white,
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


  bool validateAndSave() {
    final form = _addMilkSoldKey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }
  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }


  void _addCustomerDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          title: Text(getTranslated(context, "SAVE_CUSTOMER_LBL")!,
            style:Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.lightBlack,
                fontWeight: FontWeight.bold),),
          backgroundColor:Theme
              .of(context)
              .colorScheme
              .lightWhite,
          content: Container(
            width:MediaQuery
                .of(context)
                .size.width * 10,
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal:10, ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.white,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child:Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: TextFormField(
                              key: _customernameKey,
                              controller: _customername,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              focusNode: customerNameFocus,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
                              validator: (val) => validateFqmilyPop(
                                val!,
                                getTranslated(context, 'CUSTOMER_REQUIRED'),
                              ),
                              onSaved: (String? value) {
                                customerNames = value;
                              },
                              onFieldSubmitted: (v) {
                                _fieldFocusChange(context, customerNameFocus!, customerNameLFocus);
                              },
                              decoration: InputDecoration(
                                  label: Text(getTranslated(context, 'CUSTOMER_LBL')!),
                                  fillColor: Theme.of(context).colorScheme.white,
                                  isDense: true,
                                  hintText: getTranslated(context, 'CUSTOMER_LBL'),
                                  border: InputBorder.none),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.white,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child:Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: TextFormField(
                              key: _locationKey,
                              controller: _location,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              focusNode: locationFocus,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
                              validator: (val) => validateFqmilyPop(
                                val!,
                                getTranslated(context, 'LOCATION_REQUIRED'),
                              ),
                              onSaved: (String? value) {
                                location = value;
                              },
                              onFieldSubmitted: (v) {
                                _fieldFocusChange(context, locationFocus!, locationLFocus);
                              },
                              decoration: InputDecoration(
                                  label: Text(getTranslated(context, 'ADDRESS_LBL')!),
                                  fillColor: Theme.of(context).colorScheme.white,
                                  isDense: true,
                                  hintText: getTranslated(context, 'ADDRESS_LBL'),
                                  border: InputBorder.none),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.white,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child:Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: TextFormField(
                              controller: _email,
                              key: _emailKey,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              focusNode:addEmailFocus ,
                              validator: (val) => validateEmail(
                                val!,
                                getTranslated(context, 'EMAIL_REQUIRED'),
                                getTranslated(context, 'VALID_EMAIL'),
                              ),
                              onSaved: (String? value) {
                                email = value;
                              },
                              onFieldSubmitted: (v) {
                                _fieldFocusChange(context, addEmailFocus!, addEmailLFocus);
                              },
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
                              decoration: InputDecoration(
                                label: Text(getTranslated(context, 'ADD_EMAIL_LBL')!),
                                fillColor: Theme.of(context).colorScheme.white,
                                isDense: true,
                                hintText: getTranslated(context, 'ADD_EMAIL_LBL'),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.white,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child:Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: TextFormField(
                              controller: _phone,
                              key: _phoneKey,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              focusNode:phoneFocus ,
                              validator: (val) => validateMob(
                                val!,
                                getTranslated(context, 'MOB_REQUIRED'),
                                getTranslated(context, 'VALID_MOB'),
                              ),
                              onSaved: (String? value) {
                                phone = value;
                              },
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
                              decoration: InputDecoration(
                                label: Text(getTranslated(context, 'MOBILEHINT_LBL')!),
                                fillColor: Theme.of(context).colorScheme.white,
                                isDense: true,
                                hintText: getTranslated(context, 'MOBILEHINT_LBL'),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                )
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  flex:2,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(getTranslated(context, "CANCEL")!),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: AppBtn(
                    title: getTranslated(context, 'SAVE_LBL'),
                    btnAnim: buttonSqueezeanimationAddCustomer,
                    btnCntrl: buttonAddCustomerController,
                    onBtnSelected: () async {
                      validateVaccineAndSubmit();
                    },
                  ),
                ),
              ],
            ),
            // TextButton(
            //   onPressed: () {
            //     // Navigator.pop(context);
            //     if(_colorKey.currentState!.validate()) {
            //       saveAnimalColor();
            //     }
            //   },
            //   child: Text(getTranslated(context, "SAVE_LBL")!),
            // ),
          ],
        );
      },
    );
  }
  void validateVaccineAndSubmit() async {
    if (validateCustomerAndSave()) {
      _playCustomerAnimation();
      saveCustomer();
    }
  }
  Future<void> saveCustomer() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      Map postdata = {
        NAME: customerNames,
        EMAIL: email,
        CONTACT: phone,
        ADDRESS: location,
      };
      var _json= utf8.encode(jsonEncode(postdata));
      Response response = await post(addCustomers, headers: headers,
          body: _json);
      await buttonAddCustomerController!.reverse();
      var getdata= jsonDecode(response.body);
      print(getdata);
      if(response.statusCode==401){
        getNewToken(context,saveCustomer());
      }
      else if(response.statusCode==201){
        _clearCustomerValues();
        Navigator.of(context, rootNavigator: true).pop();
        setSnackbar("Customer saved");
      }
      else{
        String? msg = getdata['messages'][0].toString();
        setSnackbar(msg);
      }
    }
    else{
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
  _clearCustomerValues() {
    _phone.text = '';
    _customername.text='';
    _email.text='';
    _location.text='';
  }
  bool validateCustomerAndSave() {
    final form = _customernameKey.currentState!;
    final locationkey = _locationKey.currentState!;
    final phonekey = _phoneKey.currentState!;
    final emailKey = _emailKey.currentState!;
    form.save();
    locationkey.save();
    phonekey.save();
    emailKey.save();
    if (form.validate() && locationkey.validate() && emailKey.validate() && phonekey.validate()) {
      return true;
    }
    return false;
  }
  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      saveMilkSale();
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
  Future<void> saveMilkSale() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      Map postdata = {
        DATE_COLLECTED: datesold,
        LITRES: litres,
        UNIT_PRICE: _price.text,
        AMOUNT_PAID: amount_paid,
        CUSTOMER: customerdata,
      };
      print(postdata);
      var _json= utf8.encode(jsonEncode(postdata));
      Response response = await post(addMilkSoldApi, headers: headers, body: _json);
      await buttonController!.reverse();
      var getdata= jsonDecode(response.body);

      // String? msg = getdata['messages'][0].toString();
      if(response.statusCode==401){
        getNewToken(context,saveMilkSale);
      }
      else if(response.statusCode==201){
        _clearValues();
        setSnackbar("milk sale saved");
        Future.delayed(const Duration(seconds: 1)).then((_) {
          Navigator.of(context, rootNavigator: true).pop();
        });

      }
      else{
        setSnackbar(getdata['messages'][0].toString());
      }
    }
    else{
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


  _clearValues() {
    _datesold.text = '';
    _litres.text = '';
    _price.text='';
    _amount_paid.text='';
    _customer.text='';
  }
}
