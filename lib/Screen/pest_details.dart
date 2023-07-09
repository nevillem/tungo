import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Model/crop_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Session.dart';
class PestDetailsScreen extends StatefulWidget {
  final CropData? pestData;
  final String? image;
  final int curIndex;
  const PestDetailsScreen({Key? key, required this.pestData,
    required this.image, required this.curIndex}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StateItem();
}

class StateItem extends State<PestDetailsScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isBottom = false;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  PageController _controller=PageController();

  int _cindex=0;
  @override
  void initState() {
    // TODO: implement initState
    _cindex=widget.curIndex;
    super.initState();
  }

  @override
  void dispose() {
    buttonController!.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients)
        _controller.jumpToPage(_cindex);

    });
    super.didChangeDependencies();
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
    int? _infoItemCount=widget.pestData?.croppest?.length;
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
        title: Text("Farming info",
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
          _showContent(),
        ],
      ) : noInternet(context),
      floatingActionButton: _infoItemCount! >1? Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if(_cindex !=0) FloatingActionButton(
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .primary,
            heroTag: "btn1",
            onPressed: () {
              setState(() {
                _controller.jumpToPage(_cindex-1);
              });
            },
            child: const Icon(
              color: Color(0xff222222),
              FontAwesomeIcons.chevronLeft,
              size: 10,
            ),),
          if (_cindex+1 !=_infoItemCount)
            FloatingActionButton(
              backgroundColor: Theme
                  .of(context)
                  .colorScheme
                  .primary,
              heroTag: "btn2",
              onPressed: () {
                setState(() {
                  _controller.jumpToPage(_cindex+1);
                });
              },
              child: const Icon(
                color: Color(0xff222222),
                FontAwesomeIcons.chevronRight,
                size: 10,
              ),),

        ],
      ):Container(),
    );
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }
  _showContent() {
    return Expanded(
      child: Stack(
        children: <Widget>[
          _showContentInfoItem(),
        ],
      ),
    );
  }
  _showContentInfoItem(){
    return Padding(
      padding: EdgeInsets.only(left: 15, top: 10, right: 15),
      child: SizedBox(
        width: double.infinity,
        child: PageView.builder(
          itemCount: widget.pestData?.croppest?.length,
          scrollDirection: Axis.horizontal,
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          onPageChanged: (num) {
            _cindex=num;
          },
          itemBuilder: (BuildContext context, int index) {
            String numberinfo="${widget.pestData?.croppest![index]?.pestDetails!.length}";
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                      width: double.infinity,
                      child: Text("${widget.pestData?.croppest?[index].pest}",
                          style: Theme.of(this.context).textTheme.titleSmall!.copyWith(
                              color: Theme.of(context).colorScheme.lightBlack,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)
                      )
                  ),
                  SizedBox(height: 20,),
                  numberinfo !="0" ?
                  ListView.builder(
                      shrinkWrap: true,
                      // controller: cropPestListController,
                      itemCount:widget.pestData?.croppest![index].pestDetails!.length,
                      itemBuilder: (context, int columnno) {
                        return HtmlWidget("${widget.pestData?.croppest![index].pestDetails?[columnno].details}");
                      }):Center(
                      child: Text(
                          getTranslated(context, 'No information given')!))
                ],
              ),
            );
          },
        ),
      ),);
  }

  Widget _cropImage() {
    double height = MediaQuery.of(context).size.height * .43;
    double statusBarHeight = MediaQuery.of(context).padding.top;
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
            widget.image!,
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
