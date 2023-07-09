

import 'dart:async';

import 'package:agritungotest/Widgets/product_details_new.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/SimBtn.dart';
import '../Helper/SqliteData.dart';
import '../Helper/String.dart';
import '../Model/Categories_Model.dart';
import '../Provider/CartProvider.dart';
import '../Provider/FavoriteProvider.dart';
import '../Provider/HomeProvider.dart';
import '../Provider/explore_provider.dart';
import '../Widgets/star_rating.dart';

class ProductList extends StatefulWidget {
  final String? name, id;
  final bool? tag, fromSeller;
  final int? dis;
  final CategoriesData? model;

  const ProductList(
      {Key? key, this.id, this.name, this.tag, this.fromSeller, this.dis, this.model})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StateProduct();
}

class StateProduct extends State<ProductList> with TickerProviderStateMixin {
  bool _isLoading = true, _isProgress = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // List<Product> tempList = [];
  String sortBy = '', orderBy = 'DESC';
  int offset = 0;
  int total = 0;
  String? totalProduct;
  bool isLoadingmore = true;
  ScrollController controller = ScrollController();
  var filterList;
  String minPrice = '0', maxPrice = '0';
  List<String>? attnameList;
  List<String>? attsubList;
  List<String>? attListId;
  bool _isNetworkAvail = true;
  List<String> selectedId = [];
  bool _isFirstLoad = true;

  String selId = '';
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool listType = true;
  final List<TextEditingController> _controller = [];
  List<String>? tagList = [];
  ChoiceChip? tagChip, choiceChip;
  RangeValues? _currentRangeValues;
  var db = DatabaseHelper();
  AnimationController? _animationController;
  AnimationController? _animationController1;

  late AnimationController listViewIconController;
  List<String> favProduct = [];

