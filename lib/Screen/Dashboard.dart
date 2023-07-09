import 'dart:async';
import 'dart:convert';
import 'package:agritungotest/Provider/UserProvider.dart';
import 'package:agritungotest/Screen/Categories.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/SqliteData.dart';
import '../Helper/String.dart';
import '../Model/Section_Model.dart';
import '../Provider/Theme.dart';
import '../Widgets/product_details_new.dart';
import 'Cart.dart';
import 'HomePage.dart';
import 'MyProfile.dart';
import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Provider/HomeProvider.dart';
import 'Shop.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Dashboard> with TickerProviderStateMixin {
  int _selBottom = 0;
  late TabController _tabController;
  bool _isNetworkAvail = true;

  late StreamSubscription streamSubscription;

  late AnimationController navigationContainerAnimationController =
  AnimationController(
    vsync: this, // the SingleTickerProviderStateMixin
    duration: const Duration(milliseconds: 200),
  );
  List<String> proIds = [];
  var db = DatabaseHelper();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    initDynamicLinks();
    _tabController = TabController(
      length: 5,
      vsync: this,
    );

    // final pushNotificationService = PushNotificationService(
    //     context: context, tabController: _tabController);
    // pushNotificationService.initialise();

    _tabController.addListener(
          () {
        Future.delayed(const Duration(seconds: 0)).then(
              (value) {},
        );

        setState(
              () {
            _selBottom = _tabController.index;
          },
        );
        if (_tabController.index == 3) {
          cartTotalClear();
        }
      },
    );

    Future.delayed(Duration.zero, () {
      context.read<HomeProvider>()
        ..setAnimationController(navigationContainerAnimationController)
        ..setBottomBarOffsetToAnimateController(
            navigationContainerAnimationController)
        ..setAppBarOffsetToAnimateController(
            navigationContainerAnimationController);
    });
    getCartCount();
    super.initState();
  }
  getCartCount() async {
    proIds = (await db.getCart())!;
    context.read<UserProvider>().setCartCount("${proIds.length}");

  }

  void initDynamicLinks() async {
    streamSubscription = FirebaseDynamicLinks.instance.onLink.listen((event) {
      final Uri deepLink = event.link;
      if (deepLink.queryParameters.isNotEmpty) {
        int index = int.parse(deepLink.queryParameters['index']!);

        int secPos = int.parse(deepLink.queryParameters['secPos']!);

        String? id = deepLink.queryParameters['id'];

        String? list = deepLink.queryParameters['list'];

        getProduct(id!, index, secPos, list == 'true' ? true : false);
      }
    });
  }

  Future<void> getProduct(String id, int index, int secPos, bool list) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          ID: id,
        };

        // if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        Response response =
        await get(getProductApi, headers: headers)
            .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool success = getdata['success'];
        String? msg = getdata['message'];
        if (success==true) {
          var data = getdata['data']['products'];

          List<Product> items=[];

          items = (data as List).map((data) => Product.fromJson(data)).toList();

          Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => ProductDetail1(
                index: list ? int.parse(id) : index,
                model: list
                    ? items[0]
                    : sectionList[secPos].productList![index]!,
                secPos: secPos,
                list: list,
              )));
        } else {
          if (msg != 'Products Not Found !') setSnackbar(msg!, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_tabController.index != 0) {
          _tabController.animateTo(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: false,
        extendBody: true,
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .lightWhite,
        appBar: _selBottom == 0
            ? _getAppBar()
            : PreferredSize(preferredSize: Size.zero, child: Container()),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: const [
              HomePage(),
              Shop(),
              AllCategories(),
              Cart(fromBottom: true,),
              MyProfile(),
            ],
          ),
        ),
        bottomNavigationBar: _getBottomBar(),
      ),
    );
  }

  // _getAppBar() {
  //   String? title;
  //   // print("navigation$_selBottom");
  //   if (_selBottom == 1) {
  //     title = getTranslated(context, 'SHOP');
  //   } else if (_selBottom == 2) {
  //     title = getTranslated(context, 'CATEGORY');
  //   } else if (_selBottom == 3) {
  //     title = getTranslated(context, 'MYBAG');
  //   } else if (_selBottom == 4) {
  //     title = getTranslated(context, 'PROFILE');
  //   }
  //   final appBar = AppBar(
  //     elevation: 0,
  //     toolbarHeight: 100,
  //     centerTitle: false,
  //     backgroundColor: Theme
  //         .of(context)
  //         .colorScheme
  //         .primary,
  //     title: _selBottom == 0
  //         ? Container(
  //       margin: EdgeInsets.only(top: 10, bottom: 5),
  //       width: double.infinity,
  //       // height: 40,
  //       decoration: BoxDecoration(
  //         color: Theme.of(context).colorScheme.lightWhite,
  //         borderRadius: BorderRadius.circular(5),),
  //       child: GestureDetector(
  //         onTap: () async {
  //           //showOverlaySnackBar(context, Colors.amber, "message",50 );
  //           await Navigator.push(
  //               context,
  //               CupertinoPageRoute(
  //                 builder: (context) => const Search(),
  //               ));
  //         },
  //         child: TextFormField(
  //           enabled: false,
  //           textAlign: TextAlign.left,
  //           decoration: InputDecoration(
  //               focusedBorder: OutlineInputBorder(
  //                 borderSide: BorderSide(
  //                     color: Theme.of(context).colorScheme.lightWhite),
  //                 borderRadius: const BorderRadius.all(
  //                   Radius.circular(5.0),
  //                 ),
  //               ),
  //               enabledBorder: const OutlineInputBorder(
  //                 borderSide: BorderSide(color: Colors.transparent),
  //                 borderRadius: BorderRadius.all(
  //                   Radius.circular(5.0),
  //                 ),
  //               ),
  //               contentPadding: const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
  //               border: const OutlineInputBorder(
  //                 borderSide: BorderSide(color: Colors.transparent),
  //                 borderRadius: BorderRadius.all(
  //                   Radius.circular(5.0),
  //                 ),
  //               ),
  //               isDense: true,
  //               hintText: getTranslated(context, 'searchHint'),
  //               hintStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
  //                   color: Theme.of(context).colorScheme.fontColor,
  //                   fontSize: textFontSize16,
  //                   fontWeight: FontWeight.w500,
  //                   fontStyle: FontStyle.normal,
  //                   fontFamily: "ubuntu"
  //               ),
  //               // prefixIcon: const Padding(
  //               //     padding: EdgeInsets.all(15.0), child: Icon(Icons.search)),
  //               suffixIcon: Selector<ThemeNotifier, ThemeMode>(
  //                   selector: (_, themeProvider) =>
  //                       themeProvider.getThemeMode(),
  //                   builder: (context, data, child) {
  //                     return Padding(
  //                       padding: const EdgeInsets.all(10.0),
  //                       child: (data == ThemeMode.system &&
  //                           MediaQuery.of(context).platformBrightness ==
  //                               Brightness.light) ||
  //                           data == ThemeMode.light
  //                           ? SvgPicture.asset(
  //                         '${imagePath}fav_black.svg',
  //                         height: 10,
  //                         width: 10,
  //                       )
  //                           : SvgPicture.asset(
  //                         '${imagePath}voice_search_white.svg',
  //                         height: 15,
  //                         width: 15,
  //                       ),
  //                     );
  //                   }),
  //               fillColor: Theme.of(context).colorScheme.white,
  //               filled: true),
  //         ),
  //       ),
  //     )
  //         : Text(
  //       title!,
  //       style: const TextStyle(
  //         color: colors.primary,
  //         fontWeight: FontWeight.normal,
  //       ),
  //     ),
  //
  //   );
  //   return PreferredSize(
  //       preferredSize: appBar.preferredSize,
  //       child: SlideTransition(
  //         position: context.watch<HomeProvider>().animationAppBarBarOffset,
  //         child: SizedBox(
  //             height: context.watch<HomeProvider>().getBars ? 100 : 0,
  //             child: appBar),
  //       ));
  // }

  _getAppBar() {
    String? title;
    if (_selBottom == 1) {
      title = getTranslated(context, 'SHOP');
    } else if (_selBottom == 2) {
      title = getTranslated(context, 'CATEGORY');
    } else if (_selBottom == 3) {
      title = getTranslated(context, 'MYBAG');
    } else if (_selBottom == 4) {
      title = getTranslated(context, 'PROFILE');
    }
    final appBar = AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      title: _selBottom == 0
          ? SvgPicture.asset(
        'assets/images/titleicon.svg',
        height: 40,
      )
          : Text(
        title!,
        style: const TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.normal,
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(
              end: 10.0, bottom: 10.0, top: 10.0),
          child: IconButton(
            icon: SvgPicture.asset('${imagePath}fav_black.svg',
                color: Theme.of(context)
                    .colorScheme.primary// Add your color here to apply your own color
            ),
            onPressed: () {
              // Navigator.push(
              //     context,
              //     CupertinoPageRoute(
              //       builder: (context) => const Favorite(),
              //     ));
            },
          ),
        ),
        Selector<UserProvider, String>(
          builder: (context, data, child) {
            return IconButton(
              icon: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        end: 10.0, bottom: 10.0, top: 10.0),
                    child: Center(
                        child: SvgPicture.asset(
                          '${imagePath}appbarCart.svg',
                          color: Theme.of(context)
                            .colorScheme.primary,
                        )),
                  ),
                  (data.isNotEmpty && data != '0')
                      ? Positioned(
                    bottom: 20,
                    right: 7,
                    child: Container(
                      //  height: 20,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: colors.primary),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Text(
                            data,
                            style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: colors.whiteTemp),
                          ),
                        ),
                      ),
                    ),
                  )
                      : Container()
                ],
              ),
              onPressed: () {
                cartTotalClear();
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const Cart(
                      fromBottom: false,
                    ),
                  ),
                );
              },
            );
          },
          selector: (_, homeProvider) => homeProvider.curCartCount,
        ),
      ],
    );

    /*return PreferredSize(
      preferredSize: appBar.preferredSize,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: context.watch<HomeProvider>().getBars ? 100 :0,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.white,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).colorScheme.black26,
                  blurRadius: 10)
            ],
          ),
          child: appBar),
    );*/
    return PreferredSize(
        preferredSize: appBar.preferredSize,
        child: SlideTransition(
          position: context.watch<HomeProvider>().animationAppBarBarOffset,
          child: SizedBox(
              height: context.watch<HomeProvider>().getBars ? 100 : 0,
              child: appBar),
        ));
    return SlideTransition(
      position: context.watch<HomeProvider>().animationAppBarBarOffset,
      child: Container(
        height: 75,
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        child: Row(),
      ),
    );
  }

