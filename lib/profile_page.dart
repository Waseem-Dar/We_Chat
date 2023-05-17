import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/loginpage.dart';
import 'package:chatapp/models/chatuser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chatapp/helper/dailogs.dart';
import 'package:image_picker/image_picker.dart';
import 'helper/short.dart';

class ProfilePage extends StatefulWidget {
  final ChatUser user;
  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text("Profile Screen"),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.redAccent,
              onPressed: () async {
                Dialogs.showProgressBar(BuildContext, context);
                await Apis.updateActiveStatus(false);
                await Apis.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Apis.auth = FirebaseAuth.instance;
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ));
                  });
                });
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.file(
                                File(_image!),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                            ))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: CachedNetworkImage(
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                // placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: -25,
                        child: MaterialButton(
                          shape: const CircleBorder(),
                          color: Colors.white,
                          onPressed: () {
                            _showbottom();
                          },
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(fontSize: 20, color: Colors.black87),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => Apis.me.name = val ?? "",
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required Field",
                    cursorHeight: 18,
                    cursorWidth: 1,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      label: const Text("Name"),
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1)),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => Apis.me.about = val ?? "",
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required Field",
                    cursorHeight: 18,
                    cursorWidth: 1,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.info_outlined,
                        color: Colors.blue,
                      ),
                      label: const Text("About"),
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: 150,
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          // log("inside validate");
                          Apis.updateUserInfo().then((value) {
                            Dialogs.showSnackBar(
                                context, "Profile Update Successfully!");
                          });
                        }
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(75.0),
                        )),
                      ),
                      icon: const Icon(
                        Icons.edit,
                        size: 20,
                      ),
                      label: const Text(
                        "UPDATE",
                        style: TextStyle(fontSize: 19),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
  void _showbottom() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        builder: (_) {
          return ListView(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .03,
                bottom: MediaQuery.of(context).size.height * .03),
            shrinkWrap: true,
            children: [
              const Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * .3,
                              MediaQuery.of(context).size.width * .3)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          log('image path ${image.path}');
                          setState(() {
                            _image = image.path;
                          });
                          Apis.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/images/gallery.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * .3,
                              MediaQuery.of(context).size.width * .3)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          log('image path ${image.path}');
                          setState(() {
                            _image = image.path;
                          });
                          Apis.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/images/camera.png'))
                ],
              )
            ],
          );
        });
  }
}