  // late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    getProduct();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));
    _animationController1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));

    listViewIconController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

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
    getFavProduct();
  }
  getFavProduct() async {
    favProduct.clear();
    favProduct = (await db.getFav())!;
    context.read<HomeProvider>().setfavLoading(false);
  }

  @override
  void dispose() {
    buttonController!.dispose();
    _animationController!.dispose();
    _animationController1!.dispose();
    listViewIconController.dispose();
    controller.removeListener(() {});
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

  @override
  Widget build(BuildContext context) {
    // userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
        appBar: widget.fromSeller! ? null : getAppBar(widget.name!, context),
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? _isLoading
            ? shimmer(context)
            : Stack(
          children: <Widget>[
            _showForm(),
            showCircularProgress(_isProgress, colors.primary),
          ],
        )
            : noInternet(context));
  }

  Widget noInternet(BuildContext context) {
    return SingleChildScrollView(
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
                offset = 0;
                total = 0;
                // getProduct('0');
              } else {
                await buttonController!.reverse();
                if (mounted) setState(() {});
              }
            });
          },
        )
      ]),
    );
  }

  noIntBtn(BuildContext context) {
    double width = deviceWidth!;
    return Container(
        padding: const EdgeInsetsDirectional.only(bottom: 10.0, top: 50.0),
        child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: colors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                        builder: (BuildContext context) => super.widget));
              },
              child: Ink(
                child: Container(
                  constraints: BoxConstraints(maxWidth: width / 1.2, minHeight: 45),
                  alignment: Alignment.center,
                  child: Text(getTranslated(context, 'TRY_AGAIN_INT_LBL')!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: Theme.of(context).colorScheme.white,
                          fontWeight: FontWeight.normal)),
                ),
              ),
            )));
  }

  Widget listItem(int index) {
    if (index < widget.model!.products!.length) {
      // Product model = widget.model!.products![index];

      totalProduct = "${widget.model!.products!.length}";

      if (_controller.length < index + 1) {
        _controller.add(TextEditingController());
      }
      // int discountpercent=0;
      double discountpercent= double.parse(widget.model!.products![index].discount.toString());

      double off = 0;
      if (widget.model!.products![index].discount! != '0') {
        double price = double.parse(widget.model!.products![index].price!.replaceAll(RegExp('[^0-9]'), ''),);
        double discount= double.parse(widget.model!.products![index].discount!);
        double  finaldiscount=discount/100 * price;
        double finalprice= price-finaldiscount;
        off = finalprice;
      }

      return Padding(
          padding: const EdgeInsetsDirectional.only(
              start: 10.0, end: 10.0, top: 5.0),
          child: Selector<CartProvider, Tuple2<List<String?>, String?>>(
            builder: (context, data, child) {
              // if (data.item1
              //     .contains(model.prVarientList![model.selVarient!].id)) {
              //   _controller[index].text = data.item2.toString();
              // } else {
              //   if (CUR_USERID != null) {
              //     _controller[index].text =
              //     model.prVarientList![model.selVarient!].cartCount!;
              //   } else {
              //     _controller[index].text = '0';
              //   }
              // }

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Card(
                    elevation: 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Hero(
                                tag: "$index${widget.model!.products![index].id}",
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10)),
                                    child: Stack(
                                      children: [
                                        FadeInImage(
                                          image: NetworkImage(widget.model!.products![index]!.image!),
                                          height: 125.0,
                                          width: 110.0,
                                          fit: extendImg
                                              ? BoxFit.fill
                                              : BoxFit.contain,
                                          imageErrorBuilder:
                                              (context, error, stackTrace) =>
                                              erroWidget(125),
                                          placeholder: placeHolder(125),
                                        ),
                                        Positioned.fill(
                                            child: widget.model!.products![index]!.status != 'instock'
                                                ? Container(
                                              height: 55,
                                              color: colors.white70,
                                              // width: double.maxFinite,
                                              padding:
                                              const EdgeInsets.all(2),
                                              child: Center(
                                                child: Text(
                                                  getTranslated(context,
                                                      'OUT_OF_STOCK_LBL')!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption!
                                                      .copyWith(
                                                    color: colors.red,
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                  ),
                                                  textAlign:
                                                  TextAlign.center,
                                                ),
                                              ),
                                            )
                                                : Container()),
                                        discountpercent != 0
                                            ? Container(
                                          decoration: const BoxDecoration(
                                            color: colors.red,
                                          ),
                                          margin: const EdgeInsets.all(5),
                                          child: Padding(
                                            padding:
                                            const EdgeInsets.all(5.0),
                                            child: Text(
                                              '${widget.model!.products![index].discount}%',
                                              style: const TextStyle(
                                                  color: colors.whiteTemp,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  fontSize: 9),
                                            ),
                                          ),
                                        )
                                            : Container()
                                      ],
                                    ))),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          top: 15.0, start: 15.0),
                                      child: Text(
                                        widget.model!.products![index].name!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .lightBlack,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            fontSize: textFontSize12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          start: 15.0, top: 8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            discountpercent !=
                                                0 ?
                                            getPriceFormat(
                                                context,off)!
                                                : getPriceFormat(
                                                context,
                                                double.parse(widget.model!.products![index].discount!))!,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .blue,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 3,),
                                          Text(
                                            double.parse("$discountpercent") !=
                                                0
                                                ? getPriceFormat(
                                                context,
                                                double.parse(widget.model!.products![index]
                                                    .price!.replaceAll(RegExp('[^0-9]'), ''),))!
                                                : '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall!
                                                .copyWith(
                                                decoration: TextDecoration
                                                    .lineThrough,
                                                letterSpacing: 0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    widget.model!.products![index].rating!.ratingValue != '0.00'
                                        ?Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          top: 2.0, start: 15.0),
                                      child: RatingBarIndicator(
                                        rating: double.parse(widget.model!.products![index].rating?.ratingValue.toString()??"0"),
                                        itemBuilder: (context, index) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        itemCount: 5,
                                        itemSize: 20.0,
                                        unratedColor: Colors.amber.withAlpha(50),
                                        direction: Axis.horizontal,
                                      ),
                                    ):Container(),
                                    _controller[index].text != '0'
                                        ? Row(
                                      children: [
                                        //Spacer(),
                                        widget.model!.products![index].status != 'instock'
                                            ? Container()
                                            : cartBtnList
                                            ? Row(
                                          children: <Widget>[
                                            Row(
                                              children: <
                                                  Widget>[
                                                InkWell(
                                                  child: Card(
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          50),
                                                    ),
                                                    child:
                                                    const Padding(
                                                      padding:
                                                      EdgeInsets.all(
                                                          8.0),
                                                      child:
                                                      Icon(
                                                        Icons
                                                            .remove,
                                                        size:
                                                        15,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    if (_isProgress ==
                                                        false &&
                                                        (int.parse(_controller[index].text) >
                                                            0)) {
                                                      // removeFromCart(
                                                      //     index);
                                                    }
                                                  },
                                                ),
                                                SizedBox(
                                                  width: 37,
                                                  height: 20,
                                                  child: Stack(
                                                    children: [
                                                      TextField(
                                                        textAlign:
                                                        TextAlign.center,
                                                        readOnly:
                                                        true,
                                                        style: TextStyle(
                                                            fontSize:
                                                            12,
                                                            color:
                                                            Theme.of(context).colorScheme.fontColor),
                                                        controller:
                                                        _controller[index],
                                                        // _controller[index],
                                                        decoration:
                                                        const InputDecoration(
                                                          border:
                                                          InputBorder.none,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // ),

                                                InkWell(
                                                  child: Card(
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          50),
                                                    ),
                                                    child:
                                                    const Padding(
                                                      padding:
                                                      EdgeInsets.all(
                                                          8.0),
                                                      child:
                                                      Icon(
                                                        Icons
                                                            .add,
                                                        size:
                                                        15,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    // if (_isProgress ==
                                                    //     false) {
                                                    //   addToCart(
                                                    //       index,
                                                    //       (int.parse(_controller[index].text) + int.parse(model.qtyStepSize!))
                                                    //           .toString(),
                                                    //       2);
                                                    // }
                                                  },
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                            : Container(),
                                      ],
                                    )
                                        : Container(),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ]),
                      onTap: () {
                        // Product model = widget.model!.products![index];
                        //
                        // Navigator.push(
                        //   context,
                        //   PageRouteBuilder(
                        //       pageBuilder: (_, __, ___) => ProductDetail1(
                        //         model: widget.model!.products![index],
                        //         index: index,
                        //         secPos: 0,
                        //         list: true,
                        //       )),
                        // );
                      },
                    ),
                  ),
                  _controller[index].text == '0'
                      ? Positioned.directional(
                    textDirection: Directionality.of(context),
                    bottom: 4,
                    end: 4,
                    child: InkWell(
                      onTap: () {
                        if (_isProgress == false) {
                          // addToCart(
                          //     index,
                          //     (int.parse(_controller[index].text) +
                          //         int.parse(model.qtyStepSize!))
                          //         .toString(),
                          //     1);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                      : Container(),
                  Positioned.directional(
                      textDirection: Directionality.of(context),
                      top: 0,
                      end: 0,
                      child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: widget.model!.products![index].isFavLoading!
                              ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 0.7,
                                )),
                          )
                              : Selector<FavoriteProvider, List<String?>>(
                            builder: (context, data, child) {
                              return InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    !favProduct.contains(widget.model!.products![index].id)
                                        ? Icons.favorite_border
                                        : Icons.favorite,
                                    size: 20,
                                  ),
                                ),
                                onTap: () {
                                  if (!favProduct.contains(widget.model!.products![index].id)) {
                                    widget.model!.products![index].isFavLoading = true;
                                    widget.model!.products![index].isFav = '1';
                                    db.addAndRemoveFav(widget.model!.products![index].id!, true);
                                    Future.delayed(const Duration(seconds: 1)).then((_) async {
                                      if (mounted) {
                                        setState(() {
                                          getFavProduct();
                                          // getProduct("0");
                                          widget.model!.products![index].isFavLoading = false;
                                        });
                                      }
                                    });
                                  } else {
                                    widget.model!.products![index].isFavLoading = true;
                                    db.addAndRemoveFav(widget.model!.products![index].id!, false);
                                    setState(() {
                                      getFavProduct();
                                      // getProduct("0");
                                      widget.model!.products![index].isFavLoading = false;
                                    });
                                  }
                                },
                              );
                            },
                            selector: (_, provider) => provider.favIdList,
                          )
                      )
                  )
                ],
              );
            },
            selector: (_, provider) => Tuple2(provider.cartIdList,
                provider.qtyList(widget.model!.products![index].id!)),
          ));
    } else {
      return Container();
    }
  }


  Widget productItem(int index, bool pad,[bool showDiscountAtSameLine = false]) {
    if (index <  widget.model!.products!.length) {
      // Product model = widget.model!.products![index];

      totalProduct = "${widget.model!.products!.length}";

      if (_controller.length < index + 1) {
        _controller.add(TextEditingController());
      }

      double price =0;
      if (widget.model!.products![index].discount! == '0') {
        price = double.parse(widget.model!.products![index].price!.replaceAll(RegExp('[^0-9]'), ''),);
      }
      else{
        double price = double.parse(widget.model!.products![index].price!.replaceAll(RegExp('[^0-9]'), ''),);
        double discount= double.parse(widget.model!.products![index].discount!);
        double  finaldiscount=discount/100 * price;
        double finalprice= price-finaldiscount;
        price=finalprice;
      }

      // int discountpercent= int.parse(widget.model!.products![index].discount.toString());

      double off = 0;
      if (widget.model!.products![index].discount! != '0') {
        double price = double.parse(widget.model!.products![index].price!.replaceAll(RegExp('[^0-9]'), ''),);
        double discount= double.parse(widget.model!.products![index].discount!);
        double  finaldiscount=discount/100 * price;
        double finalprice= price-finaldiscount;
        off = finalprice;
      }

      if (_controller.length < index + 1) {
        _controller.add(TextEditingController());
      }

      // _controller[index].text =model.prVarientList![model.selVarient!].cartCount!;


      double width = deviceWidth! * 0.5;

      // return Selector<CartProvider, Tuple2<List<String?>, String?>>(
      //   builder: (context, data, child) {
      //     print("data: $data");
      //     if (data.item1.contains(widget.model!.products![index].id)) {
      //       _controller[index].text = data.item2.toString();
      //     } else {
      //         _controller[index].text = '0';
      //     }

          return InkWell(
            child: Card(
              elevation: 0.2,
              margin: EdgeInsetsDirectional.only(
                  bottom: 10, end: 10, start: pad ? 10 : 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5)),
                            child: Hero(
                              tag: "$index${widget.model!.products![index].id}",
                              child: FadeInImage(
                                fadeInDuration:
                                const Duration(milliseconds: 150),
                                image: NetworkImage(widget.model!.products![index].image!),
                                height: double.maxFinite,
                                width: double.maxFinite,
                                fit: extendImg ? BoxFit.fill : BoxFit.contain,
                                placeholder: placeHolder(width),
                                imageErrorBuilder:
                                    (context, error, stackTrace) =>
                                    erroWidget(width),
                              ),
                            )),
                        Positioned.fill(
                            child: widget.model!.products![index].status != 'instock'
                                ? Container(
                              height: 55,
                              color: colors.white70,
                              // width: double.maxFinite,
                              padding: const EdgeInsets.all(2),
                              child: Center(
                                child: Text(
                                  getTranslated(
                                      context, 'OUT_OF_STOCK_LBL')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                    color: colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                                : Container()),
                        off != 0
                            ? Align(
                          alignment: AlignmentDirectional.topStart,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: colors.red,
                            ),
                            margin: const EdgeInsets.all(5),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                '${widget.model!.products![index].discount}%',
                                style: const TextStyle(
                                    color: colors.whiteTemp,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9),
                              ),
                            ),
                          ),
                        )
                            : Container(),
                        const Divider(
                          height: 1,
                        ),
                        Positioned.directional(
                          textDirection: Directionality.of(context),
                          end: 0,
                          // bottom: -18,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              widget.model!.products![index].status != 'status' && !cartBtnList
                                  ? Container()
                                  : _controller[index].text == '0'
                                  ? InkWell(
                                onTap: () {
                                  if (_isProgress == false) {

                                  }
                                },
                                child: Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(50),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              )
                                  : Padding(
                                padding:
                                const EdgeInsetsDirectional.only(
                                    start: 3.0,
                                    bottom: 5,
                                    top: 3),
                                child: Row(
                                  children: <Widget>[
                                    InkWell(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              50),
                                        ),
                                        child: const Padding(
                                          padding:
                                          EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.remove,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        if (_isProgress == false &&
                                            (int.parse(
                                                _controller[index]
                                                    .text) >
                                                0)) {
                                          // removeFromCart(index);
                                        }
                                      },
                                    ),
                                    Container(
                                      width: 37,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: colors.white70,
                                        borderRadius:
                                        BorderRadius.circular(5),
                                      ),
                                      child: Stack(
                                        children: [
                                          Selector<
                                              CartProvider,
                                              Tuple2<List<String?>,
                                                  String?>>(
                                            builder: (context, data,
                                                child) {
                                              return TextField(
                                                textAlign:
                                                TextAlign.center,
                                                readOnly: true,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Theme.of(
                                                        context)
                                                        .colorScheme
                                                        .fontColor),
                                                controller:
                                                _controller[
                                                index],
                                                decoration:
                                                const InputDecoration(
                                                  border: InputBorder
                                                      .none,
                                                ),
                                              );
                                            },
                                            selector: (_, provider) =>
                                                Tuple2(
                                                    provider
                                                        .cartIdList,
                                                    provider.qtyList(
                                                        widget.model!.products![index].id!)),
                                          ),
                                          // PopupMenuButton<String>(
                                          //   tooltip: '',
                                          //   icon: const Icon(
                                          //     Icons.arrow_drop_down,
                                          //     size: 0,
                                          //   ),
                                          //   onSelected:
                                          //       (String value) {
                                          //     if (_isProgress ==
                                          //         false) {
                                          //
                                          //     }
                                          //   },
                                          //   itemBuilder: (BuildContext
                                          //   context) {
                                          //     return model
                                          //         .itemsCounter!
                                          //         .map<
                                          //         PopupMenuItem<
                                          //             String>>(
                                          //             (String value) {
                                          //           return PopupMenuItem(
                                          //               value: value,
                                          //               child: Text(value,
                                          //                   style: TextStyle(
                                          //                       color: Theme.of(
                                          //                           context)
                                          //                           .colorScheme
                                          //                           .fontColor)));
                                          //         }).toList();
                                          //   },
                                          // ),
                                        ],
                                      ),
                                    ), // ),

                                    InkWell(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              50),
                                        ),
                                        child: const Padding(
                                          padding:
                                          EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.add,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        if (_isProgress == false) {
                                          // addToCart(
                                          //     index,
                                          //     (int.parse(_controller[
                                          //     index]
                                          //         .text) +
                                          //         int.parse(model
                                          //             .qtyStepSize!))
                                          //         .toString(),
                                          //     2);
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                        Positioned.directional(
                            textDirection: Directionality.of(context),
                            top: 0,
                            end: 0,
                            child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: widget.model!.products![index].isFavLoading!
                                    ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 0.7,
                                      )),
                                )
                                    : Selector<FavoriteProvider, List<String?>>(
                                  builder: (context, data, child) {
                                    return InkWell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          !favProduct.contains(widget.model!.products![index].id)
                                              ? Icons.favorite_border
                                              : Icons.favorite,
                                          size: 20,
                                        ),
                                      ),
                                      onTap: () {
                                        if (!favProduct.contains(widget.model!.products![index].id)) {
                                          widget.model!.products![index].isFavLoading = true;
                                          widget.model!.products![index].isFav = '1';
                                          db.addAndRemoveFav(widget.model!.products![index].id!, true);
                                          Future.delayed(const Duration(seconds: 1)).then((_) async {
                                            if (mounted) {
                                              setState(() {
                                                getFavProduct();
                                                // getProduct("0");
                                                widget.model!.products![index].isFavLoading = false;
                                              });
                                            }
                                          });
                                        } else {
                                          widget.model!.products![index].isFavLoading = true;
                                          db.addAndRemoveFav(widget.model!.products![index].id!, false);
                                          setState(() {
                                            getFavProduct();
                                            // getProduct("0");
                                            widget.model!.products![index].isFavLoading = false;
                                          });
                                        }
                                      },
                                    );
                                  },
                                  selector: (_, provider) => provider.favIdList,
                                )
                            )
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 10.0,
                      top: 15,
                    ),
                    child: Text(
                      widget.model!.products![index].name!,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.lightBlack,
                        fontSize: textFontSize12,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 8.0,
                      top: 5,
                    ),
                    child: Row(
                      children: [
                        Text(
                          ' ${getPriceFormat(context, off)!}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.blue,
                            fontSize: textFontSize12,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        // Expanded(
                        //   child: Padding(
                        //     padding: const EdgeInsetsDirectional.only(
                        //       start: 10.0,
                        //       top: 5,
                        //     ),
                        //     child: Row(
                        //       children: <Widget>[
                        //         Text(
                        //           double.parse(widget.model!.products![index]
                        //               .discount!) !=
                        //               0
                        //               ? '${getPriceFormat(context,
                        //               double.parse(widget.model!.products![index].price!.replaceAll(RegExp('[^0-9]'), ''),))}'
                        //               : '',
                        //           style: Theme.of(context)
                        //               .textTheme
                        //               .labelSmall!
                        //               .copyWith(
                        //             decoration:
                        //             TextDecoration.lineThrough,
                        //             letterSpacing: 0,
                        //             fontSize: textFontSize10,
                        //             fontWeight: FontWeight.w400,
                        //             fontStyle: FontStyle.normal,
                        //           ),
                        //         ),
                        //
                        //       ],
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                        start: 10.0,
                        top: 10,
                        bottom: 5
                    ),
                    child:
                    widget.model!.products![index].rating!.ratingValue != '0.00'
                        ?Padding(
                      padding: const EdgeInsetsDirectional.only(
                          top: 8.0, start: 15.0),
                      child: RatingBarIndicator(
                        rating: double.parse(widget.model!.products![index].rating?.ratingValue.toString()??"0"),
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 20.0,
                        unratedColor: Colors.amber.withAlpha(50),
                        direction: Axis.horizontal,
                      ),
                    ): Container(
                      height: 20,
                    ),
                  ),
                ],
              ),

              //),
            ),
            onTap: () {
              // Product model = widget.model!.products![index];
              // Navigator.push(
              //   context,
              //   PageRouteBuilder(
              //       pageBuilder: (_, __, ___) => ProductDetail1(
              //         model: model,
              //         index: index,
              //         secPos: 0,
              //         list: true,
              //       )),
              // );
            },
          );
      //   },
      //   selector: (_, provider) => Tuple2(
      //       provider.cartIdList,
      //       provider.qtyList(widget.model!.products![index].id!)
      //   ),
      // );
    } else {
      return Container();
    }
  }

  void sortDialog() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.white,
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                            padding: const EdgeInsetsDirectional.only(
                                top: 19.0, bottom: 16.0),
                            child: Text(
                              getTranslated(context, 'SORT_BY')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                  color:
                                  Theme.of(context).colorScheme.fontColor),
                            )),
                      ),
                      getDivider(3,context),
                      InkWell(
                        onTap: () {
                          sortBy = '';
                          orderBy = 'DESC';
                          if (mounted) {
                            setState(() {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              widget.model!.products!.clear();
                            });
                          }
                          // getProduct('1');
                          Navigator.pop(context, 'option 1');
                        },
                        child: Container(
                          width: deviceWidth,
                          color: sortBy == ''
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: Text(getTranslated(context, 'TOP_RATED')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: sortBy == ''
                                      ? Theme.of(context).colorScheme.white
                                      : Theme.of(context)
                                      .colorScheme
                                      .fontColor)),
                        ),
                      ),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'p.date_added' && orderBy == 'DESC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Text(getTranslated(context, 'F_NEWEST')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(
                                      color: sortBy == 'p.date_added' &&
                                          orderBy == 'DESC'
                                          ? Theme.of(context).colorScheme.white
                                          : Theme.of(context)
                                          .colorScheme
                                          .fontColor))),
                          onTap: () {
                            sortBy = 'p.date_added';
                            orderBy = 'DESC';
                            if (mounted) {
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                widget.model!.products!.clear();
                              });
                            }
                            // getProduct('0');
                            Navigator.pop(context, 'option 1');
                          }),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'p.date_added' && orderBy == 'ASC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Text(
                                getTranslated(context, 'F_OLDEST')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: sortBy == 'p.date_added' &&
                                        orderBy == 'ASC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              )),
                          onTap: () {
                            sortBy = 'p.date_added';
                            orderBy = 'ASC';
                            if (mounted) {
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                widget.model!.products!.clear();
                              });
                            }
                            Navigator.pop(context, 'option 2');
                          }),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'pv.price' && orderBy == 'ASC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Text(
                                getTranslated(context, 'F_LOW')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: sortBy == 'pv.price' &&
                                        orderBy == 'ASC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              )),
                          onTap: () {
                            sortBy = 'pv.price';
                            orderBy = 'ASC';
                            if (mounted) {
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                widget.model!.products!.clear();
                              });
                            }
                            Navigator.pop(context, 'option 3');
                          }),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'pv.price' && orderBy == 'DESC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Text(
                                getTranslated(context, 'F_HIGH')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: sortBy == 'pv.price' &&
                                        orderBy == 'DESC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              )),
                          onTap: () {
                            sortBy = 'pv.price';
                            orderBy = 'DESC';
                            if (mounted) {
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                widget.model!.products!.clear();
                              });
                            }
                            // getProduct('0');
                            Navigator.pop(context, 'option 4');
                          }),
                    ]),
              );
            });
      },
    );
  }

  _showForm() {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.white,
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            children: [
              if (widget.fromSeller!) Container() else _tags(),
              sortAndFilterOption(),
              // filterOptions(),
            ],
          ),
        ),
        Expanded(
          child: widget.model!.products!.isEmpty
              ? getNoItem(context)
              :  context.watch<ExploreProvider>().getCurrentView !=
              'GridView'
              ? ListView.builder(
            controller: controller,
            shrinkWrap: true,
            itemCount: widget.model!.products!.length,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              print("product length $context");
              return (index == widget.model!.products!.length)
                  ? singleItemSimmer(context)
                  : listItem(index);
            },
          )
              : GridView.count(
              padding: const EdgeInsetsDirectional.only(top: 5),
              crossAxisCount: 2,
              controller: controller,
              childAspectRatio: 0.6,
              physics: const AlwaysScrollableScrollPhysics(),
              children: List.generate(
                widget.model!.products!.length,
                    (index) {
                  return (index == widget.model!.products!.length)
                      ? simmerSingleProduct(context)
                      : productItem(
                      index, index % 2 == 0 ? true : false);
                },
              )),
        ),
      ],
    );
  }

  Widget _tags() {
    if (tagList != null && tagList!.isNotEmpty) {
      List<Widget> chips = [];
      for (int i = 0; i < tagList!.length; i++) {
        tagChip = ChoiceChip(
          selected: false,
          label: Text(tagList![i],
              style: TextStyle(color: Theme.of(context).colorScheme.white)),
          backgroundColor: colors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          onSelected: (bool selected) {
            if (mounted) {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => ProductList(
                      name: tagList![i],
                      tag: true,
                      fromSeller: false,
                    ),
                  ));
            }
          },
        );

        chips.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: tagChip));
      }

      return Container(
        height: 50,
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: chips),
      );
    } else {
      return Container();
    }
  }

  sortAndFilterOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Container(
        color: Theme.of(context).colorScheme.white,
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 20),
                child: GestureDetector(
                  onTap: sortDialog,
                  child: Row(
                    children: [
                      Text(
                        getTranslated(context, 'SORT_BY')!,
                        style: const TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: textFontSize12),
                        textAlign: TextAlign.start,
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_sharp,
                        size: 16,
                      )
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsetsDirectional.only(end: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 3.0,),
                    child: InkWell(

                      child: AnimatedIcon(
                        textDirection: TextDirection.ltr,
                        icon: AnimatedIcons.list_view,

                        progress: listViewIconController,
                      ),
                      onTap: () {
                        if (widget.model!.products!.isNotEmpty) {
                          if (context.read<ExploreProvider>().view ==
                              'ListView') {
                            context
                                .read<ExploreProvider>()
                                .changeViewTo('GridView');
                          } else {
                            context
                                .read<ExploreProvider>()
                                .changeViewTo('ListView');
                          }
                        }
                        context.read<ExploreProvider>().view == 'ListView'
                            ? listViewIconController.forward()
                            : listViewIconController.reverse();
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text(' | '),

                  GestureDetector(
                    onTap: filterDialog,
                    child: Row(
                      children: [
                        const Icon(Icons.filter_alt_outlined,),
                        Text(
                          getTranslated(context, 'FILTER')!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.fontColor,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void filterDialog() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (builder) {
        _currentRangeValues =
            RangeValues(double.parse(minPrice), double.parse(maxPrice));
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                    padding: const EdgeInsetsDirectional.only(top: 30.0),
                    child: AppBar(
                      title: Text(
                        getTranslated(context, 'FILTER')!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                      centerTitle: true,
                      elevation: 5,
                      backgroundColor: Theme.of(context).colorScheme.white,
                      leading: Builder(builder: (BuildContext context) {
                        return Container(
                          margin: const EdgeInsets.all(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: () => Navigator.of(context).pop(),
                            child: const Padding(
                              padding: EdgeInsetsDirectional.only(end: 4.0),
                              child: Icon(Icons.arrow_back_ios_rounded,
                                  color: colors.primary),
                            ),
                          ),
                        );
                      }),
                    )),
                Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.lightWhite,
                      padding: const EdgeInsetsDirectional.only(
                          start: 7.0, end: 7.0, top: 7.0),
                      child: filterList != null
                          ? ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsetsDirectional.only(top: 10.0),
                          itemCount: filterList.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Column(
                                children: [
                                  SizedBox(
                                      width: deviceWidth,
                                      child: Card(
                                          elevation: 0,
                                          child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Price Range',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1!
                                                    .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .lightBlack,
                                                    fontWeight:
                                                    FontWeight.normal),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              )))),
                                  RangeSlider(
                                    values: _currentRangeValues!,
                                    min: double.parse(minPrice),
                                    max: double.parse(maxPrice),
                                    divisions: 10,
                                    labels: RangeLabels(
                                      _currentRangeValues!.start.round().toString(),
                                      _currentRangeValues!.end.round().toString(),
                                    ),
                                    onChanged: (RangeValues values) {
                                      setState(() {
                                        _currentRangeValues = values;
                                      });
                                    },
                                  ),
                                ],
                              );
                            } else {
                              index = index - 1;
                              attsubList =
                                  filterList[index]['attribute_values'].split(',');

                              attListId = filterList[index]['attribute_values_id']
                                  .split(',');

                              List<Widget?> chips = [];
                              List<String> att =
                              filterList[index]['attribute_values']!.split(',');

                              List<String> attSType =
                              filterList[index]['swatche_type'].split(',');

                              List<String> attSValue =
                              filterList[index]['swatche_value'].split(',');

                              for (int i = 0; i < att.length; i++) {
                                Widget itemLabel;
                                if (attSType[i] == '1') {
                                  String clr = (attSValue[i].substring(1));

                                  String color = '0xff$clr';

                                  itemLabel = Container(
                                    width: 25,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(int.parse(color))),
                                  );
                                } else if (attSType[i] == '2') {
                                  itemLabel = ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(attSValue[i],
                                          width: 80,
                                          height: 80,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                              erroWidget(80)));
                                } else {
                                  itemLabel = Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(att[i],
                                        style: TextStyle(
                                            color:
                                            selectedId.contains(attListId![i])
                                                ? Theme.of(context)
                                                .colorScheme
                                                .white
                                                : Theme.of(context)
                                                .colorScheme
                                                .fontColor)),
                                  );
                                }

                                choiceChip = ChoiceChip(
                                  selected: selectedId.contains(attListId![i]),
                                  label: itemLabel,
                                  labelPadding: const EdgeInsets.all(0),
                                  selectedColor: colors.primary,
                                  backgroundColor:
                                  Theme.of(context).colorScheme.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        attSType[i] == '1' ? 100 : 10),
                                    side: BorderSide(
                                        color: selectedId.contains(attListId![i])
                                            ? colors.primary
                                            : colors.black12,
                                        width: 1.5),
                                  ),
                                  onSelected: (bool selected) {
                                    attListId = filterList[index]
                                    ['attribute_values_id']
                                        .split(',');

                                    if (mounted) {
                                      setState(() {
                                        if (selected == true) {
                                          selectedId.add(attListId![i]);
                                        } else {
                                          selectedId.remove(attListId![i]);
                                        }
                                      });
                                    }
                                  },
                                );

                                chips.add(choiceChip);
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: deviceWidth,
                                    child: Card(
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          filterList[index]['name'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                              fontWeight: FontWeight.normal),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  chips.isNotEmpty
                                      ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      children:
                                      chips.map<Widget>((Widget? chip) {
                                        return Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: chip,
                                        );
                                      }).toList(),
                                    ),
                                  )
                                      : Container()
                                ],
                              );
                            }
                          })
                          : Container(),
                    )),
                Container(
                  color: Theme.of(context).colorScheme.white,
                  child: Row(children: <Widget>[
                    Container(
                      margin: const EdgeInsetsDirectional.only(start: 20),
                      width: deviceWidth! * 0.4,
                      child: OutlinedButton(
                        onPressed: () {
                          if (mounted) {
                            setState(() {
                              selectedId.clear();
                            });
                          }
                        },
                        child: Text(getTranslated(context, 'DISCARD')!),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 20),
                      child: SimBtn(
                          borderRadius: circularBorderRadius5,
                          size: 0.4,
                          title: getTranslated(context, 'APPLY'),
                          onBtnSelected: () {
                            selId = selectedId.join(',');

                            if (mounted) {
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                widget.model!.products!.clear();
                              });
                            }
                            // getProduct('0');
                            Navigator.pop(context, 'Product Filter');
                          }),
                    ),
                  ]),
                )
              ]);
            });
      },
    );
  }
  void getProduct() {
    _isLoading = false;

  }
  }
