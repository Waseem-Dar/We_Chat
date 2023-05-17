import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/models/chatuser.dart';
import 'package:chatapp/view_profile_page.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({Key? key, required this.user}) : super(key: key);
  final ChatUser user;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * .6,
        height: MediaQuery.of(context).size.height * .35,
        child: Stack(
          children: [
            Align(
              // top:  MediaQuery.of(context).size.height * .075,
              // left:  MediaQuery.of(context).size.width * .13,
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.height * .25),
                child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.width * .5,
                  height: MediaQuery.of(context).size.width * .5,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
              ),
            ),
            Positioned(
                left: 10,
                top: 10,
                width: MediaQuery.of(context).size.width * .55,
                child: Text(
                  user.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w400),
                )),
            Positioned(
              right: 5,
              child: MaterialButton(
                padding: const EdgeInsets.all(0),
                minWidth: 0,
                shape: const CircleBorder(),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfilePage(user: user),));
                },
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
