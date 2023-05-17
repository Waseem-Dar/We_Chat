import 'dart:developer';

import 'package:chatapp/Widgets/home_card.dart';
import 'package:chatapp/models/chatuser.dart';
import 'package:chatapp/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'helper/short.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    Apis.getSelfInfo();

    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Messages $message');
      if (Apis.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          Apis.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          Apis.updateActiveStatus(false);
        }
      }

      return Future.value(message);   
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: _isSearching
                ? TextFormField(
                    onChanged: (val) => {
                      _searchList.clear(),
                      for (var i in _list)
                        {
                          if (i.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email.toLowerCase().contains(val.toLowerCase()))
                            {
                              _searchList.add(i),
                            }
                        },
                      setState(() {
                        _searchList;
                      })
                    },
                    autofocus: true,
                    cursorHeight: 18,
                    cursorWidth: 1,
                    cursorColor: Colors.grey,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name,Email...',
                    ),
                  )
                : const Text("We Chat"),
            leading: const Icon(
              Icons.home,
              color: Colors.black,
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(
                    _isSearching ? Icons.clear_rounded : Icons.search,
                    color: Colors.black,
                  )),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(user: Apis.me),
                        ));
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.black,
                  )),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: FloatingActionButton(
              onPressed: ()  {
                _addUserDialog();
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
          body:StreamBuilder(
            stream: Apis.getMyUsersId(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
             return StreamBuilder(
                  stream: Apis.getAllUser(snapshot.data?.docs.map((e) =>e.id)
                      .toList() ??
                      []),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(child: CircularProgressIndicator());
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data
                            ?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount:
                              _isSearching ? _searchList.length : _list.length,
                              itemBuilder: (context, index) {
                                return HomeCard(
                                    user: _isSearching
                                        ? _searchList[index]
                                        : _list[index]);
                                // return Text("Name : ${list[index]}");
                              });
                        } else {
                          return const Center(
                              child: Text(
                                "No user found !",
                                style: TextStyle(fontSize: 20),
                              ));
                        }
                    }
                  });
            }
          },),
        ),
      ),
    );
  }
  void _addUserDialog(){
    String email = '';
    showDialog(context: context, builder: (_) => AlertDialog(
      contentPadding: const EdgeInsets.only(left: 24,right: 24,top: 20,bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children:const [
          Icon(Icons.person_add,color: Colors.blue,),
          Text("  Add User")
        ],
      ),
      content: TextFormField(

        maxLines: null,
        onChanged: (value)=> email = value,
        decoration: InputDecoration(
          hintText: 'Email',
          prefixIcon: const Icon(Icons.email,color: Colors.blue,),
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
          if(email.isNotEmpty) {
            Apis.addChatUser(email);
          }
        },
          child: const Text(" Add",style: TextStyle(color: Colors.blue,fontSize: 16)),
        ),
      ],
    ));
  }
}
