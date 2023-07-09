import 'dart:async';
import 'dart:convert';
import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Helper/Constant.dart';
import 'package:agritungotest/Helper/Session.dart';
import 'package:agritungotest/Provider/CategoryProvider.dart';
import 'package:agritungotest/Screen/ProductList.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../Helper/AppBtn.dart';
import '../Helper/String.dart';
import '../Model/Categories_Model.dart';
import '../Provider/HomeProvider.dart';
import 'HomePage.dart';
class AllCategories extends StatefulWidget {
  const AllCategories({Key? key}) : super(key: key);

  @override
  State<AllCategories> createState() => _AllCategoriesState();
}
class _AllCategoriesState extends State<AllCategories> with TickerProviderStateMixin {

  late Animation buttonSqueezeanimation;
  late AnimationController buttonController;
  bool _isNetworkAvail = true;
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    getCat();
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
              context.read<HomeProvider>().setCatLoading(true);
              context.read<HomeProvider>().setSecLoading(true);
              context.read<HomeProvider>().setSliderLoading(true);
              _playAnimation();

              Future.delayed(const Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  if (mounted) {
                    setState(() {
                      _isNetworkAvail = true;
                    });
                  }
                  getCat();
                } else {
                  await buttonController.reverse();
                  // if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isNetworkAvail
          ?Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.white,
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      child: Text(getTranslated(context, 'ALL_SHOPS')!),
                    ),
                    Tab(
                      child: Text(getTranslated(context, 'ALL_SERVICES')!),
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
                        _showContentOfProducts(),
                      ],
                    ),
                    Stack(
                      children: <Widget>[
                        // _showContentOfSellers(),
                        Selector<HomeProvider, bool>(
                          builder: (context, data, child) {
                            return Center(
                              child: showCircularProgress(
                                  data, colors.primary),
                            );
                          },
                          selector: (_, provider) => provider.catLoading,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ):noInternet(context),
    );
  }
  _showContentOfProducts() {
    return Consumer<HomeProvider>(
        builder: (context, homeProvider, _) {
          if (homeProvider.catLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return categoriesList.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20, top: 10),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.white,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text("SHOP BY CATEGORIES",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                 GridView.count(
                padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                crossAxisCount: 3,
                shrinkWrap: true,
                childAspectRatio: .6,
                children: List.generate(
                              categoriesList.length,
                                  (index) {
                                return(index == categoriesList.length)
                                ?shimmer(context):
                                catItem(index, context);
                              },
                ),
              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ) : Center(
            child: Text(
              getTranslated(context, 'noItem')!,
            ),
          );
        },
    );
  }

  Widget catItem(int index, BuildContext context1) {
    return  GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Card(
                    color: Theme.of(context).colorScheme.white,
                    child: SvgPicture.network(
                        categoriesList[index].icon!,
                      color: Theme.of(context)
                          .colorScheme.primary,
                      height: 75, width: 75,),
                  )
              ),
            ),
                Text(
                  '${categoriesList[index].name!}\n',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Theme.of(context).colorScheme.fontColor),
                )
              ],
            ),
            onTap: () {
              CategoriesData model = categoriesList[index];
              // if (context.read<CategoryProvider>().curCat == 0) {
                  if (categoriesList[index].products != null ||
                      categoriesList[index].products!.isNotEmpty) {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ProductList(
                            name: categoriesList[index].name,
                            id: categoriesList[index].id,
                            model:model,
                            tag: false,
                            fromSeller: false,
                          ),
                        ));
                  }
                // }
            },
          );

  }
  Future<void> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }
  subCatItem(List<CategoriesData> subList, int index, BuildContext context) {
    return GestureDetector(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: FadeInImage(
                  image: CachedNetworkImageProvider(subList[index].products![index].image!),
                  fadeInDuration: const Duration(milliseconds: 150),
                  fit: BoxFit.fill,
                  imageErrorBuilder: (context, error, stackTrace) =>
                      erroWidget(50),
                  placeholder: placeHolder(50),
                )),
          ),
          Text(
            '${subList[index].products![index].name!}\n',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
          )
        ],
      ),
      onTap: () {
        if (context.read<CategoryProvider>().curCat == 0 &&
            popularList.isNotEmpty) {
          if (popularList[index].subList == null ||
              popularList[index].subList!.isEmpty) {
            // Navigator.push(
            //     context,
            //     CupertinoPageRoute(
            //       builder: (context) => ProductList(
            //         name: popularList[index].name,
            //         id: popularList[index].id,
            //         tag: false,
            //         fromSeller: false,
            //       ),
            //     ));
          } else {
            // Navigator.push(
            //   context,
            //   CupertinoPageRoute(
            //     builder: (context) => SubCategory(
            //       subList: popularList[index].subList,
            //       title: popularList[index].name ?? '',
            //     ),
            //   ),
            // );
          }
        } else if (subList[index].products == null ||
            subList[index].products!.isEmpty) {
          // Navigator.push(
          //   context,
          //   CupertinoPageRoute(
          //     builder: (context) => ProductList(
          //       name: subList[index].name,
          //       id: subList[index].id,
          //       tag: false,
          //       fromSeller: false,
          //     ),
          //   ),
          // );
        } else {
          // Navigator.push(
          //   context,
          //   CupertinoPageRoute(
          //     builder: (context) => SubCategory(
          //       subList: subList[index].subList,
          //       title: subList[index].name ?? '',
          //     ),
          //   ),
          // );
        }
      },
    );
  }

  Future getCat() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {

        Response response =
        await get(getCategoriesApi)
            .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool success = getdata['success'];
        String? msg = getdata['message'];
        List<CategoriesData> tempSellerList = [];
        tempSellerList.clear();
        categoriesList.clear();

        if (success==true) {
          // totalSellerCount = int.parse(getdata['data']['rows_returned'].toString());
          var data = getdata['data']['categories'];
          tempSellerList =(data as List).map((data) => CategoriesData.fromJson(data)).toList();
          // sellerListOffset += perPage;
          // setState(() {});
        } else {
          setSnackbar(
            msg!,
          );
        }
        categoriesList.addAll(tempSellerList);
        context.read<HomeProvider>().setCatLoading(false);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
        if (mounted) {
          setState(() {
            // notificationisloadmore = false;
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
