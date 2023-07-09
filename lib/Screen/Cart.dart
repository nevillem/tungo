import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Helper/Constant.dart';
import 'package:agritungotest/Helper/Session.dart';
import 'package:agritungotest/Helper/SqliteData.dart';
import 'package:agritungotest/Provider/CartProvider.dart';
import 'package:agritungotest/Provider/SettingProvider.dart';
import 'package:agritungotest/Provider/UserProvider.dart';
import 'package:agritungotest/Screen/Add_Address.dart';
import 'package:agritungotest/Screen/HomePage.dart';
import 'package:agritungotest/Screen/PromoCode.dart';
import 'package:agritungotest/Screen/Shop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart'as http;
import '../Helper/AppBtn.dart';
import '../Helper/SimBtn.dart';
import '../Helper/String.dart';
import '../Model/Model.dart';
import '../Model/Section_Model.dart';
import '../Model/User.dart';
import 'Login.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import 'Manage_Address.dart';
import 'Order_Success.dart';
import 'Payment.dart';

class Cart extends StatefulWidget {
  final bool fromBottom;

  const Cart({Key? key, required this.fromBottom}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateCart();
}

List<User> addressList = [];

List<Promo> promoList = [];
double totalPrice = 0, oriPrice = 0, delCharge = 0, taxPer = 0;
int? selectedAddress = 0;
String? selAddress, payMethod = '', selTime, selDate, promocode;
bool? isTimeSlot=false,
    isPromoValid = false,
    isUseWallet = false,
    isPayLayShow = true;
int? selectedTime, selectedDate, selectedMethod;

double promoAmt = 0;
double remWalBal = 0, usedBal = 0;
bool isAvailable = true;

String? razorpayId,
    paystackId,
    stripeId,
    stripeSecret,
    stripeMode = 'test',
    stripeCurCode,
    stripePayId,
    paytmMerId,
    paytmMerKey;
bool payTesting = true;
bool isPromoLen = false;
List<SectionModel> saveLaterList = [];

/*String gpayEnv = "TEST",
    gpayCcode = "US",
    gpaycur = "USD",
    gpayMerId = "01234567890123456789",
    gpayMerName = "Example Merchant Name";*/

class StateCart extends State<Cart> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  GlobalKey<ScaffoldMessengerState>();

  final GlobalKey<ScaffoldMessengerState> _checkscaffoldKey =
  GlobalKey<ScaffoldMessengerState>();
  List<Model> deliverableList = [];
  bool _isCartLoad = true, _placeOrder = true, _isSaveLoad = true;

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  TextEditingController promoC = TextEditingController();
  final List<TextEditingController> _controller = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  String? msg;
  bool _isLoading = true;

  TextEditingController noteC = TextEditingController();
  StateSetter? checkoutState;
  bool deliverable = false;
  bool saveLater = false, addCart = false;
  final ScrollController _scrollControllerOnCartItems = ScrollController();
  final ScrollController _scrollControllerOnSaveForLaterItems =
  ScrollController();
  List<String> proIds = [];
  List<String> proVarIds = [];
  var db = DatabaseHelper();
  List<File> prescriptionImages = [];
  bool isAvailable = true;

  @override
  void initState() {
    super.initState();
    prescriptionImages.clear();
    callApi();

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
  }

