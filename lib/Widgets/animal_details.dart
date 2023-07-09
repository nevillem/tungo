
import 'package:agritungotest/Helper/String.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/SimBtn.dart';
import '../Model/AnimalsModel.dart';
import '../Provider/CartProvider.dart';
import '../Provider/UserProvider.dart';
import '../Screen/Cart.dart';
import '../Screen/Favorite.dart';
import '../Screen/Search.dart';

class AnimalDetails extends StatefulWidget {
  final AnimalsModel? model;


  const AnimalDetails(
      {Key? key,  this.model})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StateItem();
}
class StateItem extends State<AnimalDetails> with TickerProviderStateMixin {
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  bool isBottom = false;
  bool seeView = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
    super.initState();
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
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(const Duration(seconds: 2)).then(
                    (_) async {
                  _isNetworkAvail = await isNetworkAvailable();
                  if (_isNetworkAvail) {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(
                        builder: (BuildContext context) => super.widget,
                      ),
                    );
                  } else {
                    await buttonController!.reverse();
                    if (mounted) {
                      setState(
                            () {},
                      );
                    }
                  }
                },
              );
            },
          )
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isBottom
          ? Colors.transparent.withOpacity(0.5)
          : Theme.of(context).canvasColor,
      body: _isNetworkAvail
          ? Stack(
        children: <Widget>[
          _showContent(),
          Selector<CartProvider, bool>(
            builder: (context, data, child) {
              return showCircularProgress(
                data,
                colors.primary,
              );
            },
            selector: (_, provider) => provider.isProgress,
          ),
        ],
      )
          : noInternet(context),
    );
  }
  _showContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            //  physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.6,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.white,
                stretch: true,
                title: Text("${getTranslated(context, "Animal detail for No")!} ${widget.model!.tagNumber}",
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .fontColor,
                    fontWeight: FontWeight.bold,
                    fontSize: textFontSize16,
                  ),),
                leading: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 5.0,
                    bottom: 10.0,
                    top: 10.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(circularBorderRadius10),
                      color: Theme.of(context).colorScheme.white,
                    ),
                    width: 20,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),
                actions: [
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //     right: 10.0,
                  //     bottom: 10.0,
                  //     top: 10.0,
                  //   ),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(
                  //         circularBorderRadius10,
                  //       ),
                  //       color: Theme.of(context).colorScheme.white,
                  //     ),
                  //     width: 40,
                  //     child: IconButton(
                  //       icon: SvgPicture.asset(
                  //         '${imagePath}search.svg',
                  //         height: 20,
                  //         color: colors.primary,
                  //       ),
                  //       onPressed: () {
                  //         Navigator.push(
                  //           context,
                  //           CupertinoPageRoute(
                  //             builder: (context) => const Search(),
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //     right: 10.0,
                  //     bottom: 10.0,
                  //     top: 10.0,
                  //   ),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       borderRadius:
                  //       BorderRadius.circular(circularBorderRadius10),
                  //       color: Theme.of(context).colorScheme.white,
                  //     ),
                  //     width: 40,
                  //     child: IconButton(
                  //       icon: SvgPicture.asset(
                  //         '${imagePath}desel_fav.svg',
                  //         height: 20,
                  //         color: colors.primary,
                  //       ),
                  //       onPressed: () {
                  //         Navigator.push(
                  //           context,
                  //           CupertinoPageRoute(
                  //             builder: (context) => const Favorite(),
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // ),
                  // Selector<UserProvider, String>(
                  //   builder: (context, data, child) {
                  //     return Padding(
                  //       padding: const EdgeInsets.only(
                  //         right: 10.0,
                  //         bottom: 10.0,
                  //         top: 10.0,
                  //       ),
                  //       child: Container(
                  //         decoration: BoxDecoration(
                  //           borderRadius:
                  //           BorderRadius.circular(circularBorderRadius10),
                  //           color: Theme.of(context).colorScheme.white,
                  //         ),
                  //         width: 40,
                  //         child: IconButton(
                  //           icon: Stack(
                  //             children: [
                  //               Center(
                  //                 child: SvgPicture.asset(
                  //                   '${imagePath}appbarCart.svg',
                  //                   color: colors.primary,
                  //                 ),
                  //               ),
                  //               (data != '' && data.isNotEmpty && data != '0')
                  //                   ? Positioned(
                  //                 bottom: 20,
                  //                 right: 0,
                  //                 child: Container(
                  //                   //  height: 20,
                  //
                  //                   decoration: const BoxDecoration(
                  //                     shape: BoxShape.circle,
                  //                     color: colors.primary,
                  //                   ),
                  //                   child: Center(
                  //                     child: Padding(
                  //                       padding: const EdgeInsets.all(3),
                  //                       child: Text(
                  //                         data,
                  //                         style: TextStyle(
                  //                           fontSize: 7,
                  //                           fontWeight: FontWeight.bold,
                  //                           color: Theme.of(context)
                  //                               .colorScheme
                  //                               .white,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ),
                  //               )
                  //                   : Container()
                  //             ],
                  //           ),
                  //           onPressed: () {
                  //             cartTotalClear();
                  //             Navigator.push(
                  //               context,
                  //               CupertinoPageRoute(
                  //                 builder: (context) => const Cart(
                  //                   fromBottom: false,
                  //                 ),
                  //               ),
                  //             );
                  //           },
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //   selector: (_, homeProvider) => homeProvider.curCartCount,
                  // )
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _slider(),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        //showBtn(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              color: Theme.of(context).colorScheme.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // _title(),
                                  // _rate(),
                                  // available! || outOfStock!
                                  //     ? _price(selectIndex, true)
                                  //     : _price(widget.model!.selVarient, false),
                                  // _offPrice(_oldSelVarient),
                                  // _shortDesc(),
                                ],
                              ),
                            ),
                            getDivider(5.0, context),
                            // _speciExtraBtnDetails(),
                            // getDivider(5.0, context),
                            _specification(),
                            // getDivider(5, context),
                            // _deliverPincode(),
                            // getDivider(5, context),
                            // _sellerDetail(),
                          ],
                        ),

                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _slider() {
    double height = MediaQuery.of(context).size.height * .43;
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: statusBarHeight),
          child:  Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  FadeInImage(
                    image: NetworkImage(
                      widget.model!.images,
                    ),
                    placeholder: const AssetImage(
                      'assets/images/sliderph.png',
                    ),
                    fit: extendImg ? BoxFit.fill : BoxFit.contain,
                    imageErrorBuilder: (context, error, stackTrace) =>
                        erroWidget(height),
                  )
                ],
              ),
        ),
        // favImg(),
        // shareProduct(),
        // indicatorImage(),
      ],
    );
  }
  _specification() {
    return  Container(
      color: Theme.of(context).colorScheme.white,
      padding: const EdgeInsets.only(top: 5.0),
      child: InkWell(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(
                  start: 10.0, end: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      getTranslated(context, 'MORE_COW_DETAILS')!,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                          Theme.of(context).colorScheme.lightBlack),
                    ),
                  ),
                  InkWell(
                    child: Padding(
                      padding:
                      const EdgeInsetsDirectional.only(start: 2.0),
                      child: Text(
                        !seeView
                            ? getTranslated(context, 'Read More')!
                            : getTranslated(context, 'Read Less')!,
                        style:
                        Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(
                            () {
                          seeView = !seeView;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            !seeView
                ? SizedBox(
              height: 70,
              width: deviceWidth! - 10,
              child: SingleChildScrollView(
                //padding: EdgeInsets.only(left: 5.0,right: 5.0),
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _attr(),
                    ]),
              ),
            )
                : Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HtmlWidget(
                  //   widget.model!.desc!,
                  // ),
                  _attr(),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  _attr() {
    return Padding(
          padding: EdgeInsetsDirectional.only(
              start: 25.0,
              top: 10.0,
              bottom:  7.0),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Stall",
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                      child: Text(
                        widget.model!.stallno!,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              getDivider(5.0, context),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Date of Birth",
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                      child: Text(
                        widget.model!.dateOfBirth!,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              getDivider(5.0, context),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Animal age(Days)",
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                      child: Text(
                        widget.model!.dateOfBirth!,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              getDivider(5.0, context),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Weight(kg)",
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                      child: Text(
                        widget.model!.weight!,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              getDivider(5.0, context),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Height(INCHES)",
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                      child: Text(
                        widget.model!.height!,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              getDivider(5.0, context),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Color",
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                      child: Text(
                        widget.model!.color!,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              getDivider(5.0, context),
              widget.model!.pregancyApproxPregancyTime !=''? Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Next pregnance time",
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                      child: Text(
                        widget.model!.pregancyApproxPregancyTime!,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ):Container(),
             getDivider(5.0, context),
              widget.model!.broughtFrom !=''?Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Bought From",
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                      child: Text(
                        widget.model!.broughtFrom!,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ):Container(),
            getDivider(5.0, context),
              widget.model!.vaccine !=''?Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Previous vaccine",
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                      child: Text(
                        widget.model!.vaccine!,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ):Container(),
             getDivider(5.0, context),
              widget.model!.broughtFrom !=''?Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Bought From",
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                      child: Text(
                        widget.model!.broughtFrom!,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ):Container(),
            getDivider(5.0, context),
              widget.model!.notes !=''?Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Previous vaccine",
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                      child: Text(
                        widget.model!.notes!,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ):Container(),

            ],
          ),
        );

  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 10,
      ),
      child: Text(
        widget.model!.tagNumber!,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.lightBlack,
          fontSize: textFontSize12,
        ),
      ),
    );
  }

}