
import 'dart:async';
import 'dart:math';

import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Helper/Constant.dart';
import 'package:agritungotest/Helper/Session.dart';
import 'package:agritungotest/Provider/Theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../Helper/String.dart';
import '../Provider/SettingProvider.dart';
import '../model/Section_Model.dart';
class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

bool buildResult = false;

class _SearchState extends State<Search> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String lastWords = '';
  final SpeechToText speech = SpeechToText();
  late StateSetter setStater;
  int pos = 0;
  bool _isProgress = false;
  final List<TextEditingController> _controllerList = [];
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;

  String query = '';
  int notificationoffset = 0;
  int sellerListOffset = 0;
  ScrollController? notificationcontroller;
  ScrollController? sellerListController;
  bool notificationisloadmore = true,
      notificationisgettingdata = false,
      notificationisnodata = false;

  late AnimationController _animationController;
  Timer? _debounce;
  // List<Product> history = [];
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;

  String lastStatus = '';
  String _currentLocaleId = '';

  ChoiceChip? tagChip;
  // late UserProvider userProvider;
  // late TabController _tabController;

  // List<Product> sellerList = [];

  int totalSelletCount = 0;


  @override
  void initState() {
    super.initState();

    // productList.clear();

    notificationoffset = 0;

    notificationcontroller = ScrollController(keepScrollOffset: true);
    notificationcontroller!.addListener(_transactionscrollListener);
    sellerListController = ScrollController(keepScrollOffset: true);
    sellerListController!.addListener(_sellerListController);

    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        if (mounted) {
          setState(() {
            query = '';
          });
        }
      } else {
        query = _controller.text;
        notificationoffset = 0;
        notificationisnodata = false;
        buildResult = false;
        if (query.trim().isNotEmpty) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            if (query.trim().isNotEmpty) {
              notificationisloadmore = true;
              notificationoffset = 0;
              // getProduct();
            }
          });
        }
      }
      ScaffoldMessenger.of(context).clearSnackBars();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

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

    // getSeller();
  }
  _transactionscrollListener() {
    if (notificationcontroller!.offset >=
        notificationcontroller!.position.maxScrollExtent &&
        !notificationcontroller!.position.outOfRange) {
      if (mounted) {
        setState(() {
          // getProduct();
        });
      }
    }
  }
  _sellerListController() {
    if (sellerListController!.offset >=
        sellerListController!.position.maxScrollExtent &&
        !sellerListController!.position.outOfRange) {
      if (mounted) {
        if (sellerListOffset < totalSelletCount) {
          setState(() {
            // getSeller();
          });
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(end: 4.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: colors.primary),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.white,
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: TextStyle(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
            hintText: getTranslated(context, 'SEARCH_LBL'),
            hintStyle: TextStyle(color: colors.primary.withOpacity(0.5)),
            enabledBorder: UnderlineInputBorder(
              borderSide:
              BorderSide(color: Theme.of(context).colorScheme.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide:
              BorderSide(color: Theme.of(context).colorScheme.white),
            ),
          ),
          // onChanged: (query) => updateSearchQuery(query),
        ),
        titleSpacing: 0,
        actions: [
          _controller.text != ''
              ? IconButton(
            onPressed: () {
              _controller.text = '';
            },
            icon: const Icon(
              Icons.close,
              color: colors.primary,
            ),
          )
              : GestureDetector(
              onTap: () {
                lastWords = '';
                if (!_hasSpeech) {
                  initSpeechState();
                } else {
                  showSpeechDialog();
                }
              },
              child: Selector<ThemeNotifier, ThemeMode>(
                  selector: (_, themeProvider) =>
                      themeProvider.getThemeMode(),
                  builder: (context, data, child) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: (data == ThemeMode.system &&
                          MediaQuery.of(context)
                              .platformBrightness ==
                              Brightness.light) ||
                          data == ThemeMode.light
                          ? SvgPicture.asset(
                        '${imagePath}voice_search.svg',
                        height: 15,
                        width: 15,
                      )
                          : SvgPicture.asset(
                        '${imagePath}voice_search_white.svg',
                        height: 15,
                        width: 15,
                      ),
                    );
                  })),
        ],
      ),
    );
  }
  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: false,
        finalTimeout: const Duration(milliseconds: 0));
    if (hasSpeech) {
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
    if (hasSpeech) showSpeechDialog();
  }

  void errorListener(SpeechRecognitionError error) {}

  void statusListener(String status) {
    setStater(() {
      lastStatus = status;
    });
  }

  void startListening() {
    lastWords = '';
    speech.listen(
        onResult: resultListener,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setStater(() {});
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);

    setStater(() {
      this.level = level;
    });
  }

  void stopListening() {
    speech.stop();
    setStater(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setStater(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setStater(() {
      lastWords = result.recognizedWords;
      query = lastWords;
    });

    if (result.finalResult) {
      Future.delayed(const Duration(seconds: 1)).then((_) async {
        clearAll();

        _controller.text = lastWords;
        _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length));

        setState(() {});
        Navigator.of(context).pop();
      });
    }
  }
  clearAll() {
    setState(() {
      query = _controller.text;
      notificationoffset = 0;
      notificationisloadmore = true;
      // productList.clear();
    });
  }

  showSpeechDialog() {
    return dialogAnimate(context, StatefulBuilder(
        builder: (BuildContext context, StateSetter setStater1) {
          setStater = setStater1;
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.lightWhite,
            title: Text(
              getTranslated(context, 'SEarchHint')!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold,
                fontSize: textFontSize16,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          blurRadius: .26,
                          spreadRadius: level * 1.5,
                          color:
                          Theme.of(context).colorScheme.black.withOpacity(.05))
                    ],
                    color: Theme.of(context).colorScheme.white,
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                  ),
                  child: IconButton(
                      icon: const Icon(
                        Icons.mic,
                        color: colors.primary,
                      ),
                      onPressed: () {
                        if (!_hasSpeech) {
                          initSpeechState();
                        } else {
                          !_hasSpeech || speech.isListening
                              ? null
                              : startListening();
                        }
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(lastWords),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  color: Theme.of(context).colorScheme.fontColor.withOpacity(0.1),
                  child: Center(
                    child: speech.isListening
                        ? Text(
                      "I'm listening...",
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold),
                    )
                        : Text(
                      'Not listening',
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        }));
  }

}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList(
      {this.suggestions,
        this.textController,
        this.searchDelegate,
        this.notificationcontroller,
        this.getProduct,
        this.clearAll});

  final List<Product>? suggestions;
  final TextEditingController? textController;

  final notificationcontroller;
  final SearchDelegate<Product>? searchDelegate;
  final Function? getProduct, clearAll;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: suggestions!.length,
      shrinkWrap: true,
      controller: notificationcontroller,
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (BuildContext context, int i) {
        final Product suggestion = suggestions![i];

        return ListTile(
            title: Text(
              suggestion.name!,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Theme.of(context).colorScheme.lightBlack,
                  fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: textController!.text.toString().trim().isEmpty ||
                suggestion.history!
                ? null
                : Text(
              'In ${suggestion.catName!}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor),
            ),
            leading: textController!.text.toString().trim().isEmpty ||
                suggestion.history!
                ? const Icon(Icons.history)
                : ClipRRect(
                borderRadius: BorderRadius.circular(7.0),
                child: suggestion.image == ''
                    ? Image.asset(
                  'assets/images/placeholder.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : FadeInImage(
                  image:
                  CachedNetworkImageProvider(suggestion.image!),
                  fadeInDuration: const Duration(milliseconds: 10),
                  fit: BoxFit.cover,
                  height: 50,
                  width: 50,
                  placeholder: placeHolder(50),
                  imageErrorBuilder: (context, error, stackTrace) =>
                      erroWidget(50),
                )),
            trailing: const Icon(
              Icons.reply,
            ),
            onTap: () async {
              if (suggestion.name!.startsWith('Search Result for ')) {
                SettingProvider settingsProvider =
                Provider.of<SettingProvider>(context, listen: false);

                settingsProvider.setPrefrenceList(
                    HISTORYLIST, textController!.text.toString().trim());

                buildResult = true;
                clearAll!();
                getProduct!();
              } else if (suggestion.history!) {
                clearAll!();

                buildResult = true;
                textController!.text = suggestion.name!;
                textController!.selection = TextSelection.fromPosition(
                    TextPosition(offset: textController!.text.length));
              } else {
                SettingProvider settingsProvider =
                Provider.of<SettingProvider>(context, listen: false);

                settingsProvider.setPrefrenceList(
                    HISTORYLIST, textController!.text.toString().trim());
                buildResult = false;
                Product model = suggestion;
                // Navigator.push(
                //   context,
                //   PageRouteBuilder(
                //     // transitionDuration: Duration(seconds: 1),
                //       pageBuilder: (_, __, ___) => ProductDetail1(
                //         model: model,
                //         secPos: 0,
                //         index: i,
                //         list: true,
                //       )),
                // );
              }
            });
      },
    );
  }
}