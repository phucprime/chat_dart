import 'dart:ui';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  DatabaseMethods databeaseMethods = new DatabaseMethods();
  TextEditingController searchTextEditingController = new TextEditingController();

  QuerySnapshot querySnapshot;

  bool isLoading = false;

  Widget searchResults(){
    return querySnapshot != null
            ?
    ListView.builder(
      itemCount: querySnapshot.docs.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return SearchTitle(
              userName: querySnapshot.docs[index].data()["name"],
              userEmail: querySnapshot.docs[index].data()["email"],
          );
        })
            :
    Container();
  }

  initSearch(){
    setState(() {
      isLoading = true;
    });
    databeaseMethods.getUserByUserName(searchTextEditingController.text)
        .then((val){
      setState(() {
        querySnapshot = val;
        isLoading = false;
      });
    });
  }

  // ignore: non_constant_identifier_names
  createNew_Or_EnterExisted_ChatRoom({ String username }){
    if(username != Constants.myName){ // if users message to another one
      setState(() {
        isLoading = true;
      });
      Constants.friendName = username; // it will use as the chat title
      String chatroomID = getChatRoomId(Constants.myName, username);
      String chatroomIDConvert = getChatRoomId(username, Constants.myName); // use it to check if chat room already existed

      FirebaseFirestore.instance.collection("chatRoom")
          .where("chatroomID", isEqualTo: chatroomID)
          .get()
          .then((value) {
            if(value.size > 0){
              // existed, direct to this room
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => Conversation(chatroomID)
              ));

              setState(() {
                isLoading = false;
              });
            } else {
              FirebaseFirestore.instance.collection("chatRoom")
                  .where("chatroomID", isEqualTo: chatroomIDConvert)
                  .get()
                  .then((value) {
                      if(value.size > 0){
                        // existed, direct to this room
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => Conversation(chatroomIDConvert)
                        ));
                      }
                      else {
                        // not existed, we will create a new chat room for these users
                        List<String> users = [Constants.myName];
                        Map<String, dynamic> chatRoomMap = {
                          "users" : users,
                          "chatroomID" : chatroomID
                        };
                        DatabaseMethods().createChatRoom(chatroomID, chatRoomMap);
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => Conversation(chatroomID)
                        ));
                      }
              });
              setState(() {
                isLoading = false;
              });
          }
      });
    } else { // if users message to themselves
        return Toast.show("Can't message to yourself",
                          context,
                          duration: 3,
                          backgroundColor: Colors.redAccent,
                          gravity: Toast.TOP);
    }
  } // createChatRoomAndStartConversation

  // format username1_username2
  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  void initState() {
    initSearch();
    super.initState();
  }

  // ignore: non_constant_identifier_names
  Widget SearchTitle({ String userName, String userEmail }){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName, style: simpleTextStyle(),),
              Text(userEmail, style: simpleTextStyle(),),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: (){
              createNew_Or_EnterExisted_ChatRoom(
                username: userName
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text("Message", style: simpleTextStyle(),),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            Container(
              color: Color(0x54FFFFFF),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        controller: searchTextEditingController,
                        style: TextStyle(
                          color: Colors.white
                        ),
                        decoration: InputDecoration(
                          hintText: "Search username...",
                          hintStyle: TextStyle(
                            color: Colors.white54
                          ),
                          border: InputBorder.none
                        ),
                      )
                  ),
                  GestureDetector(
                    onTap: (){
                      initSearch();
                    },
                    child: Container(
                      height: 40,
                        width: 40,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0x36FFFFFF),
                              const Color(0x0FFFFFFF)
                            ]
                          ),
                          borderRadius: BorderRadius.circular(40)
                        ),
                        child: Image.asset("assets/images/search_white.png")
                    ),
                  ),
                ],
              ),
            ),
            isLoading ? Container(child: LinearProgressIndicator(),) : searchResults()
          ],
        ),
      ),
    );
  }
}


