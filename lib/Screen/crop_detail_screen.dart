import 'package:agritungotest/Model/crop_model.dart';
import 'package:agritungotest/Provider/HomeProvider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/SqliteData.dart';
import '../Helper/String.dart';
import '../Provider/CartProvider.dart';
import 'disease_details.dart';
import 'info_item_detail.dart';
import 'pest_details.dart';

class CropDetails extends StatefulWidget {
  final CropData? model;
  const CropDetails({Key? key, this.model}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateItem();
}

class StateItem extends State<CropDetails> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isBottom = false;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  late TabController _tabController;
  ScrollController? cropListController,cropDiseaseListController,cropPestListController;
  int cropListOffset = 0;
  int cropDiseaseListOffset = 0;
  int cropPestsListOffset = 0;

  @override
  void initState() {
    cropListController = ScrollController(keepScrollOffset: true);
    cropListController!.addListener(_cropInfoItemListController);
    cropDiseaseListController = ScrollController(keepScrollOffset: true);
    cropDiseaseListController!.addListener(_cropDiseaseListController);
    cropPestListController = ScrollController(keepScrollOffset: true);
    cropPestListController!.addListener(_cropPestsListController);
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
    super.initState();
  }
  _cropInfoItemListController() {
    if (cropListController!.offset >=
        cropListController!.position.maxScrollExtent &&
        !cropListController!.position.outOfRange) {
      if (mounted) {
        if (cropListOffset < widget.model!.informationitems!.length) {
          setState(() {});
        }
      }
    }
  }
  _cropDiseaseListController() {
    if (cropDiseaseListController!.offset >=
        cropDiseaseListController!.position.maxScrollExtent &&
        !cropDiseaseListController!.position.outOfRange) {
      if (mounted) {
        if (cropDiseaseListOffset < widget.model!.cropdiseases!.length) {
          setState(() {});
        }
      }
    }
  }  
  _cropPestsListController() {
    if (cropPestListController!.offset >=
        cropPestListController!.position.maxScrollExtent &&
        !cropPestListController!.position.outOfRange) {
      if (mounted) {
        if (cropPestsListOffset < widget.model!.croppest!.length) {
          setState(() {});
        }
      }
    }
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
    return Scaffold(
    key: _scaffoldKey,
    appBar: AppBar(
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
      title: Text("${widget.model!.name!}",
        style:
        const TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
      ),
    ),
      backgroundColor: isBottom
          ? Colors.transparent.withOpacity(0.5)
          : Theme.of(context).canvasColor,
      body: _isNetworkAvail
    ? Column(
    children: <Widget>[
      Container(
        color: Theme
            .of(context)
            .colorScheme
            .white,
        child: Container(
          // decoration: BoxDecoration(
          //     borderRadius:
          //     BorderRadius.circular(circularBorderRadius10)),
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: _cropImage(),
        ),
      ),
      Container(
        color: Theme.of(context).colorScheme.white,
        child: TabBar(
          controller: _tabController,
          tabs: [
          Tab(child: Text(getTranslated(context, 'IFORMATION_LBL')!),),
          Tab(child: Text(getTranslated(context, 'DISEASE_LBL')!),),
           Tab( child: Text(getTranslated(context, 'PESTS_LBL')!),),
          ],
          indicatorColor: colors.primary,
          labelColor: Theme.of(context).colorScheme.primary,
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
      _showContent(),
    ],
    ) : noInternet(context),
    );
  }

  _showContent() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          Stack(
            children: <Widget>[
              _showContentOfInformation(),
            ],
          ),
          Stack(
            children: <Widget>[
            _showContentOfDiseases(),
            ],
          ),
          Stack(
            children: <Widget>[
              _showContentOfPests(),
            ],
          ),
        ],
      ),
    );

  }
