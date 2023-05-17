import 'package:chatapp/Widgets/profile_dailog.dart';
import 'package:chatapp/chat_page.dart';
import 'package:chatapp/helper/my_date.dart';
import 'package:chatapp/helper/short.dart';
import 'package:chatapp/models/chatuser.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/models/user_messages.dart';
import 'package:flutter/material.dart';

class HomeCard extends StatefulWidget {
  final ChatUser user;
  const HomeCard({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    user: widget.user,
                  ),
                ));
          },
          child: StreamBuilder(
            stream: Apis.getLastMessages(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

              return ListTile(
                leading: InkWell(
                  onTap: (){
                    showDialog(context: context, builder: (context) =>ProfileDialog(user: widget.user));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: CachedNetworkImage(
                      width: 44,
                      height: 44,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                    ),
                  ),
                ),
                title: Text(widget.user.name),
                subtitle: Text(
                  _message != null ?
                      _message!.type == Type.image?'Image':
                  _message!.msg : widget.user.about,
                  maxLines: 1,
                ),
                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty &&
                            _message!.fromId != Apis.user.uid
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: Colors.green.shade400,
                                borderRadius: BorderRadius.circular(5)),
                          )
                        : Text(Mydate.getLastMessageTime(context: context, time: _message!.sent)),
              );
            },
          )),
    );
  }
}
