import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/signin.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp(this.toggle);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  AuthMethods authMethods = new AuthMethods();
  DatabeaseMethods databeaseMethods = new DatabeaseMethods();

  final formKey = GlobalKey<FormState>();
  TextEditingController userNameTextEditingController = new TextEditingController();
  TextEditingController emailNameTextEditingController = new TextEditingController();
  TextEditingController passwordNameTextEditingController = new TextEditingController();

  bool isLoading = false;

  QuerySnapshot querySnapshot;

  signMeUp(){
    if(formKey.currentState.validate()){
      setState(() {
        isLoading = true;
      });

      FirebaseFirestore.instance.collection("users")
          .where("name",isEqualTo: userNameTextEditingController.text)
          .get()
          .then((value){
      // check if username existed on Cloud Fire Store
        if(value.size > 0) {
          setState(() {
            isLoading = false;
          });
          Toast.show("Your username is existed", context, backgroundColor: Colors.red, duration: 4);
        }
      // if username is not existed
        else {
          authMethods.signUpWithEmailAndPassword(
              emailNameTextEditingController.text,
              passwordNameTextEditingController.text)
              .then((value) {
      // check email format and existed or not
            if (value != null) {
              Map<String, String> userInforMap = {
                "name": userNameTextEditingController.text,
                "email": emailNameTextEditingController.text
              };
              HelperFunctions.setUserNameSharedPreference(
                  userNameTextEditingController.text);
              HelperFunctions.setUserEmailSharedPreference(
                  emailNameTextEditingController.text);
              // create data on Cloud Fire Store
              databeaseMethods.uploadUserInfor(userInforMap);
              // register success, direct to Login screen
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => SignIn(this.widget.toggle)
              ));
              Toast.show("Register successfully", context,
                  backgroundColor: Colors.blue, duration: 4);
            } else {
              setState(() {
                isLoading = false;
              });
              Toast.show("Your email is badly formatted or already in use", context,
                  backgroundColor: Colors.red, duration: 4);
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context), //An app bar to display at the top of the scaffold.
      body: isLoading ? Container(
        child: Center(child: CircularProgressIndicator()),
      ) : SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 300,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min, //Minimize the amount of free space along the main axis, subject to the incoming layout constraints.
                children: [
                  TextFormField(
                    validator: (val){
                      return val.isEmpty || val.length < 4 ?
                      "Please enter your username > 4 characters" : null;
                    },
                    controller: userNameTextEditingController,
                    decoration: textFieldInputDecoration("Username"),
                    style: simpleTextStyle()
                  ),
                  TextFormField(
                    validator: (val){
                      return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(val) ? null : "Enter correct email";
                    },
                    controller: emailNameTextEditingController,
                    decoration: textFieldInputDecoration("Email"),
                    style: simpleTextStyle()
                  ),
                  TextFormField(
                    obscureText: true,
                    validator: (val){
                      return val.length > 6 ? null : "At least 6 characters";
                    },
                    controller: passwordNameTextEditingController,
                    decoration: textFieldInputDecoration("Password"),
                    style: simpleTextStyle(),
                  ),
                  SizedBox(height: 15,),
                  GestureDetector(
                    onTap: (){
                      signMeUp();
                    },
                    child: Container(
                        child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width, // full horizontal
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
                            child: Text("Sign Up", style: TextStyle(
                                color: Colors.white,
                                fontSize: 15
                            ),
                            )
                        )
                    ),
                  ),
                  SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ", style: mediumTextStyle(),),
                      GestureDetector(
                        onTap: (){
                          widget.toggle();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text("Sign in now", style: TextStyle(
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
    );
  }
}
