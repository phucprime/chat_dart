import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{
  getUserByUserName(String username) async{
   return await FirebaseFirestore.instance.collection("users")
       .where("name", isEqualTo: username)
       .get();
  }

  getUserByEmail(String email) async{
    return await FirebaseFirestore.instance.collection("users")
        .where("email", isEqualTo: email)
        .get();
  }

  uploadUserInformation(userMap){
    FirebaseFirestore.instance.collection("users")
        .add(userMap)
        .catchError((e){
      print(e.toString());
    });
  }

  createChatRoom(String chatroomID, chatRoomMap){
    FirebaseFirestore.instance.collection("chatRoom")
        .doc(chatroomID)
        .set(chatRoomMap)
        .catchError((e){
          print(e.toString());
    });
  }

  addMessage(String chatroomID, messageMap, newMessage){
    // when users send a message, set it as latest message to show on the list
    FirebaseFirestore.instance.collection("chatRoom")
        .doc(chatroomID)
        .update({"latestMessage": newMessage})
        .catchError((e){
      print(e.toString());
    });
    // add message to fire store
    FirebaseFirestore.instance.collection("chatRoom")
        .doc(chatroomID)
        .collection("chats")
        .add(messageMap).catchError((e){
          print(e.toString());
    });
  }

  getConversationMessages(String chatroomID) async {
    return await FirebaseFirestore.instance.collection("chatRoom")
        .doc(chatroomID)
        .collection("chats")
        .orderBy("time", descending: false)
        .snapshots();
  }

  getChatRooms(String username) async {
    return await FirebaseFirestore.instance.collection("chatRoom")
        .where("users", arrayContains: username)
        .snapshots();
  }

}