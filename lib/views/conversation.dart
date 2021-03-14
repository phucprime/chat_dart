import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:flutter/material.dart';

class Conversation extends StatefulWidget {
  final String chatroomID;
  Conversation(this.chatroomID);

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageTextEditingController =
    new TextEditingController();
  Stream chatMessageStream;

  // ignore: non_constant_identifier_names
  Widget MessageList(){
    return GestureDetector(
      onTap: (){
        // cancel keyboard if it's shown
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: StreamBuilder(
        stream: chatMessageStream,
          builder: (context, snapshot){
            return snapshot.hasData ? ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index){
                return MessageBubble(
                    snapshot.data.docs[index].data()["message"],
                    snapshot.data.docs[index]
                        .data()["sendBy"] == Constants.myName
                );
              }
            ) : Container();
          },
      ),
    );
  }

  sendMessage(){
    if(messageTextEditingController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageTextEditingController.text,
        "sendBy": Constants.myName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      String latestMsg = messageTextEditingController.text;
      databaseMethods.addMessage(widget.chatroomID, messageMap, latestMsg);
      messageTextEditingController.clear();
    }
  }

  @override
  void initState() {
    databaseMethods.getConversationMessages(widget.chatroomID).then((value){
      setState(() {
        chatMessageStream = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(Constants.friendName),
      ),
      body: Container(
        child: Stack(
          children: [
            MessageList(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                 //   borderRadius: BorderRadius.circular(50),
                  color: Color(0xFFECECEC),
                  borderRadius: BorderRadius.circular(40)
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 8),
                        child: Icon(Icons.collections, color: Colors.blue, size: 25,)
                    ),
                    Container(
                        child: Icon(Icons.camera_alt, color: Colors.blue, size: 30,)
                    ),
                    Container(
                        child: Icon(Icons.gif, color: Colors.blue, size: 40,)
                    ),
                    Expanded(
                        child: TextField(
                          style: TextStyle(
                              color: Colors.black
                          ),
                          controller: messageTextEditingController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (value){
                            sendMessage();
                          },
                          decoration: InputDecoration(
                              hintText: "Message...",
                              hintStyle: TextStyle(
                                  color: Color(0xFF6A6969)
                              ),
                              // remove underline border
                              border: InputBorder.none,
                          ),
                        ),
                    ),
                    GestureDetector(
                      onTap: (){
                        sendMessage();
                      },
                      child: Icon(Icons.send, color: Colors.blue,),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  MessageBubble(this.message, this.isSendByMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets
          .only(left: isSendByMe ? 0 : 6, right: isSendByMe ? 6 : 0),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSendByMe ? [
              const Color(0xFF2196F3),
              const Color(0xFF2196F3)
            ]
                : [
              const Color(0xFFECECEC),
              const Color(0xFFECECEC)
            ],
          ),
          borderRadius: isSendByMe ?
              BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomLeft: Radius.circular(23)
              )
              :
              BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomRight: Radius.circular(23)
              )
        ),
        child: Text(message, style: TextStyle(
          color: isSendByMe ? Colors.white : Colors.black,
          fontSize: 17,
        ),),
      ),
    );
  }
}

