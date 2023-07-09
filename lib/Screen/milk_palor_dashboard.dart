
import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Screen/Add_Address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Helper/update_access_token.dart';
import '../Model/Animal_Tag_Model.dart';
import '../Model/AnimalsModel.dart';
import '../Model/MilkCollected.dart';
import '../Model/milk_sold.dart';
import '../Provider/HomeProvider.dart';
import '../Provider/SettingProvider.dart';
import '../Provider/UserProvider.dart';
import 'milk_sold_screen.dart';


class MilkParlorDashboard extends StatefulWidget {
  const MilkParlorDashboard({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateMilkParlorDashboard();
  }
}

class StateMilkParlorDashboard extends State<MilkParlorDashboard> with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshSalesIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  final TextEditingController _controller = TextEditingController();

  final _dateCollected = TextEditingController();
  final _tagNo = TextEditingController();
  final _litres = TextEditingController();
  final _price = TextEditingController();
  final _notestxt = TextEditingController();
  late TabController _tabController;
  final bool _isProgress = false;
  late AnimationController _animationController;
  bool notificationisloadmore = true,notificationisnodata = false,
      notificationisgettingdata = false;
  List<MilkCollected> milkCollectedList = [];
  List<MilkSold> milkSalesList = [];
  ScrollController? milkCollectedListController;
  ScrollController? milkSoldListController;
  int milkCollectedListOffset = 0;
  int milkSoldOffset = 0;
  int milkCollectedTotalCount=0;
  int milkSoldTotalCount=0;
  bool loading = true;
  String? milkSalesid, milkCollectedid;
  final GlobalKey<FormState> _addMilkCollectedKey = GlobalKey<FormState>();
  String? dateCollected,tagNo,litres,price,notes;
  FocusNode? dateCollectedFocus,dateCollectedLFocus,litresFocus,litresLFocus,priceFocus,priceLFocus,notesFocus;
  @override
  void initState() {
    milkCollectedListController = ScrollController(keepScrollOffset: true);
    milkCollectedListController!.addListener(_milkCollectedListController);

    milkSoldListController = ScrollController(keepScrollOffset: true);
    milkSoldListController!.addListener(_milkSoldListController);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
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
    getMilkCollectedApi();
    getMilkSold();
    super.initState();
  }
  _milkCollectedListController() {
    if (milkCollectedListController!.offset >=
        milkCollectedListController!.position.maxScrollExtent &&
        !milkCollectedListController!.position.outOfRange) {
      if (mounted) {
        if (milkCollectedListOffset < milkCollectedTotalCount) {
          getMilkCollectedApi();
          setState(() {});
        }
      }
    }
  }
  _milkSoldListController() {
    if (milkSoldListController!.offset >=
        milkSoldListController!.position.maxScrollExtent &&
        !milkSoldListController!.position.outOfRange) {
      if (mounted) {
        if (milkSoldOffset < milkSoldTotalCount) {
          getMilkSold();
          setState(() {});
        }
      }
    }
  }
  @override
  void dispose() {
    buttonController!.dispose();
    milkCollectedListController!.dispose();
    milkSoldListController!.dispose();
    _notestxt!.dispose();
    _price.dispose();
    _litres.dispose();
    _tabController.dispose();
    _animationController.dispose();
    ScaffoldMessenger.of(context).clearSnackBars();
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
      resizeToAvoidBottomInset: false,
      // backgroundColor: const Color(0xFFF2F2F2),
      appBar:AppBar(
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.white,
        leading: Builder(builder: (BuildContext context) {
          return Container(
            margin: const EdgeInsets.all(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => Navigator.of(context).pop(),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: colors.primary,
                ),
              ),
            ),
          );
        }),
        elevation: 0,
        title: Text(
          getTranslated(context, 'MANAGE_PARLOR_LBL')!,
          style:
          const TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
        ),
      ),
      body: _isNetworkAvail ?
      Column(children: [
        getSearch(),
        Container(
          color: Theme.of(context).colorScheme.white,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Text(getTranslated(context, 'MANAGE_MILK_COLLECTION')!),
              ),
              Tab(
                child: Text(getTranslated(context, 'MANAGE_MILK_SALE')!),
              ),
              Tab(
                child: Text(getTranslated(context, 'MANAGE_MILK_SALES_DUE_COLLECTION')!),
              ),

            ],
            indicatorColor: colors.primary,
            labelColor: Theme.of(context).colorScheme.fontColor,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor:
            Theme.of(context).colorScheme.lightBlack,
            isScrollable: true,
            labelStyle: const TextStyle(
              fontSize: textFontSize16,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              Stack(
                children: <Widget>[
                  _getDasboardData(),
                  Center(
                      child: showCircularProgress(
                          _isProgress, colors.primary)),
                ],
              ),
              Stack(
                children: <Widget>[
                  _showContentOfMilkSold(),
                  Selector<HomeProvider, bool>(
                    builder: (context, data, child) {
                      return Center(
                        child: showCircularProgress(
                            data, colors.primary),
                      );
                    },
                    selector: (_, provider) => provider.milkcollectionLoading,
                  ),
                ],
              ),
              Stack(
                children: <Widget>[
                  Selector<HomeProvider, bool>(
                    builder: (context, data, child) {
                      return Center(
                        child: showCircularProgress(
                            data, colors.primary),
                      );
                    },
                    selector: (_, provider) => provider.milkcollectionLoading,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],) : noInternet(context),
      floatingActionButton: floatingBtn(),
    );
  }
getSearch(){
    if(_tabController.index==2){
      return Container(
        color: Theme.of(context).colorScheme.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(circularBorderRadius10)),
            height: 44,
            child: TextField(
              controller: _controller,
              autofocus: false,
              enabled: true,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                      Theme.of(context).colorScheme.lightWhite),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                contentPadding:
                const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                fillColor: Theme.of(context).colorScheme.lightWhite,
                filled: true,
                isDense: true,
                hintText: getTranslated(context, 'searchHint'),
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(
                  color:
                  Theme.of(context).colorScheme.fontColor,
                  fontSize: textFontSize12,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                ),
                // prefixIcon: const Padding(
                //     padding: EdgeInsets.all(15.0),
                //     child: Icon(Icons.search)),
                suffixIcon: _controller.text != ''
                    ? IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _controller.text = '';
                    // notificationoffset = 0;
                  },
                  icon: const Icon(
                    Icons.close,
                    color: colors.primary,
                  ),
                ):IconButton(onPressed: (){}, icon: Icon(Icons.search)),
              ),
            ),
          ),
        ),
      );
}
    else{
      return Container();
    }
}

  floatingBtn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          backgroundColor: Theme
        .of(context)
        .colorScheme
        .primary,
          child: const Icon(
            Icons.add,
            size: 32,
            color: Color(0xff222222),
          ),
          onPressed: () {
            print(_tabController.index);
            if(_tabController.index == 0) {
              addSaveMilkCollected();

            }
            else if(_tabController.index == 1){
              Navigator.pushNamed(
                context,'/milkSales',
              ).then((_) {
                setState(() {
                getMilkCollectedApi();
                getMilkSold();
                });
              });

            }
            else{

            }
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
  Future<void> _refresh() {
    context.read<HomeProvider>().setMilkCollectionLoading(true);
    return callApi();
  }
  Future<void> callApi() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getMilkCollectedApi();
      getMilkSold();
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
    return;
  }

  _showContentOfMilkSold() {
    return RefreshIndicator(
    key: _refreshSalesIndicatorKey,
    onRefresh: _refresh,
      child: milkSalesList.isNotEmpty
          ? Column(
            children: [
              Expanded(
                child: ListView.builder(
                shrinkWrap: true,
                controller: milkSoldListController,
                itemCount: milkSalesList.length,
                itemBuilder: (context, index) {
                  return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                    child: Column(
                      children: [
                    Container(
                    margin: const EdgeInsets.symmetric(
                      //horizontal: 20.0,
                      vertical:2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                      // boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 3), // changes position of shadow
                      // )],
                    ),
                    padding: EdgeInsets.only(top: 10,right: 20.0,left: 10.0,bottom: 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Invoice: ${milkSalesList[index].transactionid!}",
                                    style: const TextStyle(
                                        color: Color(0xFF737373),
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: "Poppins"
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      "Date: ${milkSalesList[index].date!}",
                                      style: const TextStyle(
                                        color: Color(0xFF737373),
                                        fontSize: 10.0,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.black12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Buyer: ${milkSalesList[index].customerdata.name!}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF737373),
                                      fontSize: 10.0,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(width: 5,),
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 5),
                                        child: const Text("Total:",
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFF737373),
                                            fontSize: 10.0,
                                          ),
                                        ),
                                      ),
                                      Text("UGX ${milkSalesList[index].price! * milkSalesList[index].litres}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF737373),

                                          fontSize: 10.0,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 5),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF73B41A),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                        child: const Text("Paid" ,
                                          style: TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                      Text("UGX ${milkSalesList[index].paid!}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF737373),

                                          fontSize: 10.0,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Container(
                                    margin: EdgeInsets.only(left:30),
                                    // child: GestureDetector(
                                    //   onTap: (){},
                                    //   child: const Text("Edit",
                                    //     style: TextStyle(
                                    //       //backgroundColor: Color(0xFFF9C404),
                                    //       color: Color(0xFF73B41A),
                                    //       fontSize: 10.0,
                                    //       fontWeight: FontWeight.w800,
                                    //     ),
                                    //   ),
                                    // ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left:5, right: 0),
                                    // child: GestureDetector(
                                    //   onTap: (){},
                                    //   child: const Text("View",
                                    //     style: TextStyle(
                                    //       color: Color(0xFF73B41A),
                                    //       fontSize: 10.0,
                                    //       fontWeight: FontWeight.w800,
                                    //     ),
                                    //
                                    //   ),
                                    // ),
                                  )
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 5),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF9C404),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                        child: const Text("Due" ,
                                          style: TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                      Text("UGX. ${milkSalesList[index].litres! * milkSalesList[index].price!-milkSalesList[index].paid!}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF737373),

                                          fontSize: 10.0,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Container(
                                    margin: EdgeInsets.only(left:5, right: 0),
                                    child: GestureDetector(
                                      onTap: () {
                                        var id =milkSalesList[index].id;
                                        _showConfirmationMilkSaleDialog(id).then((_)=>setState((){
                                          getMilkSold();
                                        }));
                                      },
                                      child: const Text("Delete",
                                        style: TextStyle(
                                          //backgroundColor: Color(0xFFF9C404),
                                          color: Color(0xFFF00000),
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.bold,
                                        ),

                                      ),
                                    ),
                                  )
                                ],
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          )
          :Selector<HomeProvider, bool>(
        builder: (context, data, child) {
          return !data
              ? Center(
              child: Text(
                  getTranslated(context, 'No milk sales found')!))
              : Container();
        },
        selector: (_, provider) => provider.milkcollectionLoading,
      ),
    );
  }
  _getDasboardData(){
      return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refresh,
            child: Column(
        children: [
          Expanded(
            child:loading
                ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF73B41A)),
                ))
                : notificationisnodata
                ? getNoItem(context)
                : ListView.builder(
                shrinkWrap: true,
                controller: milkCollectedListController,
                itemCount: milkCollectedList.length,
               physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, index) {
                return  Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10),
                  child: listItem(index),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // _getDasboardData() {
  //   print("notification: $notificationisgettingdata");
  //   return RefreshIndicator(
  //         key: _refreshIndicatorKey,
  //         onRefresh: _refresh,
  //     child: Column(
  //       children: <Widget>[
  //         // searchResult(),
  //         Expanded(
  //             child: notificationisnodata
  //                 ? getNoItem(context)
  //                 : Stack(
  //               children: [
  //                 ListView.builder(
  //                   shrinkWrap: true,
  //                   controller: milkCollectedListController,
  //                   itemCount: milkCollectedList.length,
  //                   physics: const AlwaysScrollableScrollPhysics(),
  //                   itemBuilder: (BuildContext context, index) {
  //                     return  listItem(index);
  //                   },
  //                 ),
  //               ],
  //             )),
  //       ],
  //     ),
  //   );
  // }

  Widget listItem(int index) {
    if (index < milkCollectedList.length) {
      MilkCollected? model = milkCollectedList[index];
      return Container(
      margin: const EdgeInsets.symmetric(
      //horizontal: 20.0,
      vertical:2,
      ),
      decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(5.0),
      // boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 5, blurRadius: 7, offset: Offset(0, 3), // changes position of shadow
      // )],
      ),
      padding: EdgeInsets.only(top: 10,right: 20.0,left: 10.0,bottom: 10.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("TAG No ${model.tagno!}",
                        style: const TextStyle(
                            color: Color(0xFF737373),
                            fontSize: 10.0,
                            fontWeight: FontWeight.w800,
                            fontFamily: "Poppins"
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "Date: ${model.date!}",
                          style: const TextStyle(
                            color: Color(0xFF737373),
                            fontSize: 10.0,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Litres: ${model.litres}",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF737373),
                          fontSize: 10.0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(width: 5,),
                      Text("Price Per Litre: ${model.price!}".toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF737373),
                          fontSize: 10.0,
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total" ,
                        style: TextStyle(
                            color: Color(0xFF737373),
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(model.totalprice.toString()??"",
                        style: const TextStyle(
                          color: Color(0xFF737373),
                          fontSize: 10.0,
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(left:30),
                        // child: GestureDetector(
                        //   onTap: (){},
                        //   child: const Text("Edit",
                        //     style: TextStyle(
                        //       //backgroundColor: Color(0xFFF9C404),
                        //       color: Color(0xFF73B41A),
                        //       fontSize: 10.0,
                        //       fontWeight: FontWeight.w800,
                        //     ),
                        //   ),
                        // ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left:5, right: 0),
                        child: GestureDetector(
                          onTap: () {
                            var id=milkCollectedList[index].id;
                            _showConfirmationMilkCollectionDialog(id)
                                .then((_)=>setState((){
                              getMilkCollectedApi();
                            }));
                          },
                          child: const Text("Delete",
                            style: TextStyle(
                              //backgroundColor: Color(0xFFF9C404),
                              color: Color(0xFFF00000),
                              fontSize: 10.0,
                              fontWeight: FontWeight.w800,
                            ),

                          ),
                        ),
                      )
                    ],
                  ),

                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  getTotalIcomeAndExpenditureContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text("text"),
          ],
        ),
      ),
    );
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
   addSaveMilkCollected() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          title: Text(getTranslated(context, "SAVE_MILK_COLLECTED_LBL")!,
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
            child: Form(
              key: _addMilkCollectedKey,
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                focusNode: dateCollectedFocus,
                                controller: _dateCollected,
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
                                      _dateCollected.text = formattedDate;
                                    });
                                  }else{
                                  }
                                },
                                validator: (val) => validateFqmilyPop(
                                    val!,
                                    getTranslated(context, 'COLLECTION_DATE_REQUIRED')),
                                onSaved: (String? value) {
                                  dateCollected = value;
                                },
                                onFieldSubmitted: (v) {
                                  _fieldFocusChange(context, dateCollectedFocus!, dateCollectedLFocus);
                                },
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(color: Theme.of(context).colorScheme.fontColor),
                                decoration: InputDecoration(
                                  label: Text(getTranslated(context, 'DATE_COLLECTED_LBL')!),
                                  fillColor: Theme.of(context).colorScheme.white,
                                  isDense: true,
                                  hintText: getTranslated(context, 'DATE_COLLECTED_LBL'),
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
                              child: TypeAheadFormField<AnimalTag?>(
                                debounceDuration: Duration(milliseconds: 500,),
                                hideSuggestionsOnKeyboardHide: false,
                                textFieldConfiguration: TextFieldConfiguration(
                                controller: _tagNo,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(color: Theme.of(context).colorScheme.fontColor),
                                decoration: InputDecoration(
                                  label: Text(getTranslated(context, 'TAG_NO_LBL')!),
                                  fillColor: Theme.of(context).colorScheme.white,
                                  isDense: true,
                                  hintText: getTranslated(context, 'TAG_NO_LBL'),
                                  border: InputBorder.none,
                                ),
                              ),
                                suggestionsCallback: AnimalApi.getAnimalSuggestions,
                                itemBuilder: (context, AnimalTag? suggestion) {
                                  final animaltag = suggestion!;
                                  return ListTile(
                                    title: Text(animaltag.tagNumber),
                                  );
                                },
                                validator: (value) {
                                  if (value ==null) {
                                    return "required";
                                  } else
                                    return null;
                                },
                                noItemsFoundBuilder: (context) => Container(
                                  height: 100,
                                  child:  Center(
                                    child: Text(
                                      'No animal found, add one and try again',
                                        style: Theme.of(context)
                                            .textTheme.titleLarge!
                                            .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14)                                    ),
                                  ),
                                ),
                                onSuggestionSelected: (AnimalTag? suggestion) {
                                  final animal = suggestion!;
                                  this._tagNo.text=animal.tagNumber;
                                  tagNo=(animal.id);
                                },
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
                              keyboardType: TextInputType.number,
                              controller: _litres,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              textInputAction: TextInputAction.next,
                              focusNode: litresFocus,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
                              validator: (val) => validateFqmilyPop(
                                val!,
                                getTranslated(context, 'LITRES_REQUIRED'),
                              ),
                              onSaved: (String? value) {
                                litres = value;
                              },
                              onFieldSubmitted: (v) {
                                _fieldFocusChange(context, litresFocus!, litresLFocus);
                              },
                              decoration: InputDecoration(
                                  label: Text(getTranslated(context, 'LITRES_LBL')!),
                                  fillColor: Theme.of(context).colorScheme.white,
                                  isDense: true,
                                  hintText: getTranslated(context, 'LITRES_LBL'),
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
                              keyboardType: TextInputType.number,
                              controller: _price,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              textInputAction: TextInputAction.next,
                              focusNode: priceFocus,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
                              validator: (val) => validateFqmilyPop(
                                val!,
                                getTranslated(context, 'PRICE_REQUIRED'),
                              ),
                              onSaved: (String? value) {
                                price = value;
                              },
                              onFieldSubmitted: (v) {
                                _fieldFocusChange(context, priceFocus!, priceLFocus);
                              },
                              decoration: InputDecoration(
                                  label: Text(getTranslated(context, 'PRICE_LBL')!),
                                  fillColor: Theme.of(context).colorScheme.white,
                                  isDense: true,
                                  hintText: getTranslated(context, 'PRICE_LBL'),
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
                                maxLines: 2,
                                controller: _notestxt,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                focusNode:notesFocus ,
                                textCapitalization: TextCapitalization.words,
                                onSaved: (String? value) {
                                  notes = value;
                                },
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(color: Theme.of(context).colorScheme.fontColor),
                                decoration: InputDecoration(
                                  label: Text(getTranslated(context, 'VACCINE_NOTES_LBL')!),
                                  fillColor: Theme.of(context).colorScheme.white,
                                  isDense: true,
                                  hintText: getTranslated(context, 'VACCINE_NOTES_LBL'),
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
                    btnAnim: buttonSqueezeanimation,
                    btnCntrl: buttonController,
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
    if (validateMilkCollectionAndSave()) {
      _playAnimation();
      saveMilkCollection();
    }
  }
  bool validateMilkCollectionAndSave() {
    final form = _addMilkCollectedKey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }


  Future<bool> _showConfirmationMilkCollectionDialog(String itemId) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          content: Container(
            width: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // const Text("Are you sure you want to delete this color?"),

                Container(
                  margin: EdgeInsets.only(left: 5.0, top: 5, right: 5.0),
                  child: const Text(
                    "Are you sure you want to delete this milk collection?",
                    style: TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
                children: [
                  Expanded(
                    flex:2,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text(getTranslated(context, "CANCEL")!),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: AppBtn(
                      title: getTranslated(context, 'DELETE_LBL'),
                      btnAnim: buttonSqueezeanimation,
                      btnCntrl: buttonController,
                      onBtnSelected: () async {
                        _playAnimation();
                        milkCollectedid=itemId;
                        deleteMilkCollectionCatalog();
                      },
                    ),
                  ),
                ]
            )
          ],
        );
      },
    );
  }//delete breed
  Future<bool> _showConfirmationMilkSaleDialog(String itemId) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          content: Container(
            width: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // const Text("Are you sure you want to delete this color?"),

                Container(
                  margin: EdgeInsets.only(left: 5.0, top: 5, right: 5.0),
                  child: const Text(
                    "Are you sure you want to delete this milk sale?",
                    style: TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
                children: [
                  Expanded(
                    flex:2,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text(getTranslated(context, "CANCEL")!),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: AppBtn(
                      title: getTranslated(context, 'DELETE_LBL'),
                      btnAnim: buttonSqueezeanimation,
                      btnCntrl: buttonController,
                      onBtnSelected: () async {
                        _playAnimation();
                        milkSalesid=itemId;
                        deleteMilkSaleCatalog();
                      },
                    ),
                  ),
                ]
            )
          ],
        );
      },
    );
  }//delete breed
  deleteMilkCollectionCatalog() async {
    bool avail = await isNetworkAvailable();
    if (avail) {

      Response dResponse = await delete(Uri.parse("${baseUrl}milkcollection/$milkCollectedid"),
          headers: headers);
      print(milkCollectedid);
      print(dResponse.body);
      await buttonController!.reverse();
      if (dResponse.statusCode == 401) {
        getNewToken(context, deleteMilkCollectionCatalog);
      }
      else if (dResponse.statusCode == 404) {
        setSnackbar("data not deleted");
      }
      else if (dResponse.statusCode == 200) {
        setSnackbar("Deleted Successfully");
        getMilkCollectedApi();
        Future.delayed(const Duration(seconds: 1)).then((_) {
          Navigator.of(context, rootNavigator: true).pop();
        });
      }
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
  deleteMilkSaleCatalog() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      print(milkSalesid);
      Response dResponse = await delete(Uri.parse("${baseUrl}sell-milk/$milkSalesid"),
          headers: headers);
      await buttonController!.reverse();
      // breedList.clear();
      print(dResponse.body);
      if (dResponse.statusCode == 401) {
        getNewToken(context, deleteMilkSaleCatalog);
      }
      else if (dResponse.statusCode == 404) {
        setSnackbar("data not deleted");
      }
      else if (dResponse.statusCode == 200) {
        setSnackbar("Deleted Successfully");
        Future.delayed(const Duration(seconds: 1)).then((_) {
          Navigator.of(context, rootNavigator: true).pop();
        });
        getMilkSold();
      }
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

  saveMilkCollection() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      Map postdata = {
        DATE_COLLECTED: dateCollected,
        LITRES: litres,
        PRICE: price,
        ANIMAL: tagNo,
        NOTES: notes,
      };
      var _json= utf8.encode(jsonEncode(postdata));
      Response response = await post(addMilkCollectedApi, headers: headers, body: _json);
      await buttonController!.reverse();
      var getdata= jsonDecode(response.body);
      // String? msg = getdata['messages'][0].toString();
      if(response.statusCode==401){
        getNewToken(context,saveMilkCollection());
      }
      else if(response.statusCode==201){
        _clearValues();
        setSnackbar("milk collection saved");
        Future.delayed(const Duration(seconds: 1)).then((_) {
          Navigator.of(context, rootNavigator: true).pop();
        });
        setState(() {
          getMilkCollectedApi();
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
  _clearValues() {
    _notestxt.text='';
    _dateCollected.text = '';
    _litres.text = '';
    _price.text = '';
    _tagNo.text='';
  }

  Future<void> getMilkCollectedApi() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
          var response = await get(addMilkCollectedApi, headers: headers);
          var getdata = json.decode(response.body);
          bool success = getdata['success'];
          String? msg = getdata['message'];
          List<MilkCollected> tempdata = [];
          milkCollectedList.clear();
          notificationisgettingdata = false;

          if (success == true) {
            loading = false;
            if (response.statusCode == 200) {
              milkCollectedTotalCount =
                  int.parse(getdata['data']['rows_returned'].toString());
              notificationisgettingdata = false;
              if (milkCollectedTotalCount == 0) {
                notificationisnodata = true;
              }
              else {
                notificationisnodata = false;
              }
              if (mounted) {
                Future.delayed(
                    Duration.zero,
                        () =>
                        setState(() {
                          var data = getdata['data']['milk_collected'];
                          tempdata = (data as List).map((data) =>
                              MilkCollected.fromJson(data)).toList();
                          milkCollectedList.addAll(tempdata);
                        }));
              }
            }
          }
          else{
            loading = false;
            if (response.statusCode == 401) {
            loading = false;
            getNewToken(context, getMilkCollectedApi());
          }
          else {
            setSnackbar(msg!);
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
        // if (mounted) {
        //   setState(() {
        //     notificationisloadmore = false;
        //   });
        // }
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  Future<void> getMilkSold() async {
    Map parameter = {
      LIMIT: perPage.toString(),
      OFFSET: milkSoldOffset.toString(),
    };

    Response response =
    await get(getMilkSoldApi, headers: headers)
        .timeout(const Duration(seconds: timeOut));
    var getdata = json.decode(response.body);

    bool success = getdata['success'];
    String? msg = getdata['message'];
    List<MilkSold> milkSoldList = [];
    milkSalesList.clear();

    if (success==true) {
      milkSoldTotalCount = int.parse(getdata['data']['rows_returned'].toString());
      var data = getdata['data']['milk_sold'];
      milkSoldList =
          (data as List).map((data) => MilkSold.fromJson(data)).toList();
      milkSoldOffset += perPage;
      setState(() {});
    } else {
      setSnackbar(
        msg!,
      );
    }
    milkSalesList.addAll(milkSoldList);
    context.read<HomeProvider>().setMilkCollectionLoading(false);
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

}
