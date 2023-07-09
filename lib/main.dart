
import 'package:agritungotest/Helper/Session.dart';
import 'package:agritungotest/Provider/CartProvider.dart';
import 'package:agritungotest/Provider/CategoryProvider.dart';
import 'package:agritungotest/Provider/SettingProvider.dart';
import 'package:agritungotest/Provider/ShopProvider.dart';
import 'package:agritungotest/Provider/Theme.dart';
import 'package:agritungotest/Provider/UserProvider.dart';
import 'package:agritungotest/Provider/explore_provider.dart';
import 'package:agritungotest/Provider/location_provider.dart';
import 'package:agritungotest/Screen/Dashboard.dart';
import 'package:agritungotest/Screen/Splash.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Demo_Localization.dart';
import 'Helper/PushNotificationService.dart';
import 'Helper/String.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'Provider/FavoriteProvider.dart';
import 'Provider/HomeProvider.dart';
import 'Provider/ProductDetailProvider.dart';
import 'Provider/dashboard_provider.dart';
import 'Screen/RegisterAnimals.dart';
import 'Screen/Select_favorite_crops.dart';
import 'Screen/crop_screen.dart';
import 'Screen/milk_sold_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.instance.getInitialMessage();
  initializedDownload();
  // FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  // HttpOverrides.global = MyHttpOverrides();

  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (BuildContext context) {
     String? theme = prefs.getString(APP_THEME);
     if (theme == DARK) {
       ISDARK = 'true';
     } else if (theme == LIGHT) {
       ISDARK = 'false';
     }

     if (theme == null || theme == '' || theme == DEFAULT_SYSTEM) {
       prefs.setString(APP_THEME, DEFAULT_SYSTEM);
       var brightness = SchedulerBinding.instance.window.platformBrightness;
       ISDARK = (brightness == Brightness.dark).toString();

       return ThemeNotifier(ThemeMode.system);
     }

     return ThemeNotifier(theme == LIGHT ? ThemeMode.light : ThemeMode.dark);
      },
      child: MyApp(sharedPreferences: prefs,),
    ),
  );
}

Future<void> initializedDownload() async {
  await FlutterDownloader.initialize(debug: false);
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatefulWidget {
  late SharedPreferences sharedPreferences;

  MyApp({Key? key, required this.sharedPreferences}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    if (mounted) {
      setState(
            () {
          _locale = locale;
        },
      );
    }
  }
  @override
  void didChangeDependencies() {
    getLocale().then(
          (locale) {
        if (mounted) {
          setState(
                () {
              _locale = locale;
            },
          );
        }
      },
    );
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    if (_locale == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color?>(
            colors.primary,
          ),
        ),
      );
    }else{
    return MultiProvider(
        providers: [
      Provider<SettingProvider>(
        create: (context) => SettingProvider(widget.sharedPreferences),
      ),
      ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider()),
      ChangeNotifierProvider<HomeProvider>(
              create: (context) => HomeProvider()),
          ChangeNotifierProvider<WeatherProvider>(
              create: (context) => WeatherProvider()),
          ChangeNotifierProvider<MilkDashboardProvider>(
              create: (context) => MilkDashboardProvider()),
      ChangeNotifierProvider<ShopProvider>(
              create: (context) => ShopProvider()),
          ChangeNotifierProvider<ProductDetailProvider>(
              create: (context) => ProductDetailProvider()),
          ChangeNotifierProvider<FavoriteProvider>(
              create: (context) => FavoriteProvider()),
          ChangeNotifierProvider<CartProvider>(
              create: (context) => CartProvider()),
          ChangeNotifierProvider<CategoryProvider>(
              create: (context) => CategoryProvider()),
          ChangeNotifierProvider<ExploreProvider>(
              create: (context) => ExploreProvider()),
    ],
    child: MaterialApp(
      //scaffoldMessengerKey: rootScaffoldMessengerKey,
      locale: _locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('zh', 'CN'),
        Locale('es', 'ES'),
        Locale('hi', 'IN'),
        Locale('fr', 'FR'),
        Locale('ar', 'DZ'),
        Locale('ru', 'RU'),
        Locale('ja', 'JP'),
        Locale('de', 'DE')
      ],
      localizationsDelegates:  const [
        CountryLocalizations.delegate,
        DemoLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale!.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: colors.primary_app,
        ).copyWith(
          secondary: colors.darkIcon,
          brightness: Brightness.light,
        ),
        canvasColor: Theme.of(context).colorScheme.lightWhite,
        cardColor: Theme.of(context).colorScheme.white,
        dialogBackgroundColor: Theme.of(context).colorScheme.white,
        iconTheme:
        Theme.of(context).iconTheme.copyWith(color: colors.primary),
        primarySwatch: colors.primary_app,
        primaryColor: Theme.of(context).colorScheme.lightWhite,
        fontFamily: 'opensans',
        brightness: Brightness.light,
        textTheme: TextTheme(
          headline6: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.w600,
          ),
          subtitle1: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.bold,
          ),
        ).apply(
          bodyColor: Theme.of(context).colorScheme.fontColor,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Splash(),
        '/home': (context) => const Dashboard(),
        '/registerAnimals': (context) => const RegisterAnimals(),
        '/milkSales': (context) => const MilkSoldScreen(),
        '/selectCrops': (context) => const SelectedFavoriteCrops(),
        '/selectSelectedCrops': (context) => const CropScreen(),
      },
      darkTheme: ThemeData(
        canvasColor: colors.darkColor,
        cardColor: colors.darkColor2,
        dialogBackgroundColor: colors.darkColor2,
        primaryColor: colors.darkColor,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: colors.darkIcon,
          selectionColor: colors.darkIcon,
          selectionHandleColor: colors.darkIcon,
        ),
        fontFamily: 'ubuntu',
        brightness: Brightness.dark,
        hintColor: colors.white10,
        iconTheme:
        Theme.of(context).iconTheme.copyWith(color: colors.secondary),
        textTheme: TextTheme(
          headline6: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.w600,
          ),
          subtitle1: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.bold,
          ),
        ).apply(bodyColor: Theme.of(context).colorScheme.fontColor),
        colorScheme:
        ColorScheme.fromSwatch(primarySwatch: colors.primary_app)
            .copyWith(
            secondary: colors.darkIcon,
            brightness: Brightness.dark), checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) { return null; }
          if (states.contains(MaterialState.selected)) { return colors.primary; }
          return null;
        }),
      ), radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) { return null; }
          if (states.contains(MaterialState.selected)) { return colors.primary; }
          return null;
        }),
      ), switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) { return null; }
          if (states.contains(MaterialState.selected)) { return colors.primary; }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) { return null; }
          if (states.contains(MaterialState.selected)) { return colors.primary; }
          return null;
        }),
      ),
      ),
      themeMode: themeNotifier.getThemeMode(),
    ),
    );
    }

  }

}

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }


