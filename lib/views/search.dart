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

  Widget getSearchResults(){
    return querySnapshot != null
            ?
            ListView.builder(
              itemCount: querySnapshot.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return itemSearchResult(
                      userName: querySnapshot.docs[index].data()["name"],
                      userEmail: querySnapshot.docs[index].data()["email"],
                  );
                })
            :
            Container(child: Text("a"),);
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

  // create new chat room or enter into an existed chat room
  // ignore: non_constant_identifier_names
  createChatRoom({ String username }){
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
                        List<String> users = [Constants.myName, Constants.friendName]; // will create 2 'users' record, map 2 users together
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
  Widget itemSearchResult({ String userName, String userEmail }){
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
                )
              ),
              Text(userEmail,
                  style: TextStyle(
                    fontSize: 17,
              )),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: (){
              createChatRoom(
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
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Image.asset("assets/images/logo.png", height: 50,),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              color: Color(0xFFE8E8E8),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        controller: searchTextEditingController,
                        style: TextStyle(
                          color: Colors.black
                        ),
                        decoration: InputDecoration(
                          hintText: "Search username...",
                          hintStyle: TextStyle(
                            color: Colors.black54
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
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(40)
                        ),
                        child: Image.asset("assets/images/search_white.png")
                    ),
                  ),
                ],
              ),
            ),
            isLoading ? Container(child: LinearProgressIndicator(),) : getSearchResults()
          ],
        ),
      ),
    );
  }
}


