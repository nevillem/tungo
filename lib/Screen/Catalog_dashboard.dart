import 'dart:async';
import 'dart:convert';
import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Model/models_b.dart';
import 'package:agritungotest/Model/monitoring_model.dart';
import 'package:agritungotest/Model/vaccine_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Helper/update_access_token.dart';
import '../Model/ColorModel.dart';
import '../Model/model_stall.dart';
import '../Provider/HomeProvider.dart';
import '../Provider/SettingProvider.dart';
import '../Provider/UserProvider.dart';
import 'LivestockGraph.dart';
import 'Login.dart';
import 'ManageAnimalMain.dart';

class CatalogDashboard extends StatefulWidget {
  const CatalogDashboard({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateCatalogDashboard();
  }
}

class StateCatalogDashboard extends State<CatalogDashboard> with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormFieldState> _colorKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _stallKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _vaccineKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _repeatKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _dozeKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _vaccinePeriodKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _notesKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _breedKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _monitoringKey = GlobalKey<FormFieldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =GlobalKey<RefreshIndicatorState>();
  late TabController _tabController;
  final bool _isProgress = false;
  late AnimationController listViewIconController;
  late AnimationController _animationController;
  var colorNametxt = TextEditingController();
  var breedNametxt = TextEditingController();
  var stallNametxt = TextEditingController();
  var vaccinetxt = TextEditingController();
  var vaccineperiodtxt = TextEditingController();
  var vaccineDozetxt = TextEditingController();
  var vaccinenotestxt = TextEditingController();
  var vaccinerepeattxt = TextEditingController();
  var monitoringNametxt = TextEditingController();
  FocusNode? colorFocus,stallFocus, vaccinenameFocus,dozeFocus,
      repeatFocus,notesFocus,periodFocus, breedFocus,monitoringFocus;
  String? colonames,stallNames, vaccinenames, vaccinedoze, vaccineperiod,
      notes, repeat, breedNames;
  List<Map> _option = [{"option":"Yes"}, {"option":"No"}];
  String? colorId, breedsid, vaccinesid, stallsid, motoringcategoriesid, monitoringNames;
  bool notificationisnodata = false,
      notificationisgettingdata = false;
  List<ModelColors> colorsList = [];
  List<BreedModel> breedList = [];
  List<ModelStall> stallList = [];
  List<VaccinationModel> vaccineList = [];
  List <MonitoringModel> monitoringModel = [];
  ScrollController? colorListController;
  ScrollController? stallListController;
  ScrollController? vaccineListController;
  ScrollController? breedListController;
  ScrollController? monitoringListController;

  int totalColorCount = 0;
  int totalStallCount = 0;
  int totalVaccineCount = 0;
  int totalBreedCount = 0;
  int totalMonitoringCount = 0;
  int colorListOffset = 0;
  int stallListOffset = 0;
  int vaccineListOffset = 0;
  int breedListOffset = 0;
  int monitoringListOffset = 0;

