import 'dart:async';
import 'dart:convert';

import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Helper/Session.dart';
import 'package:agritungotest/Model/crop_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:filter_list/filter_list.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Constant.dart';
import '../Helper/SqliteData.dart';
import '../Helper/String.dart';
import '../Provider/HomeProvider.dart';
import 'Select_favorite_crops.dart';
import 'crop_detail_screen.dart';

class CropScreen extends StatefulWidget {
  const CropScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateCropScreen();
  }
}
class StateCropScreen extends State<CropScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  List cropList=[];
  bool notificationisloadmore = true;
  List<int> cropIds = [];
  var db = DatabaseHelper();

  @override
  void initState() {
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
    getCrops();
    getSelectedFavCrop();
  }
  getSelectedFavCrop() async {
    cropIds = (await db.getFavCrops())!;
    context.read<HomeProvider>().setCatLoading(false);
  }
  @override
  void dispose() {
    buttonController!.dispose();
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
                  // addressList.clear();
                  // addModel.clear();
                  // if (!ISFLAT_DEL) delCharge = 0;
                  // _getAddress();
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

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
            '/home', (Route<dynamic> route) => false);
            },
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: colors.primary,
                ),
              ),
            ),
          );
        }),
        // elevation: 0,
        title: Text(
          getTranslated(context, 'MANAGE_CROP')!,
          style:
          const TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
        ),
      ),
      // getSimpleAppBar(getTranslated(context, 'MANAGE_CROP')!, context),
      body: _isNetworkAvail
          ? RefreshIndicator(
        color: colors.primary,
        key: _refreshIndicatorKey,
        onRefresh: getCrops,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Consumer<HomeProvider>(
                    builder: (context, homeProvider, _) {
                      if (homeProvider.cropLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    return cropIds.isNotEmpty?
                    GridView.count(
                      padding: const EdgeInsetsDirectional.only(top: 5),
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      childAspectRatio: 0.730,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                      physics: const BouncingScrollPhysics(),
                      children: List.generate(
                        cropList.length,
                            (index) {
                          return Column(
                            children: [
                         Card(
                         elevation: 0.0,
                         color: Color.fromRGBO(115, 180, 26, 0.38),
                         margin: const EdgeInsetsDirectional.only(bottom: 2, end: 2),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  child: GestureDetector(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(top:18.0, left:10, right: 10),                                        child: ClipRRect(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(50.0),
                                              child: Hero(
                                                transitionOnUserGestures: true,
                                                tag: '${cropList[index].id}',
                                                child: FadeInImage(
                                                  fadeInDuration:
                                                  const Duration(milliseconds: 150),
                                                  image: CachedNetworkImageProvider(
                                                    cropList[index].image!,
                                                  ),
                                                  height:80.0,
                                                  width: 80.0,
                                                  fit: BoxFit.cover,
                                                  imageErrorBuilder:
                                                      (context, error, stackTrace) =>
                                                      erroWidget(50),
                                                  placeholder: placeHolder(50),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional.only(
                                            start: 10.0,
                                            top: 10,
                                          ),
                                        child:Text(
                                          '${cropList[index].name!}\n',
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(color: Theme.of(context).colorScheme.fontColor),
                                        ),
                                       )
                                      ],
                                    ),
                                    onTap: () async {
                                      CropData model = cropList[index];
                                      await Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) => CropDetails(
                                              model: model,
                                            ),
                                          ));
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                     : Center(
                      child: Text(
                        getTranslated(context, 'Please select your favorite crops')!,
                      ),
                    );
                    }
                    ),
                  ),
                      selectCrops(getTranslated(context, 'CROP_LBL')!, () {
                        // Navigator.pushNamed(context, '/selectCrops').then((_) {
                        //   // This block runs when you have returned back from screen 2.
                        //   setState(() {
                        //     // code here to refresh data
                        //     getCrops();
                        //   });
                        // });
                        Navigator.push(context,  CupertinoPageRoute(builder: (_) => const SelectedFavoriteCrops())).then((_) {
                          // This block runs when you have returned back to the 1st Page from 2nd.
                          setState(() {
                            context.read<HomeProvider>().setCropsLoading(true);
                            getCrops();
                          });
                        });                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context) => SelectedFavoriteCrops()));
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ):noInternet(context),
    );
  }
  Widget selectCrops(String title,  VoidCallback? onBtnSelected) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        width: double.infinity,
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
    );
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

  Future  getCrops() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        Response response =
        await get(getCropsApi, headers: headers)
            .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool success = getdata['success'];
        String? msg = getdata['message'];
        cropList.clear();
        if (success==true) {
          if (mounted) {
            var data = getdata['data']['cropsinformation'];
            List<CropData> cropData=[];
            // cropData.clear();
            cropData =
                (data as List).map((data) => CropData.fromJson(data)).toList();
            List newList=[];
            for (int i = 0; i < cropIds.length; i++) {
              // cropData.where((x) => x.id!.contains("{cropIds[i]}"));
              // cropData.removeWhere((element) => element.id == "${cropIds[i]}");
              // cropData.removeWhere((element) => element.id == "${cropIds[i]}");
              newList=cropData .where((x) => x.id == "${cropIds[i]}").toList();
              cropList.addAll(newList);
            }

          }
        } else {
          // notificationisloadmore = false;
          if (mounted) setState(() {});
        }
        context.read<HomeProvider>().setCropsLoading(false);
      }on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
        if (mounted) {
          setState(() {
            // notificationisloadmore = false;
          });
        }
      }
    }
    else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

}
