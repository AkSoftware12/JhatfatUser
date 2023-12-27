import 'dart:async';
import 'dart:io';

// import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jhatfat/Auth/login_navigator.dart';
import 'package:jhatfat/HomeOrderAccount/home_order_account.dart';
import 'package:jhatfat/Locale/locales.dart';
import 'package:jhatfat/Routes/routes.dart';
import 'package:jhatfat/Themes/colors.dart';
import 'package:jhatfat/Themes/style.dart';
import 'package:location/location.dart' as loc;
import 'bean/cartitem.dart';
import 'databasehelper/dbhelper.dart';



class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([

    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);


  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? result = prefs.getBool('islogin');
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: kMainTextColor.withOpacity(0.5),
  ));
  await PushNotificationService().setupInteractedMessage();
  _requestPermission();

  runApp(
      Phoenix(child: (result != null && result) ? GoMarketHome() : GoMarket()));


  RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // App received a notification when it was killed
  }
}
_requestPermission() async {
  var status = await Permission.location.request();
  var status1 = await Permission.notification.request();
  if (status.isGranted) {
    print('done');
  } else if (status.isDenied) {
    _requestPermission();
  } else if (status.isPermanentlyDenied) {
  //  openAppSettings();
  }


  if (status1.isGranted) {
    print('done');
  } else if (status1.isDenied) {
    _requestPermission();
  } else if (status1.isPermanentlyDenied) {
   // openAppSettings();
  }
}
class GoMarket extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('hi'),
      ],
      theme: appTheme,
      home: LoginNavigator(),
      routes: PageRoutes().routes(),
    );
  }
}

class GoMarketHome extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('hi'),
      ],
      theme: appTheme,
      home: HomeStateless(),
      routes: PageRoutes().routes(),
    );
  }
}



class PushNotificationService {
  Future<void> setupInteractedMessage() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['type'] == 'chat') {
        // Navigator.pushNamed(context, '/chat',
        //     arguments: ChatArguments(message));
      }
    });
    await enableIOSNotifications();
    await registerNotificationListeners();
  }

  registerNotificationListeners() async {
    AndroidNotificationChannel channel = androidNotificationChannel();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    var androidSettings =
    new AndroidInitializationSettings('app_icon');

    var iOSSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    var initSetttings =
    InitializationSettings(android: androidSettings, iOS: iOSSettings);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onDidReceiveNotificationResponse: (message) async {
        });

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      print("message is: $message");
     /* FlutterRingtonePlayer.play(fromAsset: "assets/12.mp3",asAlarm: true);*/
      RemoteNotification? notification = message!.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              '123456', // id
              'High Importance Notifications',
              icon: android.smallIcon,
              priority: Priority.high,
              playSound: true,
            ),
          ),
        );

      }
    });
  }
}
enableIOSNotifications() async {
  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );
}
const sound =  "mixkit_melodic_gold_price_2000.wav";
androidNotificationChannel() => const AndroidNotificationChannel(
  '123456', // id
  'High Importance Notifications', // description
  importance: Importance.max,
  playSound: true,
    /*sound:  const UriAndroidNotificationSound("assets/12.mp3")*/
);

Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // You can perform any required processing here.
  // For example, show a notification, update local data, etc.
}

