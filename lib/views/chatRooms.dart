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
  DatabeaseMethods databeaseMethods = new DatabeaseMethods();
  Stream chatRoomStream;

  Widget chatRoomList(){
    return StreamBuilder(
      stream: chatRoomStream,
        builder: (context, snapshot){
          return snapshot.hasData ? ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index){
              return ChatRoomItem(
                snapshot.data.docs[index].data()["chatroomID"]
                    .toString()
                    .replaceAll("${Constants.myName}" + "_", "")
                    .replaceAll("_" + "${Constants.myName}", ""),
               snapshot.data.docs[index].data()["chatroomID"]
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
    databeaseMethods.getChatRooms(Constants.myName).then((value){
      setState(() {
        chatRoomStream = value;
      });
    });
    setState(() {

    });
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
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
                // this will solve issue: 'pushReplacement' works as 'push' when navigator from a dialog
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => Authenticate()
                ));
                HelperFunctions.setUserLoggedInSharedPreference(false);
                Toast.show("Log out successfully", context, backgroundColor: Colors.blue, duration: 3);
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
      appBar: AppBar(
        title: Image.asset("assets/images/logo.png", height: 50,),
        actions: [
          GestureDetector(
            onTap: (){
              _showDialog();
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
  ChatRoomItem(this.username, this.chatroomID);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => Conversation(chatroomID)
        ));
      },
      child: Container(
        color: Colors.black26,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: [
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
            Text(
              username,
              style: simpleTextStyle(),
            )
          ],
        ),
      ),
    );
  }
}