  @override
  void initState() {
    colorListController = ScrollController(keepScrollOffset: true);
    colorListController!.addListener(_sellerListController);
    vaccineListController = ScrollController(keepScrollOffset: true);
    vaccineListController!.addListener(_vaccineListController);
    stallListController = ScrollController(keepScrollOffset: true);
    stallListController!.addListener(_stallListController);
    breedListController = ScrollController(keepScrollOffset: true);
    breedListController!.addListener(_breedListController);
    monitoringListController = ScrollController(keepScrollOffset: true);
    monitoringListController!.addListener(_monitoringListController);

    listViewIconController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _tabController = TabController(
      length: 5,
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
    callApi();
    super.initState();
  }

  _sellerListController() {
    if (colorListController!.offset >=
        colorListController!.position.maxScrollExtent &&
        !colorListController!.position.outOfRange) {
      if (mounted) {
        if (colorListOffset < totalColorCount) {
          getColors();
          setState(() {});
        }
      }
    }
  }
 _stallListController() {
    if (stallListController!.offset >=
        stallListController!.position.maxScrollExtent &&
        !stallListController!.position.outOfRange) {
      if (mounted) {
        if (stallListOffset < totalStallCount) {
          getStallsApi();
          setState(() {});
        }
      }
    }
  }
  _breedListController() {
    if (breedListController!.offset >=
        breedListController!.position.maxScrollExtent &&
        !breedListController!.position.outOfRange) {
      if (mounted) {
        if (breedListOffset < totalBreedCount) {
          getBreedApi();
          setState(() {});
        }
      }
    }
  }
_vaccineListController() {
    if (vaccineListController!.offset >=
        vaccineListController!.position.maxScrollExtent &&
        !vaccineListController!.position.outOfRange) {
      if (mounted) {
        if (vaccineListOffset < totalVaccineCount) {
          getVaccineApi();
          setState(() {});
        }
      }
    }
  }
  _monitoringListController() {
    if (monitoringListController!.offset >=
        monitoringListController!.position.maxScrollExtent &&
        !monitoringListController!.position.outOfRange) {
      if (mounted) {
        if (monitoringListOffset < totalMonitoringCount) {
          getMonitoringApi();
          setState(() {});
        }
      }
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    vaccineListController!.dispose();
    colorListController!.dispose();
    _tabController.dispose();
    listViewIconController.dispose();
    _animationController.dispose();
    ScaffoldMessenger.of(context).clearSnackBars();
    colorNametxt.dispose();
    stallNametxt.dispose();
    vaccinenotestxt.dispose();
    vaccineperiodtxt.dispose();
    vaccineDozetxt.dispose();
    vaccinerepeattxt.dispose();
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
                  callApi();
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
          getTranslated(context, 'MANAGE_CATALOG_LBL')!,
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
                child: Text(getTranslated(context, 'CATALOG_ANIMAL_COLORS')!),
              ),
              Tab(
                child: Text(getTranslated(context, 'CATALOG_ANIMAL_BREED')!),
              ),
              Tab(
                child: Text(getTranslated(context, 'CATALOG_ANIMAL_STALLS')!),
              ),
              Tab(
                child: Text(getTranslated(context, 'CATALOG_ANIMAL_VACCINES')!),
              ),
              Tab(
                child: Text(getTranslated(context, 'CATALOG_ANIMAL_MONITORING')!),
              ),
              // Tab(
              //   child: Text(getTranslated(context, 'CATALOG_ANIMAL_Branches')!),
              // ),

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
                  _getShowColorData(),
                  Selector<HomeProvider, bool>(
                    builder: (context, data, child) {
                      return Center(
                        child: showCircularProgress(
                            data, colors.primary),
                      );
                    },
                    selector: (_, provider) => provider.catalogLoading,
                  ),
                ],
              ),
              Stack(
                children: <Widget>[
                  _getShowBreedData(),
                  Selector<HomeProvider, bool>(
                    builder: (context, data, child) {
                      return Center(
                        child: showCircularProgress(
                            data, colors.primary),
                      );
                    },
                    selector: (_, provider) => provider.catalogLoading,
                  ),
                ],
              ),
              Stack(
                children: <Widget>[
                  _getShowStallData(),
                  Selector<HomeProvider, bool>(
                    builder: (context, data, child) {
                      return Center(
                        child: showCircularProgress(
                            data, colors.primary),
                      );
                    },
                    selector: (_, provider) => provider.catalogLoading,
                  ),
                ],
              ),
              Stack(
                children: <Widget>[
                  _showVaccineData(),
                  Selector<HomeProvider, bool>(
                    builder: (context, data, child) {
                      return Center(
                        child: showCircularProgress(
                            data, colors.primary),
                      );
                    },
                    selector: (_, provider) => provider.catalogLoading,
                  ),
                ],
              ),
              Stack(
                children: <Widget>[
                  _getshowMonitoring(),
                  Selector<HomeProvider, bool>(
                    builder: (context, data, child) {
                      return Center(
                        child: showCircularProgress(
                            data, colors.primary),
                      );
                    },
                    selector: (_, provider) => provider.catalogLoading,
                  ),
                ],
              ),

            ],
          ),
        ),
      ],) : noInternet(context),
    );
  }
  Future<void> _refresh() {
    context.read<HomeProvider>().setCatalogLoading(true);
    return callApi();
  }
  Future<void> callApi() async {
    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    SettingProvider setting =
    Provider.of<SettingProvider>(context, listen: false);
    user.setUserId(setting.userId);

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getColors();
      getStallsApi();
      getVaccineApi();
      getBreedApi();
      getMonitoringApi();
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
    return;
  }
  _getShowColorData(){
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: Column(
        children: [
          addAnimalColors(getTranslated(context, 'ANIMAL_COLORS_LBL')!, () {
            addColorsModel();
          }),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: colorsList.isNotEmpty?
                  ListView.builder(
                    shrinkWrap: true,
                      controller: colorListController,
                    itemCount: colorsList.length,
                    itemBuilder: (context, int index) {
                      return Container(
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color:
                            Theme
                            .of(context)
                            .colorScheme
                            .lightBlack2))),
                        child: ListTile(
                       leading: Text(
                      colorsList[index].colorName,
                          style: Theme.of(context)
                              .textTheme.titleLarge!
                              .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14)
                      ),
                      trailing:TextButton(
                          onPressed:  () {
                          },
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Theme.of(context).primaryColor;
                              }
                              return null; // Defer to the widget's default.
                            }),
                          ),
                          child: GestureDetector(
                              onTap: () {
                                _showConfirmationDialog(colorsList[index].id).then((_)=>setState((){
                                  getColors();
                                }));
                              },
                            child: Container(
                        decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(5)
                        ),
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              child: Text('Delete',
                                style: Theme.of(context)
                        .textTheme.titleLarge!
                        .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14),
                              ),
                            ),
                          ),
                      ),
                        ),
                      );
                  }):Selector<HomeProvider, bool>(
                builder: (context, data, child) {
                  return !data
                      ? Center(
                      child: Text(
                          getTranslated(context, 'No Animal Colors Saved Yet')!))
                      : Container();
                },
                selector: (_, provider) => provider.catalogLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }
 _getShowBreedData(){
    return Column(
      children: [
        addAnimalColors(getTranslated(context, 'ANIMAL_BREED_LBL')!, () {
          addBreedsModel();
        }),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: breedList.isNotEmpty?
                ListView.builder(
                  shrinkWrap: true,
                  controller: breedListController,
                  itemCount: breedList.length,
                  itemBuilder: (context, int index) {
                    return Container(
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color:
                          Theme
                          .of(context)
                          .colorScheme
                          .lightBlack2))),
                      child: ListTile(
                     leading: Text(
                         breedList[index].breedName,
                        style: Theme.of(context)
                            .textTheme.titleLarge!
                            .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14)
                    ),
                    trailing:TextButton(
                        onPressed:  () {
                        },
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Theme.of(context).primaryColor;
                            }
                            return null; // Defer to the widget's default.
                          }),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            _showConfirmationBreedDialog(breedList[index].id).then((_)=>setState((){
                              getBreedApi();
                            }));
                          },
                          child: Container(
                      decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(5)
                      ),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            child: Text('Delete',
                              style: Theme.of(context)
                      .textTheme.titleLarge!
                      .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14),
                            ),
                          ),
                        ),
                    ),
                      ),
                    );
                }):Selector<HomeProvider, bool>(
              builder: (context, data, child) {
                return !data
                    ? Center(
                    child: Text(
                        getTranslated(context, 'No Animal breed found')!))
                    : Container();
              },
              selector: (_, provider) => provider.catalogLoading,
            ),
          ),
        ),
      ],
    );
  }

  //get stall//
  _getShowStallData(){
    return Column(
      children: [
        addAnimalColors(getTranslated(context, 'ANIMAL_STALL_LBL')!, () {
          addStallModel();
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: stallList.isNotEmpty?
          ListView.builder(
              shrinkWrap: true,
              controller: colorListController,
              itemCount: stallList.length,
              itemBuilder: (context, int index) {
                return Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color:
                  Theme
                      .of(context)
                      .colorScheme
                      .lightBlack2))),
                  child: ListTile(
                    leading: Text(
                        stallList[index].stallName,
                        style: Theme.of(context)
                            .textTheme.titleLarge!
                            .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14)
                    ),
                    trailing:TextButton(
                      onPressed:  () {
                      },
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Theme.of(context).primaryColor;
                          }
                          return null; // Defer to the widget's default.
                        }),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          _showConfirmationStallDialog(stallList[index].id).then((_)=>setState((){
                            getStallsApi();
                          }));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(5)
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          child: Text('Delete',
                            style: Theme.of(context)
                                .textTheme.titleLarge!
                                .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }):Selector<HomeProvider, bool>(
            builder: (context, data, child) {
              return !data
                  ? Center(
                  child: Text(
                      getTranslated(context, 'No stalls Saved Yet')!))
                  : Container();
            },
            selector: (_, provider) => provider.catalogLoading,
          ),
        ),
      ],
    );
  }
  //get vaccines//
  _showVaccineData(){
    return Column(
      children: [
        addAnimalColors(getTranslated(context, 'ANIMAL_VACCINE_LBL')!, () {
          addVaccineModel();
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: vaccineList.isNotEmpty?
          ListView.builder(
              shrinkWrap: true,
              controller: colorListController,
              itemCount: vaccineList.length,
              itemBuilder: (context, int index) {
                return Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(
                      color:
                  Theme
                      .of(context)
                      .colorScheme
                      .lightBlack2))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        vaccineList[index].vaccineNname,
                                        style: Theme.of(context)
                                            .textTheme.titleLarge!
                                            .copyWith(color: Theme.of(context).colorScheme.fontColor,
                                            fontSize: textFontSize14),
                                        textAlign: TextAlign.left,
                                      ),
                                      Container(
                                        alignment: Alignment.bottomRight,
                                        child: Text("Days: " +vaccineList[index].period,
                                          style: Theme.of(context)
                                            .textTheme.titleLarge!
                                            .copyWith(color: Theme.of(context).colorScheme.fontColor,
                                              fontSize: textFontSize14),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Divider(
                                  //     color: Colors.black12
                                  // ),
                                  Text("Dose: " +
                                      vaccineList[index].doze,
                                    style:Theme.of(context)
                                      .textTheme.titleLarge!
                                      .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14),
                                    textAlign: TextAlign.left,
                                  ),
                                  Text("Notes: " +
                                      vaccineList[index].notes,
                                    style: Theme.of(context)
                                        .textTheme.titleLarge!
                                        .copyWith(color: Theme.of(context).colorScheme.fontColor,
                                        fontSize: textFontSize14),
                                    textAlign: TextAlign.left,
                                  ),
                                  Row(
                                    children: [
                                      Text("Vaccine Repeat: " ,
                                        style: const TextStyle(
                                          color: Color(0xFF737373),
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      vaccineList[index].repeatVacine=="yes"?Container(
                                        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                                        decoration: BoxDecoration(color: Color(0xFF73B41A),
                                            borderRadius: BorderRadius.circular(20)
                                        ),
                                        child: Text(
                                          capitalize(vaccineList[index].repeatVacine.toLowerCase()),
                                            style: Theme.of(context)
                                                .textTheme.titleLarge!
                                                .copyWith(color: Theme.of(context).colorScheme.fontColor,
                                                fontSize: textFontSize12)
                                        ),
                                      ):Container(
                                        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                                        decoration: BoxDecoration(color: Color(0xFFF9C404),
                                            borderRadius: BorderRadius.circular(20)
                                        ),
                                        child: Text(
                                          capitalize(vaccineList[index].repeatVacine.toLowerCase()),
                                          style: Theme.of(context)
                                              .textTheme.titleLarge!
                                              .copyWith(color: Theme.of(context).colorScheme.fontColor,
                                              fontSize: textFontSize12),
                                        ),
                                      ),
                                      Container(margin: EdgeInsets.only(left: 50),),
                                      // Container(
                                      //   margin: EdgeInsets.only(left:30),
                                      //   child: GestureDetector(
                                      //     onTap: (){
                                      //       // print(vaccineList[index].id);
                                      //       var vaccine_id = vaccineList[index].id;
                                      //
                                      //     },
                                      //     child: const Text("Edit",
                                      //       style: TextStyle(
                                      //         //backgroundColor: Color(0xFFF9C404),
                                      //         color: Color(0xFF73B41A),
                                      //         fontSize: textFontSize14,
                                      //         fontWeight: FontWeight.w800,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      GestureDetector(
                                        onTap: () {
                                          _showConfirmationVaccineDialog(vaccineList[index].id).then((_)=>setState((){
                                            getVaccineApi();
                                          }));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(left:5, right: 0),
                                          child: const Text("Delete",
                                            style: TextStyle(
                                              //backgroundColor: Color(0xFFF9C404),
                                              color: Color(0xFFF00000),
                                              fontSize: textFontSize14,
                                              fontWeight: FontWeight.w800,
                                            ),

                                          ),
                                        ),
                                      )
                                    ],
                                  )

                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }):Selector<HomeProvider, bool>(
            builder: (context, data, child) {
              return !data
                  ? Center(
                  child: Text(
                      getTranslated(context, 'No Vaccines found')!))
                  : Container();
            },
            selector: (_, provider) => provider.catalogLoading,
          ),
        ),
      ],
    );
  }

  //get vaccines//
  _getshowMonitoring(){
    return Column(
      children: [
        addAnimalColors(getTranslated(context, 'MONITORING_LBL')!, () {
          addMonitoringModel();
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: monitoringModel.isNotEmpty?
          ListView.builder(
              shrinkWrap: true,
              controller: monitoringListController,
              itemCount: monitoringModel.length,
              itemBuilder: (context, int index) {
                return Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color:
                  Theme
                      .of(context)
                      .colorScheme
                      .lightBlack2))),
                  child: ListTile(
                    leading: Text(
                        monitoringModel[index].monitoringcategory??"",
                        style: Theme.of(context)
                            .textTheme.titleLarge!
                            .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14)
                    ),
                    trailing:TextButton(
                      onPressed:  () {
                      },
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Theme.of(context).primaryColor;
                          }
                          return null; // Defer to the widget's default.
                        }),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          _showConfirmationMonitoringDialog(monitoringModel[index].id).then((_)=>setState((){
                            getMonitoringApi();
                          }));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(5)
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          child: Text('Delete',
                            style: Theme.of(context)
                                .textTheme.titleLarge!
                                .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }):Selector<HomeProvider, bool>(
            builder: (context, data, child) {
              return !data
                  ? Center(
                  child: Text(
                      getTranslated(context, 'No monitoring categories found')!))
                  : Container();
            },
            selector: (_, provider) => provider.catalogLoading,
          ),
        ),
      ],
    );
  }

  Widget addAnimalColors(String title, VoidCallback? onBtnSelected) {
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
  void addColorsModel() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          title: Text(getTranslated(context, "SAVE_COLORS_LBL")!,
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
            Padding(
            padding: const EdgeInsets.symmetric(horizontal:10, vertical: 5.0),
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
                  controller: colorNametxt,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  focusNode: colorFocus,
                  textCapitalization: TextCapitalization.words,
                  key: _colorKey,
                  validator: (val) {
                    if(val!.isEmpty){
                      return getTranslated(context, 'COLOR_REQUIRED');
                    }
                    else
                      return null;
                  },
                  onSaved: (String? value) {
                    colonames = value;
                  },
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Theme.of(context).colorScheme.fontColor),
                  decoration: InputDecoration(
                    label: Text(getTranslated(context, 'ENTER_COLOR_LBL')!),
                    fillColor: Theme.of(context).colorScheme.white,
                    isDense: true,
                    hintText: getTranslated(context, 'ENTER_COLOR_LBL'),
                    border: InputBorder.none,
                  ),
                ),
              ),
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
                    btnAnim: buttonSqueezeanimation,
                    btnCntrl: buttonController,
                    onBtnSelected: () async {
                      validateAndSubmit();
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
  void addMonitoringModel() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          title: Text(getTranslated(context, "SAVE_MONITORING_LBL")!,
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
            Padding(
            padding: const EdgeInsets.symmetric(horizontal:10, vertical: 5.0),
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
                  controller: monitoringNametxt,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  focusNode: monitoringFocus,
                  textCapitalization: TextCapitalization.words,
                  key: _monitoringKey,
                  validator: (val) {
                    if(val!.isEmpty){
                      return getTranslated(context, 'MONITORING_REQUIRED');
                    }
                    else
                      return null;
                  },
                  onSaved: (String? value) {
                    monitoringNames = value;
                  },
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Theme.of(context).colorScheme.fontColor),
                  decoration: InputDecoration(
                    label: Text(getTranslated(context, 'ENTER_MONITORING_LBL')!),
                    fillColor: Theme.of(context).colorScheme.white,
                    isDense: true,
                    hintText: getTranslated(context, 'ENTER_MONITORING_LBL'),
                    border: InputBorder.none,
                  ),
                ),
              ),
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
                    onPressed: () {
                      Navigator.pop(context);
                      colorsList.clear();
                    } ,
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
                      validateMonitoringAndSubmit();
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
  void addBreedsModel() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          title: Text(getTranslated(context, "SAVE_BREEDS_LBL")!,
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
            Padding(
            padding: const EdgeInsets.symmetric(horizontal:10, vertical: 5.0),
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
                  controller: breedNametxt,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  focusNode: breedFocus,
                  textCapitalization: TextCapitalization.words,
                  key: _breedKey,
                  validator: (val) {
                    if(val!.isEmpty){
                      return getTranslated(context, 'BREED_REQUIRED');
                    }
                    else
                      return null;
                  },
                  onSaved: (String? value) {
                    breedNames = value;
                  },
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Theme.of(context).colorScheme.fontColor),
                  decoration: InputDecoration(
                    label: Text(getTranslated(context, 'ENTER_BREED_LBL')!),
                    fillColor: Theme.of(context).colorScheme.white,
                    isDense: true,
                    hintText: getTranslated(context, 'ENTER_BREED_LBL'),
                    border: InputBorder.none,
                  ),
                ),
              ),
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
                    onPressed: () {
                      Navigator.pop(context);
                      colorsList.clear();
                    } ,
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
                      validateBreedAndSubmit();
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
  void addStallModel() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          title: Text(getTranslated(context, "SAVE_STALLS_LBL")!,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:10, vertical: 5.0),
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
                        controller: stallNametxt,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        focusNode: stallFocus,
                        textCapitalization: TextCapitalization.words,
                        key: _stallKey,
                        validator: (val) {
                          if(val!.isEmpty){
                            return getTranslated(context, 'STALL_REQUIRED');
                          }
                          else
                            return null;
                        },
                        onSaved: (String? value) {
                          stallNames = value;
                        },
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: Theme.of(context).colorScheme.fontColor),
                        decoration: InputDecoration(
                          label: Text(getTranslated(context, 'ENTER_STALL_LBL')!),
                          fillColor: Theme.of(context).colorScheme.white,
                          isDense: true,
                          hintText: getTranslated(context, 'ENTER_STALL_LBL'),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
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
                    btnAnim: buttonSqueezeanimation,
                    btnCntrl: buttonController,
                    onBtnSelected: () async {
                      validateStallAndSubmit();
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

  void addVaccineModel() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          title: Text(getTranslated(context, "SAVE_VACCINE_LBL")!,
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
                              controller: vaccinetxt,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              focusNode: vaccinenameFocus,
                              textCapitalization: TextCapitalization.words,
                              key: _vaccineKey,
                              validator: (val) {
                                if(val!.isEmpty){
                                  return getTranslated(context, 'VACCINE_REQUIRED');
                                }
                                else
                                  return null;
                              },
                              onSaved: (String? value) {
                                vaccinenames = value;
                              },
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
                              decoration: InputDecoration(
                                label: Text(getTranslated(context, 'VACCINE_STALL_LBL')!),
                                fillColor: Theme.of(context).colorScheme.white,
                                isDense: true,
                                hintText: getTranslated(context, 'VACCINE_STALL_LBL'),
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
                              controller: vaccineDozetxt,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              focusNode: dozeFocus,
                              textCapitalization: TextCapitalization.words,
                              key: _dozeKey,
                              validator: (val) {
                                if(val!.isEmpty){
                                  return getTranslated(context, 'VACCINE_REPEAT_REQUIRED');
                                }
                                else
                                  return null;
                              },
                              onSaved: (String? value) {
                                vaccinedoze = value;
                              },
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
                              decoration: InputDecoration(
                                label: Text(getTranslated(context, 'VACCINE_DOZE_LBL')!),
                                fillColor: Theme.of(context).colorScheme.white,
                                isDense: true,
                                hintText: getTranslated(context, 'VACCINE_DOZE_LBL'),
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
                            child: DropdownButtonFormField<String>(
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
                              focusNode: repeatFocus,
                              key: _repeatKey,
                              validator: (value) {
                                if (value ==null) {
                                  return getTranslated(context, 'VACCINE_REPEAT_REQUIRED');
                                } else
                                  return null;
                              },
                              // getTranslated(context, 'GENDER_REQUIRED')
                              value: repeat,
                              onChanged: (String? newValue) {
                                setState(() {
                                  repeat = newValue;

                                });
                                // print (_countrySelection);
                              },
                              decoration: InputDecoration(
                                label: Text(getTranslated(context, 'VACCINE_REPEAT_LBL')!),
                                fillColor: Theme.of(context).colorScheme.white,
                                isDense: true,
                                hintText: getTranslated(context, 'VACCINE_REPEAT_LBL'),
                                border: InputBorder.none,
                              ),
                              items: _option.map((Map map) {
                                return new DropdownMenuItem<String>(
                                  value: map["option"].toString(),
                                  child: new Text(
                                    map["option"],
                                  ),
                                );
                              }).toList(),
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
                              controller: vaccineperiodtxt,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              focusNode:periodFocus ,
                              textCapitalization: TextCapitalization.words,
                              key: _vaccinePeriodKey,
                              validator: (val) {
                                if(val!.isEmpty){
                                  return getTranslated(context, 'VACCINE_REPEAT_REQUIRED');
                                }
                                else
                                  return null;
                              },
                              onSaved: (String? value) {
                                vaccineperiod = value;
                              },
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
                              decoration: InputDecoration(
                                label: Text(getTranslated(context, 'VACCINE_PERIOD_LBL')!),
                                fillColor: Theme.of(context).colorScheme.white,
                                isDense: true,
                                hintText: getTranslated(context, 'VACCINE_PERIOD_LBL'),
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
                              controller: vaccinenotestxt,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              focusNode:notesFocus ,
                              textCapitalization: TextCapitalization.words,
                              key: _notesKey,
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
  bool validateAndSave() {
    final form = _colorKey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }
  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      saveAnimalColor();
    }
  }
  void validateBreedAndSubmit() async {
    if (validateBreedAndSave()) {
      _playAnimation();
      saveAnimalBreed();
    }
  }


  bool validateBreedAndSave() {
    final form = _breedKey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  bool validateStallAndSave() {
    final form = _stallKey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }
  void validateStallAndSubmit() async {
    if (validateStallAndSave()) {
      _playAnimation();
      saveAnimalStall();
    }
  }
  void validateMonitoringAndSubmit() async {
    if (validateMonitoringAndSave()) {
      _playAnimation();
      saveAnimalMonitoring();
    }
  }
  bool validateMonitoringAndSave() {
    final form = _monitoringKey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  bool validateVaccineAndSave() {
    final form = _repeatKey.currentState!;
    final vaccine = _vaccineKey.currentState!;
    final vaccinep = _vaccinePeriodKey.currentState!;
    final dozep = _dozeKey.currentState!;
    form.save();
    vaccine.save();
    vaccinep.save();
    dozep.save();
    if (vaccine.validate()&& form.validate() && vaccinep.validate()&& dozep.validate()) {
      return true;
    }
    return false;
  }
  void validateVaccineAndSubmit() async {
    if (validateVaccineAndSave()) {
      _playAnimation();
      saveAnimalVacccines();
    }
  }
  saveAnimalColor() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      Map postdata = {
        COLOR_NAME: colonames
      };
      var _json= utf8.encode(jsonEncode(postdata));
      Response response = await post(addColors, headers: headers, body: _json);
      await buttonController!.reverse();
      var getdata= jsonDecode(response.body);
      String? msg = getdata['messages'][0].toString();
     colorsList.clear();
      if(response.statusCode==401){
        getNewToken(context,saveAnimalColor);
      }
      else if(response.statusCode==201){
        _clearValues();
        setSnackbar("Color added",context);
        Future.delayed(const Duration(seconds: 1)).then((_) {
          Navigator.of(context, rootNavigator: true).pop();
        });
        setState(() {
          getColors();
        });
      }
      else{
        setSnackbar(msg!,context);
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
  saveAnimalMonitoring() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      Map postdata = {
        NAME: monitoringNames
      };
      var _json= utf8.encode(jsonEncode(postdata));
      Response response = await post(addMonitoring, headers: headers, body: _json);
      await buttonController!.reverse();
      var getdata= jsonDecode(response.body);
      print(getdata);
      String? msg = getdata['messages'][0].toString();
     monitoringModel.clear();
      if(response.statusCode==401){
        getNewToken(context,saveAnimalMonitoring);
      }
      else if(response.statusCode==201){
        _clearMonitoringValues();
        setSnackbar("Monitoring service saved",context);
        Future.delayed(const Duration(seconds: 1)).then((_) {
          Navigator.of(context, rootNavigator: true).pop();
        });
        getMonitoringApi();
      }
      else{
        setSnackbar(msg!,context);
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
  saveAnimalBreed() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      Map postdata = {
        BREED_NAME: breedNames
      };
      var _json= utf8.encode(jsonEncode(postdata));
      Response response = await post(addBreed, headers: headers, body: _json);
      await buttonController!.reverse();
      var getdata= jsonDecode(response.body);
      String? msg = getdata['messages'][0].toString();
     breedList.clear();
      if(response.statusCode==401){
        getNewToken(context,saveAnimalBreed);
      }
      else if(response.statusCode==201){
        _clearBreedValues();
        setSnackbar("Breed saved",context);
        Future.delayed(const Duration(seconds: 1)).then((_) {
          Navigator.of(context, rootNavigator: true).pop();
        });
        getBreedApi();
      }
      else{
        setSnackbar(msg!,context);
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
  saveAnimalStall() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      Map postdata = {
        STALL_NAME: stallNames
      };
      var _json= utf8.encode(jsonEncode(postdata));
      Response response = await post(addStall, headers: headers, body: _json);
      await buttonController!.reverse();
      var getdata= jsonDecode(response.body);
      String? msg = getdata['messages'][0].toString();
      colorsList.clear();
      if(response.statusCode==401){
        getNewToken(context,saveAnimalStall);
      }
      else if(response.statusCode==201){
        _clearStallValues();
        Future.delayed(const Duration(seconds: 1)).then((_) {
          Navigator.of(context, rootNavigator: true).pop();
        });
        setSnackbar("Color added",context);
          getStallsApi();
      }
      else{
        setSnackbar(msg!,context);
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

  saveAnimalVacccines() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      Map postdata = {
        VACCINE_NAME:vaccinenames,
        VACCINE_PERIOD:vaccineperiod,
        VACCINE_REPEAT:repeat,
        VACCINE_DOZE:vaccinedoze,
        VACCINE_NOTES:notes,
      };
      var _json= utf8.encode(jsonEncode(postdata));
      Response response = await post(addVaccine, headers: headers,
          body: _json);
      await buttonController!.reverse();
      var getdata= jsonDecode(response.body);
      String? msg = getdata['messages'][0].toString();
      vaccineList.clear();
      if(response.statusCode==401){
        getNewToken(context,saveAnimalVacccines);
      }
      else if(response.statusCode==201){
        _clearVaccineValues();
        Future.delayed(const Duration(seconds: 1)).then((_) {
          Navigator.of(context, rootNavigator: true).pop();
        });
        setSnackbar("Vaccine saved",context);
          getVaccineApi();
      }
      else{
        setSnackbar(msg!,context);
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
    colorNametxt.text = '';
  }
  _clearStallValues() {
    stallNametxt.text = '';
  }
  _clearBreedValues() {
    breedNametxt.text = '';
  }
  _clearMonitoringValues() {
    monitoringNametxt.text = '';
  }
  _clearVaccineValues() {
    vaccinetxt.text = '';
    vaccineperiodtxt.text = '';
    vaccinerepeattxt.text='';
    vaccineDozetxt.text='';
    vaccinenotestxt.text='';
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

  Future<void> getColors() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      Map parameter = {
        LIMIT: perPage.toString(),
        OFFSET: colorListOffset.toString(),
      };
      Response response = await get(getColorsApi, headers: headers)
          .timeout(const Duration(seconds: timeOut));
      var getdata = json.decode(response.body);
      bool success = getdata['success'];
      String? msg = getdata['message'];
      colorsList.clear();
      List<ModelColors> itemColors = [];
      notificationisnodata = false;
      if (success==true) {
        totalColorCount = int.parse(getdata['data']['rows_returned'].toString());
        var data = getdata['data']['colors'];
        itemColors=(data as List).map((data) =>  ModelColors.fromJson(data)).toList();
        setState(() {});
      }
      else{
       if(response.statusCode==401) {
         getNewToken(context,getColors);
       }else {
         setSnackbar(
             msg!, context
         );
       }
      }
      colorsList.addAll(itemColors);
      context.read<HomeProvider>().setCatalogLoading(false);
    }
    else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }
    Future<void> getBreedApi() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      Map parameter = {
        LIMIT: perPage.toString(),
        OFFSET: breedListOffset.toString(),
      };
      Response response = await get(getBreeds, headers: headers)
          .timeout(const Duration(seconds: timeOut));
      var getdata = json.decode(response.body);
      bool success = getdata['success'];
      String? msg = getdata['message'];
      List<BreedModel> itemBreeds = [];
      breedList.clear();
      notificationisnodata = false;
      if (success==true) {
        totalColorCount = int.parse(getdata['data']['rows_returned'].toString());
        var data = getdata['data']['breed'];
        itemBreeds=(data as List).map((data) =>  BreedModel.fromJson(data)).toList();
        setState(() {});
      }
      else{
       if(response.statusCode==401) {
         getNewToken(context,getBreedApi());
       }else {
         setSnackbar(
             msg!, context
         );
       }
      }
      breedList.addAll(itemBreeds);
      context.read<HomeProvider>().setCatalogLoading(false);
    }
    else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

    Future<void> getStallsApi() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      Map parameter = {
        LIMIT: perPage.toString(),
        OFFSET: stallListOffset.toString(),
      };
      Response response = await get(getStalls, headers: headers)
          .timeout(const Duration(seconds: timeOut));
      var getdata = json.decode(response.body);
      bool success = getdata['success'];
      String? msg = getdata['message'];
      List<ModelStall> stallitem = [];
      stallList.clear();
      notificationisnodata = false;
      if (success==true) {
        totalStallCount = int.parse(getdata['data']['rows_returned'].toString());
        var data = getdata['data']['stalls'];
        stallitem=(data as List).map((data) =>  ModelStall.fromJson(data)).toList();
        setState(() {});
      }
      else {
       if(response.statusCode==401) {
       }else
        setSnackbar(
          msg!,context
        );
      }
      stallList.addAll(stallitem);
      context.read<HomeProvider>().setCatalogLoading(false);
    }
    else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  Future<void> getVaccineApi() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      Map parameter = {
        LIMIT: perPage.toString(),
        OFFSET: stallListOffset.toString(),
      };
      Response response = await get(getVaccines, headers: headers)
          .timeout(const Duration(seconds: timeOut));
      var getdata = json.decode(response.body);
      bool success = getdata['success'];
      String? msg = getdata['message'];

      List<VaccinationModel> vaccinationitems = [];
      vaccineList.clear();
      notificationisnodata = false;
      if (success==true) {
        totalVaccineCount = int.parse(getdata['data']['rows_returned'].toString());
        var data = getdata['data']['vaccines'];
        vaccinationitems=(data as List).map((data) =>  VaccinationModel.fromJson(data)).toList();
        setState(() {});
      }
      else {
        if(response.statusCode==401) {
        }else
          setSnackbar(
              msg!,context
          );
      }
      vaccineList.addAll(vaccinationitems);
      context.read<HomeProvider>().setCatalogLoading(false);
    }
    else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }  Future<void> getMonitoringApi() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      Map parameter = {
        LIMIT: perPage.toString(),
        OFFSET: monitoringListOffset.toString(),
      };
      Response response = await get(getMonitoring, headers: headers)
          .timeout(const Duration(seconds: timeOut));
      var getdata = json.decode(response.body);
      bool success = getdata['success'];
      String? msg = getdata['message'];

      List<MonitoringModel> monitoringList = [];
      monitoringModel.clear();
      notificationisnodata = false;
      if (success==true) {
        totalMonitoringCount = int.parse(getdata['data']['rows_returned'].toString());
        var data = getdata['data']['monitor'];
        monitoringList=(data as List).map((data) =>  MonitoringModel.fromJson(data)).toList();
        setState(() {});
      }
      else {
        if(response.statusCode==401) {
        }else
          setSnackbar(
              msg!,context
          );
      }
      monitoringModel.addAll(monitoringList);
      context.read<HomeProvider>().setCatalogLoading(false);
    }
    else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }
//delete stall
  //delete
  Future<bool> _showConfirmationStallDialog(String itemId) async {
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
                    "Are you sure you want to delete this stall?",
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
                  stallsid=itemId;
                  deleteStallCatalog();
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
  Future<bool> _showConfirmationVaccineDialog(String itemId) async {
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
                    "Are you sure you want to delete this vaccine, can't be undone?",
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
                  vaccinesid=itemId;
                  deleteVaccineCatalog();
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
  //delete
  Future<bool> _showConfirmationMonitoringDialog(String itemId) async {
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
                    "Are you sure you want to delete this monitoring service?",
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
                  motoringcategoriesid=itemId;
                  deleteMonitoringCatalog();
                },
              ),
            ),
        ]
        )
          ],
        );
      },
    );
  }
  Future<bool> _showConfirmationBreedDialog(String itemId) async {
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
                    "Are you sure you want to delete this breed?",
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
                  breedsid=itemId;
                  deleteBreedCatalog();
                },
              ),
            ),
        ]
        )
          ],
        );
      },
    );
  }

  //delete colors
  Future<bool> _showConfirmationDialog(String itemId) async {
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
                    "Are you sure you want to delete this color?",
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
                  colorId=itemId;
                  deleteCatalog();
                },
              ),
            ),
        ]
        )
          ],
        );
      },
    );
  }
