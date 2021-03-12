import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/helper/authenticate.dart';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation.dart';
import 'package:chat_app/views/search.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream chatRoomStream;

  Widget chatRoomList(){
    return StreamBuilder(
      stream: chatRoomStream,
        builder: (context, snapshot){
          return snapshot.hasData ? ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index){
              return ChatRoomItem(
                // username
                  snapshot.data.docs[index].data()["chatroomID"].toString()
                          .replaceAll("${Constants.myName}" + "_", "")
                          .replaceAll("_" + "${Constants.myName}", ""),
                 // chat room id
                 snapshot.data.docs[index].data()["chatroomID"],
                 // latest message, it shows below friend's name on the list
                 snapshot.data.docs[index].data()["latestMessage"] != null
                     ? snapshot.data.docs[index].data()["latestMessage"] : ""
              );
            }
          ) : Container();
        }
    );
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async{
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    databaseMethods.getChatRooms(Constants.myName).then((value){
      setState(() {
        chatRoomStream = value;
      });
    });
    setState(() {

    });
  }

  // ignore: non_constant_identifier_names
  Future<void> warningLogOutDialog() async {
    return showDialog<void>(
      context: context,
      // user must tap button!
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Would you like to log out application?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Log Out'),
              onPressed: () {
                authMethods.signOut();
                // this will resolve issue: 'pushReplacement' works as 'push'
                // when navigator from a dialog
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => Authenticate()
                ));
                HelperFunctions.setUserLoggedInSharedPreference(false);
                Toast.show("Log out successfully", context,
                    backgroundColor: Colors.blue, duration: 3);
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Image.asset("assets/images/logo.png", height: 50,),
        actions: [
          GestureDetector(
            onTap: (){
              warningLogOutDialog();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.exit_to_app)
            ),
          )
        ],
      ),
      body: chatRoomList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => Search()
          ));
        },
      ),
    );
  }
}

class ChatRoomItem extends StatelessWidget {
  final String username;
  final String chatroomID;
  final String latestMessage;
  ChatRoomItem(this.username, this.chatroomID, this.latestMessage);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => Conversation(chatroomID)
        ));
        // it will use as the chat title
        Constants.friendName = username;
      },
      child: Container(
        color: Colors.white10,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: [
            // Use first character as an avatar
            Container(
              height: 50,
              width: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(40)
              ),
              child: Text(
                "${username.substring(0,1).toUpperCase()}",
                style: simpleTextStyle(),
              ),
            ),
            SizedBox(width: 8,),
            // Display friend's name and latest message below
            Padding(
              padding: const EdgeInsets.only(),
              child: new Container(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: new Text(username,
                          style: new TextStyle(
                              color: new Color.fromARGB(255, 117, 117, 117),
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold
                          )
                      ),
                    ),
                    new Text(latestMessage)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

