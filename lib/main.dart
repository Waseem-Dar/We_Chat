
import 'dart:developer';

import 'package:chatapp/splashpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'firebase_options.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(elevation: 2,centerTitle: true,backgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 19,))
      ),
      home: const SplashPage(),
    );
  }
}
_initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  log('notificatiom result : $result');
}
