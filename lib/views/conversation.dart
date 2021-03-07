import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';

class Conversation extends StatefulWidget {
  final String chatroomID;
  Conversation(this.chatroomID);

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {

  DatabeaseMethods databeaseMethods = new DatabeaseMethods();
  TextEditingController messageTextEditingController = new TextEditingController();
  Stream chatMessageStream;

  Widget ChatMessageList(){
    return StreamBuilder(
      stream: chatMessageStream,
        builder: (context, snapshot){
          return snapshot.hasData ? ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index){
              return MessageTitle(snapshot.data.docs[index].data()["message"],
                  snapshot.data.docs[index].data()["sendBy"] == Constants.myName);
            }
          ) : Container();
        },
    );
  }

  sendMessage(){
    if(messageTextEditingController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageTextEditingController.text,
        "sendBy": Constants.myName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      databeaseMethods.addMessage(widget.chatroomID, messageMap);
      messageTextEditingController.clear();
    }
  }

  @override
  void initState() {
    databeaseMethods.getConversationMessages(widget.chatroomID).then((value){
      setState(() {
        chatMessageStream = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Stack(
          children: [
            ChatMessageList(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Color(0x54FFFFFF),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          style: TextStyle(
                              color: Colors.white
                          ),
                          controller: messageTextEditingController,
                          decoration: InputDecoration(
                              hintText: "Message...",
                              hintStyle: TextStyle(
                                  color: Colors.white54
                              ),
                              border: InputBorder.none
                          ),
                        )
                    ),
                    GestureDetector(
                      onTap: (){
                        sendMessage();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          padding: EdgeInsets.all(11),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    const Color(0x45FFFFFF),
                                    const Color(0x0FFFFFFF)
                                  ]
                              ),
                              borderRadius: BorderRadius.circular(40)
                          ),
                          child: Image.asset("assets/images/send.png")
                      ),
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

class MessageTitle extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  MessageTitle(this.message, this.isSendByMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: isSendByMe ? 0 : 6, right: isSendByMe ? 6 : 0),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSendByMe ? [
              const Color(0xff007EF4),
              const Color(0xff2A75BC)
            ]
                : [
              const Color(0x1AFFFFFF),
              const Color(0x1AFFFFFF)
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
          color: Colors.white,
          fontSize: 17,
        ),),
      ),
    );
  }
}