@override
 void dispose(){
  _tabController.dispose();
  super.dispose();
  }
    Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }
  _showContentOfInformation(){
   var numberItems= widget.model?.informationitems?.length;
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15, top: 10),
      child: numberItems !=0?
      Column(
        children: [
      HtmlWidget("${widget.model?.informationitems?[0]!.information?[0].information}"),
          ListView.builder(
              shrinkWrap: true,
              controller: cropListController,
              itemCount:numberItems,
              itemBuilder: (context, int index) {
                var counter=index +1;
                return GestureDetector(
                  onTap: (){
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (BuildContext context) =>
                                InfoItemDetails(
                                  curIndex: index,
                                  image: widget.model?.image!,
                                  infoItems:widget.model,
                                )));
                  },
                  child: Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color:
                    Theme
                        .of(context)
                        .colorScheme
                        .lightBlack2))),
                    child: ListTile(
                      leading: Text(
                          "$counter . ${widget.model?.informationitems?[index].name}",
                          style: Theme.of(context)
                              .textTheme.titleLarge!
                              .copyWith(color: Theme.of(context).colorScheme.primary, fontSize: textFontSize14)
                      ),
                      trailing: const Icon(
                        FontAwesomeIcons.rightLong,
                        size: 10,
                      ),
                    ),
                  ),
                );
              }),
        ],
      ):Center(
          child: Text(
              getTranslated(context, 'No information to show yet')!)),
    );
  }
  _showContentOfDiseases(){
   var numberItems= widget.model?.cropdiseases?.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: numberItems !=0?
      Column(
        children: [

          ListView.builder(
              shrinkWrap: true,
              controller: cropDiseaseListController,
              itemCount:numberItems,
              itemBuilder: (context, int index) {
                return GestureDetector(
                  onTap: (){
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (BuildContext context) =>
                                DiseaseDetailScreen(
                                  curIndex: index,
                                  image: widget.model!.cropdiseases![index].image!,
                                  diseaseItem:widget.model,
                                )));
                  },
                  child: Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color:
                    Theme
                        .of(context)
                        .colorScheme
                        .lightBlack2))),
                    child: ListTile(
                      leading: ClipRRect(
                          borderRadius: BorderRadius.circular(7.0),
                          child:  FadeInImage(
                            image: CachedNetworkImageProvider(
                                widget.model!.cropdiseases![index].image!),
                            fadeInDuration:
                            const Duration(milliseconds: 10),
                            fit: BoxFit.cover,
                            height: 50,
                            width: 50,
                            placeholder: placeHolder(50),
                            imageErrorBuilder:
                                (context, error, stackTrace) =>
                                erroWidget(50),
                          )),
                      title: Text(
                          "${widget.model?.cropdiseases?[index].disease}",
                          style: Theme.of(context)
                              .textTheme.titleLarge!
                              .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14)
                      ),
                      trailing: const Icon(
                        FontAwesomeIcons.rightLong,
                        size: 10,
                      ),
                    ),
                  ),
                );
              }),
        ],
      ):Center(
          child: Text(
              getTranslated(context, 'No crop diseases to show yet')!)),
    );
  }
  _showContentOfPests(){
   var numberItems= widget.model?.croppest?.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: numberItems !=0?
      ListView.builder(
          shrinkWrap: true,
          controller: cropPestListController,
          itemCount:numberItems,
          itemBuilder: (context, int index) {
            return GestureDetector(
              onTap: (){
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (BuildContext context) =>
                            PestDetailsScreen(
                              curIndex: index,
                              image: widget.model!.croppest![index].image!,
                              pestData:widget.model,
                            )));
              },
              child: Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color:
                Theme
                    .of(context)
                    .colorScheme
                    .lightBlack2))),
                child: ListTile(
                  leading: ClipRRect(
                      borderRadius: BorderRadius.circular(7.0),
                      child:  FadeInImage(
                        image: CachedNetworkImageProvider(
                            widget.model!.croppest![index].image!),
                        fadeInDuration:
                        const Duration(milliseconds: 10),
                        fit: BoxFit.cover,
                        height: 50,
                        width: 50,
                        placeholder: placeHolder(50),
                        imageErrorBuilder:
                            (context, error, stackTrace) =>
                            erroWidget(50),
                      )),
                  title: Text(
                      "${widget.model?.croppest?[index].pest}",
                      style: Theme.of(context)
                          .textTheme.titleLarge!
                          .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14)
                  ),
                  trailing: const Icon(
                    FontAwesomeIcons.rightLong,
                    size: 10,
                  ),
                ),
              ),
            );
          }):Center(
          child: Text(
              getTranslated(context, 'No crop pests to show yet')!)),
    );
  }

  Widget _cropImage() {
    double height = MediaQuery.of(context).size.height * .43;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    // print(widget.model!.id);
    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   PageRouteBuilder(
        //     // transitionDuration: Duration(seconds: 1),
        //     pageBuilder: (_, __, ___) => ProductPreview(
        //       pos: _curSlider,
        //       secPos: widget.secPos,
        //       index: widget.index,
        //       id: widget.model!.id,
        //       imgList: sliderList,
        //       list: widget.list,
        //       video: widget.model!.video,
        //       videoType: widget.model!.videType,
        //       from: true,
        //       screenSize: MediaQuery.of(context).size,
        //     ),
        //   ),
        // );
      },
      child: FadeInImage(
        image: NetworkImage(
          widget.model!.image!,
        ),
        placeholder: const AssetImage(
          'assets/images/sliderph.png',
        ),
        fit: BoxFit.cover,
        imageErrorBuilder: (context, error, stackTrace) =>
            erroWidget(height),
      )
    );
  }

}
