import 'package:chat_app/modal/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserFromFirebase _userFromFirebase(User user){
    return user != null ? UserFromFirebase(userID: user.uid) : null;
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword
        (email: email, password: password); //UserCredential = AuthResult(old version)
      User user = result.user; //User = FirebaseUser
      return _userFromFirebase(user);
    }catch(e){
      print(e.toString());
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword
        (email: email, password: password);
      User user = result.user;
      return _userFromFirebase(user);
    }catch(e){
      print(e.toString());
    }
  }

  Future resetPassword(String email) async {
    try{
      return await _auth.sendPasswordResetEmail(email: email);
    }catch(e){
      print(e.toString());
    }
  }

  Future signOut() async {
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
    }
  }
}