//delete vaccine
  deleteVaccineCatalog() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
    Response dResponse = await delete(Uri.parse("${baseUrl}catalog/vaccine/$vaccinesid"),
        headers: headers);
    await buttonController!.reverse();
    // breedList.clear();
    if (dResponse.statusCode == 401) {
      getNewToken(context, deleteVaccineCatalog);
    }
    else if (dResponse.statusCode == 201) {
      setSnackbar("Deleted Successfully", context);
      Future.delayed(const Duration(seconds: 1)).then((_) {
        Navigator.of(context, rootNavigator: true).pop();
      });
      getStallsApi();
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
  deleteStallCatalog() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
    Response dResponse = await delete(Uri.parse("${baseUrl}catalog/stall/$stallsid"),
        headers: headers);
    await buttonController!.reverse();
    // breedList.clear();
    if (dResponse.statusCode == 401) {
      getNewToken(context, deleteStallCatalog);
    }
    else if (dResponse.statusCode == 201) {
      setSnackbar("Deleted Successfully", context);
      Future.delayed(const Duration(seconds: 1)).then((_) {
        Navigator.of(context, rootNavigator: true).pop();
      });
      getStallsApi();
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
  deleteMonitoringCatalog() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
    Response dResponse = await delete(Uri.parse("${baseUrl}catalog/monitor/$motoringcategoriesid"),
        headers: headers);
    await buttonController!.reverse();
    // breedList.clear();
    if (dResponse.statusCode == 401) {
      getNewToken(context, deleteCatalog);
    }
    else if (dResponse.statusCode == 201) {
      setSnackbar("Deleted Successfully", context);
      Future.delayed(const Duration(seconds: 1)).then((_) {
        Navigator.of(context, rootNavigator: true).pop();
      });
      getMonitoringApi();
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
  deleteBreedCatalog() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
    Response dResponse = await delete(Uri.parse("${baseUrl}catalog/breed/$breedsid"),
        headers: headers);
    await buttonController!.reverse();
    // breedList.clear();
    if (dResponse.statusCode == 401) {
      getNewToken(context, deleteCatalog);
    }
    else if (dResponse.statusCode == 201) {
      setSnackbar("Deleted Successfully", context);
      Future.delayed(const Duration(seconds: 1)).then((_) {
        Navigator.of(context, rootNavigator: true).pop();
      });
      getBreedApi();
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
  deleteCatalog() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
    Response dResponse = await delete(Uri.parse("${baseUrl}catalog/color/$colorId"),
        headers: headers);
    await buttonController!.reverse();
    // colorsList.clear();
    if (dResponse.statusCode == 401) {
      getNewToken(context, deleteCatalog);
    }
    else if (dResponse.statusCode == 201) {
      setSnackbar("Deleted Successfully", context);
      Future.delayed(const Duration(seconds: 1)).then((_) {
        Navigator.of(context, rootNavigator: true).pop();
      });
      getColors();
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
}
