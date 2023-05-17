import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chatapp/models/chatuser.dart';
import 'package:chatapp/models/user_messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class Apis {
  // FirebaseAuth short
  static FirebaseAuth auth = FirebaseAuth.instance;
  // firestore short
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static late ChatUser me;

  static User get user => auth.currentUser!;

  static Future<bool> userExists() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('pushtoken $t');
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "Chats",
        },
        "data": {
          "Some_data": "User ID : ${me.id}",
        },
      };
      var res = await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAA4faZf9o:APA91bGi-oA_Qfj-jmrr7dL1Zqx_L9v56cSEgp09X4rSHofdaFyfHqKRfeUJ9x5IZF82YIN-LqtweEwKsWG_8uYvdnEk4mQJ4QvMPcZLFdFzyBfwXbCGR9XHcbU2csFgttGjcxrWRg3Z'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendpushnotificationE $e');
    }
  }

  static Future<void> getSelfInfo() async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        Apis.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using We Chat! ",
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(
      List<String> userIds) {
    log('\n userIds : $userIds');
    return firestore
        .collection('users')
        .where('id', whereIn: userIds)
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> sendFirstMessage( ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users').doc(user.uid).set({}).then((value) =>sendMessage(chatUser, msg, type))
    ;
  }

  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    log('Extension : $ext');
    final ref = storage.ref().child('profile_picture ${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred :${p0.bytesTransferred / 1000} kb');
    });
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isonline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isonline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  // CHAT SCREEN APIS

  static getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // Chat user msg
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: "",
        type: type,
        fromId: user.uid,
        sent: time);
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // last Mesaages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // cemera image picke
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;

    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/ ${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred :${p0.bytesTransferred / 1000} kb');
    });
    final imageURL = await ref.getDownloadURL();
    await sendMessage(chatUser, imageURL, Type.image);
  }

  static Future<void> deleteMessages(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> updateMessages(Message message, String updateMsg) async {
    firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updateMsg});
  }
}
