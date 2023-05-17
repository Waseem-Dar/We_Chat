import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Widgets/chat_message.dart';
import 'package:chatapp/helper/my_date.dart';
// import 'package:chatapp/helper/my_date.dart';
// import 'package:chatapp/main.dart';
import 'package:chatapp/models/chatuser.dart';
import 'package:chatapp/view_profile_page.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'helper/my_date.dart';

import 'helper/short.dart';
import 'models/user_messages.dart';

class ChatPage extends StatefulWidget {
  final ChatUser user;
  const ChatPage({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Message> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false, _isUploading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),
          backgroundColor: const Color.fromARGB(255, 234, 248, 255),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                    stream: Apis.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(child: SizedBox());
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                reverse: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _list.length,
                                itemBuilder: (context, index) {
                                  return ChatMessage(
                                    message: _list[index],
                                  );
                                });
                          } else {
                            return const Center(
                                child: Text(
                              "Say Hi 👏!",
                              style: TextStyle(fontSize: 20),
                            ));
                          }
                      }
                    }),
              ),
              if (_isUploading)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: CircularProgressIndicator(),
                  ),
                ),
              _bottomBar(),
              if (_showEmoji)
                SizedBox(
                  height: MediaQuery.of(context).size.height * .35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      columns: 8,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewProfilePage(user: widget.user),
            ));
      },
      child: SafeArea(
        child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: StreamBuilder(
              stream: Apis.getUserInfo(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                        [];
                return Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back)),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      child: CachedNetworkImage(
                        width: 40,
                        height: 40,
                        imageUrl:
                            list.isNotEmpty ? list[0].image : widget.user.image,
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                              child: Icon(Icons.person),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.isNotEmpty ? list[0].name : widget.user.name,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                                  ? "Online"
                                  : Mydate.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive)
                              : Mydate.getLastActiveTime(
                                  context: context,
                                  lastActive: widget.user.lastActive),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    )
                  ],
                );
              },
            )),
      ),
    );
  }

  Widget _bottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(children: [
        Expanded(
          child: Card(
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                    )),
                Expanded(
                    child: TextField(
                  controller: _textController,
                  onTap: () {
                    if (_showEmoji) {
                      setState(() => _showEmoji = !_showEmoji);
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: "Type Something...",
                    border: InputBorder.none,
                  ),
                )),
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);
                      for (var i in images) {
                        log('image path ${i.path}');
                        setState(() => _isUploading = true);
                        Apis.sendChatImage(widget.user, File(i.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.blueAccent,
                      size: 26,
                    )),
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        log('image path ${image.path}');
                        setState(() => _isUploading = true);
                        Apis.sendChatImage(widget.user, File(image.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.blueAccent,
                      size: 26,
                    )),
              ],
            ),
          ),
        ),
        MaterialButton(
          padding:
              const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 5),
          minWidth: 0,
          color: Colors.green,
          shape: const CircleBorder(),
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              if(_list.isEmpty){
                Apis.sendFirstMessage(widget.user, _textController.text, Type.text);
              }else{
                Apis.sendMessage(widget.user, _textController.text, Type.text);
              }

              _textController.text = "";
            }
          },
          child: const Icon(
            Icons.send,
            color: Colors.white,
            size: 33,
          ),
        )
      ]),
    );
  }
}
