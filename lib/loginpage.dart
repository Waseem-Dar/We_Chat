import 'dart:developer';
import 'dart:io';
import 'package:chatapp/helper/dailogs.dart';
import 'package:chatapp/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'helper/short.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _googlebtnclick() {
    Dialogs.showProgressBar(BuildContext, context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
     if(user != null){
       log('\nuser : ${user.user}');
       log('\nuserinfo : ${user.additionalUserInfo}');
       if(( await Apis.userExists())){
         Navigator.pushReplacement(
             context,
             MaterialPageRoute(
               builder: (context) => const HomePage(),
             ));
       }else{
         await Apis.createUser().then((value) {
           Navigator.pushReplacement(
               context,
               MaterialPageRoute(
                 builder: (context) => const HomePage(),
               ));
         });
       }

     }
     // else{}
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
   try{
     InternetAddress.lookup('google.com');
     // Trigger the authentication flow
     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

     // Obtain the auth details from the request
     final GoogleSignInAuthentication? googleAuth =
     await googleUser?.authentication;

     // Create a new credential
     final credential = GoogleAuthProvider.credential(
       accessToken: googleAuth?.accessToken,
       idToken: googleAuth?.idToken,
     );

     // Once signed in, return the UserCredential
     return await Apis.auth.signInWithCredential(credential);
   }catch(e){
     log('\n_signInWithGoogle :$e');
     Dialogs.showSnackBar(context, "Something wrong check internet !");
     return null;
   }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome To We Chat"),
      ),
      body: Stack(
        children: [
          Positioned(
              width: MediaQuery.of(context).size.width * .6,
              top: MediaQuery.of(context).size.width * .15,
              left: MediaQuery.of(context).size.width * .20,
              child: Image.asset("assets/images/Cicon.png")),
                                                                           // positioned widget
          Positioned(
              width: MediaQuery.of(context).size.width * .9,
              bottom: MediaQuery.of(context).size.width * .3,
              left: MediaQuery.of(context).size.width * .05,
              height: MediaQuery.of(context).size.width * .12,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: () {
                    _googlebtnclick();
                  },
                  child: const Text(
                    "Login with Google",
                    style: TextStyle(fontSize: 16),
                  ))),
        ],
      ),
    );
  }
}