//tab item enanable disable function
  getTabItem(String enabledImage, String disabledImage, int selectedIndex,
      String name) {
    return Wrap(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: SizedBox(
                height: 25,
                child: _selBottom == selectedIndex
                    ? Lottie.asset('assets/animation/$enabledImage',
                    repeat: false, height: 25)
                    : SvgPicture.asset(imagePath + disabledImage,
                    color: Colors.grey, height: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(getTranslated(context, name)!,
                  style: TextStyle(
                      color: _selBottom == selectedIndex
                          ? Theme.of(context).colorScheme.fontColor
                          : Theme.of(context).colorScheme.lightBlack,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 10.0),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            )
          ],
        ),
      ],
    );
  }

  //botoom navigation menu
  Widget _getBottomBar() {
    Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    return SlideTransition(
      position: context.watch<HomeProvider>().animationNavigationBarOffset,
      child: Container(
        height: context.watch<HomeProvider>().getBars
            ? kBottomNavigationBarHeight
            : 0,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.white,
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).colorScheme.black26, blurRadius: 5)
          ],
        ),
        child: Selector<ThemeNotifier, ThemeMode>(
            selector: (_, themeProvider) => themeProvider.getThemeMode(),
            builder: (context, data, child) {
              return TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: getTabItem(
                        (data == ThemeMode.system &&
                            currentBrightness == Brightness.dark) ||
                            data == ThemeMode.dark
                            ? 'dark_active_home.json'
                            : 'light_active_home.json',
                        'home.svg',
                        0,
                        'HOME_LBL'),
                  ),
                  Tab(
                    child: getTabItem(
                        (data == ThemeMode.system &&
                            currentBrightness == Brightness.dark) ||
                            data == ThemeMode.dark
                            ? 'dark_active_category.json'
                            : 'light_active_category.json',
                        'category.svg',
                        1,
                        'SHOP'),
                  ),
                  Tab(
                    child: getTabItem(
                        (data == ThemeMode.system &&
                            currentBrightness == Brightness.dark) ||
                            data == ThemeMode.dark
                            ? 'dark_active_explorer.json'
                            : 'light_active_explorer.json',
                        'brands.svg',
                        2,
                        'CATEGORY'),
                  ),
                  Tab(
                    child: getTabItem(
                        (data == ThemeMode.system &&
                            currentBrightness == Brightness.dark) ||
                            data == ThemeMode.dark
                            ? 'dark_active_cart.json'
                            : 'light_active_cart.json',
                        'cart.svg',
                        3,
                        'CART'),
                  ),
                  Tab(
                    child: getTabItem(
                        (data == ThemeMode.system &&
                            currentBrightness == Brightness.dark) ||
                            data == ThemeMode.dark
                            ? 'dark_active_profile.json'
                            : 'light_active_profile.json',
                        'profile.svg',
                        4,
                        'PROFILE'),
                  ),
                ],
                indicatorColor: Colors.transparent,
                labelColor: colors.primary,
                labelStyle: const TextStyle(fontSize: textFontSize12),
              );
            }),
      ),
    );
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
