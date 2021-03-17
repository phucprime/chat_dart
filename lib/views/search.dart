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
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchTextEditingController =
      new TextEditingController();

  QuerySnapshot querySnapshot;

  bool isLoading = false;

  Widget getSearchResults() {
    return querySnapshot != null
        ? ListView.builder(
            itemCount: querySnapshot.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return itemSearchResult(
                userName: querySnapshot.docs[index].data()["name"],
                userEmail: querySnapshot.docs[index].data()["email"],
              );
            })
        : Container();
  }

  initSearch() {
    setState(() {
      isLoading = true;
    });
    databaseMethods
        .getUserByUserName(searchTextEditingController.text)
        .then((val) {
      setState(() {
        querySnapshot = val;
        isLoading = false;
      });
    });
  }

  // create new chat room or enter into an existed chat room
  // ignore: non_constant_identifier_names
  createChatRoom({String username}) {
    // if users message to another one
    if (username != Constants.myName) {
      setState(() {
        isLoading = true;
      });
      // it will use as the chat title
      Constants.friendName = username;
      String chatroomID = getChatRoomId(Constants.myName, username);
      // use it to check if chat room already existed
      String chatroomIDConverse = getChatRoomId(username, Constants.myName);
      // start get chat rooms from firebase
      FirebaseFirestore.instance
          .collection("chatRoom")
          .where("chatroomID", isEqualTo: chatroomID)
          .get()
          .then((value) {
        // existed, direct to the room username1_username2
        if (value.size > 0) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Conversation(chatroomID)));
          setState(() {
            isLoading = false;
          });
        } else {
          FirebaseFirestore.instance
              .collection("chatRoom")
              .where("chatroomID", isEqualTo: chatroomIDConverse)
              .get()
              .then((value) {
            // existed,
            // direct to the converse room id username2_username1
            if (value.size > 0) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Conversation(chatroomIDConverse)));
            }
            // not existed,
            // we will create a new chat room for these users
            else {
              List<String> users = [Constants.myName, Constants.friendName];
              Map<String, dynamic> chatRoomMap = {
                "users": users,
                "latestMessage": "",
                "chatroomID": chatroomID
              };
              databaseMethods.createChatRoom(chatroomID, chatRoomMap);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Conversation(chatroomID)));
            }
          });
          setState(() {
            isLoading = false;
          });
        }
      });
    }
    // if users message to themselves
    else {
      return Toast.show("Can not message to yourself", context,
          duration: 3, backgroundColor: Colors.redAccent, gravity: Toast.TOP);
    }
  } // createChatRoom

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
  Widget itemSearchResult({String userName, String userEmail}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName,
                  style: TextStyle(
                    fontSize: 17,
                  )),
              Text(userEmail,
                  style: TextStyle(
                    fontSize: 17,
                  )),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              createChatRoom(username: userName);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Message",
                style: simpleTextStyle(),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        // custom theme of the icon on the app bar
        iconTheme: IconThemeData(color: Colors.blue),
        title: Image.asset(
          "assets/images/logo.png",
          height: 50,
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              height: 40,
              decoration: BoxDecoration(
                  color: Color(0xFFEAEAEA),
                  borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      initSearch();
                    },
                    controller: searchTextEditingController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(bottom: 8),
                        hintText: "Search username...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none),
                  )),
                  GestureDetector(
                    onTap: () {
                      initSearch();
                    },
                    child: Icon(Icons.search_rounded),
                  ),
                ],
              ),
            ),
            isLoading
                ? Container(
                    child: CircularProgressIndicator(),
                  )
                : getSearchResults()
          ],
        ),
      ),
    );
  }
}
