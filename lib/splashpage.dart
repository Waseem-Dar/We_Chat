import 'dart:async';
import 'dart:developer';
import 'package:chatapp/homepage.dart';
import 'package:chatapp/loginpage.dart';
import 'package:flutter/material.dart';

import 'helper/short.dart';
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if(Apis.auth.currentUser != null){
        log('\nuser : ${Apis.auth}');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage(),));
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage(),));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Welcome To We Chat"),),
      body: Stack(
        children: [
          Positioned(
              width: MediaQuery.of(context).size.width * .6,
              top: MediaQuery.of(context).size.width * .3,
              left: MediaQuery.of(context).size.width * .20,
              child: Image.asset("assets/images/Cicon.png")),
          Positioned(
              width: MediaQuery.of(context).size.width ,
              bottom: MediaQuery.of(context).size.width * .3,
              // left: MediaQuery.of(context).size.width * .05,
              // height:  MediaQuery.of(context).size.width * .12,
              child:const Text("MADE IN PAKISTAN",textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20,letterSpacing: 4),)
          ),

        ],
      ),
    );
  }
}