  // callApi() async {
  //   if (CUR_USERID != null) {
  //     _getCart('0');
  //     _getSaveLater('1');
  //   } else {
  //     proIds = (await db.getCart())!;
  //     _getOffCart();
  //     proVarIds = (await db.getSaveForLater())!;
  //     _getOffSaveLater();
  //   }
  // }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }
  callApi() async {
    proIds = (await db.getCart())!;
    _getOffCart();
    proVarIds = (await db.getSaveForLater())!;
    _getOffSaveLater();
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _isCartLoad = true;
        _isSaveLoad = true;
      });
    }
    isAvailable = true;
    oriPrice = 0;
    saveLaterList.clear();
    proIds = (await db.getCart())!;
    await _getOffCart();
    proVarIds = (await db.getSaveForLater())!;
    await _getOffSaveLater();
  }

  clearAll() {
    totalPrice = 0;
    oriPrice = 0;

    taxPer = 0;
    delCharge = 0;
    addressList.clear();
    WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) {
        context.read<CartProvider>().setCartlist([]);
        context.read<CartProvider>().setProgress(false);
      },
    );

    promoAmt = 0;
    remWalBal = 0;
    usedBal = 0;
    payMethod = '';
    isPromoValid = false;
    isUseWallet = false;
    isPayLayShow = true;
    selectedMethod = null;
  }

  @override
  void dispose() {
    buttonController!.dispose();
    promoC.dispose();
    _scrollControllerOnCartItems.removeListener(() {});
    _scrollControllerOnSaveForLaterItems.removeListener(() {});

    for (int i = 0; i < _controller.length; i++) {
      _controller[i].dispose();
    }

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
                          builder: (BuildContext context) => super.widget),
                    );
                  } else {
                    await buttonController!.reverse();
                    if (mounted) setState(() {});
                  }
                },
              );
            },
          )
        ],
      ),
    );
  }

  updatePromo(String promo) {
    setState(
          () {
        isPromoLen = false;
        promoC.text = promo;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
/*    hideAppbarAndBottomBarOnScroll(_scrollControllerOnCartItems, context);
    hideAppbarAndBottomBarOnScroll(
        _scrollControllerOnSaveForLaterItems, context);*/
    return Scaffold(
      appBar: widget.fromBottom
          ? null
          : getSimpleAppBar(getTranslated(context, 'CART')!, context),
      body: _isNetworkAvail
          ? Stack(
        children: <Widget>[
          _showContent1(context),
          Selector<CartProvider, bool>(
            builder: (context, data, child) {
              return showCircularProgress(data, colors.primary);
            },
            selector: (_, provider) => provider.isProgress,
          ),
        ],
      )
          : noInternet(context),
    );
  }


  Widget listItem(int index, List<SectionModel> cartList) {
    int selectedPos = 0;
    // for (int i = 0;
    // i < cartList[index].productList![0].prVarientList!.length;
    // i++) {
    //   if (cartList[index].varientId ==
    //       cartList[index].productList![0].prVarientList![i].id) selectedPos = i;
    // }

    String? offPer;
    double price = double.parse(
        "${cartList[index].productList![0].discPrice}");
    if (price == 0) {
      price = double.parse(
          cartList[index].productList![0].price!.replaceAll(RegExp('[^0-9]'), ''));
    } else {
      double off = (double.parse(cartList[index]
          .productList![0].price!.replaceAll(RegExp('[^0-9]'), ''))) -
          price;
      double discountPrice = price /
          100 *
          double.parse(cartList[index].productList![0].price!.replaceAll(RegExp('[^0-9]'), ''));
      price=double.parse(cartList[index].productList![0].price!.replaceAll(RegExp('[^0-9]'), '')) -discountPrice;

      offPer = (double.parse("${cartList[index]
          .productList![0].discPrice}"))
          .toStringAsFixed(2);

    }

    cartList[index].perItemPrice = price.toString();

    if (_controller.length < index + 1) {
      _controller.add(TextEditingController());
    }
    if (cartList[index].productList![0].availability == 'instock') {
      cartList[index].perItemTotal =
          (price * double.parse(cartList[index].qty!)).toString();
      _controller[index].text = cartList[index].qty!;
    }
    // List att = [], val = [];
    // if (cartList[index].productList![0].prVarientList![selectedPos].attr_name !=
    //     '') {
    //   att = cartList[index]
    //       .productList![0]
    //       .prVarientList![selectedPos]
    //       .attr_name!
    //       .split(',');
    //   val = cartList[index]
    //       .productList![0]
    //       .prVarientList![selectedPos]
    //       .varient_value!
    //       .split(',');
    // }

    // if (cartList[index].productList![0]!.isEmpty) {
    //   if (cartList[index].productList![0].availability == '0') {
    //     isAvailable = false;
    //   }
    // } else {
    //   if (cartList[index]
    //       .productList![0]
    //       .prVarientList![selectedPos]
    //       .availability ==
    //       '0') {
    //     isAvailable = false;
    //   }
    // }
    if (cartList[index]
        .productList![0].availability != 'instock') {
      isAvailable = false;
    }

    // double total = (price *
    //     double.parse(cartList[index]
    //         .productList![0]
    //         .prVarientList![selectedPos]
    //         .cartCount!));
    double total = (price * 0);

    print(
        " productaa : ${cartList[index].productList![0].image!.isEmpty}");

    // print(
    //     "testing ${cartList[index].productList![0].prVarientList![selectedPos].images![0]}");

    print(
        "cartList[index].productList![0].type : ${cartList[index].productList![0].type}");

    return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 1.0,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: 0.1,
              child: Row(
                children: <Widget>[
                  Hero(
                      tag: "$index${cartList[index].productList![0].id}",
                      child: Stack(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(7.0),
                              child: Stack(children: [
                                FadeInImage(
                                  image: NetworkImage(
                                    cartList[index]
                                        .productList![0]
                                        .image!,
                                  ),
                                  height: 100.0,
                                  width: 100.0,
                                  fit: extendImg ? BoxFit.fill : BoxFit.contain,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) =>
                                      erroWidget(125),
                                  placeholder: placeHolder(125),
                                ),
                                Positioned.fill(
                                    child: cartList[index].productList![0].availability != 'instock'
                                        ? Container(
                                      height: 55,
                                      color: colors.white70,
                                      padding: const EdgeInsets.all(2),
                                      child: Center(
                                        child: Text(
                                          getTranslated(context,
                                              'OUT_OF_STOCK_LBL')!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                            color: colors.red,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                        : Container()),
                              ])),
                          offPer != null
                              ? getDiscountLabel(double.parse(offPer))
                              : Container()
                        ],
                      )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      top: 5.0),
                                  child: Text(
                                    cartList[index].productList![0].name!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              InkWell(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 8.0, end: 8, bottom: 8),
                                  child: Icon(
                                    Icons.close,
                                    size: 20,
                                    color:
                                    Theme.of(context).colorScheme.fontColor,
                                  ),
                                ),
                                onTap: () async {
                                  if (context.read<CartProvider>().isProgress ==
                                      false) {
                                    db.removeCart(
                                      // cartList[index]
                                      //     .productList![0]
                                      //     .prVarientList![selectedPos]
                                      //     .id!,
                                        cartList[index].id!,
                                        context);
                                    cartList.removeWhere((item) =>
                                    item.productId ==
                                        cartList[index].productId);
                                    oriPrice = oriPrice - total;
                                    proIds = (await db.getCart())!;
                                    setState(() {
                                      _getOffSaveLater();
                                    });
                                  }
                                },
                              )
                            ],
                          ),
                          // cartList[index]
                          //     .productList![0]
                          //     .prVarientList![selectedPos]
                          //     .attr_name !=
                          //     null &&
                          //     cartList[index]
                          //         .productList![0]
                          //         .prVarientList![selectedPos]
                          //         .attr_name!
                          //         .isNotEmpty
                          //     ? ListView.builder(
                          //     physics: const NeverScrollableScrollPhysics(),
                          //     shrinkWrap: true,
                          //     itemCount: att.length,
                          //     itemBuilder: (context, index) {
                          //       return Row(children: [
                          //         Flexible(
                          //           child: Text(
                          //             att[index].trim() + ':',
                          //             overflow: TextOverflow.ellipsis,
                          //             style: Theme.of(context)
                          //                 .textTheme
                          //                 .subtitle2!
                          //                 .copyWith(
                          //               color: Theme.of(context)
                          //                   .colorScheme
                          //                   .lightBlack,
                          //             ),
                          //           ),
                          //         ),
                          //         Padding(
                          //           padding:
                          //           const EdgeInsetsDirectional.only(
                          //               start: 5.0),
                          //           child: Text(
                          //             val[index],
                          //             style: Theme.of(context)
                          //                 .textTheme
                          //                 .subtitle2!
                          //                 .copyWith(
                          //                 color: Theme.of(context)
                          //                     .colorScheme
                          //                     .lightBlack,
                          //                 fontWeight: FontWeight.bold),
                          //           ),
                          //         )
                          //       ]);
                          //     })
                          //     : Container(),
                          Row(
                            children: <Widget>[
                              Text(
                                double.parse(cartList[index]
                                    .productList![0].discPrice!) !=
                                    0
                                    ? getPriceFormat(
                                    context,
                                    double.parse(cartList[index]
                                        .productList![0].price!.replaceAll(RegExp('[^0-9]'), ''),))!
                                    : '',
                                style: Theme.of(context)
                                    .textTheme
                                    .overline!
                                    .copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    letterSpacing: 0.7),
                              ),
                              Text(
                                ' ${getPriceFormat(context, price)!} ',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          cartList[index].productList![0].availability == 'instock' ||
                              cartList[index].productList![0].stockType ==
                                  ''
                              ? Row(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  InkWell(
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(50),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.remove,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      // print("added qty: ${ cartList[index].productList![0].total!}");
                                      if (context
                                          .read<CartProvider>()
                                          .isProgress ==
                                          false) {
                                        if ((int.parse(cartList[index].qty!)) >
                                            1) {
                                          setState(() {
                                            addAndRemoveQty(
                                                cartList[index].qty!,
                                                2,
                                                cartList[index]
                                                    .productList![0]
                                                    .itemsCounter!
                                                    .length *
                                                    int.parse(cartList[
                                                    index]
                                                        .productList![0]
                                                        .qtyStepSize!),
                                                index,
                                                price,
                                                selectedPos,
                                                total,
                                                cartList,
                                                int.parse(
                                                    cartList[index]
                                                        .productList![0]
                                                        .qtyStepSize!));
                                          });
                                        }
                                      }
                                    },
                                  ),
                                  SizedBox(
                                    width: 37,
                                    height: 20,
                                    child: Stack(
                                      children: [
                                        TextField(
                                          textAlign: TextAlign.center,
                                          readOnly: true,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor),
                                          controller: _controller[index],
                                          decoration:
                                          const InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          tooltip: '',
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                            size: 1,
                                          ),
                                          onSelected: (String value) {
                                            if (context
                                                .read<CartProvider>()
                                                .isProgress ==
                                                false) {

                                              addAndRemoveQty(
                                                  value,
                                                  3,
                                                  int.parse(cartList[
                                                  index].productList![0].qtyStepSize!),
                                                  index,
                                                  price,
                                                  selectedPos,
                                                  total,
                                                  cartList,
                                                  int.parse(cartList[
                                                  index]
                                                      .productList![0]
                                                      .qtyStepSize!));

                                            }
                                          },
                                          itemBuilder:
                                              (BuildContext context) {
                                            print("counter:${cartList[index].productList![0].itemsCounter!.length}");
                                            return cartList[index]
                                                .productList![0]
                                                .itemsCounter!
                                                .map<
                                                PopupMenuItem<
                                                    String>>(
                                                    (String value) {
                                                  return PopupMenuItem(
                                                      value: value,
                                                      child: Text(value,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                  context)
                                                                  .colorScheme
                                                                  .fontColor)));
                                                }).toList();
                                          },
                                        ),
                                      ],
                                    ),
                                  ), // ),

                                  InkWell(
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(50),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.add,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      if (context
                                          .read<CartProvider>()
                                          .isProgress ==
                                          false) {
                                        addAndRemoveQty(
                                            cartList[index].qty!,
                                            1,
                                            int.parse(
                                                cartList[index]
                                                    .productList![0]
                                                    .qtyStepSize!),
                                            index,
                                            price,
                                            selectedPos,
                                            total,
                                            cartList,
                                            int.parse(cartList[index]
                                                .productList![0]
                                                .qtyStepSize!));
                                      }
                                    },
                                  )
                                ],
                              ),
                            ],
                          )
                              : Container(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned.directional(
                textDirection: Directionality.of(context),
                end: 5,
                bottom: 12,
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: InkWell(
                    onTap: !saveLater &&
                        !context.read<CartProvider>().isProgress
                        ? () {
                      if (int.parse(cartList[index].qty!) >
                          0) {
                        setState(() async {
                          saveLater = true;
                          context
                              .read<CartProvider>()
                              .setProgress(true);
                          await saveForLaterFun(
                              index, selectedPos, total, cartList);
                        });
                      } else {
                        context.read<CartProvider>().setProgress(true);
                      }
                    }: null,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.archive_rounded,
                        size: 20,
                      ),
                    ),
                  ),
                ))
          ],
        ));
  }

  Widget cartItem(int index, List<SectionModel> cartList) {
    int selectedPos = 0;
    // for (int i = 0;
    // i < cartList[index].productList![0].prVarientList!.length;
    // i++) {
    //   if (cartList[index].varientId ==
    //       cartList[index].productList![0].prVarientList![i].id) selectedPos = i;
    // }

    String? offPer;
    double price = double.parse(
        "${cartList[index].productList![0].discPrice}");
    if (price == 0) {
      price = double.parse(
          cartList[index].productList![0].price!.replaceAll(RegExp('[^0-9]'), ''));
    } else {
      double off = (double.parse(cartList[index]
          .productList![0].price!.replaceAll(RegExp('[^0-9]'), ''))) -
          price;
      double discountPrice = price /
          100 *
          double.parse(cartList[index].productList![0].price!.replaceAll(RegExp('[^0-9]'), ''));
      price=double.parse(cartList[index].productList![0].price!.replaceAll(RegExp('[^0-9]'), '')) -discountPrice;

      offPer = (double.parse("${cartList[index]
          .productList![0].discPrice}"))
          .toStringAsFixed(2);

    }

    cartList[index].perItemPrice = price.toString();

    if (_controller.length < index + 1) {
      _controller.add(TextEditingController());
    }
    if (cartList[index].productList![0].availability == 'instock') {
      cartList[index].perItemTotal =
          (price * double.parse(cartList[index].qty!)).toString();
      _controller[index].text = cartList[index].qty!;
    }
    // List att = [], val = [];
    // if (cartList[index].productList![0].prVarientList![selectedPos].attr_name !=
    //     '') {
    //   att = cartList[index]
    //       .productList![0]
    //       .prVarientList![selectedPos]
    //       .attr_name!
    //       .split(',');
    //   val = cartList[index]
    //       .productList![0]
    //       .prVarientList![selectedPos]
    //       .varient_value!
    //       .split(',');
    // }

    // if (cartList[index].productList![0]!.isEmpty) {
    //   if (cartList[index].productList![0].availability == '0') {
    //     isAvailable = false;
    //   }
    // } else {
    //   if (cartList[index]
    //       .productList![0]
    //       .prVarientList![selectedPos]
    //       .availability ==
    //       '0') {
    //     isAvailable = false;
    //   }
    // }
    if (cartList[index]
        .productList![0].availability != 'instock') {
      isAvailable = false;
    }

    // double total = (price *
    //     double.parse(cartList[index]
    //         .productList![0]
    //         .prVarientList![selectedPos]
    //         .cartCount!));
    double total = (price * 0);


    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Hero(
                    tag: "$index${cartList[index].productList![0].id}",
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.0),
                        child:FadeInImage(
                          image: NetworkImage(
                            cartList[index]
                                .productList![0]
                                .image!,
                          ),
                          height: 100.0,
                          width: 100.0,
                          fit: extendImg ? BoxFit.fill : BoxFit.contain,
                          imageErrorBuilder:
                              (context, error, stackTrace) =>
                              erroWidget(125),
                          placeholder: placeHolder(125),
                        ))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsetsDirectional.only(top: 5.0),
                                child: Text(
                                  cartList[index].productList![0].name!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 8.0, end: 8, bottom: 8),
                                child: Icon(
                                  Icons.close,
                                  size: 13,
                                  color:
                                  Theme.of(context).colorScheme.fontColor,
                                ),
                              ),
                              onTap: () async {
                                if (context.read<CartProvider>().isProgress ==
                                    false) {
                                  db.removeCart(
                                    // cartList[index]
                                    //     .productList![0]
                                    //     .prVarientList![selectedPos]
                                    //     .id!,
                                      cartList[index].id!,
                                      context);
                                  cartList.removeWhere((item) =>
                                  item.productId ==
                                      cartList[index].productId);
                                  oriPrice = oriPrice - total;
                                  proIds = (await db.getCart())!;
                                  setState(() {
                                    _getOffSaveLater();
                                  });
                                }
                              },
                            )
                          ],
                        ),
                        Row(
                          // mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              double.parse(cartList[index]
                                  .productList![0].discPrice!) !=
                                  0
                                  ? getPriceFormat(
                                  context,
                                  double.parse(cartList[index]
                                      .productList![0].price!.replaceAll(RegExp('[^0-9]'), ''),))!
                                  : '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  letterSpacing: 0.7),
                            ),
                            SizedBox(width: 2,),
                            Text(
                              '${getPriceFormat(context, price)!} ',
                              style: TextStyle(
                                  color:
                                  Theme.of(context).colorScheme.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        cartList[index].productList![0].availability ==
                            'instock' ||
                            cartList[index].productList![0].stockType ==
                                ''? Row(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                InkWell(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(50),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                    ),
                                  ),
                                  onTap: () {

                                  },
                                ),
                                SizedBox(
                                  width: 37,
                                  height: 20,
                                  child: Stack(
                                    children: [
                                      TextField(
                                        textAlign: TextAlign.center,
                                        readOnly: true,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor),
                                        controller:
                                        _controller[index],
                                        decoration:
                                        const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(50),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                      ),
                                    ),
                                    onTap: () {
                                    })
                              ],
                            ),
                          ],
                        )
                            : Container(),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  getTranslated(context, 'NET_AMOUNT')!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                ),
                Text(
                  ' ${getPriceFormat(context, (double.parse(cartList[index].perItemPrice!)))!} x ${cartList[index].qty}',
                  // ' ${getPriceFormat(context, (price - cartList[index].perItemTaxPriceOnItemAmount!))!} x ${cartList[index].qty}',
                  style: TextStyle(
                    fontSize:12 ,
                      color: Theme.of(context).colorScheme.lightBlack2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '= ${getPriceFormat(context, ((double.parse(cartList[index].perItemPrice!)) * double.parse(cartList[index].qty!)))!}',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                )
              ],
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       getTranslated(context, 'TAXPER')!,
            //       style: TextStyle(
            //           color: Theme.of(context).colorScheme.lightBlack2),
            //     ),
            //     Text(
            //       '${cartList[index].productList![0].tax!}%',
            //       style: TextStyle(
            //           color: Theme.of(context).colorScheme.lightBlack2),
            //     ),
            //     Text(
            //       ' ${getPriceFormat(context, ((double.parse(cartList[index].singleItemTaxAmount!)) * double.parse(cartList[index].qty!)))}',
            //       style: TextStyle(
            //           color: Theme.of(context).colorScheme.lightBlack2),
            //     )
            //   ],
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, 'TOTAL_LBL')!,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.lightBlack2),
                ),
                // !avail! && deliverableList.isNotEmpty
                //     ? Text(
                //   getTranslated(context, 'NOT_DEL')!,
                //   style: const TextStyle(color: colors.red),
                // )
                //     : Container(),
                Text(
                  getPriceFormat(
                      context,
                      (((double.parse(cartList[index].perItemPrice!)) *
                          double.parse(cartList[index].qty!)) ))!,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.fontColor),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget saveLaterItem(int index) {
    int selectedPos = 0;
    for (int i = 0;
    i < saveLaterList[index].productList![0].prVarientList!.length;
    i++)
    {
      if (saveLaterList[index].varientId ==
          saveLaterList[index].productList![0].prVarientList![i].id) {
        selectedPos = i;
      }
    }

    double price = double.parse(saveLaterList[index]
        .productList![0]
        .prVarientList![selectedPos]
        .disPrice!);
    if (price == 0) {
      price = double.parse(saveLaterList[index]
          .productList![0]
          .prVarientList![selectedPos]
          .price!);
    }

    double off = (double.parse(saveLaterList[index]
        .productList![0]
        .prVarientList![selectedPos]
        .price!) -
        double.parse(saveLaterList[index]
            .productList![0]
            .prVarientList![selectedPos]
            .disPrice!))
        .toDouble();
    off = off *
        100 /
        double.parse(saveLaterList[index]
            .productList![0]
            .prVarientList![selectedPos]
            .price!);

    saveLaterList[index].perItemPrice = price.toString();
    if (saveLaterList[index].productList![0].availability != '0') {
      saveLaterList[index].perItemTotal =
          (price * double.parse(saveLaterList[index].qty!)).toString();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          elevation: 0.1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Hero(
                    tag: "$index${saveLaterList[index].productList![0].id}",
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(7.0),
                            child: Stack(children: [
                              FadeInImage(
                                image: NetworkImage(
                                    saveLaterList[index].productList![0].type ==
                                        "variable_product" &&
                                        saveLaterList[index]
                                            .productList![0]
                                            .prVarientList![selectedPos]
                                            .images!
                                            .isNotEmpty
                                        ? saveLaterList[index]
                                        .productList![0]
                                        .prVarientList![selectedPos]
                                        .images![0]
                                        : saveLaterList[index]
                                        .productList![0]
                                        .image!),
                                height: 100.0,
                                width: 100.0,
                                fit: extendImg ? BoxFit.fill : BoxFit.contain,
                                imageErrorBuilder:
                                    (context, error, stackTrace) =>
                                    erroWidget(100),
                                placeholder: placeHolder(100),
                              ),
                              Positioned.fill(
                                  child: saveLaterList[index]
                                      .productList![0]
                                      .availability ==
                                      '0'
                                      ? Container(
                                    height: 55,
                                    color: colors.white70,
                                    padding: const EdgeInsets.all(2),
                                    child: Center(
                                      child: Text(
                                        getTranslated(
                                            context, 'OUT_OF_STOCK_LBL')!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                      : Container()),
                            ])),
                        off != 0 &&
                            saveLaterList[index]
                                .productList![0]
                                .prVarientList![selectedPos]
                                .disPrice! !=
                                '0'
                            ? getDiscountLabel(off)
                            : Container()
                      ],
                    )),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsetsDirectional.only(top: 5.0),
                                child: Text(
                                  saveLaterList[index].productList![0].name!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 8.0, end: 8, bottom: 8),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color:
                                  Theme.of(context).colorScheme.fontColor,
                                ),
                              ),
                              onTap: () async {
                                if (context.read<CartProvider>().isProgress ==
                                    false) {
                                  if (CUR_USERID != null) {
                                    removeFromCart(index, true, saveLaterList,
                                        true, selectedPos);
                                  } else {
                                    db.removeSaveForLater(
                                      // saveLaterList[index]
                                      //     .productList![0]
                                      //     .prVarientList![selectedPos]
                                      //     .id!,
                                        saveLaterList[index]
                                            .productList![0]
                                            .id!);
                                    proVarIds.remove(saveLaterList[index]
                                        .productList![0]
                                        .prVarientList![selectedPos]
                                        .id!);

                                    saveLaterList.removeAt(index);
                                    setState(() {});
                                  }
                                }
                              },
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              double.parse(saveLaterList[index]
                                  .productList![0]
                                  .prVarientList![selectedPos]
                                  .disPrice!) !=
                                  0
                                  ? getPriceFormat(
                                  context,
                                  double.parse(saveLaterList[index]
                                      .productList![0]
                                      .prVarientList![selectedPos]
                                      .price!))!
                                  : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .overline!
                                  .copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  letterSpacing: 0.7),
                            ),
                            Text(
                              ' ${getPriceFormat(context, price)!} ',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        saveLaterList[index].productList![0].availability == '1' ||
            saveLaterList[index].productList![0].stockType == ''
            ? Positioned.directional(
            textDirection: Directionality.of(context),
            bottom: 12,
            end: 5,
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: InkWell(
                onTap: !addCart && !context.read<CartProvider>().isProgress
                    ? () {
                  if (CUR_USERID != null) {
                    setState(() {
                      addCart = true;
                    });
                    saveForLater(
                        saveLaterList[index].varientId,
                        '0',
                        saveLaterList[index].qty,
                        double.parse(
                            saveLaterList[index].perItemTotal!),
                        saveLaterList[index],
                        true);
                  } else {
                    setState(() async {
                      addCart = true;
                      context.read<CartProvider>().setProgress(true);
                      await cartFun(
                          index,
                          selectedPos,
                          double.parse(
                              saveLaterList[index].perItemTotal!));
                    });
                  }
                }
                    : null,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.shopping_cart,
                    size: 20,
                  ),
                ),
              ),
            ))
            : Container()
      ],
    );
  }

  Future<void> _getCart(String save) async {
    _isNetworkAvail = await isNetworkAvailable();

    if (_isNetworkAvail) {
      try{
        Response response =
        await get(getProductApi, headers: headers)
            .timeout(const Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool success = getdata['success'];
        String? msg = getdata['message'];

        if (success==true) {
          print(true);
          var data = getdata['data']["products"];

          List<SectionModel> cartList = [];
          cartList= (data as List)
              .map((data) => SectionModel.fromCart(data))
              .toList();

          List<SectionModel>  newList=[];
          for (int i = 0; i < proIds.length; i++) {
            // cropData.where((x) => x.id!.contains("{cropIds[i]}"));
            // cropData.removeWhere((element) => element.id == "${cropIds[i]}");
            // cropData.removeWhere((element) => element.id == "${cropIds[i]}");
            newList=cartList .where((x) => x.id == "${proIds[i]}").toList();
            context.read<CartProvider>().setCartlist(newList);
          }

          if (getdata.containsKey(PROMO_CODES)) {
            var promo = getdata[PROMO_CODES];
            promoList =
                (promo as List).map((e) => Promo.fromJson(e)).toList();
          }

          for (int i = 0; i < cartList.length; i++) {
            _controller.add(TextEditingController());
          }
        } else {
          if (msg != 'Cart Is Empty !') setSnackbar(msg!, _scaffoldKey);
        }
        if (mounted) {
          setState(() {
            _isCartLoad = false;
          });
        }
        _getAddress();

      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  Future<void> _getOffCart() async {
    if (proIds.isNotEmpty) {
      _isNetworkAvail = await isNetworkAvailable();

      if (_isNetworkAvail) {
        try {

          var parameter = {'product_variant_ids': proIds.join(',')};

          Response response =
          await get(getProductApi, headers: headers)
              .timeout(const Duration(seconds: timeOut));

          var getdata = json.decode(response.body);
          bool success = getdata['success'];
          String? msg = getdata['message'];
          if (success==true) {
            var data = getdata['data']["products"];
            setState(() {
              context.read<CartProvider>().setCartlist([]);
              oriPrice = 0;
            });

            List<Product> cartList =
            (data as List).map((data) => Product.fromJson(data)).toList();

            for (int i = 0; i < cartList.length; i++) {
              if (proIds.contains(cartList[i].id)) {
                String qty = (await db.checkCartItemExists(
                    cartList[i].id!
                  // , cartList[i].prVarientList![j].id!
                ))!;

                List<Product>? prList = [];
                // cartList[i].prVarientList![j].cartCount = qty;
                prList.add(cartList[i]);

                context.read<CartProvider>().addCartItem(SectionModel(
                  id: cartList[i].id,
                  // varientId: cartList[i].prVarientList![j].id,
                  qty: qty,
                  productList: prList,
                ));

                double price =
                double.parse(cartList[i].discPrice!);
                if (price == 0) {
                  price =
                      double.parse(cartList[i].price!.replaceAll(RegExp('[^0-9]'), ''));

                }
                else{
                  double discountPrice = price /
                      100 *double.parse(cartList[i].price!.replaceAll(RegExp('[^0-9]'), ''));
                  price=double.parse(cartList[i].price!.replaceAll(RegExp('[^0-9]'), ''))-discountPrice;
                }

                double total = (price * int.parse(qty));
                setState(() {
                  oriPrice = oriPrice + total;
                });
              }

            }

            setState(() {});
          }
          if (mounted) {
            setState(() {
              _isCartLoad = false;
            });
          }
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
      }
    } else {
      context.read<CartProvider>().setCartlist([]);
      setState(() {
        _isCartLoad = false;
      });
    }
  }

  Future<void> _getOffSaveLater() async {
    print("hey");
    if (proIds.isNotEmpty) {
      _isNetworkAvail = await isNetworkAvailable();

      if (_isNetworkAvail) {
        try {
          var parameter = {'product_variant_ids': proIds.join(',')};

          Response response =
          await get(getProductApi, headers: headers)
              .timeout(const Duration(seconds: timeOut));

          var getdata = json.decode(response.body);
          bool success = getdata['success'];
          String? msg = getdata['message'];
          if (success==true) {
            var data = getdata['data']['products'];
            saveLaterList.clear();
            List<Product> cartList =
            (data as List).map((data) => Product.fromJson(data)).toList();
            for (int i = 0; i < cartList.length; i++) {
              if (proIds.contains(cartList[i].id)) {
                String qty = (await db.checkSaveForLaterExists(
                    cartList[i].id!))!;
                List<Product>? prList = [];
                prList.add(cartList[i]);
                saveLaterList.add(SectionModel(
                  id: cartList[i].id,
                  // varientId: cartList[i].prVarientList![j].id,
                  qty: qty,
                  productList: prList,
                ));
              }
            }
            print ("save for later:${saveLaterList.length}");
            print ("sqlite product ids:${proIds.length}");

            setState(() {});
          }
          if (mounted) {
            setState(() {
              _isSaveLoad = false;
            });
          }

        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
      }
    } else {
      setState(() {
        _isSaveLoad = false;
      });
      saveLaterList = [];
    }
  }

  Future<void> _getSaveLater(String save) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save};
        apiBaseHelper.postAPICall(getCartApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            var data = getdata['data'];

            saveLaterList = (data as List)
                .map((data) => SectionModel.fromCart(data))
                .toList();

            List<SectionModel> cartList = context.read<CartProvider>().cartList;
            for (int i = 0; i < cartList.length; i++) {
              _controller.add(TextEditingController());
            }
          } else {
            if (msg != 'Cart Is Empty !') setSnackbar(msg!, _scaffoldKey);
          }
          if (mounted) setState(() {});
        }, onError: (error) {
          setSnackbar(error.toString(), _scaffoldKey);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }

    return;
  }

  Future<void> addToCart(
      int index, String qty, List<SectionModel> cartList) async {
    _isNetworkAvail = await isNetworkAvailable();

    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        if (int.parse(qty) < cartList[index].productList![0].minOrderQuntity!) {
          qty = cartList[index].productList![0].minOrderQuntity.toString();

          setSnackbar(
              "${getTranslated(context, 'MIN_MSG')}$qty", _checkscaffoldKey);
        }

        var parameter = {
          PRODUCT_VARIENT_ID: cartList[index].varientId,
          USER_ID: CUR_USERID,
          QTY: qty,
        };
        apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            var data = getdata['data'];

            String qty = data['total_quantity'];

            context.read<UserProvider>().setCartCount(data['cart_count']);
            cartList[index].qty = qty;

            oriPrice = double.parse(data['sub_total']);

            _controller[index].text = qty;
            totalPrice = 0;

            var cart = getdata['cart'];
            List<SectionModel> uptcartList = (cart as List)
                .map((cart) => SectionModel.fromCart(cart))
                .toList();
            context.read<CartProvider>().setCartlist(uptcartList);

            if (!ISFLAT_DEL) {
              if (addressList.isEmpty) {
                delCharge = 0;
              } else {
                if ((oriPrice) <
                    double.parse(addressList[selectedAddress!].freeAmt!)) {
                  delCharge = double.parse(
                      addressList[selectedAddress!].deliveryCharge!);
                } else {
                  delCharge = 0;
                }
              }
            } else {
              if (oriPrice < double.parse(MIN_AMT!)) {
                delCharge = double.parse(CUR_DEL_CHR!);
              } else {
                delCharge = 0;
              }
            }
            totalPrice = delCharge + oriPrice;

            if (isPromoValid!) {
              validatePromo(false);
            } else if (isUseWallet!) {
              context.read<CartProvider>().setProgress(false);
              if (mounted) {
                setState(() {
                  remWalBal = 0;
                  payMethod = null;
                  usedBal = 0;
                  isUseWallet = false;
                  isPayLayShow = true;

                  selectedMethod = null;
                });
              }
            } else {
              setState(() {});
              context.read<CartProvider>().setProgress(false);
            }
          } else {
            setSnackbar(msg!, _scaffoldKey);
            context.read<CartProvider>().setProgress(false);
          }
        }, onError: (error) {
          setSnackbar(error.toString(), _scaffoldKey);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }


  saveForLaterFun(int index, int selectedPos, double total,
      List<SectionModel> cartList) async {
    db.moveToCartOrSaveLater(
        'cart',
        // cartList[index].productList![0].prVarientList![selectedPos].id!,
        cartList[index].id!,
        context);

    proVarIds
        .add(cartList[index].productList![0].prVarientList![selectedPos].id!);
    proIds.remove(
        cartList[index].productList![0].prVarientList![selectedPos].id!);
    oriPrice = oriPrice - total;
    saveLaterList.add(context.read<CartProvider>().cartList[index]);
    context.read<CartProvider>().removeCartItem(
        cartList[index].productList![0].prVarientList![selectedPos].id!);

    saveLater = false;
    context.read<CartProvider>().setProgress(false);
    setState(() {});
  }

  cartFun(int index, int selectedPos, double total) async {
    db.moveToCartOrSaveLater(
        'save',
        // saveLaterList[index].productList![0].prVarientList![selectedPos].id!,
        saveLaterList[index].id!,
        context);

    proIds.add(
        saveLaterList[index].productList![0].prVarientList![selectedPos].id!);
    proVarIds.remove(
        saveLaterList[index].productList![0].prVarientList![selectedPos].id!);
    oriPrice = oriPrice + total;
    context.read<CartProvider>().addCartItem(saveLaterList[index]);
    saveLaterList.removeAt(index);

    addCart = false;
    context.read<CartProvider>().setProgress(false);
    setState(() {});
  }

  saveForLater(String? id, String save, String? qty, double price,
      SectionModel curItem, bool fromSave) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        var parameter = {
          PRODUCT_VARIENT_ID: id,
          USER_ID: CUR_USERID,
          QTY: qty,
          SAVE_LATER: save
        };
        apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            var data = getdata['data'];

            context.read<UserProvider>().setCartCount(data['cart_count']);
            if (save == '1') {
              saveLaterList.add(curItem);

              context.read<CartProvider>().removeCartItem(id!);
              setState(() {
                saveLater = false;
              });
              oriPrice = oriPrice - price;
            } else {
              context.read<CartProvider>().addCartItem(curItem);
              saveLaterList.removeWhere((item) => item.varientId == id);
              setState(() {
                addCart = false;
              });
              oriPrice = oriPrice + price;
            }

            totalPrice = 0;

            if (!ISFLAT_DEL) {
              if (addressList.isNotEmpty &&
                  (oriPrice) <
                      double.parse(addressList[selectedAddress!].freeAmt!)) {
                delCharge =
                    double.parse(addressList[selectedAddress!].deliveryCharge!);
              } else {
                delCharge = 0;
              }
            } else {
              if ((oriPrice) < double.parse(MIN_AMT!)) {
                delCharge = double.parse(CUR_DEL_CHR!);
              } else {
                delCharge = 0;
              }
            }
            totalPrice = delCharge + oriPrice;

            if (isPromoValid!) {
              validatePromo(false);
            } else if (isUseWallet!) {
              context.read<CartProvider>().setProgress(false);
              if (mounted) {
                setState(() {
                  remWalBal = 0;
                  payMethod = null;
                  usedBal = 0;
                  isUseWallet = false;
                  isPayLayShow = true;
                });
              }
            } else {
              context.read<CartProvider>().setProgress(false);
              setState(() {});
            }
          } else {
            setSnackbar(msg!, _scaffoldKey);
          }

          context.read<CartProvider>().setProgress(false);
        }, onError: (error) {
          setSnackbar(error.toString(), _scaffoldKey);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  removeFromCartCheckout(
      int index, bool remove, List<SectionModel> cartList) async {
    _isNetworkAvail = await isNetworkAvailable();

    if (!remove &&
        int.parse(cartList[index].qty!) ==
            cartList[index].productList![0].minOrderQuntity) {
      setSnackbar("${getTranslated(context, 'MIN_MSG')}${cartList[index].qty}",
          _checkscaffoldKey);
    } else {
      if (_isNetworkAvail) {
        try {
          context.read<CartProvider>().setProgress(true);

          int? qty;
          if (remove) {
            qty = 0;
          } else {
            qty = (int.parse(cartList[index].qty!) -
                int.parse(cartList[index].productList![0].qtyStepSize!));

            if (qty < cartList[index].productList![0].minOrderQuntity!) {
              qty = cartList[index].productList![0].minOrderQuntity;

              setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty",
                  _checkscaffoldKey);
            }
          }

          var parameter = {
            PRODUCT_VARIENT_ID: cartList[index].varientId,
            USER_ID: CUR_USERID,
            QTY: qty.toString()
          };
          apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              var data = getdata['data'];

              String? qty = data['total_quantity'];

              context.read<UserProvider>().setCartCount(data['cart_count']);
              if (qty == '0') remove = true;

              if (remove) {
                context
                    .read<CartProvider>()
                    .removeCartItem(cartList[index].varientId!);
              } else {
                cartList[index].qty = qty.toString();
              }

              oriPrice = double.parse(data[SUB_TOTAL]);

              if (!ISFLAT_DEL) {
                if ((oriPrice) <
                    double.parse(addressList[selectedAddress!].freeAmt!)) {
                  delCharge = double.parse(
                      addressList[selectedAddress!].deliveryCharge!);
                } else {
                  delCharge = 0;
                }
              } else {
                if ((oriPrice) < double.parse(MIN_AMT!)) {
                  delCharge = double.parse(CUR_DEL_CHR!);
                } else {
                  delCharge = 0;
                }
              }

              totalPrice = 0;

              totalPrice = delCharge + oriPrice;

              if (isPromoValid!) {
                validatePromo(true);
              } else if (isUseWallet!) {
                if (mounted) {
                  checkoutState!(() {
                    remWalBal = 0;
                    payMethod = null;
                    usedBal = 0;
                    isPayLayShow = true;
                    isUseWallet = false;
                  });
                }
                context.read<CartProvider>().setProgress(false);
                setState(() {});
              } else {
                context.read<CartProvider>().setProgress(false);

                checkoutState!(() {});
                setState(() {});
              }
            } else {
              setSnackbar(msg!, _checkscaffoldKey);
              context.read<CartProvider>().setProgress(false);
            }
          }, onError: (error) {
            setSnackbar(error.toString(), _scaffoldKey);
          });
        } on TimeoutException catch (_) {
          setSnackbar(
              getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
          context.read<CartProvider>().setProgress(false);
        }
      } else {
        if (mounted) {
          checkoutState!(() {
            _isNetworkAvail = false;
          });
        }
        setState(() {});
      }
    }
  }

  removeFromCart(int index, bool remove, List<SectionModel> cartList, bool move,
      int selPos) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (!remove &&
        int.parse(cartList[index].qty!) ==
            cartList[index].productList![0].minOrderQuntity) {
      setSnackbar("${getTranslated(context, 'MIN_MSG')}${cartList[index].qty}",
          _scaffoldKey);
    } else {
      if (_isNetworkAvail) {
        try {
          context.read<CartProvider>().setProgress(true);

          int? qty;
          if (remove) {
            qty = 0;
          } else {
            qty = (int.parse(cartList[index].qty!) -
                int.parse(cartList[index].productList![0].qtyStepSize!));

            if (qty < cartList[index].productList![0].minOrderQuntity!) {
              qty = cartList[index].productList![0].minOrderQuntity;

              setSnackbar("${getTranslated(context, 'MIN_MSG')}$qty",
                  _checkscaffoldKey);
            }
          }
          String varId;
          if (cartList[index].productList![0].availability == '0') {
            varId = cartList[index].productList![0].prVarientList![selPos].id!;
          } else {
            varId = cartList[index].varientId!;
          }

          var parameter = {
            PRODUCT_VARIENT_ID: varId,
            USER_ID: CUR_USERID,
            QTY: qty.toString()
          };
          apiBaseHelper.postAPICall(manageCartApi, parameter).then((getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];
            if (!error) {
              var data = getdata['data'];

              String? qty = data['total_quantity'];

              context.read<UserProvider>().setCartCount(data['cart_count']);
              if (move == false) {
                if (qty == '0') remove = true;

                if (remove) {
                  cartList.removeWhere(
                          (item) => item.varientId == cartList[index].varientId);
                } else {
                  cartList[index].qty = qty.toString();
                }

                oriPrice = double.parse(data[SUB_TOTAL]);

                if (!ISFLAT_DEL) {
                  if (addressList.isNotEmpty &&
                      (oriPrice) <
                          double.parse(
                              addressList[selectedAddress!].freeAmt!)) {
                    delCharge = double.parse(
                        addressList[selectedAddress!].deliveryCharge!);
                  } else {
                    delCharge = 0;
                  }
                } else {
                  if ((oriPrice) < double.parse(MIN_AMT!)) {
                    delCharge = double.parse(CUR_DEL_CHR!);
                  } else {
                    delCharge = 0;
                  }
                }

                totalPrice = 0;

                totalPrice = delCharge + oriPrice;

                if (isPromoValid!) {
                  validatePromo(false);
                } else if (isUseWallet!) {
                  context.read<CartProvider>().setProgress(false);
                  if (mounted) {
                    setState(() {
                      remWalBal = 0;
                      payMethod = null;
                      usedBal = 0;
                      isPayLayShow = true;
                      isUseWallet = false;
                    });
                  }
                } else {
                  context.read<CartProvider>().setProgress(false);
                  setState(() {});
                }
              } else {
                if (qty == '0') remove = true;

                if (remove) {
                  cartList.removeWhere(
                          (item) => item.varientId == cartList[index].varientId);
                }
              }
            } else {
              setSnackbar(msg!, _scaffoldKey);
            }
            if (mounted) setState(() {});
            context.read<CartProvider>().setProgress(false);
          }, onError: (error) {
            setSnackbar(error.toString(), _scaffoldKey);
          });
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg')!, _scaffoldKey);
          context.read<CartProvider>().setProgress(false);
        }
      } else {
        if (mounted) {
          setState(() {
            _isNetworkAvail = false;
          });
        }
      }
    }
  }

  setSnackbar(
      String msg, GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) {
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

  _showContent1(BuildContext context) {
    List<SectionModel> cartList = context.read<CartProvider>().cartList;
    print(_isCartLoad);
    return _isCartLoad || _isSaveLoad
        ? shimmer(context)
        : cartList.isEmpty && saveLaterList.isEmpty
        ? cartEmpty()
        : Container(
      color: Theme.of(context).colorScheme.lightWhite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: RefreshIndicator(
                    color: colors.primary,
                    key: _refreshIndicatorKey,
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      controller: _scrollControllerOnCartItems,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: cartList.length,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return listItem(index, cartList);
                            },
                          ),
                          saveLaterList.isNotEmpty &&
                              proVarIds.isNotEmpty
                              ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              getTranslated(
                                  context, 'SAVEFORLATER_BTN')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor),
                            ),
                          )
                              : Container(height: 0),
                          if (saveLaterList.isNotEmpty &&
                              proVarIds.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: saveLaterList.length,
                              physics:
                              const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return saveLaterItem(index);
                              },
                            ),
                        ],
                      ),
                    ))),
          ),
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                context.read<CartProvider>().cartList.length != 0
                    ? Padding(
                  padding: const EdgeInsetsDirectional.only(
                      top: 5.0, end: 10.0, start: 10.0),
                  child: Container(
                      decoration: BoxDecoration(
                        color:
                        Theme.of(context).colorScheme.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 5),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(getTranslated(
                                  context, 'TOTAL_PRICE')!),
                              Text(
                                '${getPriceFormat(context, oriPrice)!} ',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              ),
                            ],
                          )
                        ],
                      )),
                )
                    : Container(
                  height: 0,
                ),
              ]),
          cartList.isNotEmpty
              ? SimBtn(
              size: 0.9,
              height: 40,
              borderRadius: circularBorderRadius5,
              title: getTranslated(context, 'PROCEED_CHECKOUT'),
              onBtnSelected: () async {
                // Navigator.push(
                //   context,
                //   CupertinoPageRoute(
                //       builder: (context) => const Login()),
                // );
                if (oriPrice > 0) {
                  FocusScope.of(context).unfocus();
                  if (isAvailable) {
                    //proceed to check flutter
                    checkout(cartList);
                  } else {
                    setSnackbar(
                        getTranslated(
                            context, 'CART_OUT_OF_STOCK_MSG')!,
                        _scaffoldKey);
                  }
                  if (mounted) setState(() {});
                } else {
                  setSnackbar(getTranslated(context, 'ADD_ITEM')!,
                      _scaffoldKey);
                }
              })
              : Container(
            height: 0,
          ),
        ],
      ),
    );
  }

  cartEmpty() {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noCartImage(context),
          noCartText(context),
          noCartDec(context),
          shopNow()
        ]),
      ),
    );
  }

  getAllPromo() {}

  noCartImage(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/empty_cart.svg',
      fit: BoxFit.contain,
    );
  }

  noCartText(BuildContext context) {
    return Text(getTranslated(context, 'NO_CART')!,
        style: Theme.of(context)
            .textTheme
            .headline5!
            .copyWith(color: colors.primary, fontWeight: FontWeight.normal));
  }

  noCartDec(BuildContext context) {
    return Container(
      padding:
      const EdgeInsetsDirectional.only(top: 30.0, start: 30.0, end: 30.0),
      child: Text(getTranslated(context, 'CART_DESC')!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6!.copyWith(
            color: Theme.of(context).colorScheme.lightBlack2,
            fontWeight: FontWeight.normal,
          )),
    );
  }

  shopNow() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 28.0),
      child: CupertinoButton(
        child: Container(
            width: deviceWidth! * 0.7,
            height: 45,
            alignment: FractionalOffset.center,
            decoration: const BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.all(Radius.circular(50.0)),
            ),
            child: Text(getTranslated(context, 'SHOP_NOW')!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.white,
                    fontWeight: FontWeight.normal))),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        },
      ),
    );
  }

  checkout(List<SectionModel> cartList) {

    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    print("cartlist: ${_isLoading}");

    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                _isLoading=false;
                checkoutState = setState;
                return Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.8),
                    child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      key: _checkscaffoldKey,
                      body: _isNetworkAvail
                          ? cartList.isEmpty
                          ? cartEmpty()
                          : _isLoading
                          ? shimmer(context)
                          : Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: <Widget>[
                                SingleChildScrollView(
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        address(),
                                        attachPrescriptionImages(
                                            cartList),
                                        payment(),
                                        cartItems(cartList),
                                        // promo(),
                                        orderSummary(cartList),
                                      ],
                                    ),
                                  ),
                                ),
                                Selector<CartProvider, bool>(
                                  builder: (context, data, child) {
                                    return showCircularProgress(
                                        data, colors.primary);
                                  },
                                  selector: (_, provider) =>
                                  provider.isProgress,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            color:
                            Theme.of(context).colorScheme.white,
                            child: Row(children: <Widget>[
                              Padding(
                                  padding: const EdgeInsetsDirectional
                                      .only(start: 15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${getPriceFormat(context, oriPrice)!} ',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor,
                                            fontWeight:
                                            FontWeight.bold),
                                      ),
                                      Text(
                                          '${cartList.length} Items'),
                                    ],
                                  )),
                              const Spacer(),

                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 10.0),
                                child: SimBtn(
                                  borderRadius: circularBorderRadius5,
                                  size: 0.4,
                                  title: getTranslated(
                                      context, 'PLACE_ORDER'),
                                  onBtnSelected: _placeOrder
                                      ? () {
                                    print('we are hgere');
                                    checkoutState!(() {
                                      _placeOrder = false;
                                    });
                                    if (selAddress == '' ||
                                        selAddress!.isEmpty) {
                                      msg = getTranslated(
                                          context,
                                          'addressWarning');
                                      Navigator.pushReplacement(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (BuildContext
                                            context) =>
                                            const ManageAddress(
                                              home: false,
                                            ),
                                          ));
                                      checkoutState!(() {
                                        _placeOrder = true;
                                      });
                                      print('testing 1');
                                    } else if (payMethod ==
                                        null ||
                                        payMethod!.isEmpty) {
                                      msg = getTranslated(
                                          context,
                                          'payWarning');
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (BuildContext
                                              context) =>
                                                  Payment(
                                                      updateCheckout,
                                                      msg)));
                                      checkoutState!(() {
                                        _placeOrder = true;
                                      });
                                      print('testing 2');
                                    } else if (isTimeSlot! &&
                                        int.parse(allowDay!) >
                                            0 &&
                                        (selDate == null ||
                                            selDate!.isEmpty)) {
                                      msg = getTranslated(
                                          context,
                                          'dateWarning');
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (BuildContext
                                              context) =>
                                                  Payment(
                                                      updateCheckout,
                                                      msg)));
                                      checkoutState!(() {
                                        _placeOrder = true;
                                      });
                                      print('testing 3');
                                    } else if (isTimeSlot! &&
                                        timeSlotList
                                            .isNotEmpty &&
                                        (selTime == null ||
                                            selTime!.isEmpty)) {
                                      msg = getTranslated(
                                          context,
                                          'timeWarning');
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (BuildContext
                                              context) =>
                                                  Payment(
                                                      updateCheckout,
                                                      msg)));
                                      checkoutState!(() {
                                        _placeOrder = true;
                                      });
                                      print('testing 4');
                                    } else if (double.parse(
                                        MIN_ALLOW_CART_AMT!) >
                                        oriPrice) {
                                      setSnackbar(
                                          getTranslated(context,
                                              'MIN_CART_AMT')!,
                                          _checkscaffoldKey);
                                      print('testing 5');
                                    } else if (!deliverable) {
                                      checkDeliverable();
                                      print('testing 6');
                                    } else {
                                      confirmDialog();
                                      print('testing 7');
                                    }
                                  }
                                      : null,
                                ),
                              )
                              //}),
                            ]),
                          ),
                        ],
                      )
                          : noInternet(context),
                    ));
              });
        });
  }

  doPayment() {
    if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
      placeOrder('');
    } else if (payMethod == getTranslated(context, 'RAZORPAY_LBL')) {
      razorpayPayment();
    }else if (payMethod == getTranslated(context, 'FLUTTERWAVE_LBL')) {
      flutterwavePayment();
    } else if (payMethod == getTranslated(context, 'STRIPE_LBL')) {
      stripePayment();
    } else if (payMethod == getTranslated(context, 'PAYTM_LBL')) {
      paytmPayment();
    } else if (payMethod == getTranslated(context, 'BANKTRAN')) {
      bankTransfer();
    } else {
      placeOrder('');
    }
  }

  Future<void> _getAddress() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          USER_ID: CUR_USERID,
        };

      } on TimeoutException catch (_) {}
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  updateCheckout() {
    if (mounted) checkoutState!(() {});
  }

  razorpayPayment() async {
    SettingProvider settingsProvider =
    Provider.of<SettingProvider>(context, listen: false);

    String? contact = settingsProvider.mobile;
    String? email = settingsProvider.email;

    String amt = ((totalPrice) * 100).toStringAsFixed(2);

    if (contact != '' && email != '') {
      context.read<CartProvider>().setProgress(true);

      checkoutState!(() {});
      var options = {
        KEY: razorpayId,
        AMOUNT: amt,
        NAME: settingsProvider.userName,
        'prefill': {CONTACT: contact, EMAIL: email},
      };

      try {
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      if (email == '') {
        setSnackbar(getTranslated(context, 'emailWarning')!, _checkscaffoldKey);
      } else if (contact == '') {
        setSnackbar(getTranslated(context, 'phoneWarning')!, _checkscaffoldKey);
      }
    }
  }

  void paytmPayment() async {
    String? paymentResponse;
    context.read<CartProvider>().setProgress(true);

    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    String callBackUrl =
        '${payTesting ? 'https://securegw-stage.paytm.in' : 'https://securegw.paytm.in'}/theia/paytmCallback?ORDER_ID=$orderId';

    var parameter = {
      AMOUNT: totalPrice.toString(),
      USER_ID: CUR_USERID,
      ORDER_ID: orderId
    };

    try {

    } catch (e) {
      print(e);
    }
  }

  Future<void> placeOrder(String? tranId) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      context.read<CartProvider>().setProgress(true);

      SettingProvider settingsProvider =
      Provider.of<SettingProvider>(context, listen: false);

      String? mob = settingsProvider.mobile;

      String? varientId, quantity;

      List<SectionModel> cartList = context.read<CartProvider>().cartList;
      for (SectionModel sec in cartList) {
        varientId =
        varientId != null ? '$varientId,${sec.varientId!}' : sec.varientId;
        quantity = quantity != null ? '$quantity,${sec.qty!}' : sec.qty;
      }
      String? payVia;
      if (payMethod == getTranslated(context, 'COD_LBL')) {
        payVia = 'COD';
      } else if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
        payVia = 'PayPal';
      } else if (payMethod == getTranslated(context, 'PAYUMONEY_LBL')) {
        payVia = 'PayUMoney';
      } else if (payMethod == getTranslated(context, 'RAZORPAY_LBL')) {
        payVia = 'RazorPay';
      } else if (payMethod == getTranslated(context, 'PAYSTACK_LBL')) {
        payVia = 'Paystack';
      } else if (payMethod == getTranslated(context, 'FLUTTERWAVE_LBL')) {
        payVia = 'Flutterwave';
      } else if (payMethod == getTranslated(context, 'STRIPE_LBL')) {
        payVia = 'Stripe';
      } else if (payMethod == getTranslated(context, 'PAYTM_LBL')) {
        payVia = 'Paytm';
      } else if (payMethod == 'Wallet') {
        payVia = 'Wallet';
      } else if (payMethod == getTranslated(context, 'BANKTRAN')) {
        payVia = 'bank_transfer';
      }

      var request = http.MultipartRequest('POST', placeOrderApi);
      request.headers.addAll(headers);

      try {
        request.fields[USER_ID] = CUR_USERID!;
        request.fields[MOBILE] = mob;
        request.fields[PRODUCT_VARIENT_ID] = varientId!;
        request.fields[QUANTITY] = quantity!;
        request.fields[TOTAL] = oriPrice.toString();
        request.fields[FINAL_TOTAL] = totalPrice.toString();
        request.fields[DEL_CHARGE] = delCharge.toString();
        request.fields[TAX_PER] = taxPer.toString();
        request.fields[PAYMENT_METHOD] = payVia!;
        request.fields[ADD_ID] = selAddress!;
        request.fields[ISWALLETBALUSED] = isUseWallet! ? '1' : '0';
        request.fields[WALLET_BAL_USED] = usedBal.toString();
        request.fields[ORDER_NOTE] = noteC.text;

        if (isTimeSlot!) {
          request.fields[DELIVERY_TIME] = selTime ?? 'Anytime';
          request.fields[DELIVERY_DATE] = selDate ?? '';
        }
        if (isPromoValid!) {
          request.fields[PROMOCODE] = promocode!;
          request.fields[PROMO_DIS] = promoAmt.toString();
        }

        if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
          request.fields[ACTIVE_STATUS] = WAITING;
        } else if (payMethod == getTranslated(context, 'STRIPE_LBL')) {
          if (tranId == 'succeeded') {
            request.fields[ACTIVE_STATUS] = PLACED;
          } else {
            request.fields[ACTIVE_STATUS] = WAITING;
          }
        } else if (payMethod == getTranslated(context, 'BANKTRAN')) {
          request.fields[ACTIVE_STATUS] = WAITING;
        }

        if (prescriptionImages.isNotEmpty) {
          for (var i = 0; i < prescriptionImages.length; i++) {
            final mimeType = lookupMimeType(prescriptionImages[i].path);

            var extension = mimeType!.split('/');

            var pic = await http.MultipartFile.fromPath(
              DOCUMENT,
              prescriptionImages[i].path,
              contentType: MediaType('image', extension[1]),
            );

            request.files.add(pic);
          }
        }

        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);

        _placeOrder = true;
        if (response.statusCode == 200) {
          var getdata = json.decode(responseString);

          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            String orderId = getdata['order_id'].toString();
            if (payMethod == getTranslated(context, 'RAZORPAY_LBL')) {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else if (payMethod == getTranslated(context, 'PAYPAL_LBL')) {
              paypalPayment(orderId);
            } else if (payMethod == getTranslated(context, 'STRIPE_LBL')) {
              addTransaction(stripePayId, orderId,
                  tranId == 'succeeded' ? PLACED : WAITING, msg, true);
            } else if (payMethod == getTranslated(context, 'PAYSTACK_LBL')) {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else if (payMethod == getTranslated(context, 'PAYTM_LBL')) {
              addTransaction(tranId, orderId, SUCCESS, msg, true);
            } else {
              context.read<UserProvider>().setCartCount('0');

              clearAll();

              Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(
                      builder: (BuildContext context) => const OrderSuccess()),
                  ModalRoute.withName('/home'));
            }
          } else {
            setSnackbar(msg!, _checkscaffoldKey);
            context.read<CartProvider>().setProgress(false);
          }
        }
      } on TimeoutException catch (_) {
        if (mounted) {
          checkoutState!(() {
            _placeOrder = true;
          });
        }
        context.read<CartProvider>().setProgress(false);
      }
    } else {
      if (mounted) {
        checkoutState!(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  Future<void> paypalPayment(String orderId) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        ORDER_ID: orderId,
        AMOUNT: totalPrice.toString()
      };

    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
    }
  }

  Future<void> addTransaction(String? tranId, String orderID, String? status,
      String? msg, bool redirect) async {
    try {
      var parameter = {
        USER_ID: CUR_USERID,
        ORDER_ID: orderID,
        TYPE: payMethod,
        TXNID: tranId,
        AMOUNT: totalPrice.toString(),
        STATUS: status,
        MSG: msg
      };
      // apiBaseHelper.postAPICall(addTransactionApi, parameter).then((getdata) {
      //   bool error = getdata['error'];
      //   String? msg1 = getdata['message'];
      //   if (!error) {
      //     if (redirect) {
      //       context.read<UserProvider>().setCartCount('0');
      //       clearAll();
      //
      //       Navigator.pushAndRemoveUntil(
      //           context,
      //           CupertinoPageRoute(
      //               builder: (BuildContext context) => const OrderSuccess()),
      //           ModalRoute.withName('/home'));
      //     }
      //   } else {
      //     setSnackbar(msg1!, _checkscaffoldKey);
      //   }
      // }, onError: (error) {
      //   setSnackbar(error.toString(), _scaffoldKey);
      // });
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
    }
  }


  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  stripePayment() async {
    context.read<CartProvider>().setProgress(true);

    // var response = await StripeService.payWithPaymentSheet(
    //     amount: (totalPrice.toInt() * 100).toString(),
    //     currency: stripeCurCode,
    //     from: 'order',
    //     context: context);
    //
    // if (response.message == 'Transaction successful') {
    //   placeOrder(response.status);
    // } else if (response.status == 'pending' || response.status == 'captured') {
    //   placeOrder(response.status);
    // } else {
    //   if (mounted) {
    //     setState(() {
    //       _placeOrder = true;
    //     });
    //   }
    //
    //   context.read<CartProvider>().setProgress(false);
    // }
    // setSnackbar(response.message!, _checkscaffoldKey);
  }

  address() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on),
                Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8.0),
                    child: Text(
                      getTranslated(context, 'SHIPPING_DETAIL') ?? '',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.fontColor),
                    )),
              ],
            ),
            const Divider(),
            addressList.isNotEmpty
                ? Padding(
              padding: const EdgeInsetsDirectional.only(start: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child:
                          Text(addressList[selectedAddress!].name!)),
                      InkWell(
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            getTranslated(context, 'CHANGE')!,
                            style: const TextStyle(
                              color: colors.primary,
                            ),
                          ),
                        ),
                        onTap: () async {
                          await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (BuildContext context) =>
                                  const ManageAddress(
                                    home: false,
                                  )));

                          checkoutState!(() {
                            deliverable = false;
                          });
                        },
                      ),
                    ],
                  ),
                  Text(
                    '${addressList[selectedAddress!].address!}, ${addressList[selectedAddress!].area!}, ${addressList[selectedAddress!].city!}, ${addressList[selectedAddress!].state!}, ${addressList[selectedAddress!].country!}, ${addressList[selectedAddress!].pincode!}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.lightBlack),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        Text(
                          addressList[selectedAddress!].mobile!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .lightBlack),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
                : Padding(
              padding: const EdgeInsetsDirectional.only(start: 8.0),
              child: InkWell(
                child: Text(
                  getTranslated(context, 'ADDADDRESS')!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                  ),
                ),
                onTap: () async {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => AddAddress(
                          update: false,
                          index: addressList.length,
                   )),
                  );
                  if (mounted) setState(() {});
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  payment() {
    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () async {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          msg = '';
          await Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) =>
                      Payment(updateCheckout, msg)));
          if (mounted) checkoutState!(() {});
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.payment),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8.0),
                    child: Text(
                      getTranslated(context, 'SELECT_PAYMENT')!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              payMethod != null && payMethod != ''
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const Divider(), Text(payMethod!)],
                ),
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }


  cartItems(List<SectionModel> cartList) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: cartList.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return cartItem(index, cartList);
      },
    );
  }

  orderSummary(List<SectionModel> cartList) {
    return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${getTranslated(context, 'ORDER_SUMMARY')!} (${cartList.length} items)',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, 'SUBTOTAL')!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack2),
                  ),
                  Text(
                    '${getPriceFormat(context, oriPrice)!} ',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, 'DELIVERY_CHARGE')!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack2),
                  ),
                  Text(
                    '${getPriceFormat(context, delCharge)!} ',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              isPromoValid!
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, 'PROMO_CODE_DIS_LBL')!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack2),
                  ),
                  Text(
                    '${getPriceFormat(context, promoAmt)!} ',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )
                  : Container(),
              isUseWallet!
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, 'WALLET_BAL')!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack2),
                  ),
                  Text(
                    '${getPriceFormat(context, usedBal)!} ',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )
                  : Container(),
            ],
          ),
        ));
  }

  Future<void> validatePromo(bool check) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);
        if (check) {
          if (mounted && checkoutState != null) checkoutState!(() {});
        }
        setState(() {});
        var parameter = {
          USER_ID: CUR_USERID,
          PROMOCODE: promoC.text,
          FINAL_TOTAL: oriPrice.toString()
        };
        apiBaseHelper.postAPICall(validatePromoApi, parameter).then((getdata) {
          bool error = getdata['error'];
          String? msg = getdata['message'];
          if (!error) {
            var data = getdata['data'][0];

            totalPrice = double.parse(data['final_total']) + delCharge;

            promoAmt = double.parse(data['final_discount']);

            promocode = data['promo_code'];

            isPromoValid = true;
            isPromoLen = false;
            setSnackbar(
                getTranslated(context, 'PROMO_SUCCESS')!, _checkscaffoldKey);
          } else {
            isPromoValid = false;
            promoAmt = 0;
            promocode = null;
            promoC.clear();
            isPromoLen = false;
            var data = getdata['data'];

            totalPrice = double.parse(data['final_total']) + delCharge;

            setSnackbar(msg!, _checkscaffoldKey);
          }
          if (isUseWallet!) {
            remWalBal = 0;
            payMethod = null;
            usedBal = 0;
            isUseWallet = false;
            isPayLayShow = true;

            selectedMethod = null;
            context.read<CartProvider>().setProgress(false);
            if (mounted && check) checkoutState!(() {});
            setState(() {});
          } else {
            if (mounted && check) checkoutState!(() {});
            setState(() {});
            context.read<CartProvider>().setProgress(false);
          }
        }, onError: (error) {
          setSnackbar(error.toString(), _scaffoldKey);
        });
      } on TimeoutException catch (_) {
        context.read<CartProvider>().setProgress(false);
        if (mounted && check) checkoutState!(() {});
        setState(() {});
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
    } else {
      _isNetworkAvail = false;
      if (mounted && check) checkoutState!(() {});
      setState(() {});
    }
  }

  Future<void> flutterwavePayment() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        var parameter = {
          AMOUNT: totalPrice.toString(),
          USER_ID: CUR_USERID,
        };

      } on TimeoutException catch (_) {
        context.read<CartProvider>().setProgress(false);
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
    } else {
      if (mounted) {
        checkoutState!(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  void confirmDialog() {
    showGeneralDialog(
        barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                contentPadding: const EdgeInsets.all(0),
                elevation: 2.0,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding:
                          const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                          child: Text(
                            getTranslated(context, 'CONFIRM_ORDER')!,
                            style: Theme.of(this.context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .fontColor),
                          )),
                      Divider(color: Theme.of(context).colorScheme.lightBlack),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getTranslated(context, 'SUBTOTAL')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack2),
                                ),
                                Text(
                                  getPriceFormat(context, oriPrice)!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getTranslated(context, 'DELIVERY_CHARGE')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack2),
                                ),
                                Text(
                                  getPriceFormat(context, delCharge)!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            isPromoValid!
                                ? Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getTranslated(
                                      context, 'PROMO_CODE_DIS_LBL')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack2),
                                ),
                                Text(
                                  getPriceFormat(context, promoAmt)!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            )
                                : Container(),
                            isUseWallet!
                                ? Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getTranslated(context, 'WALLET_BAL')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack2),
                                ),
                                Text(
                                  getPriceFormat(context, usedBal)!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            )
                                : Container(),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, 'TOTAL_PRICE')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightBlack2),
                                  ),
                                  Text(
                                    '${getPriceFormat(context, totalPrice)!} ',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                padding:
                                const EdgeInsets.symmetric(vertical: 10),
                                child: TextField(
                                  controller: noteC,
                                  style: Theme.of(context).textTheme.subtitle2,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: colors.primary.withOpacity(0.1),
                                    hintText: getTranslated(context, 'NOTE'),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ]),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      getTranslated(context, 'CANCEL')!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.lightBlack,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      checkoutState!(
                            () {
                          _placeOrder = true;
                          isPromoValid = false;
                        },
                      );
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text(
                      getTranslated(context, 'DONE')!,
                      style: const TextStyle(
                        color: colors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      doPayment();
                    },
                  )
                ],
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  void bankTransfer() {
    showGeneralDialog(
        barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  contentPadding: const EdgeInsets.all(0),
                  elevation: 2.0,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding:
                            const EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                            child: Text(
                              getTranslated(context, 'BANKTRAN')!,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor),
                            )),
                        Divider(
                            color: Theme.of(context).colorScheme.lightBlack),
                        Padding(
                            padding:
                            const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                            child: Text(getTranslated(context, 'BANK_INS')!,
                                style: Theme.of(context).textTheme.caption)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10),
                          child: Text(
                            getTranslated(context, 'ACC_DETAIL')!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .fontColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            '${getTranslated(context, 'ACCNAME')!} : ${acName!}',
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            '${getTranslated(context, 'ACCNO')!} : ${acNo!}',
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            '${getTranslated(context, 'BANKNAME')!} : ${bankName!}',
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            '${getTranslated(context, 'BANKCODE')!} : ${bankNo!}',
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Text(
                            '${getTranslated(context, 'EXTRADETAIL')!} : ${exDetails!}',
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        )
                      ]),
                  actions: <Widget>[
                    TextButton(
                        child: Text(getTranslated(context, 'CANCEL')!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.lightBlack,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          checkoutState!(() {
                            _placeOrder = true;
                          });
                          Navigator.pop(context);
                        }),
                    TextButton(
                        child: Text(getTranslated(context, 'DONE')!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(context);

                          context.read<CartProvider>().setProgress(true);

                          placeOrder('');
                        })
                  ],
                )),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  Future<void> checkDeliverable() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        context.read<CartProvider>().setProgress(true);

        var parameter = {
          USER_ID: CUR_USERID,
          ADD_ID: selAddress,
        };

      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  attachPrescriptionImages(List<SectionModel> cartList) {
    bool isAttachReq = false;
    for (int i = 0; i < cartList.length; i++) {
      if (cartList[i].productList![0].is_attch_req == '1') {
        isAttachReq = true;
      }
    }
    return ALLOW_ATT_MEDIA == '1' && isAttachReq
        ? Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getTranslated(context, 'ADD_ATT_REQ')!,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack),
                ),
                SizedBox(
                  height: 30,
                  child: IconButton(
                      icon: const Icon(
                        Icons.add_photo_alternate,
                        color: colors.primary,
                        size: 20.0,
                      ),
                      onPressed: () {
                        _imgFromGallery();
                      }),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsetsDirectional.only(
                  start: 20.0, end: 20.0, top: 5),
              height: prescriptionImages.isNotEmpty ? 180 : 0,
              child: Row(
                children: [
                  Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: prescriptionImages.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, i) {
                          return InkWell(
                            child: Stack(
                              alignment: AlignmentDirectional.topEnd,
                              children: [
                                Image.file(
                                  prescriptionImages[i],
                                  width: 180,
                                  height: 180,
                                ),
                                Container(
                                    color:
                                    Theme.of(context).colorScheme.black26,
                                    child: const Icon(
                                      Icons.clear,
                                      size: 15,
                                    ))
                              ],
                            ),
                            onTap: () {
                              checkoutState!(() {
                                prescriptionImages.removeAt(i);
                              });
                            },
                          );
                        },
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        : Container();
  }

  _imgFromGallery() async {
    var result = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);
    if (result != null) {
      checkoutState!(() {
        prescriptionImages = result.paths.map((path) => File(path!)).toList();
      });
    } else {
      // User canceled the picker
    }
  }

  addAndRemoveQty(
      String qty,
      int from,
      int totalLen,
      int index,
      double price,
      int selectedPos,
      double total,
      List<SectionModel> cartList,
      int itemCounter) async {
    context.read<CartProvider>().setProgress(true);
    if (from == 1) {
      print("totalquantity $totalLen");
      if (int.parse(qty) >= totalLen) {
        setSnackbar("${getTranslated(context, 'MAXQTY')!}  $qty", _scaffoldKey);
      } else {
        int quantity=int.parse(qty);
        quantity++;
        db.updateCart(
            cartList[index].id!,
            // cartList[index].productList![0].prVarientList![selectedPos].id!,
            quantity.toString());
        context.read<CartProvider>().updateCartItem(
          cartList[index].productList![0].id!,
          quantity.toString(),
          selectedPos,
          // cartList[index].productList![0].id!
        );

        oriPrice = (oriPrice + price);

        setState(() {});
      }
    } else if (from == 2) {
      int quantity=int.parse(qty);
      quantity--;
      if (int.parse(qty) <= cartList[index].productList![0].minOrderQuntity!) {
        db.updateCart(
            cartList[index].id!,
            quantity.toString());
        context.read<CartProvider>().updateCartItem(
          cartList[index].productList![0].id!,
          quantity.toString(),
          selectedPos,
          // cartList[index].productList![0].prVarientList![selectedPos].id!
        );
        setState(() {});
      } else {
        int quantity=int.parse(qty);
        quantity--;
        db.updateCart(
            cartList[index].id!,
            // cartList[index].productList![0].prVarientList![selectedPos].id!,
            quantity.toString());

        context.read<CartProvider>().updateCartItem(
          cartList[index].productList![0].id!,
          quantity.toString(),
          selectedPos,
          // cartList[index].productList![0].prVarientList![selectedPos].id!
        );
        oriPrice = (oriPrice - price);
        setState(() {});
      }
    } else {
      db.updateCart(cartList[index].id!, qty);
      context.read<CartProvider>().updateCartItem(
        cartList[index].productList![0].id!,
        qty,
        selectedPos,
        // cartList[index].productList![0].prVarientList![selectedPos].id!
      );
      oriPrice = (oriPrice - total + (int.parse(qty) * price));

      setState(() {});
    }
    Future.delayed(const Duration(seconds: 1)).then((_) async {
      context.read<CartProvider>().setProgress(false);
    });

  }

}
