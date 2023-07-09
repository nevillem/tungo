import 'dart:async';
import 'dart:convert';
import 'package:agritungotest/Helper/Color.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Helper/update_access_token.dart';
import '../Model/AnimalsModel.dart';
import '../Provider/HomeProvider.dart';
import '../Provider/SettingProvider.dart';
import '../Provider/UserProvider.dart';
import '../Widgets/Animal_conatiner.dart';
import '../Widgets/animal_details.dart';
import 'Login.dart';
import 'RegisterAnimals.dart';


class ManageAnimalMain extends StatefulWidget {
  const ManageAnimalMain({Key? key}) : super(key: key);


  @override
  State<StatefulWidget> createState() {
    return StateManageAnimalMain();
  }
}

 class StateManageAnimalMain extends State<ManageAnimalMain> with TickerProviderStateMixin {

  final _controller = PageController();
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshAnimalIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  bool notificationisloadmore = true,
      notificationisgettingdata = false,
      notificationisnodata = false;
  int totalAnimalsCount=0;
  int animalListOffset = 0;
  bool loading=true;
  ScrollController? animalsController;
  String? animaid;
  @override

  void initState() {
    getAnimals();
    animalsController = ScrollController(keepScrollOffset: true);
    animalsController!.addListener(_animalListScrollListener);
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
    // TODO: implement initState
    super.initState();

  }
  _animalListScrollListener() {
    if (animalsController!.offset >=
        animalsController!.position.maxScrollExtent &&
        !animalsController!.position.outOfRange) {
      if (mounted) {
        if (animalListOffset < totalAnimalsCount) {
          getAnimals();
          setState(() {});
        }
      }
    }
  }
  List<AnimalsModel> animalModel = [];
  List<AnimalsModel> signleAnimalModel = [];
  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
           mainAxisSize: MainAxisSize.min, children: [
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
                  callApi();
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: getSimpleAppBar(getTranslated(context, 'MANAGE_ANIMALS')!, context),
      body: _isNetworkAvail
          ?Container(
            child: RefreshIndicator(
              key: _refreshAnimalIndicatorKey,
              onRefresh: _refresh,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: ClampingScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      _showContentofAnimals(screenHeight, screenWidth),
                    ],
                  ),
                ),
              ),
            ),
          ):noInternet(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF73B41A),
        onPressed: () {
          Navigator.pushNamed(
            context,'/registerAnimals',
          ).then((_) {
            getAnimals();
            setState(() {
            });
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }


  Widget _showContentofAnimals(double screenHeight, screenWidth) {
    return Expanded(
      child:loading
          ? const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF73B41A)),
          ))
          : notificationisnodata
          ? getNoItem(context)
          : Stack(
        children: [
        Container(
            width: screenWidth * 10,
            margin: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 4,
            ),
            //padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              //  color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
          child:ListView.builder(
              shrinkWrap: true,
              controller: animalsController,
              itemCount: animalModel.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    AnimalsModel model = animalModel[index];
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        // transitionDuration: Duration(milliseconds: 150),
                        pageBuilder: (_, __, ___) => AnimalDetails(
                            model: model
                          //  title: sectionList[secPos].title,
                        ),
                      ),
                    );
                    // ANIMAL_ID= animalModel[index].id;
                    // _getCowDetails(ANIMAL_ID);
                    // getAnimals();
                  },
                  child: AnimalContainer(
                    stallno: animalModel[index].stallno,
                    gender: animalModel[index].gender,
                    breed: animalModel[index].breed,
                    litres: animalModel[index].litres,
                    pregancyStatus: animalModel[index].pregancyStatus,
                    press: () {
                      //   var animalid = e.id;
                      //   Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => EditAnimals(animal_id: '$animalid',)), (Route<dynamic> route) => false);
                    },
                    pressDelete: () {
                      var animalid = animalModel[index].id;
                      _showConfirmationDialog(animalid).then((_) => setState(() {
                        getAnimals();
                      }));
                    },
                    imageUrl: animalModel[index].images,
                  ),
                );
              },
            ),
          ),
        notificationisgettingdata
        ? const Center(
        child: CircularProgressIndicator(),
    )
        : Container(),
        ],
      ),
    );
  }


  //delete
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
                    "Are you sure you want to delete this animal?",
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
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     TextButton(
                //         onPressed: () {
                //           _deleteAnimal(itemId);
                //           Navigator.of(context).pop(true);
                //         },
                //         child: const Text("DELETE")),
                //     TextButton(
                //       onPressed: () => Navigator.of(context).pop(false),
                //       child: const Text("CANCEL"),
                //     ),
                //   ],
                // ),
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
                      Navigator.of(context).pop(false);
                      animalModel.clear();
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
                      animaid=(itemId);
                      deleteAnimal();
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> getAnimals() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
          var response = await get(saveanimalsApi, headers: headers);
          var getdata = json.decode(response.body);
          bool success = getdata['success'];
          String? msg = getdata['message'];
          List<AnimalsModel> tempdata=[];
          animalModel.clear();
          notificationisgettingdata = false;
          if (success==true) {
            loading = false;
            totalAnimalsCount = int.parse(getdata['data']['rows_returned'].toString());
            if (totalAnimalsCount == 0) {
              notificationisnodata = true;
            }
            else {
              notificationisnodata = false;
            }
            Future.delayed(
                Duration.zero,
                    () => setState(() {
                      var data = getdata['data']['animals'];
                      tempdata =(data as List).map((data) =>AnimalsModel.fromJson(data)).toList();
                      animalModel.addAll(tempdata);
                    }));
          }else{
            loading = false;
            if (response.statusCode == 401) {
            getNewToken(context, getAnimals);
          }
          else {
            setSnackbar( msg!);
          }
          }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
        if (mounted) {
          setState(() {
            notificationisloadmore = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  Future<void> _refresh() {
    return callApi();
  }
  Future<void> callApi() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getAnimals();
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
    return;
  }
  deleteAnimal() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      Response dResponse =
      await delete(Uri.parse('${baseUrl}animals/$animaid'), headers: headers);
      await buttonController!.reverse();
      if (dResponse.statusCode == 401) {
        getNewToken(context, deleteAnimal);
      }
       else if (dResponse.statusCode == 200) {
        setSnackbar("Deleted Successfully");
        Future.delayed(const Duration(seconds: 1)).then((_) {
          Navigator.of(context, rootNavigator: true).pop();
        });
        setState(() {
          getAnimals();
        });

      }
    } else {
      loading = false;
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

  clearAll() {
    setState(() {
      // query = _controller.text;
      // notificationoffset = 0;
      notificationisloadmore = true;
      // productList.clear();
    });
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
}
