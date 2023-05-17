import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/helper/my_date.dart';
import 'package:chatapp/models/chatuser.dart';
import 'package:flutter/material.dart';

class ViewProfilePage extends StatefulWidget {
  final ChatUser user;
  const ViewProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(widget.user.name),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Joined On : ', style:  TextStyle(fontSize: 18, color: Colors.black87),),
              Text(
                Mydate.getLastMessageTime(context: context, time: widget.user.createdAt, showYear: true),
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
          body: Padding(
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  widget.user.email,
                  style: const TextStyle(fontSize: 20, color: Colors.black87),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'About : ',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                    Text(
                      widget.user.about,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),

              ],
            ),
          )),
    );
  }
}
