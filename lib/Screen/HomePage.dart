import 'dart:async';
import 'dart:convert';
import 'dart:io';
import'dart:core';
import 'package:agritungotest/Screen/FarmDashboard.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agritungotest/Helper/ApiBaseHelper.dart';
import 'package:agritungotest/Helper/AppBtn.dart';
import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Helper/Constant.dart';
import 'package:agritungotest/Helper/Session.dart';
import 'package:agritungotest/Helper/SqliteData.dart';
import 'package:agritungotest/Helper/String.dart';
import 'package:agritungotest/Model/Model.dart';
import 'package:agritungotest/Model/Section_Model.dart';
import 'package:agritungotest/Provider/HomeProvider.dart';
import 'package:agritungotest/Provider/SettingProvider.dart';
import 'package:agritungotest/Provider/UserProvider.dart';
import 'package:agritungotest/widgets/product_details_new.dart';
// import 'package:eshop_multivendor/widgets/product_details_new.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Model/Categories_Model.dart';
import '../Provider/location_provider.dart';
import '../Widgets/FeaturesCard.dart';
import 'Login.dart';
import 'UpdateProfile.dart';
import 'crop_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

List<SectionModel> sectionList = [];
List<Product> catList = [];
List<Product> popularList = [];
ApiBaseHelper apiBaseHelper = ApiBaseHelper();
List<String> tagList = [];
List<Product> sellerList = [];
List<CategoriesData> categoriesList = [];
int count = 1;
List<Model> homeSliderList = [];
List<Widget> pages = [];
final symbolTemp='°C';

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, TickerProviderStateMixin {
  bool _isNetworkAvail = true;

  final _controller = PageController();
  late Animation buttonSqueezeanimation;
  late AnimationController buttonController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  List<Model> offerImages = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  var db = DatabaseHelper();
  final ScrollController _scrollBottomBarController = ScrollController();

  //String? curPin;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    SettingProvider setting =
    Provider.of<SettingProvider>(context, listen: false);
    user.setMobile(setting.mobile);
    user.setUserId(setting.userId);
    user.setFirstName(setting.firstName);
    user.setLastName(setting.lastName);
    user.setAccessToken(setting.accessToken);
    user.setRefreshToken(setting.refreshToken);
    // user.setEmail(setting.email);
    // user.setProfilePic(setting.profileUrl);
    callApi();
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

    //commented in sessions helper
    // Future.delayed(Duration.zero).then((value) {
    //   hideAppbarAndBottomBarOnScroll(_scrollBottomBarController, context);
    // });

    final postModel = Provider.of<WeatherProvider>(context, listen: false);
    postModel.getPostData();
    WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
    getSetting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isNetworkAvail
            ?RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            controller: _scrollBottomBarController,
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  child: Column(
                    children: [
                      _headerSection(),
                      // _showSliderPosition(),
                      // _catList(),
                      // _section(),
    //           _seller(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ):noInternet(context),
      ),
    );
  }

  Future<void> _refresh() {
    context.read<HomeProvider>().setCatLoading(true);
    context.read<HomeProvider>().setSecLoading(true);
    context.read<HomeProvider>().setSliderLoading(true);

    return callApi();
  }
  void getSetting() {
    CUR_USERID = context.read<SettingProvider>().userId;
    CUR_LAST_NAME = context.read<SettingProvider>().firstName;
    CUR_ACCESS = context.read<SettingProvider>().accessToken;
    CUR_REFRESH = context.read<SettingProvider>().refreshToken;
    CUR_FIRST_NAME = context.read<SettingProvider>().lastName;
    CUR_MOBILE = context.read<SettingProvider>().mobile;
    CUR_STATUS = context.read<SettingProvider>().status;
  }
  Widget _headerSection(){
    return  Column(
      children: [
        Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 80.0),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration:  BoxDecoration(
                  color:Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
              ),
              // height: 350.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      _slider(),
                      _showSliderPosition(),
                    ],
                  ),

                  // const SizedBox(height: 2,),
                  _username(),
                  // const SizedBox(height: 2,),
                  _getWeather(),
                  const SizedBox(height: 100.0,),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
              child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    Features(
                      title: "Crop Farm Management",
                      svgSrc: "assets/images/crops.svg",
                      press: ()  {
                        if((CUR_LAST_NAME ==null) || (CUR_LAST_NAME =='')){
                          updateUserProfile();
                        }
                        else{
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CropScreen()),
                          );
                        }
                      },
                    ),
                    Features(
                      title: "Livestock Farm Management",
                      svgSrc: "assets/images/Cow-face.svg",
                      press: ()  {
                        if((CUR_LAST_NAME ==null) || (CUR_LAST_NAME =='')){
                          // await Future.delayed(Duration(microseconds: 2));
                           updateUserProfile();
                        }
                        else{
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FarmDashboard()),
                          );

                        }
                        },
                    )]
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _slider() {
    double height = deviceWidth! / 1.8;
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? sliderLoading()
            : SizedBox(
          width: double.infinity,
          height: height,
          child: PageView.builder(
            itemCount: homeSliderList.length,
            scrollDirection: Axis.horizontal,
            controller: _controller,
            physics: const AlwaysScrollableScrollPhysics(),
            onPageChanged: (index) {
              context.read<HomeProvider>().setCurSlider(index);
            },
            itemBuilder: (BuildContext context, int index) {
              return pages[index];
            },
          ),
        );
      },
      selector: (_, homeProvider) => homeProvider.sliderLoading,
    );
  }
  Widget _getWeather(){
    double width = deviceWidth!;
    double height = width / 2.3;
    final postModel = Provider.of<WeatherProvider>(context);
    var temp =postModel.post?.data?.temp.toString()??"";
    return Container(
        height: height,
        // padding: EdgeInsets.symmetric(horizontal: 10),
        child:postModel.loading?sliderLoading()
            :Container(
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.white,
            // color: Color(0x007EEA),
            borderRadius: BorderRadius.circular(10),),
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    postModel.post?.data?.city.toString()??"",
                    style:Theme.of(this.context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.lightBlack,
                        fontSize: 25,
                        fontFamily: "opensans",
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Center(
                child: Text(temp+symbolTemp,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w200,
                    color: Theme.of(context).colorScheme.lightBlack,
                  ),),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Center(
                    child: Column(
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network('https:${postModel.post?.data?.icon??""}', width:50, height: 50,),
                              Text(postModel.post?.data?.textNote??"")
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),

            ],
          ),
        ));
  }
  Widget _username(){
    if(CUR_LAST_NAME==null){
      return Container();
    }else{
      return Container(
        width: deviceWidth,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text("Hello $CUR_LAST_NAME",
                  textAlign: TextAlign.left,
                  style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: "ubuntu",
                      fontWeight: FontWeight.w800)
              ),
            ],
          ),
        ),
      );
    }
  }

  void _animateSlider() {
    Future.delayed(const Duration(seconds: 5)).then(
          (_) {
        if (mounted) {
          int nextPage = _controller.hasClients
              ? _controller.page!.round() + 1
              : _controller.initialPage;

          if (nextPage == homeSliderList.length) {
            nextPage = 0;
          }
          if (_controller.hasClients) {
            _controller
                .animateToPage(nextPage,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.linear)
                .then((_) => _animateSlider());
          }
        }
      },
    );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Future<void> callApi() async {
    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    SettingProvider setting =
    Provider.of<SettingProvider>(context, listen: false);

    user.setUserId(setting.userId);

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getSlider();
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
    return;
  }

  updateDailog() async {
    await dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            title: Text(getTranslated(context, 'UPDATE_APP')!),
            content: Text(
              getTranslated(context, 'UPDATE_AVAIL')!,
              style: Theme.of(this.context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
            ),
            actions: <Widget>[
              TextButton(
                  child: Text(
                    getTranslated(context, 'NO')!,
                    style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                        color: Theme.of(context).colorScheme.lightBlack,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  }),
              TextButton(
                  child: Text(
                    getTranslated(context, 'YES')!,
                    style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(false);

                    String url = '';
                    if (Platform.isAndroid) {
                      url = androidLink + packageName;
                    } else if (Platform.isIOS) {
                      url = iosLink;
                    }

                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  })
            ],
          );
        }));
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

  //imagepage
  Widget _buildImagePageItem(Model slider) {
    double height = deviceWidth! / 2;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.white,
        borderRadius: BorderRadius.circular(10),),
      height: height,
      child: GestureDetector(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: FadeInImage(
              fadeInDuration: const Duration(milliseconds: 150),
              image: CachedNetworkImageProvider(slider.image!),
              height: height,
              //width: double.maxFinite,
              fit: BoxFit.fill,
              imageErrorBuilder: (context, error, stackTrace) => SvgPicture.asset(
                'assets/images/sliderph.png',
                fit: BoxFit.fill,
                height: height,
                color: colors.primary,
              ),
              placeholderErrorBuilder: (context, error, stackTrace) =>
                  SvgPicture.asset(
                    'assets/images/sliderph.png',
                    fit: BoxFit.fill,
                    height: height,
                    color: colors.primary,
                  ),
              placeholder: AssetImage('${imagePath}sliderph.png')),
        ),
        onTap: () async {
          int curSlider = context.read<HomeProvider>().curSlider;

          if (homeSliderList[curSlider].name == 'products') {
            Product? item = homeSliderList[curSlider].list;
            Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ProductDetail1(
                      model: item, secPos: 0, index: 0, list: true)),
            );
          } else if (homeSliderList[curSlider].name == 'categories') {
            Product item = homeSliderList[curSlider].list;
            if (item.subList == null || item.subList!.isEmpty) {
              // Navigator.push(
              //     context,
              //     CupertinoPageRoute(
              //       builder: (context) => ProductList(
              //         name: item.name,
              //         id: item.id,
              //         tag: false,
              //         fromSeller: false,
              //       ),
              //     ));
            } else {
              // Navigator.push(
              //     context,
              //     CupertinoPageRoute(
              //       builder: (context) => SubCategory(
              //         title: item.name!,
              //         subList: item.subList,
              //       ),
              //     ));
            }
          }
        },
      ),
    );
  }

  Widget deliverLoading() {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  Widget catLoading() {
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
                  callApi();
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
  _showSliderPosition() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: map<Widget>(
          homeSliderList,
              (index, url) {
            return Selector<HomeProvider, int>(
              builder: (context, curSliderIndex, child) {
                return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: curSliderIndex == index ? 25 : 8.0,
                    height: 5.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: curSliderIndex == index
                          ? Theme.of(context).colorScheme.blue
                          : Theme.of(context)
                          .colorScheme
                          .blue
                          .withOpacity(0.7),
                    ));
              },
              selector: (_, slider) => slider.curSlider,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollBottomBarController.removeListener(() {});
    super.dispose();
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;

    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  Future<void> getSlider() async {
    Map map = {};
    Response response =
    await get(getSliderApi,headers: headers)
        .timeout(const Duration(seconds: timeOut));
    Map<String, dynamic> getdata = json.decode(response.body);

    bool success = getdata['success'];
    String? msg = getdata['message'];
    if (success==true) {
      List data= getdata['data']['categories'];
      homeSliderList =  data.map((data) => Model.fromSlider(data)).toList();
      pages = homeSliderList.map((slider) {
        return _buildImagePageItem(slider);
      }).toList();
    } else {
      setSnackbar(msg!, context);
    }
    context.read<HomeProvider>().setSliderLoading(false);
  }

    void appMaintenanceDialog() async {
    await dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              title: Text(
                getTranslated(context, 'APP_MAINTENANCE')!,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.normal,
                    fontSize: 16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Lottie.asset('assets/animation/app_maintenance.json'),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    MAINTENANCE_MESSAGE != ''
                        ? '$MAINTENANCE_MESSAGE'
                        : getTranslated(context, 'MAINTENANCE_DEFAULT_MESSAGE')!,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 12),
                  )
                ],
              ),
            ),
          );
        }));
  }
 updateUserProfile() async {
   await dialogAnimate(
       context,
       StatefulBuilder(
       builder: (BuildContext context, setState) {
     return AlertDialog(
       elevation: 0,
       shape: const RoundedRectangleBorder(
         borderRadius: BorderRadius.all(
           Radius.circular(5.0),
         ),
       ),
       content: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         crossAxisAlignment: CrossAxisAlignment.center,
         mainAxisSize: MainAxisSize.min,
         children: [
           //==================
           // when currentIndex == 0
           //==================
           Text(
             getTranslated(context, "Update profile")!,
             style: Theme.of(this.context)
                 .textTheme
                 .subtitle2!
                 .copyWith(
               color: Theme.of(context).colorScheme.error,
               fontWeight: FontWeight.bold,
             ),
           ),
        const SizedBox(
             height: 10,
           ),
            Text(
             getTranslated(
               context,
               'Please update your profile to access this service',
             )!,
             style: Theme.of(this.context)
                 .textTheme
                 .titleSmall!
                 .copyWith(),
           ),

         ],
       ),
       actions: <Widget>[
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           children: [
             TextButton(
               child: Text(
                 getTranslated(context, 'NO')!,
                 style: Theme.of(this.context)
                     .textTheme
                     .titleSmall!
                     .copyWith(
                   color:
                   Theme.of(context).colorScheme.lightBlack,
                   fontWeight: FontWeight.bold,
                 ),
               ),
               onPressed: () {
                 Navigator.of(context).pop(false);
               },
             ),
            TextButton(
               child: Text(
                 getTranslated(context, 'YES')!,
                 style: Theme.of(this.context)
                     .textTheme
                     .titleSmall!
                     .copyWith(
                   color: Theme.of(context).colorScheme.error,
                   fontWeight: FontWeight.bold,
                 ),
               ),
               onPressed: () {
                 Navigator.pop(context);
                 Navigator.of(context).push(
                     CupertinoPageRoute(
                       builder: (context) => UserProfile(),
                     ),
                   );
               },
             )
           ],
         ),
       ],
     );
   },
   ),
   );
 }

}
