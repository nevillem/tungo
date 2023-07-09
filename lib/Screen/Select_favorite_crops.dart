import 'dart:async';
import 'dart:convert';

import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Helper/Session.dart';
import 'package:agritungotest/Model/crop_model.dart';
import 'package:agritungotest/Widgets/search_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:filter_list/filter_list.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Constant.dart';
import '../Helper/SqliteData.dart';
import '../Helper/String.dart';
import '../Provider/HomeProvider.dart';
import 'Select_favorite_crops.dart';
import 'crop_detail_screen.dart';
import 'crop_screen.dart';

class SelectedFavoriteCrops extends StatefulWidget {
  const SelectedFavoriteCrops({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateCropScreen();
  }
}
class StateCropScreen extends State<SelectedFavoriteCrops> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  List cropList=[];
  bool notificationisloadmore = true;
  List<int> cropIds = [];
  List cropSelectionList = [];
  String query = '';
  Timer? debouncer;
  var db = DatabaseHelper();
  List  allCropList=[];


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
    getSelectedCrops(query);
    getSelectedFavCrop();
  }
  getSelectedFavCrop() async {
    cropIds.clear();
    cropIds = (await db.getFavCrops())!;
    context.read<HomeProvider>().setCropsSelectedLoading(false);
  }
  _getColors(index) {
    Color? color;
    for (int i = 0; i < cropIds.length; i++) {
      // print("object${cropIds[i]}-id for selected crop $index");
       if("${cropIds[i]}"=="$index"){
       color=  const Color.fromRGBO(115, 180, 26, 0.38);
       }
       else{
         print(false);
       }
    }
    return color;
  }
  @override
  void dispose() {
    buttonController!.dispose();
    debouncer?.cancel();
    super.dispose();
  }
  void debounce(
      VoidCallback callback, {
        Duration duration = const Duration(milliseconds: 1000),
      }) {
    if (debouncer != null) {
      debouncer!.cancel();
    }

    debouncer = Timer(duration, callback);
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
      appBar:
      getSimpleAppBar(getTranslated(context, 'MANAGE_CROP')!, context),
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
                children: [
                  Container(
                    color: Theme
                        .of(context)
                        .colorScheme
                        .white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
                      child: buildSearch(),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0, top: 10.0, left: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Flexible(
                              flex: 3,
                              child: Text(
                                "Selected crops",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.normal,
                                    fontSize: textFontSize16,
                                    color: Theme.of(context).colorScheme.fontColor,
                                  )
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: GestureDetector(
                                child: const Icon(FontAwesomeIcons.chevronRight,
                                size: 15,),
                                onTap: () {

                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 15.0),
                        child:  Divider(thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Consumer<HomeProvider>(
                            builder: (context, homeProvider, _) {
                              if (homeProvider.cropsSelectedLoading) {
                                return SizedBox(
                                    width: double.infinity,
                                    child: Shimmer.fromColors(
                                        baseColor: Theme.of(context).colorScheme.simmerBase,
                                        highlightColor: Theme.of(context).colorScheme.simmerHigh,
                                        child: selectedCropsLoading()));
                              }else {
                                return cropIds.isNotEmpty?
                              Container(
                                height: 100,
                                child: ListView.builder(
                                    itemCount: cropList.length,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsetsDirectional.only(end: 18),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(25.0),
                                              child: FadeInImage(
                                                fadeInDuration:
                                                const Duration(milliseconds: 150),
                                                image: CachedNetworkImageProvider(
                                                  cropList[index].image!,
                                                ),
                                                height: 50.0,
                                                width: 50.0,
                                                fit: BoxFit.cover,
                                                imageErrorBuilder:
                                                    (context, error, stackTrace) =>
                                                    erroWidget(50),
                                                placeholder: placeHolder(50),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: SizedBox(
                                                width: 50,
                                                child: Text(
                                                  cropList[index].name!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .fontColor,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 10),
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
                            }
                        ),
                      ),
                      _allCrops(),
                      selectCrops(getTranslated(context, 'CROP_COMFIRM_LBL')!, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CropScreen())).then((_) {
                          // This block runs when you have returned back to the 1st Page from 2nd.
                          setState(() {
                            getCrops();
                          });
                        });                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context) => SelectedFavoriteCrops()));
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ):noInternet(context),
    );
  }

  Widget selectedCropsLoading(){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                    .map((_) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.white,
                    shape: BoxShape.circle,
                  ),
                  width: 50.0,
                  height: 50.0,
                ))
                    .toList()),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ),
      ],
    );
  }

  _allCrops(){
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Consumer<HomeProvider>(
              builder: (context, homeProvider, _) {
                if (homeProvider.cropSelectionLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return cropSelectionList.isNotEmpty?GridView.count(
                  padding: const EdgeInsetsDirectional.only(top: 5),
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  childAspectRatio: 0.700,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  physics: const BouncingScrollPhysics(),
                  children: List.generate(
                    cropSelectionList.length,
                        (index) {
                       var id=cropSelectionList[index].id;
                     return  Card(
                        elevation: 0.0,
                        color:_getColors(id),
                        margin: const EdgeInsetsDirectional.only(bottom: 2, end: 2),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              GestureDetector(
                              onTap: () async {
                                db.addCrop(cropSelectionList![index].id!);
                                Future.delayed(const Duration(seconds: 1)).then((_) async {
                                if (mounted) {
                                setState(() {
                                getSelectedFavCrop();
                                getCrops();
                                });
                                }
                                });
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top:28.0, left:10, right: 10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50.0),
                                        child: Hero(
                                          transitionOnUserGestures: true,
                                          tag: '${cropSelectionList[index].id}',
                                          child: FadeInImage(
                                            fadeInDuration:
                                            const Duration(milliseconds: 150),
                                            image: CachedNetworkImageProvider(
                                              cropSelectionList[index].image!,
                                            ),
                                            height: 80.0,
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
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                        start: 10.0,
                                        top: 15,
                                      ),
                                      child: Text(
                                        '${cropSelectionList[index].name!}\n',
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
                              ),
                              if(cropIds.isNotEmpty)
                                for(var item in cropIds)
                                  "$item"=="${cropSelectionList[index].id}"?
                                  Positioned.directional(
                                    textDirection: Directionality.of(context),
                                    top: 0,
                                    end: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                       db.removeCrop(cropSelectionList![index].id!);
                                        setState(() {
                                          getSelectedFavCrop();
                                          getCrops();
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary,
                                            borderRadius: const  BorderRadiusDirectional.only(
                                                bottomStart:
                                                Radius.circular(circularBorderRadius10),
                                                topEnd: Radius.circular(0))),
                                        child: InkWell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(FontAwesomeIcons.squareCheck,
                                              // : Icons.favorite,
                                              color: Theme.of(context).colorScheme.white,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ):Container()
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
                    : Center(
                  child: Text(
                    getTranslated(context, 'noItem')!,
                  ),
                );
              }
          ),
        ],
      ),

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

  Widget buildSearch() => SearchWidget(
    text: query,
    hintText: 'Search',
    onChanged: searchCrop,
  );

  Future searchCrop(String query)  async => debounce(() async {
    context.read<HomeProvider>().setSelectionCropLoading(true);
    getSelectedCrops(query);
    if (!mounted) return;
    setState(() {
      this.query = query;
      cropSelectionList;
    });
  });

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
            // cropSelectionList =
            //     (data as List).map((data) => CropData.fromJson(data)).toList();
          }
        } else {
          // notificationisloadmore = false;
          if (mounted) setState(() {});
        }
        context.read<HomeProvider>().setCropsSelectedLoading(false);
        context.read<HomeProvider>().setSelectionCropLoading(false);
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

  Future getSelectedCrops(String query) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        Response response =
        await get(getCropsApi, headers: headers)
            .timeout(const Duration(seconds: timeOut));
        var getdata = json.decode(response.body);
        bool success = getdata['success'];
        String? msg = getdata['message'];
        if (success==true) {
          if (mounted) {
            var data = getdata['data']['cropsinformation'];
            cropSelectionList =
                (data as List).map((data) => CropData.fromJson(data)).where((element){
                  final titleLower = element.name!.toLowerCase();
                  final searchLower = query.toLowerCase();
                  return  titleLower.contains(searchLower);
                }).toList();
          }
        } else {
          // notificationisloadmore = false;
          if (mounted) setState(() {});
        }
        context.read<HomeProvider>().setSelectionCropLoading(false);
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
