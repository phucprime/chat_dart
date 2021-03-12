import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chatRooms.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class SignIn extends StatefulWidget {

  final Function toggle;
  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  final formKey = GlobalKey<FormState>();

  TextEditingController emailTextEditingController =
    new TextEditingController();
  TextEditingController passwordTextEditingController =
    new TextEditingController();

  bool isLoading = false;
  QuerySnapshot snapshot;

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ChatRoom(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  signMeIn(){
    if(formKey.currentState.validate()){
      HelperFunctions
          .setUserEmailSharedPreference(emailTextEditingController.text);

      databaseMethods.getUserByEmail(emailTextEditingController.text)
          .then((value){
        snapshot = value;
        HelperFunctions.setUserNameSharedPreference(
            snapshot.docs[0].data()["name"]);
      });
      setState(() {
        isLoading = true;
      });
      // start sign user in
      authMethods.signInWithEmailAndPassword(emailTextEditingController.text,
          passwordTextEditingController.text).then((value){
            // log in successfully
            if(value != null){
              HelperFunctions.setUserLoggedInSharedPreference(true);
              Navigator.pushReplacement(context, _createRoute());
              Toast.show(
                "Login successfully",
                context,
                backgroundColor: Colors.blue,
                duration: 3,
                gravity: Toast.TOP
              );
            }
            // incorrect email / password
            else {
              setState(() {
                isLoading = false;
              });
              Toast.show(
                "There is no user corresponding to this identifier",
                context,
                duration: 4,
                backgroundColor: Colors.red,
                gravity: Toast.BOTTOM
              );
            }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading ? Container(
              child: Center( child: CircularProgressIndicator(),),
            ) : SingleChildScrollView(
        child: Container(
          child: Container(
            height: MediaQuery.of(context).size.height - 250,
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      validator: (val){
                        return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?"
                        r"^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(val) ? null
                            : "Please enter a correct email";
                      },
                      controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: textFieldInputDecoration("Email"),
                        style: simpleTextStyle()
                    ),
                    TextFormField(
                      obscureText: true,
                      validator: (val){
                        return val.length > 6 ? null
                            : "Password at least 6 characters";
                      },
                      controller: passwordTextEditingController,
                      decoration: textFieldInputDecoration("Password"),
                      style: simpleTextStyle(),
                    ),
                    SizedBox(height: 15,),
                    Container(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets
                              .symmetric(horizontal: 16, vertical: 8),
                          child: Text("Forgot password?",
                            style: simpleTextStyle(),
                          ),
                        )
                    ),
                    SizedBox(height: 15,),
                    GestureDetector(
                      onTap: (){
                        signMeIn();
                      },
                      child: Container(
                          child: Container(
                              alignment: Alignment.center,
                              // full horizontal
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                        const Color(0xff007EF4),
                                        const Color(0xff2A75BC)
                                      ]
                                  ),
                                  borderRadius: BorderRadius.circular(30)
                              ),
                              child: Text("Sign In", style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15
                              ),
                              )
                          )
                      ),
                    ),
                    SizedBox(height: 15,),
                    Container(
                        child: Container(
                            alignment: Alignment.center,
                            // full horizontal
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30)
                            ),
                            child: Text("Sign In with Google",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15
                              ),
                            )
                        )
                    ),
                    SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                          style: mediumTextStyle(),
                        ),
                        GestureDetector(
                          onTap: (){
                            widget.toggle();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text("Register now",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                decoration: TextDecoration.underline
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 50,)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
