import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/helper/my_date.dart';
import 'package:chatapp/helper/short.dart';
import 'package:chatapp/models/user_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../helper/dailogs.dart';

class ChatMessage extends StatefulWidget {
  final Message message;
  const ChatMessage({Key? key, required this.message}) : super(key: key);

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  @override
  Widget build(BuildContext context) {
    bool isMe = Apis.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () {
          _showbottom(isMe);
        },
        child: isMe ? _greenMessage() : _blueMessage());
  }

  // another messages
  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      Apis.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? 5 : 9),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
                color: Colors.blue.shade100,
                border: Border.all(color: Colors.lightBlue)),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 19, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      // fit: BoxFit.cover,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(9),
          child: Text(Mydate.getFormatedTime(
              context: context, time: widget.message.sent)),
        ),
      ],
    );
  }

  // OUr message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),
            const SizedBox(
              width: 5,
            ),
            Text(Mydate.getFormatedTime(
                context: context, time: widget.message.sent)),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? 5 : 9),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(15)),
                color: Colors.green.shade100,
                border: Border.all(color: Colors.green)),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 19, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      // fit: BoxFit.cover,
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showbottom(bool isMe) {
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
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(2)),
              ),
              widget.message.type == Type.text
                  ? _OptionItem(
                      icon: const Icon(
                        Icons.copy_all_rounded,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: "Copy Text",
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);
                          Dialogs.showSnackBar(context, 'Text copied!');
                        });
                      })
                  : _OptionItem(
                      icon: const Icon(
                        Icons.download_rounded,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: "Save Image",
                      onTap: () async {
                        try{
                          log("Image URL : ${widget.message.msg}");
                          await GallerySaver.saveImage(widget.message.msg ,albumName: 'WeChat')
                              .then((success) {
                            Navigator.pop(context);
                            if (success != null && success) {
                              Dialogs.showSnackBar(
                                  context, 'Image Successfully Saved!');
                            }
                          });
                        }
                            catch(e){
                          log("Image saved error : $e");
                            }
                      }),
              if (isMe)
                const Divider(
                  color: Colors.black54,
                  indent: 20,
                  endIndent: 20,
                ),
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.black54,
                      size: 26,
                    ),
                    name: "Edit Message",
                    onTap: () {
                      Navigator.pop(context);
                      _showMessageDialog();

                    }),
              if (isMe)
                _OptionItem(
                    icon: const Icon(
                      Icons.delete_rounded,
                      color: Colors.red,
                      size: 26,
                    ),
                    name: "Delete Message",
                    onTap: () async {
                      await Apis.deleteMessages(widget.message).then((value) {
                        Navigator.pop(context);
                      });
                    }),
              const Divider(
                color: Colors.black54,
                indent: 20,
                endIndent: 20,
              ),
              _OptionItem(
                  icon: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.blue,
                  ),
                  name:
                      "Sent At : ${Mydate.getMessageTime(context: context, time: widget.message.sent)}",
                  onTap: () {}),
              _OptionItem(
                  icon: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.green,
                  ),
                  name: widget.message.read.isEmpty
                      ? 'Read At : Not seen yet'
                      : "Read At :  ${Mydate.getMessageTime(context: context, time: widget.message.read)}",
                  onTap: () {}),
            ],
          );
        });
  }
  void _showMessageDialog(){
    String updateMsg = widget.message.msg;
    showDialog(context: context, builder: (_) => AlertDialog(
      contentPadding: const EdgeInsets.only(left: 24,right: 24,top: 20,bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children:const [
          Icon(Icons.message,color: Colors.blue,),
          Text(" Update Message")
        ],
      ),
      content: TextFormField(
        initialValue: updateMsg,
        maxLines: null,
        onChanged: (value)=> updateMsg = value,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      actions: [
        MaterialButton(onPressed: (){
          Navigator.pop(context);
        },
          child: const Text("Cancel",style: TextStyle(color: Colors.blue,fontSize: 16)),
        ),
        MaterialButton(onPressed: (){
          Navigator.pop(context);
          Apis.updateMessages(widget.message, updateMsg);
          },
          child: const Text("Update",style: TextStyle(color: Colors.blue,fontSize: 16)),
        ),
      ],
    ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '   $name',
              style: const TextStyle(fontSize: 18),
            ))
          ],
        ),
      ),
    );
  }
}
