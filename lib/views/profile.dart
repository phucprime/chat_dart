import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toast/toast.dart';

class ProfilePage extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();

  DatabaseMethods _databaseMethods = new DatabaseMethods();
  QuerySnapshot _querySnapshot;

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController
    passwordTextEditingController = new TextEditingController();
  TextEditingController
    confirmPasswordTextEditingController = new TextEditingController();

  bool _isLoadingUpdatePassword = false;

  @override
  void initState() {
    _databaseMethods.getUserByUserName(Constants.myName).then((value){
      setState(() {
        _querySnapshot = value;
      });
    });
    super.initState();
  }

  Widget getUserInformation() {
    return _querySnapshot != null ?
    ListView.builder(
        itemCount: _querySnapshot.docs.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return userInformation(
            userName: _querySnapshot.docs[index].data()["name"],
            userEmail: _querySnapshot.docs[index].data()["email"],
          );
        }
    ) : Container();
  }

  Widget userInformation({ String userName, String userEmail }){
    return new Container(
      color: Color(0xffFFFFFF),
      child: Padding(
        padding: EdgeInsets.only(bottom: 5.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(
                    left: 25.0, right: 25.0, top: 25.0
                ),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Text(
                          'Your profile',
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _status ? _getEditIcon()
                            : _getCancelIcon(),
                      ],
                    )
                  ],
                )),
            Padding(
                padding: EdgeInsets.only(
                    left: 25.0, right: 25.0, top: 25.0
                ),
                child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Text(
                          'Username: ' + userName,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ],
                )
            ),
            Padding(
                padding: EdgeInsets.only(
                    left: 25.0, right: 25.0, top: 25.0
                ),
                child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Text(
                          'Email: ' + userEmail,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ],
                )
            ),
            Padding(
                padding: EdgeInsets.only(
                    left: 25.0, right: 25.0, top: 25.0
                ),
                child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: new Text(
                          'New Password',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      flex: 2,
                    ),
                    Expanded(
                      child: Container(
                        child: new Text(
                          'Confirm Password',
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      flex: 2,
                    ),
                  ],
                )),
            Padding(
                padding: EdgeInsets.only(
                    left: 25.0, right: 25.0, top: 2.0
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: new TextFormField(
                            obscureText: true,
                            controller: passwordTextEditingController,
                            decoration: const InputDecoration(
                                hintText: "Enter new password"
                            ),
                            enabled: !_status,
                          ),
                        ),
                        flex: 2,
                    ),
                    Flexible(
                      child: new TextFormField(
                        obscureText: true,
                        controller: confirmPasswordTextEditingController,
                        decoration: const InputDecoration(
                            hintText: "Confirm password"
                        ),
                        enabled: !_status,
                      ),
                      flex: 2,
                    ),
                  ],
                )),
            !_status ? _getActionButtons() : new Container(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoadingUpdatePassword
        ? Center(child: CircularProgressIndicator(),)
        : Scaffold(
        body: new Container(
          color: Colors.white,
          child: new ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  new Container(
                    height: 150.0,
                    color: Colors.white,
                    child: new Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: new Stack(
                              fit: StackFit.loose,
                              children: <Widget>[
                            new Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Container(
                                    width: 140.0,
                                    height: 140.0,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        image: new ExactAssetImage(
                                          "assets/images/default_profile.png"
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                ),
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 90.0, right: 100.0),
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new CircleAvatar(
                                      backgroundColor: Colors.blueGrey,
                                      radius: 25.0,
                                      child: new Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                )
                            ),
                            ]
                          ),
                        )
                      ],
                    ),
                  ),
                  getUserInformation()
                ],
              ),
            ],
          ),
        )
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                    child: new Text("Save"),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: () {
                      setState(() {
                        _isLoadingUpdatePassword = true;
                      });

                      _firebaseAuth.currentUser
                          .updatePassword(
                          passwordTextEditingController.text ==
                              confirmPasswordTextEditingController.text ?
                            passwordTextEditingController.text : null)
                          .then((_) {
                        Toast.show(
                            "Password updated successfully",
                            context,
                            gravity: Toast.TOP,
                            duration: 4,
                            backgroundColor: Colors.blue
                        );
                        setState(() {
                          _isLoadingUpdatePassword = false;
                          _status = true;
                          FocusScope.of(context).requestFocus(new FocusNode());
                          passwordTextEditingController.clear();
                          confirmPasswordTextEditingController.clear();
                        });
                      }).catchError((error){
                        Toast.show(
                            error.toString(),
                            context,
                            gravity: Toast.TOP,
                            duration: 4,
                            backgroundColor: Colors.red
                        );
                        setState(() {
                          _isLoadingUpdatePassword = false;
                        });
                      });
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0)
                    ),
                  )
              ),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                    child: new Text("Cancel"),
                    textColor: Colors.white,
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        _status = true;
                        FocusScope.of(context).requestFocus(new FocusNode());
                        passwordTextEditingController.clear();
                        confirmPasswordTextEditingController.clear();
                      });
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0)
                    ),
                  )
              ),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.blueGrey,
        radius: 14.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 18.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }

  Widget _getCancelIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.redAccent,
        radius: 14.0,
        child: new Icon(
          Icons.close,
          color: Colors.white,
          size: 18.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = true;
          passwordTextEditingController.clear();
          confirmPasswordTextEditingController.clear();
        });
      },
    );
  }

}

