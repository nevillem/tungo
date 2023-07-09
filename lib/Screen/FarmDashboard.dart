
import 'dart:async';
import 'dart:convert';

import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Screen/Add_Address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Helper/update_access_token.dart';
import '../Model/Income.dart';
import '../Model/other_dashboard_report.dart';
import '../Provider/HomeProvider.dart';
import '../Provider/SettingProvider.dart';
import '../Provider/ShopProvider.dart';
import '../Provider/UserProvider.dart';
import '../Provider/dashboard_provider.dart';
import 'Catalog_dashboard.dart';
import 'LivestockGraph.dart';
import 'ManageAnimalMain.dart';
import 'milk_palor_dashboard.dart';

class FarmDashboard extends StatefulWidget {
  const FarmDashboard({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateFarmDashboard();
  }
}

class StateFarmDashboard extends State<FarmDashboard> with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  final bool _isProgress = false;
  late AnimationController listViewIconController;
  late AnimationController _animationController;
  bool notificationisnodata = false,
      notificationisgettingdata = false;
  // List<Gender> dashBoardList = [];

  @override
  void initState() {

    listViewIconController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

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
    getDashboardData();

    super.initState();
  }

  @override
  void dispose() {
    buttonController!.dispose();
    // productsController!.dispose();
    // sellerListController!.dispose();
    _tabController.dispose();
    listViewIconController.dispose();
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
          getTranslated(context, 'MANAGE_LIVESTOCK_LBL')!,
          style:
          const TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
        ),
      ),
      body: _isNetworkAvail ?  Column(children: [
        Container(
          color: Theme.of(context).colorScheme.white,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Text(getTranslated(context, 'FARM_DASHBOARD')!),
              ),
              Tab(
                child: Text(getTranslated(context, 'FARM_INCOME')!),
              ),
              Tab(
                child: Text(getTranslated(context, 'FARM_EXPENDITURE')!),
              ),

            ],
            indicatorColor: colors.primary,
            labelColor: Theme.of(context).colorScheme.fontColor,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor:
            Theme.of(context).colorScheme.lightBlack,
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
                  Selector<HomeProvider, bool>(
                    builder: (context, data, child) {
                      return Center(
                        child: showCircularProgress(
                            data, colors.primary),
                      );
                    },
                    selector: (_, provider) => provider.sellerLoading,
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
                    selector: (_, provider) => provider.sellerLoading,
                  ),
                ],
              ),

            ],
          ),
        ),
      ],) : noInternet(context),
    );
  }
  _getDasboardData(){
    return Column(
      children: <Widget>[
        Expanded(
            child: notificationisnodata
                ? getNoItem(context)
                : Stack(
              children: [
                getTotalIcomeAndExpenditureContainer(),
                notificationisgettingdata
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : Container(),
              ],
       )),
      ],
    );
  }
  getTotalIcomeAndExpenditureContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
           dashboardWidgets(),
           reportCharts(),
           dashboardMenu()
          ],
        ),
      ),
    );
  }
 Widget dashboardWidgets(){
   List<Gender> gendertList = context.read<MilkDashboardProvider>().genderList;

   return  Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.lightWhite,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Container(
            height: 90,
            // margin: const EdgeInsets.only(left: 10, right: 10, top: 10,),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.lightWhite,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      // Text('Ugx. 0',
                      //     textAlign: TextAlign.center,
                      //     style: TextStyle(
                      //       fontWeight: FontWeight.w800,
                      //       fontSize: 16,
                      //       overflow: TextOverflow.ellipsis,
                      //       color: Color(0xFF737373),
                      //     )
                      // ),
                      Selector<ShopProvider, String>(
                        builder: (context, expenses, child) {
                          return Text('${getPriceFormat(context, double.parse(expenses))!}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                overflow: TextOverflow.ellipsis,
                                color: Theme.of(context).colorScheme.fontColor,
                              )
                          );
                        },
                        selector: (_, exploreProvider) => exploreProvider.totalExpenses,
                      ),
                      SizedBox(height: 2,),
                      const Text(
                        'Total Monthly Expenditure',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.normal,
                          fontSize: 12,
                          color: Color(0xFF737373),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  color: Colors.grey.withOpacity(0.4),
                  width: 1,
                ), // THE DIVIDER. CHANGE THIS TO ACCOMMODATE YOUR NEEDS
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Selector<ShopProvider, String>(
                        builder: (context, income, child) {
                          return Text('${getPriceFormat(context, double.parse(income))!}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                overflow: TextOverflow.ellipsis,
                                color: Theme.of(context).colorScheme.fontColor,
                              )
                          );
                        },
                        selector: (_, exploreProvider) => exploreProvider.totalIncome,
                      ),
                      SizedBox(height: 2,),
                      const Text('Total Monthly Income',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.normal,
                            fontSize: 12,
                            color: Color(0xFF737373)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:gendertList.isNotEmpty
                ?
            ListView.builder(
              shrinkWrap: true,
              // controller: colorListController,
              itemCount: gendertList.length,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index){
               return Column(
                 children: <Widget>[
                   Container(
                       decoration: BoxDecoration(
                         color: Theme.of(context).colorScheme.lightWhite,
                         borderRadius: BorderRadius.circular(5),
                       ),
                       height: 60,
                       child: Row(
                           children: [
                             Expanded(
                               child: Column(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Container(
                                     decoration: BoxDecoration(
                                       color: Color(0xFF73B41A),

                                       borderRadius: BorderRadius.circular(15),
                                     ),
                                     padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                     child: Text('Total Animals',
                                       style: TextStyle(
                                           fontWeight: FontWeight.normal,
                                           fontSize: 12,
                                         color: Theme.of(context).colorScheme.fontColor,
                                       ),
                                     ),
                                   ),
                                   Text(
                                     '${gendertList[index].total}',
                                     style: TextStyle(fontWeight: FontWeight.normal,
                                       fontSize: 13,
                                       overflow: TextOverflow.ellipsis,
                                       color: Theme.of(context).colorScheme.fontColor,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                             Container(
                               margin: const EdgeInsets.symmetric(vertical: 5),
                               color: Colors.grey.withOpacity(0.4),
                               width: 1,
                             ), // THE DIVIDER. CHANGE THIS TO ACCOMMODATE YOUR NEEDS
                             Expanded(
                               child: Column(
                                 mainAxisAlignment: MainAxisAlignment.center,

                                 children: [
                                   Container(
                                     decoration: BoxDecoration(
                                       color: Color(0xFF73B41A),
                                       borderRadius: BorderRadius.circular(15),
                                     ),
                                     padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                     child: Text('Total Male',
                                       style: TextStyle(
                                         fontWeight: FontWeight.normal,
                                         fontSize: 12,
                                         color: Theme.of(context).colorScheme.fontColor,
                                       ),
                                     ),
                                   ),
                                   Container(
                                     margin: const EdgeInsets.symmetric(vertical: 2),
                                     color: Colors.grey.withOpacity(0.4),
                                     width: 1,
                                   ),
                                   Text(gendertList[index].male??"0",
                                     style: TextStyle(fontWeight: FontWeight.normal,
                                         fontSize: 13,
                                       overflow: TextOverflow.ellipsis,
                                       color: Theme.of(context).colorScheme.fontColor,
                                     ),
                                   ),
                                 ],
                               ),
                             )
                           ]
                       )
                   ),
                   Container(
                     margin: const EdgeInsets.symmetric(vertical:1),
                     color: Colors.grey.withOpacity(0.4),
                     width: 1,
                   ),
                   Container(
                       decoration: BoxDecoration(
                         color: Theme.of(context).colorScheme.lightWhite,
                         borderRadius: BorderRadius.circular(5),
                       ),
                       height: 60,
                       child: Row(
                           children: [
                             Expanded(
                               child: Column(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Container(
                                     decoration: BoxDecoration(
                                       color: Color(0xFF73B41A),

                                       borderRadius: BorderRadius.circular(15),
                                     ),
                                     padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                     child: Text('Total Female',
                                       style: TextStyle(
                                           fontWeight: FontWeight.normal,
                                           fontSize: 12,
                                         color: Theme.of(context).colorScheme.fontColor,
                                       ),
                                     ),
                                   ),
                                    Text(
                                     gendertList[index].female??"0",
                                     style: TextStyle(
                                       fontWeight: FontWeight.normal,
                                       fontSize: 13,
                                       overflow: TextOverflow.ellipsis,
                                       color: Theme.of(context).colorScheme.fontColor,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                             Container(
                               margin: const EdgeInsets.symmetric(vertical: 5),
                               color: Colors.grey.withOpacity(0.4),
                               width: 1,
                             ), // THE DIVIDER. CHANGE THIS TO ACCOMMODATE YOUR NEEDS
                             Expanded(
                               child: Column(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Container(
                                     decoration: BoxDecoration(
                                       color: Color(0xFF73B41A),
                                       borderRadius: BorderRadius.circular(15),
                                     ),
                                     padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                     child: Text('Total Milk Collected',
                                       style: TextStyle(
                                           fontWeight: FontWeight.normal,
                                           fontSize: 12,
                                         color: Theme.of(context).colorScheme.fontColor,
                                       ),
                                     ),
                                   ),
                                   Container(
                                     margin: const EdgeInsets.symmetric(vertical: 2),
                                     color: Colors.grey.withOpacity(0.4),
                                     width: 1,
                                   ),
                                   Selector<ShopProvider, String>(
                                     builder: (context, totalMilk, child) {
                                       return Text('$totalMilk',
                                         style: TextStyle(
                                           fontWeight: FontWeight.normal,
                                           fontSize: 13,
                                           overflow: TextOverflow.ellipsis,
                                           color: Theme.of(context).colorScheme.fontColor,
                                           )
                                       );
                                     },
                                     selector: (_, exploreProvider) => exploreProvider.totalMilkCollected,
                                   ),
                                 ],
                               ),
                             )
                           ]
                       )
                   ),
                 ],
               );
            },
            ):Selector<MilkDashboardProvider, bool>(
              builder: (context, data, child) {
                return Center(
                  child: showCircularProgress(
                      data, colors.primary),
                );
              },
              selector: (_, provider) => provider.isProgress,
            ),
          ),
        ],
      ),
    );
 }

 Widget reportCharts(){
 return Padding(
   padding: const EdgeInsets.all(10.0),
   child: Container(
     decoration: BoxDecoration(
       color: Theme.of(context).colorScheme.lightWhite,
       borderRadius: BorderRadius.circular(5),
     ),
     child: Column(
       children: [
         Container(
           margin: EdgeInsets.symmetric(horizontal: 5),
           height: 300,
           // child: LegendOptions.withSampleData(),
           child: LiveStockStatistics(),
         ),
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           children: [
             Container(
               decoration: BoxDecoration(
                 color: Color(0xFFF9C404),
                 borderRadius: BorderRadius.circular(5),
               ),
               margin: const EdgeInsets.only(
                 top: 4.0,
                 left: 5.0,
               ),
               padding: const EdgeInsets.fromLTRB(13, 5, 13, 5),
               child:  Text(getTranslated(context, "TODAY")!,
                 style: TextStyle(
                     fontWeight: FontWeight.normal,
                   color: Theme.of(context).colorScheme.lightWhite,
                 ),),
             ),
             Container(
               padding: EdgeInsets.fromLTRB(13, 5, 13, 5),
               decoration: BoxDecoration(
                 color: Color(0xFFF9C404),
                 borderRadius: BorderRadius.circular(5),
               ),
               margin: const EdgeInsets.only(
                 top: 4.0,
                 left: 5.0,
               ),
               child:  Text(getTranslated(context,'WEEKLY')!,
                 style: TextStyle(
                     fontWeight: FontWeight.normal,
                   color: Theme.of(context).colorScheme.lightWhite,
                 ),),
             ),
             Container(
               padding: EdgeInsets.fromLTRB(13, 5, 13, 5),
               decoration: BoxDecoration(
                 color: Color(0xFFF9C404),
                 borderRadius: BorderRadius.circular(5),
               ),
               margin: const EdgeInsets.only(
                 top: 4.0,
                 left: 5.0,
               ),
               child: Text(getTranslated(context, "MONTHLY")!,
                 style: TextStyle(
                   fontWeight: FontWeight.normal,
                   color: Theme.of(context).colorScheme.lightWhite,
                 ),
               ),
             ),
             Container(
               padding: EdgeInsets.fromLTRB(13, 5, 13, 5),
               decoration: BoxDecoration(
                 color: Color(0xFFF9C404),
                 borderRadius: BorderRadius.circular(5),
               ),
               margin: const EdgeInsets.only(
                 top: 4.0,
                 left: 5.0,
               ),
               child: Text(getTranslated(context, "YEARLY")!,
                 style: TextStyle(
                     fontWeight: FontWeight.normal,
                   color: Theme.of(context).colorScheme.lightWhite,
                 ),),
             )
           ],
         ),
         SizedBox(height: 10,),
       ],
     ),
   ),
 );
 }

  Widget dashboardMenu(){
    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.lightWhite,
          borderRadius: BorderRadius.circular(5),
        ),
    child: Column(
      children: [
        _setCatalogButton(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: _setAddAnimalButton(),
            ),
            SizedBox(width: 10,),
            Expanded(
              flex: 5,
              child: _setAddMilkPalour(),
            ),
          ],
        ),
        // SizedBox(width: 10,),
      ],
    ),
    );
  }
  _setAddAnimalButton(){
    return GestureDetector(
      onTap: (){

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ManageAnimalMain()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF737373),
          borderRadius: BorderRadius.circular(5.0),
        ),
        height: 40,
        child:Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Icon(FontAwesomeIcons.democrat,
                size: 15,
                color: Color(0xFFFFFFFF),),
              Container(
                margin:EdgeInsets.only(left:2),
                //height: screenHeight * 0.20,
                child: Text(getTranslated(context, "MANAGE_ANIMAL")!,
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 12.0,
                    //fontWeight:FontWeight.w800,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 2,
                ),
              ),
              const Icon(FontAwesomeIcons.angleRight,
                size: 10,
                color: Color(0xFFFFFFFF),
              )
            ]),
      ),
    );
  }

  _setAddMilkPalour(){
    return GestureDetector(
      onTap: (){
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MilkParlorDashboard()));
      },
      child: Container(
        // margin: const EdgeInsets.symmetric(
        //   vertical: 4.0,
        //   horizontal: 5.0,
        // ),
        decoration: BoxDecoration(
          color: Color(0xFF737373),
          borderRadius: BorderRadius.circular(5.0),
        ),
        height: 40,
        child:Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(FontAwesomeIcons.fireFlameSimple,
                size: 15,
                color: Color(0xFFFFFFFF),),
              Container(
                margin:EdgeInsets.only(left:2),
                //height: screenHeight * 0.20,
                child: Text(getTranslated(context, "MILK_PALOR")!,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 12.0,
                    //fontWeight:FontWeight.w800,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 2,
                ),
              ),
              Icon(FontAwesomeIcons.angleRight,
                size: 10,
                color: Color(0xFFFFFFFF),)
            ]),
      ),
    );
  }
  _setCatalogButton(){
    return GestureDetector(
      onTap: (){
        print("object");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CatalogDashboard()));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF737373),
            borderRadius: BorderRadius.circular(5.0),
          ),
          height: 40,
          child:Row(
              // mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const Icon(FontAwesomeIcons.chartPie,
                  size: 15,
                  color: Color(0xFFFFFFFF),),
                Container(
                  margin:EdgeInsets.only(left:2),
                  //height: screenHeight * 0.20,
                  child:  Text(getTranslated(context, "CATALOG")!,
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 12.0,
                      //fontWeight:FontWeight.w800,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 2,
                  ),
                ),
                const Icon(FontAwesomeIcons.angleRight,
                  size: 10,
                  color: Color(0xFFFFFFFF),
                )
         ]),
        ),
      ),
    );
  }
  Widget sliderLoading() {
    double width = deviceWidth!;
    double height = width / 2;
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.white,
            borderRadius: BorderRadius.circular(10),),
          width: double.infinity,
          height: height,
        ));
  }
  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
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
  Future<void> getDashboardData() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {

    var response = await get(otherDataUrl, headers: headers);
    var getdata = json.decode(response.body);
    bool success = getdata['success'];
    String? msg = getdata['message'];
    // dashBoardList.clear();
    List<Gender> tempdata = [];
    if (success==true) {
      var data = getdata['data']['gender'];
      context.read<ShopProvider>().setMilkCollectedTotal(getdata['data']["milkCollected"][0]['total']?.toString()??
          context.read<ShopProvider>().totalMilkCollected);
      context.read<ShopProvider>().setExpenseTotal(getdata['data']["expensesTotal"][0]['expenditure']?.toString()??
          context.read<ShopProvider>().totalExpenses);
      context.read<ShopProvider>().setIncomeTotal(getdata['data']["incomeCollected"][0]['income']?.toString()??
          context.read<ShopProvider>().totalIncome);

      tempdata=(data as List).map((data) =>  Gender.fromJson(data)).toList();
      setState(() {});
      // dashBoardList.addAll(tempdata);
    }
    else{
      if(response.statusCode==401) {
        getNewToken(context,getDashboardData);
      }else {
        setSnackbar(
            msg!
        );
      }
    }
    context.read<MilkDashboardProvider>().setProgress(false);
    context.read<MilkDashboardProvider>().setDashboardList(tempdata);
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

}
